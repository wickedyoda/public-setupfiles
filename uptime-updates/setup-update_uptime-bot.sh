#!/usr/bin/env bash
set -euo pipefail

# Installs or updates the uptime bot service and runtime files.
# Intended usage:
#   sudo ./setup-update_uptime-bot.sh

APP_NAME="uptime-updates-bot"
SERVICE_NAME="${APP_NAME}.service"
INSTALL_DIR="/opt/uptime-updates"
RUN_AS_USER="root"
RUN_AS_GROUP="root"
ENABLE_ON_BOOT="true"
START_AFTER_INSTALL="true"
DRY_RUN="false"
MIN_PYTHON_VERSION="3.9"
VENV_DIR=""
OVERWRITE_CONFIG="false"
OVERWRITE_MAP="false"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_DIR="/etc/systemd/system"

RUNNER_FILE=""
RUNNER_EXEC=""

log() {
	echo "[INFO] $*"
}

warn() {
	echo "[WARN] $*" >&2
}

err() {
	echo "[ERROR] $*" >&2
}

usage() {
	cat <<EOF
Usage:
	sudo bash setup-update_uptime-bot.sh [options]

Options:
	--install-dir PATH     Install directory (default: /opt/uptime-updates)
	--service-name NAME    systemd unit name (default: uptime-updates-bot.service)
	--user USER            User to run service as (default: root)
	--group GROUP          Group to run service as (default: root)
	--no-enable            Do not enable service on boot
	--no-start             Do not start/restart service after install
	--min-python-version V Minimum Python version if using uptime-bot.py (default: 3.9)
	--overwrite-config     Replace existing installed config.yml with repo copy
	--overwrite-map        Replace existing installed container-monitor-map.yaml with repo copy
	--overwrite-all        Replace both installed config/map files with repo copies
	--dry-run              Print actions without changing the system
	-h, --help             Show this help

Notes:
	- This script is idempotent: re-run it after making changes to bot files.
	- Source files are read from the same directory as this script.
EOF
}

run_cmd() {
	if [[ "${DRY_RUN}" == "true" ]]; then
		echo "[DRY-RUN] $*"
	else
		eval "$@"
	fi
}

require_root() {
	if [[ "${EUID}" -ne 0 ]]; then
		err "Please run as root or with sudo."
		exit 1
	fi
}

version_ge() {
	local actual="$1"
	local required="$2"
	[[ "$(printf '%s\n%s\n' "${required}" "${actual}" | sort -V | head -n1)" == "${required}" ]]
}

detect_package_manager() {
	if command -v apt-get >/dev/null 2>&1; then
		echo "apt-get"
	elif command -v dnf >/dev/null 2>&1; then
		echo "dnf"
	elif command -v yum >/dev/null 2>&1; then
		echo "yum"
	elif command -v zypper >/dev/null 2>&1; then
		echo "zypper"
	elif command -v pacman >/dev/null 2>&1; then
		echo "pacman"
	elif command -v apk >/dev/null 2>&1; then
		echo "apk"
	else
		echo ""
	fi
}

install_python3() {
	local pm
	pm="$(detect_package_manager)"

	if [[ -z "${pm}" ]]; then
		err "No supported package manager found to install Python automatically."
		err "Install Python ${MIN_PYTHON_VERSION}+ manually, then re-run this script."
		exit 1
	fi

	log "Attempting to install Python 3 using ${pm}"
	case "${pm}" in
		apt-get)
			run_cmd "apt-get update"
			run_cmd "apt-get install -y python3 python3-venv python3-pip"
			;;
		dnf)
			run_cmd "dnf install -y python3 python3-pip"
			;;
		yum)
			run_cmd "yum install -y python3 python3-pip"
			;;
		zypper)
			run_cmd "zypper --non-interactive install python3 python3-pip"
			;;
		pacman)
			run_cmd "pacman -Sy --noconfirm python python-pip"
			;;
		apk)
			run_cmd "apk add --no-cache python3 py3-pip"
			;;
		*)
			err "Unsupported package manager: ${pm}"
			exit 1
			;;
	esac
}

setup_python_environment() {
	local venv_python
	local requirements_path

	VENV_DIR="${INSTALL_DIR}/.venv"
	venv_python="${VENV_DIR}/bin/python"
	requirements_path="${INSTALL_DIR}/requirements.txt"

	log "Creating/updating Python virtual environment at ${VENV_DIR}"
	run_cmd "python3 -m venv \"${VENV_DIR}\""

	log "Installing Python dependencies for uptime bot"
	run_cmd "\"${venv_python}\" -m pip install --upgrade pip"
	if [[ -f "${requirements_path}" ]]; then
		run_cmd "\"${venv_python}\" -m pip install -r \"${requirements_path}\""
	else
		warn "requirements.txt not found in install dir. Falling back to default dependencies."
		run_cmd "\"${venv_python}\" -m pip install uptime-kuma-api PyYAML"
	fi
}

