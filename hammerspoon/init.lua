-- ~/.hammerspoon/init.lua

local blueutilPath = "/opt/homebrew/bin/blueutil"

local function toggleBluetoothDevice(name, mac)
  local checkCmd = string.format("%s --is-connected %s", blueutilPath, mac)
  local output = hs.execute(checkCmd):gsub("%s+", "")

  local action, verb, emoji
  if tonumber(output) == 1 then
    action = "--disconnect"
    verb = "🔇 Disconnected"
    emoji = "🚫"
  else
    action = "--connect"
    verb = "🎧 Connected"
    emoji = "✅"
  end

  local cmd = string.format("%s %s %s", blueutilPath, action, mac)
  hs.task.new("/bin/sh", function(exitCode, stdOut, stdErr)
    -- Optional verification for connection
    if action == "--connect" then
      hs.timer.doAfter(3, function()
        local verifyCmd = string.format("%s --is-connected %s", blueutilPath, mac)
        local verify = hs.execute(verifyCmd):gsub("%s+", "")
        if tonumber(verify) == 1 then
          hs.alert.show(verb .. " " .. name .. " " .. emoji)
        else
          hs.alert.show("❌ Failed to connect " .. name)
        end
      end)
    else
      hs.alert.show(verb .. " " .. name .. " " .. emoji)
    end
  end, { "-c", cmd }):start()
end

-- Nothing Ear (a) → Ctrl + B
hs.hotkey.bind({ "cmd", "ctrl" }, "B", function()
  toggleBluetoothDevice("Nothing Ear (a)", "2c-be-eb-d3-47-65")
end)

-- CMF Pro 2 → Ctrl + Shift + B
hs.hotkey.bind({ "cmd", "ctrl", "alt" }, "B", function()
  toggleBluetoothDevice("OPZ2", "08-12-87-d1-2a-50")
end)
