local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local naughty = require('naughty')

local memgraph_widget = wibox.widget {
    max_value = 100,
    color = '#51935c',
    background_color = "#1e252c",
--    forced_width = 15,
--   step_width = 2,
    forced_width = 15,
    step_width = 15,
    step_spacing = 1,
    widget = wibox.widget.graph
}

mem_widget = wibox.container.margin(wibox.container.mirror(memgraph_widget, { horizontal = true }), 0, 0, 0, 2)


watch("cat /proc/meminfo | grep '^Mem'", 1,
    function(widget, stdout, stderr, exitreason, exitcode)
        local total, free, available =
        stdout:match('[^%d]+(%d+)[^%d]+(%d+)[^%d]+(%d+)')

        local usage = (total - available) / total * 100

        if usage > 80 then
            widget:set_color('#a5151c')
        else
            widget:set_color('#51935c')
        end

        widget:add_value(usage)

    end,
    memgraph_widget
)

memgraph_widget:buttons(
    awful.util.table.join(
        awful.button({}, 1, function() naughty.notify({
            title = "ps acux --sort -%mem",
            text = io.popen("ps acux --sort -%mem"):read(10000),
            bg = "#000000",
            timeout = 10
        }) end)
        --awful.button({}, 3, function() awful.spawn.with_shell("echo mright | xclip -selection clipboard") end)
    )
)
