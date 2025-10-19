#!/bin/bash

set -u

# ---------- helpers ----------
cecho() { printf "%b%s%b\n" "\033[1;36m" "$1" "\033[0m"; }  # cyan bold
wecho() { printf "%b%s%b\n" "\033[1;33m" "$1" "\033[0m"; }  # yellow bold
eecho() { printf "%b%s%b\n" "\033[1;31m" "$1" "\033[0m"; }  # red bold
gecho() { printf "%b%s%b\n" "\033[1;32m" "$1" "\033[0m"; }  # green bold

# ---------- checks ----------
if ! command -v brew >/dev/null 2>&1; then
  eecho "Homebrew not found. Install from https://brew.sh and re-run."
  exit 1
fi

# ---------- gather installed casks ----------
cecho "Collecting installed casks..."
mapfile -t INSTALLED_CASKS < <(brew list --cask 2>/dev/null || true)

if [[ ${#INSTALLED_CASKS[@]} -eq 0 ]]; then
  wecho "No casks installed. Nothing to do."
  exit 0
fi

# ---------- detect deprecated/disabled ----------
cecho "Checking cask status (deprecated/disabled/discontinued)..."
DEPRECATED=()
for c in "${INSTALLED_CASKS[@]}"; do
  # Brew prints status text in `brew info --cask`
  INFO="$(brew info --cask "$c" 2>/dev/null || true)"
  if echo "$INFO" | grep -qiE 'deprecated|disabled|discontinued'; then
    DEPRECATED+=("$c")
  fi
done

if [[ ${#DEPRECATED[@]} -eq 0 ]]; then
  gecho "No deprecated or disabled casks detected. ✅"
  exit 0
fi

wecho "Deprecated/disabled casks detected:"
for c in "${DEPRECATED[@]}"; do echo "  - $c"; done
echo

# ---------- confirm removal ----------
read -r -p "Proceed to uninstall ALL of the above casks? [y/N] " ans
if [[ ! "$ans" =~ ^[Yy]$ ]]; then
  wecho "Aborting uninstall by user choice."
  exit 0
fi

# ---------- uninstall ----------
REMOVED=()
FAILED=()
for c in "${DEPRECATED[@]}"; do
  cecho "Uninstalling $c ..."
  if brew uninstall --cask "$c"; then
    REMOVED+=("$c")
  else
    FAILED+=("$c")
  fi
done

echo
gecho "Uninstall complete."
if [[ ${#REMOVED[@]} -gt 0 ]]; then
  gecho "Successfully removed:"
  for c in "${REMOVED[@]}"; do echo "  - $c"; done
fi
if [[ ${#FAILED[@]} -gt 0 ]]; then
  eecho "Failed to remove:"
  for c in "${FAILED[@]}"; do echo "  - $c"; done
fi
echo

# ---------- cleanup & autoremove ----------
cecho "Running cleanup..."
brew cleanup -s
brew autoremove || true
gecho "Cleanup done."
echo

# ---------- offer optional replacements ----------
# We’ll offer common replacements for known casks you had:
OFFER_GSTREAMER=false
OFFER_PWSH=false

for c in "${REMOVED[@]}"; do
  case "$c" in
    gstreamer-runtime|gstreamer-development)
      OFFER_GSTREAMER=true
      ;;
    powershell)
      OFFER_PWSH=true
      ;;
  esac
done

OPTIONS=()
[[ "$OFFER_GSTREAMER" == true ]] && OPTIONS+=("1) Install GStreamer via Homebrew (formula: gstreamer)")
[[ "$OFFER_GSTREAMER" == true ]] && OPTIONS+=("2) Open official GStreamer downloads page in browser")
[[ "$OFFER_PWSH" == true     ]] && OPTIONS+=("3) Install PowerShell via Homebrew cask (stable)")
[[ "$OFFER_PWSH" == true     ]] && OPTIONS+=("4) Open official PowerShell releases in browser")

if [[ ${#OPTIONS[@]} -gt 0 ]]; then
  cecho "Optional replacements (enter numbers separated by spaces, or press Enter to skip):"
  for opt in "${OPTIONS[@]}"; do echo "  $opt"; done
  read -r -p "Choice(s): " choices
  echo

  for choice in $choices; do
    case "$choice" in
      1)
        cecho "Installing GStreamer (formula)..."
        brew install gstreamer || eecho "Failed to install gstreamer."
        ;;
      2)
        cecho "Opening GStreamer downloads page..."
        # Official downloads
        open "https://gstreamer.freedesktop.org/download/"
        ;;
      3)
        cecho "Installing PowerShell (cask)..."
        # Homebrew core cask usually handles latest stable
        brew install --cask powershell || eecho "Failed to install PowerShell."
        ;;
      4)
        cecho "Opening PowerShell releases page..."
        open "https://github.com/PowerShell/PowerShell/releases"
        ;;
      *)
        wecho "Unknown option: $choice (skipped)"
        ;;
    esac
  done
else
  wecho "No known replacements to offer for removed casks."
fi

gecho "All set. 👍"