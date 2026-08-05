#!/bin/zsh

echo "=== Updating Homebrew ==="
brew update && brew upgrade
if command -v brew >/dev/null 2>&1; then
  if [ -n "$(brew list --cask 2>/dev/null)" ]; then
    echo "=== Updating Homebrew Casks ==="
    brew upgrade --cask
  fi
  echo "=== Cleaning up Homebrew ==="
  brew cleanup
fi

echo "=== Updating npm (if available) ==="
if command -v npm >/dev/null 2>&1; then
  npm install -g npm@latest
else
  echo "npm not found, skipping."
fi

echo "=== Updating pip (if available) ==="
if command -v pip3 >/dev/null 2>&1; then
  pip3 install --upgrade pip
else
  echo "pip3 not found, skipping."
fi

echo "=== Updating pip packages ==="
pip3 list --outdated --format=freeze 2>/dev/null | grep -v '^##' | cut -d '=' -f 1 | while read package; do
  echo "Updating $package..."
  pip3 install --upgrade "$package"
done

echo "=== Checking for macOS updates ==="
echo "If any macOS updates are available, you may need to install them via System Settings > General > Software Update."
softwareupdate -l 2>/dev/null

echo "=== Update complete! ==="