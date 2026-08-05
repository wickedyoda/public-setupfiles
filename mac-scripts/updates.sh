#!/bin/zsh

echo "=== Updating macOS Software ==="
softwareupdate -i -a

echo "=== Updating Homebrew ==="
brew update && brew upgrade
if [ -n "$(brew list --cask 2>/dev/null)" ]; then
  echo "=== Updating Casks ==="
  brew upgrade --cask
fi
brew cleanup

echo "=== Updating npm (if available) ==="
if command -v npm >/dev/null 2>&1; then
  npm install -g npm@latest
else
  echo "npm not found, skipping."
fi

echo "=== Updating pip3 packages ==="
if command -v pip3 >/dev/null 2>&1; then
  # Upgrade pip itself first
  pip3 install --upgrade pip
  # Then list and upgrade all outdated packages
  pip3 list --outdated --format=freeze 2>/dev/null | grep -v '^#' | cut -d '=' -f 1 | while read pkg; do
    echo "Updating $pkg..."
    pip3 install --upgrade "$pkg"
  done
else
  echo "pip3 not found, skipping."
fi

echo "=== System Update Complete ==="