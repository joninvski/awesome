require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")
require("vicious")
require('couth.couth')
require('couth.alsa')
-- require("blingbling")

--{{---| Error handling |---------------------------------------------------------------------------

if awesome.startup_errors then
naughty.notify({ preset = naughty.config.presets.critical,
title = "Oops, there were errors during startup!",
text = awesome.startup_errors })
end
do
local in_error = false
awesome.add_signal("debug::error", function (err)
if in_error then return end
in_error = true
naughty.notify({ preset = naughty.config.presets.critical,
title = "Oops, an error happened!",
text = err })
in_error = false
end)
end

--{{---| Theme |------------------------------------------------------------------------------------

config_dir = ("/home/jtrindade/.config/awesome")
themes_dir = (config_dir .. "/themes")
beautiful.init(themes_dir .. "/powerarrow/theme.lua")

--{{---| Variables |--------------------------------------------------------------------------------

modkey        = "Mod1"
terminal      = "roxterm"

--{{---| Couth Alsa volume applet |-----------------------------------------------------------------

couth.CONFIG.ALSA_CONTROLS = { 'Master', 'PCM' }
couth.CONFIG.ALSA_CONTROLS = { 'Master', 'PCM' }
couth.CONFIG.NOTIFIER_FONT = 'mono 10'
couth.CONFIG.NOTIFIER_POSITION = 'top_right'
couth.CONFIG.NOTIFIER_TIMEOUT = 1

--{{---| Table of layouts |-------------------------------------------------------------------------

layouts =
{
  awful.layout.suit.tile,
  -- awful.layout.suit.tile.left,
  -- awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.floating
}

--{{---| Naughty theme |----------------------------------------------------------------------------

naughty.config.default_preset.font         = beautiful.notify_font
naughty.config.default_preset.fg           = beautiful.notify_fg
naughty.config.default_preset.bg           = beautiful.notify_bg
naughty.config.presets.normal.border_color = beautiful.notify_border
naughty.config.presets.normal.opacity      = 0.8
naughty.config.presets.low.opacity         = 0.8
naughty.config.presets.critical.opacity    = 0.8

--{{---| Tags |-------------------------------------------------------------------------------------

tags = {}
for s = 1, screen.count() do
    tags[s] = awful.tag({ 1, 2, 3, 4, 5 }, s, layouts[1])
end

--{{---| Menu |-------------------------------------------------------------------------------------

mymainmenu = awful.menu({ items = { 
  {"terminal",             terminal},
  {"hibernate",             "sudo pm-hibernate"},
  {"restart",               awesome.restart },
  {"reboot",                "sudo reboot"},
  {"quit",                  awesome.quit }
}
})

mylauncher = awful.widget.launcher({ image = image(beautiful.clear_icon), menu = mymainmenu })

--{{---| Wibox |------------------------------------------------------------------------------------

mysystray = widget({ type = "systray" })
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                 client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=450 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
for s = 1, screen.count() do
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

--{{---| MEM widget |-------------------------------------------------------------------------------

memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, '<span background="#777E76" font="Terminus 12"> <span font="Terminus 9" color="#EEEEEE" background="#777E76">$1% ($2MB/$3MB) </span></span>', 13)
memicon = widget ({type = "imagebox" })
memicon.image = image(beautiful.widget_mem)

--{{---| CPU / sensors widget |---------------------------------------------------------------------

cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu, '<span background="#4B696D" font="Terminus 12"> <span font="Terminus 9" color="#DDDDDD">$2% </span></span>', 3)
cpuicon = widget ({type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)
-- sensors = widget({ type = "textbox" })
-- vicious.register(sensors, vicious.widgets.sensors)
tempicon = widget ({type = "imagebox" })
tempicon.image = image(beautiful.widget_temp)

--{{---| FS's widget / udisks-glue menu |-----------------------------------------------------------

-- fswidget = widget({ type = "textbox" })
-- vicious.register(fswidget, vicious.widgets.fs,
-- '<span background="#D0785D" font="Terminus 12"> <span font="Terminus 9" color="#EEEEEE">${/home avail_gb}GB </span></span>', 8)

--{{---| Battery widget |---------------------------------------------------------------------------  

baticon = widget ({type = "imagebox" })
baticon.image = image(beautiful.widget_battery)
batwidget = widget({ type = "textbox" })
vicious.register( batwidget, vicious.widgets.bat, '<span background="#92B0A0" font="Terminus 12"> <span font="Terminus 9" color="#FFFFFF" background="#92B0A0">$1$2% </span></span>', 1, "BAT0" )

--{{---| Net widget |-------------------------------------------------------------------------------

netwidget = widget({ type = "textbox" })
vicious.register(netwidget, 
vicious.widgets.net,
'<span background="#C2C2A4" font="Terminus 12"> <span font="Terminus 9" color="#FFFFFF">${eth2 down_kb} ↓↑ ${eth2 up_kb}</span> </span>', 3)
neticon = widget ({type = "imagebox" })
neticon.image = image(beautiful.widget_net)
netwidget:buttons(awful.util.table.join(awful.button({ }, 1,
function () awful.util.spawn_with_shell(iptraf) end)))

--{{---| Text Clock |-----------------------------------------------------------------------------
--
mytextclock = awful.widget.textclock({ align = "right" })

--{{---| Binary Clock |-----------------------------------------------------------------------------


binaryclock = {}
binaryclock.widget = widget({type = "imagebox"})
binaryclock.w = 42  
binaryclock.h = 16  
binaryclock.show_sec = true 
binaryclock.color_active = beautiful.binclock_fga
binaryclock.color_bg = beautiful.binclock_bg
binaryclock.color_inactive = beautiful.binclock_fgi
binaryclock.dotsize = math.floor(binaryclock.h / 5)
binaryclock.step = math.floor(binaryclock.dotsize / 3)
binaryclock.widget.image = image.argb32(binaryclock.w, binaryclock.h, nil) 
if (binaryclock.show_sec) then binaryclock.timeout = 1 else binaryclock.timeout = 20 end 
binaryclock.DEC_BIN = function(IN) 
local B,K,OUT,I,D=2,"01","",0
while IN>0 do
I=I+1
IN,D=math.floor(IN/B),math.mod(IN,B)+1
OUT=string.sub(K,D,D)..OUT
end
return OUT
end
binaryclock.paintdot = function(val,shift,limit) 
local binval = binaryclock.DEC_BIN(val)
local l = string.len(binval)
local height = 0 
if (l < limit) then
for i=1,limit - l do binval = "0" .. binval end
end
for i=0,limit-1 do
if (string.sub(binval,limit-i,limit-i) == "1") then
binaryclock.widget.image:draw_rectangle(shift,
binaryclock.h - binaryclock.dotsize - height, 
binaryclock.dotsize, binaryclock.dotsize, true, binaryclock.color_active)
else
binaryclock.widget.image:draw_rectangle(shift,
binaryclock.h - binaryclock.dotsize - height, 
binaryclock.dotsize,binaryclock.dotsize, true, binaryclock.color_inactive)
end
height = height + binaryclock.dotsize + binaryclock.step
end
end
binaryclock.drawclock = function ()
binaryclock.widget.image:draw_rectangle(0, 0, binaryclock.w, binaryclock.h, true, binaryclock.color_bg)
local t = os.date("*t")
local hour = t.hour
if (string.len(hour) == 1) then
hour = "0" .. t.hour
end
local min = t.min
if (string.len(min) == 1) then
min = "0" .. t.min
end
local sec = t.sec
if (string.len(sec) == 1) then
sec = "0" .. t.sec
end
local col_count = 6
if (not binaryclock.show_sec) then col_count = 4 end
local step = math.floor((binaryclock.w - col_count * binaryclock.dotsize) / 8)
binaryclock.paintdot(0 + string.sub(hour, 1, 1), step, 2)
binaryclock.paintdot(0 + string.sub(hour, 2, 2), binaryclock.dotsize + 2 * step, 4)
binaryclock.paintdot(0 + string.sub(min, 1, 1),binaryclock.dotsize * 2 + 4 * step, 3)
binaryclock.paintdot(0 + string.sub(min, 2, 2),binaryclock.dotsize * 3 + 5 * step, 4)
if (binaryclock.show_sec) then
binaryclock.paintdot(0 + string.sub(sec, 1, 1), binaryclock.dotsize * 4 + 7 * step, 3)
binaryclock.paintdot(0 + string.sub(sec, 2, 2), binaryclock.dotsize * 5 + 8 * step, 4)
end
binaryclock.widget.image = binaryclock.widget.image
end
binarytimer = timer { timeout = binaryclock.timeout }
binarytimer:add_signal("timeout", function()
binaryclock.drawclock()
end)
binarytimer:start()

-- binaryclock.widget:buttons(awful.util.table.join(
--   awful.button({ }, 1, function () 
--   end)
-- ))

--{{---| Separators widgets |-----------------------------------------------------------------------

spr = widget({ type = "textbox" })
spr.text = ' '
sprd = widget({ type = "textbox" })
sprd.text = '<span background="#313131" font="Terminus 12"> </span>'
spr3f = widget({ type = "textbox" })
spr3f.text = '<span background="#777e76" font="Terminus 12"> </span>'
arr1 = widget ({type = "imagebox" })
arr1.image = image(beautiful.arr1)
arr2 = widget ({type = "imagebox" })
arr2.image = image(beautiful.arr2)
arr3 = widget ({type = "imagebox" })
arr3.image = image(beautiful.arr3)
arr4 = widget ({type = "imagebox" })
arr4.image = image(beautiful.arr4)
arr5 = widget ({type = "imagebox" })
arr5.image = image(beautiful.arr5)
arr6 = widget ({type = "imagebox" })
arr6.image = image(beautiful.arr6)
arr7 = widget ({type = "imagebox" })
arr7.image = image(beautiful.arr7)
arr8 = widget ({type = "imagebox" })
arr8.image = image(beautiful.arr8)
arr9 = widget ({type = "imagebox" })
arr9.image = image(beautiful.arr9)
arr0 = widget ({type = "imagebox" })
arr0.image = image(beautiful.arr0)


--{{---| Panel |------------------------------------------------------------------------------------

mywibox[s] = awful.wibox({ position = "top", screen = s, height = "12" })

mywibox[s].widgets = {
   { mylauncher, mytaglist[s], mypromptbox[s], layout = awful.widget.layout.horizontal.leftright },
     mytextclock,
     mylayoutbox[s],
     arr1,
     spr3f,
     binaryclock.widget,
     spr3f, 
     arr2, 
     netwidget,
     neticon,
     arr3,
     batwidget,
     baticon,
     arr4, 
     fswidget,
     -- udisks_glue.widget,
     arr5,
     -- sensors,
     -- tempicon,
     arr6,
     cpuwidget,
     cpuicon,
     arr7,
     memwidget,
     memicon,
     arr8,
     arr9,
     spr,
     s == 1 and mysystray, spr or nil, mytasklist[s], 
     layout = awful.widget.layout.horizontal.rightleft } end

--{{---| Mouse bindings |---------------------------------------------------------------------------

root.buttons(awful.util.table.join(awful.button({ }, 3, function () mymainmenu:toggle() end)))

--{{---| Key bindings |-----------------------------------------------------------------------------

globalkeys = awful.util.table.join(
    awful.key({ modkey, "Control" }, "h",   awful.tag.viewprev       ),
    awful.key({ modkey, "Control" }, "l",  awful.tag.viewnext       ),
    awful.key({ modkey, "Control" }, "Escape", awful.tag.history.restore),
    awful.key({ modkey, "Control" }, "j", function () awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end end),
    awful.key({ modkey, "Control" }, "k", function () awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end end),
    awful.key({ "Mod4",             }, "w", function () mymainmenu:show({keygrabber=true}) end),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Shift"   }, "h", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Shift"   }, "l", function () awful.screen.focus_relative(-1) end),
    awful.key({ "Mod4",           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab", function () awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end end),
    awful.key({ modkey, "Control" }, "r",     function () mypromptbox[mouse.screen]:run() end),

--{{---| Hotkeys |----------------------------------------------------------------------------------

--{{---| Terminals, shells und multiplexors |---------------------------------------------------------\-\\
                                                                                                        --
awful.key({ modkey,           }, "Return",   function () awful.util.spawn(terminal) end),               --
                                                                                                        --
--{{--------------------------------------------------------------------------------------------------/-//

awful.key({ modkey, "Shift"   } , "r",                          awesome.restart),
awful.key({ modkey            } , "r",                          function () mypromptbox[mouse.screen]:run() end),
awful.key({ modkey, "Shift"   } , "h",                          function () awful.tag.incnmaster( 1)      end),
awful.key({ modkey, "Shift"   } , "l",                          function () awful.tag.incnmaster(-1)      end),
awful.key({ modkey, "Control" } , "h",                          function () awful.tag.incncol( 1)         end),
awful.key({ modkey, "Control" } , "l",                          function () awful.tag.incncol(-1)         end),
awful.key({ modkey,           } , "space",                      function () awful.layout.inc(layouts,  1) end),
awful.key({ modkey, "Shift"   } , "space",                      function () awful.layout.inc(layouts, -1) end),
awful.key({ modkey            } , "Print",                      function () awful.util.spawn_with_shell("screengrab") end),
awful.key({ modkey, "Control" } , "Print",                      function () awful.util.spawn_with_shell("screengrab --region") end),
awful.key({ modkey, "Shift"   } , "Print",                      function () awful.util.spawn_with_shell("screengrab --active") end),
awful.key({ "Mod4",           } , "q",                          awesome.quit),
awful.key({ "Mod4",           } , "l",                          function () awful.tag.incmwfact( 0.05)    end),
awful.key({ "Mod4",           } , "h",                          function () awful.tag.incmwfact(-0.05)    end),
awful.key({                   } , "XF86Calculator",             function () awful.util.spawn_with_shell("gcalctool") end),
awful.key({                   } , "XF86Sleep",                  function () awful.util.spawn_with_shell("sudo pm-hibernate") end),
awful.key({                   } , "XF86AudioPlay",              function () awful.util.spawn_with_shell("ncmpcpp toggle") end),
awful.key({                   } , "XF86AudioStop",              function () awful.util.spawn_with_shell("ncmpcpp stop") end),
awful.key({                   } , "XF86AudioPrev",              function () awful.util.spawn_with_shell("ncmpcpp prev") end),
awful.key({                   } , "XF86AudioNext",              function () awful.util.spawn_with_shell("ncmpcpp next") end),
awful.key({                   } , "XF86AudioLowerVolume",       function () couth.notifier:notify(couth.alsa:setVolume('Master','3dB-')) end),
awful.key({                   } , "XF86AudioRaiseVolume",       function () couth.notifier:notify(couth.alsa:setVolume('Master','3dB+')) end),
awful.key({                   } , "XF86AudioMute",              function () couth.notifier:notify(couth.alsa:setVolume('Master','toggle')) end)

)

clientkeys = awful.util.table.join(
awful.key({ "Mod4",           }, "r",        function (c) c:redraw()                       end),
awful.key({ modkey, "Control" }, "f",        function (c) c.fullscreen = not c.fullscreen  end),
awful.key({ modkey, "Control" }, "w",        function (c) c:kill()                         end),
awful.key({ modkey, "Control" }, "n",        function (c) c.minimized = true end),
awful.key({ modkey, "Control" }, "m",        function (c) c.maximized_horizontal = not c.maximized_horizontal
c.maximized_vertical   = not c.maximized_vertical end)
)

keynumber = 0
for s = 1, screen.count() do keynumber = math.min(9, math.max(#tags[s], keynumber)); end
for i = 1, keynumber do globalkeys = awful.util.table.join(globalkeys,
awful.key({ modkey }, "#" .. i + 9, function () local screen = mouse.screen
if tags[screen][i] then awful.tag.viewonly(tags[screen][i]) end end),
awful.key({ modkey, "Control" }, "#" .. i + 9, function () local screen = mouse.screen
if tags[screen][i] then awful.tag.viewtoggle(tags[screen][i]) end end),
awful.key({ modkey, "Shift" }, "#" .. i + 9, function () if client.focus and 
tags[client.focus.screen][i] then awful.client.movetotag(tags[client.focus.screen][i]) end end),
awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function () if client.focus and
tags[client.focus.screen][i] then awful.client.toggletag(tags[client.focus.screen][i]) end end)) end
clientbuttons = awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize))

--{{---| Set keys |---------------------------------------------------------------------------------

root.keys(globalkeys)

--{{---| Rules |------------------------------------------------------------------------------------

awful.rules.rules = {
    { rule = { },
    properties = { size_hints_honor = false,
    border_width = beautiful.border_width,
    border_color = beautiful.border_normal,
    focus = true,
    keys = clientkeys,
    buttons = clientbuttons } },
    { rule = { class = "gimp" },
    properties = { floating = true } },
}

--{{---| Signals |----------------------------------------------------------------------------------

client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })
    c:add_signal("mouse::enter", function(c) if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then client.focus = c end end)
    if not startup then if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c) awful.placement.no_offscreen(c) end end end)
client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

--{{---| run_once |---------------------------------------------------------------------------------

function run_once(prg)
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. prg .. " || (" .. prg .. ")") end

--{{---| run_once with args |-----------------------------------------------------------------------

function run_oncewa(prg) if not prg then do return nil end end
    awful.util.spawn_with_shell('ps ux | grep -v grep | grep -F ' .. prg .. ' || ' .. prg .. ' &') end

--{{--| Autostart |---------------------------------------------------------------------------------

run_once("awsetbg -f ~/.config/awesome/wallpaper.png")
-- os.execute("setxkbmap -layout 'us,ru' -variant 'winkeys' -option 'grp:caps_toggle,grp_led:caps,compose:ralt' &")
-- run_once("udisks-glue")
-- os.execute("sudo /etc/init.d/dcron start &")
-- run_once("kbdd")
-- run_once("qlipper")

--{{Xx----------------------------------------------------------------------------------------------

