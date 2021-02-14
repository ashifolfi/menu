local gmcontrols = {}

local gmconst = lua_require("const")
local gmconf = lua_require("conf")

--
-- Controls handling
--

-- Increases a timer while `condition` is true, zeroing if false.
-- If nil, don't effect the timer.
function gmcontrols.runConditionalTimer(timer, condition)
	if condition == nil then
		return timer
	end

	timer = $ or 0
	timer = $ == INT32_MAX and $-1 or $

	timer = condition and $+1 or 0

	return timer
end

-- i don't want too many double table accesses in my code so i'm doing this
-- Determines how long a button corresponding to a menu bind has been pressed, in tics.
function gmcontrols.menuBindPressed(goldmenu, menuBind)
	return goldmenu.pressed[goldmenu.binds[menuBind]]
end

-- Gathers all the menu controls
function gmcontrols.getMenuControls(player)
	-- Pressed controls
	if not player.goldmenu.pressed then
		-- [gmconst.control.*] = tics pressed
		player.goldmenu.pressed = {}
	end

	local cmd = player.cmd

	-- gather movement controls
	player.goldmenu.pressed[gmconst.control.moveUp] = gmcontrols.runConditionalTimer($, cmd.forwardmove > 0)
	player.goldmenu.pressed[gmconst.control.moveDown] = gmcontrols.runConditionalTimer($, cmd.forwardmove < 0)

	player.goldmenu.pressed[gmconst.control.moveLeft] = gmcontrols.runConditionalTimer($, -cmd.sidemove > 0)
	player.goldmenu.pressed[gmconst.control.moveRight] = gmcontrols.runConditionalTimer($, -cmd.sidemove < 0)

	-- gather camera controls
	local aimdiff = cmd.aiming - player.goldmenu.prevaiming
	local turndiff = (cmd.angleturn - player.goldmenu.prevangleturn) & ~1

	player.goldmenu.pressed[gmconst.control.cameraUp] = gmcontrols.runConditionalTimer($, aimdiff > 0)
	player.goldmenu.pressed[gmconst.control.cameraDown] = gmcontrols.runConditionalTimer($, aimdiff < 0)

	player.goldmenu.pressed[gmconst.control.cameraLeft] = gmcontrols.runConditionalTimer($, turndiff > 0)
	player.goldmenu.pressed[gmconst.control.cameraRight] = gmcontrols.runConditionalTimer($, turndiff < 0)

	-- gather weapon number controls
	local weaponNum = cmd.buttons & BT_WEAPONMASK

	for i = 1, BT_WEAPONMASK do
		player.goldmenu.pressed[gmconst.control.weapon1 + i - 1] = gmcontrols.runConditionalTimer($, i == weaponNum)
	end

	-- go through the rest of the buttons as a truth table
	for i = (BT_WEAPONMASK + 1)>>2, 15 do
		local button = cmd.buttons & (1 << i)
		local newcontrol = gmconst.playerButtonToControl[1 << i]

		if newcontrol ~= nil then
			player.goldmenu.pressed[newcontrol] = gmcontrols.runConditionalTimer($, button > 0)
		end
	end

	-- player.goldmenu.prev* set by caller.
end

return gmcontrols