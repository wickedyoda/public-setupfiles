-- tile-windows.applescript
-- A clickable macOS app that tells Hammerspoon to tile the two most-recent
-- windows side by side on the main screen.
--
-- REQUIREMENTS:
--   1. Hammerspoon must be installed and running (https://hammerspoon.org)
--   2. This file's companion init.lua must be loaded in ~/.hammerspoon/init.lua
--   3. In Hammerspoon → Preferences → "Enable CLI (IPC Server)" must be checked
--      (this registers the `hs` command on your PATH)
--
-- BUILD INSTRUCTIONS (creates a double-clickable .app):
--   Open Script Editor.app → File → Open... navigate to this file.
--   Or use osacompile from Terminal:
--     osacompile -o ~/Applications/Tile\ Windows.app tile-windows.applescript
--   Then double-click "Tile Windows.app" in Finder/Dock to run it.

try
  set resultText to do shell script "/opt/homebrew/bin/hs -c 'tileTwoWindows()'"
on error errMsg number errNum
  -- If the IPC call fails, fall back to a friendly notification
  display notification "Could not reach Hammerspoon IPC. Make sure Hammerspoon is running and IPC Server is enabled." with title "Tile Windows" subtitle "❌"
  return
end try

-- Optional: brief visual confirmation
display notification "Windows tiled ✓" with title "Tile Windows"
