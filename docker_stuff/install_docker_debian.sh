#!/usr/bin/env bash

set -euo pipefail

# Docker installer for Debian 12 (bookworm) and Debian 13 (trixie).
# Installs Docker Engine, CLI, containerd, Buildx, and Docker Compose plugin.
# Optionally configures unattended upgrades for Docker packages.

SCRIPT_NAME="$(basename "$0")"
AUTO_UPDATES=true

log() {
	printf "[%s] %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$*"
}

die() {
	printf "Error: %s\n" "$*" >&2
	exit 1
}

usage() {
	cat <<EOF
Usage: sudo ./${SCRIPT_NAME} [options]

Options:
	--no-auto-updates   Do not configure unattended-upgrades for Docker packages
	--auto-updates      Configure unattended-upgrades for Docker packages (default)
	-h, --help          Show this help text

Examples:
	sudo ./${SCRIPT_NAME}
	sudo ./${SCRIPT_NAME} --no-auto-updates
EOF
}

parse_args() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
			--no-auto-updates)
				AUTO_UPDATES=false
				;;
			--auto-updates)
				AUTO_UPDATES=true
				;;
			-h|--help)
				usage
				exit 0
				;;
			*)
				die "Unknown option: $1"
				;;
		esac
		shift
	done
}

require_root() {
	if [[ "${EUID}" -ne 0 ]]; then
		die "Please run as root: sudo ./${SCRIPT_NAME}"
	fi
}

check_os() {
	[[ -r /etc/os-release ]] || die "Cannot read /etc/os-release"
	# shellcheck disable=SC1091
	source /etc/os-release

	[[ "${ID:-}" == "debian" ]] || die "This script supports Debian only. Detected: ${ID:-unknown}"

	case "${VERSION_CODENAME:-}" in
		bookworm|trixie)
			;;
		*)
			die "Unsupported Debian codename: ${VERSION_CODENAME:-unknown}. Supported: bookworm (12), trixie (13)."
			;;
	esac

	log "Detected Debian ${VERSION_ID:-unknown} (${VERSION_CODENAME})"
}

install_prereqs() {
	log "Installing prerequisite packages..."
	apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
		ca-certificates \
		curl \
		gnupg \
		lsb-release \
		apt-transport-https
}

setup_docker_repo() {
	local keyring_dir="/etc/apt/keyrings"
	local keyring_file="${keyring_dir}/docker.asc"
	local repo_file="/etc/apt/sources.list.d/docker.list"
	local arch
	arch="$(dpkg --print-architecture)"

	log "Configuring Docker APT repository..."
	install -m 0755 -d "${keyring_dir}"

	curl -fsSL https://download.docker.com/linux/debian/gpg -o "${keyring_file}"
	chmod a+r "${keyring_file}"

	cat > "${repo_file}" <<EOF
deb [arch=${arch} signed-by=${keyring_file}] https://download.docker.com/linux/debian ${VERSION_CODENAME} stable
EOF
}

install_docker() {
	log "Installing Docker Engine and plugins..."
	apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
		docker-ce \
		docker-ce-cli \
		containerd.io \
		docker-buildx-plugin \
		docker-compose-plugin
}

enable_services() {
	log "Enabling and starting Docker services..."
	systemctl enable --now docker
	systemctl enable --now containerd
}

configure_user_group() {
	local target_user="${SUDO_USER:-}"

	if ! getent group docker >/dev/null; then
		groupadd docker
	fi

	if [[ -n "${target_user}" && "${target_user}" != "root" ]]; then
		if id -nG "${target_user}" | tr ' ' '\n' | grep -qx docker; then
			log "User '${target_user}' is already in docker group."
		else
			log "Adding user '${target_user}' to docker group..."
			usermod -aG docker "${target_user}"
			log "User '${target_user}' must log out and back in for group changes to apply."
		fi
	else
		log "No non-root sudo user detected. Skipping docker group assignment."
	fi
}

configure_unattended_upgrades() {
	log "Configuring unattended-upgrades for Docker packages..."

	DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades

	local auto_file="/etc/apt/apt.conf.d/20auto-upgrades"
	local docker_upgrade_file="/etc/apt/apt.conf.d/52docker-unattended-upgrades"

	cat > "${auto_file}" <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

	cat > "${docker_upgrade_file}" <<'EOF'
Unattended-Upgrade::Origins-Pattern {
	"origin=Docker";
};

Unattended-Upgrade::Package-Blacklist {
};
EOF

	systemctl enable --now unattended-upgrades
}

print_versions() {
	log "Installed versions:"
	docker --version || true
	docker compose version || true
	containerd --version || true
}

main() {
	parse_args "$@"
	require_root
	check_os
	install_prereqs
	setup_docker_repo
	install_docker
	enable_services
	configure_user_group

	if [[ "${AUTO_UPDATES}" == "true" ]]; then
		configure_unattended_upgrades
	else
		log "Skipping unattended-upgrades configuration."
	fi

	print_versions

	log "Docker installation complete."
	log "Test with: docker run --rm hello-world"
}

main "$@"
