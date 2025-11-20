# ...existing code...
sudo apt update
sudo apt upgrade -y
sudo apt full-upgrade -y

# Prompt for Kali tool categories to install (supports numbers, comma-separated, or 'all'/'a')
echo
echo "Select Kali tool categories to install (comma-separated, numbers, or 'all'):"
echo " 1) Identify   -> kali-tools-identify"
echo " 2) Protect    -> kali-tools-protect"
echo " 3) Detect     -> kali-tools-detect"
echo " 4) Respond    -> kali-tools-respond"
echo " 5) Recover    -> kali-tools-recover"
echo " Enter numbers (e.g. 1,3), 'all' or 'a' to install all. Leave empty to skip."
read -p "Selection: " selection

declare -A map=(
  [1]=kali-tools-identify
  [2]=kali-tools-protect
  [3]=kali-tools-detect
  [4]=kali-tools-respond
  [5]=kali-tools-recover
)

pkgs=()
if [[ -n "$selection" ]]; then
  selection="${selection,,}"   # lowercase
  # direct all options
  if [[ "$selection" == "all" || "$selection" == "a" ]]; then
    pkgs=(kali-tools-identify kali-tools-protect kali-tools-detect kali-tools-respond kali-tools-recover)
  else
    IFS=',' read -ra choices <<< "$selection"
    for c in "${choices[@]}"; do
      # trim whitespace
      c="${c//[[:space:]]/}"
      if [[ -z "$c" ]]; then
        continue
      fi
      if [[ "$c" == "all" || "$c" == "a" ]]; then
        pkgs=(kali-tools-identify kali-tools-protect kali-tools-detect kali-tools-respond kali-tools-recover)
        break
      fi
      if [[ -n "${map[$c]}" ]]; then
        pkgs+=("${map[$c]}")
      else
        echo "Warning: invalid choice '$c' ignored."
      fi
    done
  fi
else
  echo "No tools selected. Skipping Kali tool installation."
fi

# deduplicate packages and install if any
if [[ ${#pkgs[@]} -gt 0 ]]; then
  declare -A seen=()
  final_pkgs=()
  for p in "${pkgs[@]}"; do
    if [[ -z "${seen[$p]}" ]]; then
      final_pkgs+=("$p")
      seen[$p]=1
    fi
  done

  echo "Installing: ${final_pkgs[*]}"
  sudo apt update
  sudo apt install -y "${final_pkgs[@]}"
  echo "Selected Kali tool packages installed."
fi

# ...existing code...
sudo apt autoremove -y
sudo apt clean -y
sudo apt purge -y
echo "System update and cleanup complete!"
# ...existing code...
```// filepath: /Users/traver/Library/CloudStorage/GoogleDrive-traveryates@gmail.com/My Drive/Coding Documents/public-setupfiles/updates_scripts/kali-updates.sh
# ...existing code...
sudo apt update
sudo apt upgrade -y
sudo apt full-upgrade -y

# Prompt for Kali tool categories to install (supports numbers, comma-separated, or 'all'/'a')
echo
echo "Select Kali tool categories to install (comma-separated, numbers, or 'all'):"
echo " 1) Identify   -> kali-tools-identify"
echo " 2) Protect    -> kali-tools-protect"
echo " 3) Detect     -> kali-tools-detect"
echo " 4) Respond    -> kali-tools-respond"
echo " 5) Recover    -> kali-tools-recover"
echo " Enter numbers (e.g. 1,3), 'all' or 'a' to install all. Leave empty to skip."
read -p "Selection: " selection

declare -A map=(
  [1]=kali-tools-identify
  [2]=kali-tools-protect
  [3]=kali-tools-detect
  [4]=kali-tools-respond
  [5]=kali-tools-recover
)

pkgs=()
if [[ -n "$selection" ]]; then
  selection="${selection,,}"   # lowercase
  # direct all options
  if [[ "$selection" == "all" || "$selection" == "a" ]]; then
    pkgs=(kali-tools-identify kali-tools-protect kali-tools-detect kali-tools-respond kali-tools-recover)
  else
    IFS=',' read -ra choices <<< "$selection"
    for c in "${choices[@]}"; do
      # trim whitespace
      c="${c//[[:space:]]/}"
      if [[ -z "$c" ]]; then
        continue
      fi
      if [[ "$c" == "all" || "$c" == "a" ]]; then
        pkgs=(kali-tools-identify kali-tools-protect kali-tools-detect kali-tools-respond kali-tools-recover)
        break
      fi
      if [[ -n "${map[$c]}" ]]; then
        pkgs+=("${map[$c]}")
      else
        echo "Warning: invalid choice '$c' ignored."
      fi
    done
  fi
else
  echo "No tools selected. Skipping Kali tool installation."
fi

# deduplicate packages and install if any
if [[ ${#pkgs[@]} -gt 0 ]]; then
  declare -A seen=()
  final_pkgs=()
  for p in "${pkgs[@]}"; do
    if [[ -z "${seen[$p]}" ]]; then
      final_pkgs+=("$p")
      seen[$p]=1
    fi
  done

  echo "Installing: ${final_pkgs[*]}"
  sudo apt update
  sudo apt install -y "${final_pkgs[@]}"
  echo "Selected Kali tool packages installed."
fi

# ...existing code...
sudo apt autoremove -y
sudo apt clean -y
sudo apt purge -y
echo "System update and cleanup complete!"
# ...existing code...