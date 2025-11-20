#!/bin/bash
set -euo pipefail

SUDO=""
if [[ $EUID -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo "
  else
    echo "This script must be run as root or have sudo installed."
    exit 1
  fi
fi

${SUDO}apt update
${SUDO}apt upgrade -y
${SUDO}apt full-upgrade -y

declare -A TOOL_MAP=(
  [1]=kali-tools-identify
  [2]=kali-tools-protect
  [3]=kali-tools-detect
  [4]=kali-tools-respond
  [5]=kali-tools-recover
)

add_packages() {
  local pkg
  for pkg in "$@"; do
    if [[ -z "${PACKAGE_SEEN[$pkg]:-}" ]]; then
      INSTALL_PKGS+=("$pkg")
      PACKAGE_SEEN[$pkg]=1
    fi
  done
}

INSTALL_PKGS=()
declare -A PACKAGE_SEEN=()

echo
echo "Select Kali tool categories to install (comma-separated numbers, or 'all'):"
echo " 1) Identify   -> kali-tools-identify"
echo " 2) Protect    -> kali-tools-protect"
echo " 3) Detect     -> kali-tools-detect"
echo " 4) Respond    -> kali-tools-respond"
echo " 5) Recover    -> kali-tools-recover"
echo " Enter numbers (e.g. 1,3), 'all' or 'a' to install all. Leave empty to skip."
read -r -p "Selection: " selection

selection="${selection,,}"
selection="${selection//[[:space:]]/}"

if [[ -z "$selection" ]]; then
  echo "No tools selected. Skipping Kali tool installation."
elif [[ "$selection" == "all" || "$selection" == "a" ]]; then
  add_packages "${TOOL_MAP[@]}"
else
  IFS=',' read -ra choices <<< "$selection"
  for c in "${choices[@]}"; do
    if [[ "$c" == "all" || "$c" == "a" ]]; then
      add_packages "${TOOL_MAP[@]}"
      break
    elif [[ -n "${TOOL_MAP[$c]:-}" ]]; then
      add_packages "${TOOL_MAP[$c]}"
    else
      echo "Warning: invalid choice '$c' ignored."
    fi
  done
fi

echo
echo "Kali Purple installation options:"
echo " 1) Kali Purple tools (identify/protect/detect/respond/recover)"
echo " 2) Kali Purple experience (kali-themes-purple, kali-menu, kali-wallpapers-legacy)"
echo " 3) All Kali Purple options"
echo " 4) Continue without Kali Purple installation"
read -r -p "Selection [4]: " purple_selection

purple_selection="${purple_selection,,}"
purple_selection="${purple_selection//[[:space:]]/}"

case "$purple_selection" in
  1)
    add_packages ${TOOL_MAP[@]}
    ;;
  2)
    add_packages kali-themes-purple kali-menu kali-wallpapers-legacy
    ;;
  3|all|a)
    add_packages ${TOOL_MAP[@]} kali-themes-purple kali-menu kali-wallpapers-legacy
    ;;
  ""|4|skip)
    echo "Skipping Kali Purple installation."
    ;;
  *)
    echo "Unrecognized choice. Skipping Kali Purple installation."
    ;;
  esac

if [[ ${#INSTALL_PKGS[@]} -gt 0 ]]; then
  echo "Installing selected packages: ${INSTALL_PKGS[*]}"
  ${SUDO}apt install -y "${INSTALL_PKGS[@]}"
  echo "Selected packages installed."
else
  echo "No optional Kali packages selected for installation."
fi

${SUDO}apt autoremove -y
${SUDO}apt clean -y
residual_configs=($(dpkg -l | awk '/^rc/{print $2}'))
if [[ ${#residual_configs[@]} -gt 0 ]]; then
  echo "Purging residual configuration packages: ${residual_configs[*]}"
  ${SUDO}apt purge -y "${residual_configs[@]}"
else
  echo "No residual configuration packages to purge."
fi

echo "System update and cleanup complete!"
