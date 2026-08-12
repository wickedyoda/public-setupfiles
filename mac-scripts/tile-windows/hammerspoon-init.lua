--[[
  Hammerspoon config: Tile two most-recent windows side by side
  on the main screen, activated by click or hotkey.

  Install:
    1. Install Hammerspoon: https://www.hammerspoon.org
    2. Copy this file to ~/.hammerspoon/init.lua  (or merge)
    3. In Hammerspoon → Open Config Folder → Reload All
    4. Grant Accessibility permission to Hammerspoon in System Settings.
    5. (Optional) Assign hotkey: Cmd+Ctrl+T toggles tiling.
    6. Build the clickable .app from tile-windows.applescript (see companion file).
--]]

-- Config ---------------------------------------------------------------
local HOTKEY = { "cmd", "ctrl" }
local HOTKEY_KEY = "t"

-- Window focus-order tracking -------------------------------------------
-- We keep a ring of recently-focused normal windows. When tiling, we grab
-- the two most recent distinct windows and place them side by side.
local focusOrder = {}
local MAX_HISTORY = 10

local function recordFocus(win)
  if not win or not win:id() then return end
  -- Remove any existing entry for this window, then push to front.
  local filtered = {}
  for _, w in ipairs(focusOrder) do
    if w:id() ~= win:id() then
      table.insert(filtered, w)
    end
  end
  table.insert(filtered, win)
  -- Trim oldest
  if #filtered > MAX_HISTORY then
    table.remove(filtered, 1)
  end
  focusOrder = filtered
end

-- Track all app windows
local trackFilter = hs.windowFilter.new(nil, "TrackAll")
trackFilter:setWindowFilter("AXStandardWindow", true)
trackFilter:subscribe(hs.windowFilter.windowFocused, function(win)
  recordFocus(win)
end)

-- Core tiling function --------------------------------------------------
local function tileTwoWindows()
  -- Collect all currently-visible normal windows (skip minimized/invisible)
  local allWins = hs.window.allWindows()
  local visible = {}
  for _, w in ipairs(allWins) do
    local fr = w:frame()
    if fr.w > 0 and fr.h > 0 then
      table.insert(visible, w)
    end
  end

  if #visible < 2 then
    hs.alert.show("Need 2+ visible windows")
    return
  end

  -- Prefer the two most-recently-focused visible windows.
  local function focusIndex(win)
    for i, w in ipairs(focusOrder) do
      if w:id() == win:id() then return i end
    end
    return 9999
  end
  table.sort(visible, function(a, b)
    return focusIndex(a) < focusIndex(b)
  end)

  local winA = visible[1]
  local winB = visible[2]

  if not winA or not winB then
    hs.alert.show("No windows to tile")
    return
  end

  -- Determine the screen for winA (its current screen, or main screen)
  local screen = winA:screen()
  if not screen then
    screen = hs.screen.mainScreen()
  end
  local screenFrame = screen:frame()

  -- Compute two halves with a small gap
  local gap = 6
  local halfW = (screenFrame.w - gap) / 2
  local halfH = screenFrame.h

  local frameA = hs.geometry.rect(screenFrame.x, screenFrame.y, halfW, halfH)
  local frameB = hs.geometry.rect(screenFrame.x + halfW + gap, screenFrame.y, halfW, halfH)

  winA:setFrame(frameA)
  winB:setFrame(frameB)

  -- Focus the first window
  winA:focus()

  hs.alert.show("Tiled \xe2\x9c\x93")
end

-- Hotkey binding
hs.hotkey.bind(HOTKEY, HOTKEY_KEY, tileTwoWindows)

-- Expose for AppleScript / IPC: `hs -c 'tileTwoWindows()'`
_G.tileTwoWindows = tileTwoWindows

-- Optional: menubar button for one-click trigger (alternative to .app)
local mb = hs.menubar.new(true, "TileClick")
mb:setTitle("\x.f\x87")
mb:setTooltip("Tile two recent windows")
mb:setClickCallback(function()
  tileTwoWindows()
end)

print("Hammerspoon tiling config loaded. Hotkey: Cmd+Ctrl+T. Menubar icon ready.")
