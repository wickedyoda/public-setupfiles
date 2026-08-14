-- tile-windows.applescript
-- A clickable macOS app that tells Hammerspoon to tile the two most-recent
-- windows side by side on the main screen.
--
-- REQUIREMENTS:
--   1. Hammerspoon must be installed and running (https://hammerspoon.org)
--   2. This file's companion hammerspoon-init.lua must be loaded in ~/.hammerspoon/init.lua
--   3. In Hammerspoon → Preferences → "Enable CLI (IPC Server)" must be checked
--      (this registers the `hs` command so this script can invoke it)
--
-- BUILD INSTRUCTIONS (creates a double-clickable .app):
--   Open Script Editor.app → File → Open... navigate to this file.
--   Or use osacompile from Terminal:
--     osacompile -o ~/Applications/Tile\ Windows.app tile-windows.applescript
--   Then double-click "Tile Windows.app" in Finder/Dock to run it.
--
-- NOTE: `do shell script` in AppleScript runs with a minimal PATH,
-- so we search known install locations for the `hs` binary.

property hsBinaryPaths : { ¬
	"/opt/homebrew/bin/hs", ¬
	"/usr/local/bin/hs", ¬
	"/opt/local/bin/hs", ¬
	"/opt/homebrew/Caskroom/hammerspoon/latest/Hammerspoon.app/Contents/Resources/hs" ¬
}

on findHsBinary()
	repeat with p in hsBinaryPaths
		try
			do shell script "test -x " & quoted form of p
			return p
		end try
	end repeat
	return ""
end findHsBinary

set hsPath to findHsBinary()

if hsPath is "" then
	display notification "Hammerspoon CLI (hs) not found. Install Hammerspoon and enable IPC Server in Preferences." with title "Tile Windows" subtitle "❌"
	return
end if

try
	do shell script quoted form of hsPath & " -c 'tileTwoWindows()'"
on error errMsg number errNum
	-- If the IPC call fails, it likely means Hammerspoon isn't running
	display notification "Could not reach Hammerspoon. Make sure Hammerspoon is running and IPC Server is enabled." with title "Tile Windows" subtitle "❌"
	return
end try

-- Brief visual confirmation
display notification "Windows tiled ✓" with title "Tile Windows"