ensure_python3_compatible() {
	local py_ver

	if ! command -v python3 >/dev/null 2>&1; then
		warn "python3 not found; attempting automatic install."
		install_python3
	fi

	if ! command -v python3 >/dev/null 2>&1; then
		err "python3 is still unavailable after install attempt."
		exit 1
	fi

	if [[ "${DRY_RUN}" == "true" ]]; then
		log "Dry-run: skipping python version verification command."
		return
	fi

	py_ver="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
	if version_ge "${py_ver}" "${MIN_PYTHON_VERSION}"; then
		log "Detected python3 ${py_ver} (required: ${MIN_PYTHON_VERSION}+)"
		return
	fi

	warn "Detected python3 ${py_ver}, but ${MIN_PYTHON_VERSION}+ is required. Trying to upgrade python3."
	install_python3
	py_ver="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"

	if ! version_ge "${py_ver}" "${MIN_PYTHON_VERSION}"; then
		err "python3 ${py_ver} is still below required ${MIN_PYTHON_VERSION}+ after install/upgrade attempt."
		err "Please install a newer Python manually, then re-run this script."
		exit 1
	fi

	log "Python upgraded to compatible version: ${py_ver}"
}

parse_args() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
			--install-dir)
				shift
				[[ $# -gt 0 ]] || { err "Missing value for --install-dir"; exit 1; }
				INSTALL_DIR="$1"
				;;
			--service-name)
				shift
				[[ $# -gt 0 ]] || { err "Missing value for --service-name"; exit 1; }
				SERVICE_NAME="$1"
				;;
			--user)
				shift
				[[ $# -gt 0 ]] || { err "Missing value for --user"; exit 1; }
				RUN_AS_USER="$1"
				;;
			--group)
				shift
				[[ $# -gt 0 ]] || { err "Missing value for --group"; exit 1; }
				RUN_AS_GROUP="$1"
				;;
			--no-enable)
				ENABLE_ON_BOOT="false"
				;;
			--no-start)
				START_AFTER_INSTALL="false"
				;;
			--min-python-version)
				shift
				[[ $# -gt 0 ]] || { err "Missing value for --min-python-version"; exit 1; }
				MIN_PYTHON_VERSION="$1"
				;;
			--overwrite-config)
				OVERWRITE_CONFIG="true"
				;;
			--overwrite-map)
				OVERWRITE_MAP="true"
				;;
			--overwrite-all)
				OVERWRITE_CONFIG="true"
				OVERWRITE_MAP="true"
				;;
			--dry-run)
				DRY_RUN="true"
				;;
			-h|--help)
				usage
				exit 0
				;;
			*)
				err "Unknown argument: $1"
				usage
				exit 1
				;;
		esac
		shift
	done
}

check_prereqs() {
	command -v systemctl >/dev/null 2>&1 || { err "systemctl is required."; exit 1; }
	command -v install >/dev/null 2>&1 || { err "install is required."; exit 1; }

	if [[ -f "${SCRIPT_DIR}/uptime-bot.py" ]]; then
		ensure_python3_compatible
		RUNNER_FILE="uptime-bot.py"
		VENV_DIR="${INSTALL_DIR}/.venv"
		RUNNER_EXEC="${VENV_DIR}/bin/python ${INSTALL_DIR}/uptime-bot.py"
	elif [[ -f "${SCRIPT_DIR}/uptime-bot.sh" ]]; then
		RUNNER_FILE="uptime-bot.sh"
		RUNNER_EXEC="/usr/bin/env bash ${INSTALL_DIR}/uptime-bot.sh"
	else
		err "No runner found. Create uptime-bot.py or uptime-bot.sh in ${SCRIPT_DIR}."
		exit 1
	fi

	[[ -f "${SCRIPT_DIR}/config.yml" ]] || { err "Missing ${SCRIPT_DIR}/config.yml"; exit 1; }
	[[ -f "${SCRIPT_DIR}/container-monitor-map.yaml" ]] || { err "Missing ${SCRIPT_DIR}/container-monitor-map.yaml"; exit 1; }
}

