local _, acpi_exit_code
_, _, acpi_exit_code = (io.popen("which acpi")):close()
if acpi_exit_code == 0 then
  local awful = awful or require('awful')
  local naughty = naughty or require('naughty')
  local timer = timer or require('timer')
  local percent = 20
  local INTERVAL_TIME = 30
  local SIG_NAME = "timeout"

  local battery_alert
  battery_alert = function()
    local battery, exit_code
    do
      local _with_0 = io.popen("acpi")
      battery = _with_0:read("*a")
      _, _, exit_code = _with_0:close()
    end
    if exit_code == 0 then
      local battery1, battery2
      battery1, battery2 = battery:match("(.-)\n(.-)\n")
      if battery2 == nil then
        local lefttime = battery:match("(%d%d:%d%d:%d%d)")
        local status
        status, battery = battery:match("^[^%s]+%s+[^%s]+%s+([^%s,]+).-(%d+)%%")
        if (status == "Discharging") and (tonumber(battery)) <= percent then
          percent = percent == 97 and 10 or -1
          return naughty.notify({
            title = "           Battery        ",
            text = tostring(battery) .. "% left (" .. tostring(lefttime) .. ")",
		    bg = "#FF0000",
            timeout = 20
          })
        end
      else
        local lefttime = battery:match("(%d%d:%d%d:%d%d)")
        local status1, status2
        status1, battery1 = battery1:match("^[^%s]+%s+[^%s]+%s+([^%s,]+).-(%d+)%%")
        status2, battery2 = battery2:match("^[^%s]+%s+[^%s]+%s+([^%s,]+).-(%d+)%%")
        total_battery = (tonumber(battery1) + tonumber(battery2))/2
        if (status1 == "Discharging" or status2 == "Discharging") and (total_battery) <= percent then
          percent = percent == 97 and 10 or -1
          return naughty.notify({
            title = "           Battery        ",
            text = tostring(total_battery) .. "% left (" .. tostring(lefttime) .. ")",
		    bg = "#FF0000",
            timeout = 20
          })
        end
      end
    end
  end
  do
    local _with_0 = timer({
      timeout = INTERVAL_TIME
    })
    _with_0:connect_signal(SIG_NAME, battery_alert)
    _with_0:start()
    return _with_0
  end
end
