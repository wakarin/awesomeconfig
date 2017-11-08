local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")

local batgraph_widget = wibox.widget {
    max_value = 100,
    color = '#51935c',
    background_color = "#1e252c",
    forced_width = 15,
    step_width = 15,
    step_spacing = 1,
    widget = wibox.widget.graph
}

bat_widget = wibox.container.margin(wibox.container.mirror(batgraph_widget, { horizontal = true }), 0, 0, 0, 2)


watch("acpi", 1,
    function(widget, stdout, stderr, exitreason, exitcode)
        local battery1, battery2 =
        stdout:match("(.-)\n(.-)\n")

        if battery2 == nil then
            local status
            status, battery = stdout:match("^[^%s]+%s+[^%s]+%s+([^%s,]+).-(%d+)%%")
            if (status == "Discharging") then
                widget:set_background_color('#1e252c')
            else
                widget:set_background_color('#51935c')
            end
        else
            local status1, status2
            status1, battery1 = battery1:match("^[^%s]+%s+[^%s]+%s+([^%s,]+).-(%d+)%%")
            status2, battery2 = battery2:match("^[^%s]+%s+[^%s]+%s+([^%s,]+).-(%d+)%%")
            battery = (tonumber(battery1) + tonumber(battery2))/2
            if (status1 == "Discharging" or status2 == "Discharging") then
                widget:set_background_color('#1e252c')
            else
                widget:set_background_color('#51935c')
            end
        end

        if battery > 60 then
            widget:set_color('#20affc')
        elseif battery > 40 then
            widget:set_color("#70ff38")
        elseif battery > 20 then
            widget:set_color("#f1ff38")
        elseif battery > 10 then
            widget:set_color("#ff9138")
        else
            widget:set_color('#ff3b38')
        end

        widget:add_value(battery)
    end,
    batgraph_widget
)

batgraph_widget:buttons(
    awful.util.table.join(
        awful.button({}, 1, function() awful.spawn.with_shell("echo bleft | xclip -selection clipboard")  end),
        awful.button({}, 3, function() awful.spawn.with_shell("echo bright | xclip -selection clipboard") end)
    )
)