install_files() {
	local src_config
	local dst_config
	local src_map
	local dst_map

	src_config="${SCRIPT_DIR}/config.yml"
	dst_config="${INSTALL_DIR}/config.yml"
	src_map="${SCRIPT_DIR}/container-monitor-map.yaml"
	dst_map="${INSTALL_DIR}/container-monitor-map.yaml"

	log "Installing files into ${INSTALL_DIR}"
	run_cmd "mkdir -p \"${INSTALL_DIR}\""

	if [[ -f "${dst_config}" && "${OVERWRITE_CONFIG}" != "true" ]]; then
		warn "Keeping existing installed config.yml (use --overwrite-config to replace)."
	else
		if [[ -f "${dst_config}" && "${OVERWRITE_CONFIG}" == "true" ]]; then
			run_cmd "cp -a \"${dst_config}\" \"${dst_config}.bak.${TIMESTAMP}\""
			log "Backed up existing config.yml to ${dst_config}.bak.${TIMESTAMP}"
		fi
		run_cmd "install -m 0644 \"${src_config}\" \"${dst_config}\""
	fi

	if [[ -f "${dst_map}" && "${OVERWRITE_MAP}" != "true" ]]; then
		warn "Keeping existing installed container-monitor-map.yaml (use --overwrite-map to replace)."
	else
		if [[ -f "${dst_map}" && "${OVERWRITE_MAP}" == "true" ]]; then
			run_cmd "cp -a \"${dst_map}\" \"${dst_map}.bak.${TIMESTAMP}\""
			log "Backed up existing container-monitor-map.yaml to ${dst_map}.bak.${TIMESTAMP}"
		fi
		run_cmd "install -m 0644 \"${src_map}\" \"${dst_map}\""
	fi

	if [[ -f "${SCRIPT_DIR}/requirements.txt" ]]; then
		run_cmd "install -m 0644 \"${SCRIPT_DIR}/requirements.txt\" \"${INSTALL_DIR}/requirements.txt\""
	fi
	run_cmd "install -m 0755 \"${SCRIPT_DIR}/${RUNNER_FILE}\" \"${INSTALL_DIR}/${RUNNER_FILE}\""
	run_cmd "install -m 0755 \"${SCRIPT_DIR}/setup-update_uptime-bot.sh\" \"${INSTALL_DIR}/setup-update_uptime-bot.sh\""

	run_cmd "chown -R ${RUN_AS_USER}:${RUN_AS_GROUP} \"${INSTALL_DIR}\""
}

write_service() {
	local service_path="${SYSTEMD_DIR}/${SERVICE_NAME}"

	log "Writing service unit ${service_path}"
	if [[ "${DRY_RUN}" == "true" ]]; then
		cat <<EOF
[DRY-RUN] Would write:
[Unit]
Description=Uptime Updates Bot (container ID sync)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${RUN_AS_USER}
Group=${RUN_AS_GROUP}
WorkingDirectory=${INSTALL_DIR}
ExecStart=${RUNNER_EXEC}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
		return
	fi

	cat > "${service_path}" <<EOF
[Unit]
Description=Uptime Updates Bot (container ID sync)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${RUN_AS_USER}
Group=${RUN_AS_GROUP}
WorkingDirectory=${INSTALL_DIR}
ExecStart=${RUNNER_EXEC}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
}

reload_and_apply_service() {
	log "Reloading systemd"
	run_cmd "systemctl daemon-reload"

	if [[ "${ENABLE_ON_BOOT}" == "true" ]]; then
		log "Enabling ${SERVICE_NAME}"
		run_cmd "systemctl enable ${SERVICE_NAME}"
	else
		warn "Skipping enable step (--no-enable used)."
	fi

	if [[ "${START_AFTER_INSTALL}" == "true" ]]; then
		if [[ "${DRY_RUN}" == "true" ]]; then
			echo "[DRY-RUN] systemctl restart ${SERVICE_NAME}"
		else
			if systemctl list-unit-files | grep -q "^${SERVICE_NAME}"; then
				log "Restarting ${SERVICE_NAME}"
				systemctl restart "${SERVICE_NAME}"
			else
				log "Starting ${SERVICE_NAME}"
				systemctl start "${SERVICE_NAME}"
			fi
		fi
	else
		warn "Skipping start/restart step (--no-start used)."
	fi
}

print_summary() {
	echo
	echo "Install/update complete."
	echo "Service: ${SERVICE_NAME}"
	echo "Install dir: ${INSTALL_DIR}"
	echo "Runner: ${RUNNER_FILE}"
	echo
	echo "Useful commands:"
	echo "  systemctl status ${SERVICE_NAME}"
	echo "  journalctl -u ${SERVICE_NAME} -f"
}

main() {
	parse_args "$@"
	require_root
	check_prereqs
	install_files
	if [[ "${RUNNER_FILE}" == "uptime-bot.py" ]]; then
		setup_python_environment
	fi
	write_service
	reload_and_apply_service
	print_summary
}

main "$@"
