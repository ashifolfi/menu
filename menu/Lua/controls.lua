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

-- Gathers all the menu controls
function gmcontrols.getMenuControls(player)
	-- Pressed controls
	if not player.goldmenu.pressed then
		-- [GM_CONTROL_*] = tics pressed
		player.goldmenu.pressed = {}
	end

	local cmd = player.cmd

	-- gather movement controls
	player.goldmenu.pressed[GM_CONTROL_MOVEUP] = gmcontrols.runConditionalTimer($, cmd.forwardmove > 0)
	player.goldmenu.pressed[GM_CONTROL_MOVEDOWN] = gmcontrols.runConditionalTimer($, cmd.forwardmove < 0)

	player.goldmenu.pressed[GM_CONTROL_MOVELEFT] = gmcontrols.runConditionalTimer($, -cmd.sidemove > 0)
	player.goldmenu.pressed[GM_CONTROL_MOVERIGHT] = gmcontrols.runConditionalTimer($, -cmd.sidemove < 0)

	-- gather camera controls
	local aimdiff = cmd.aiming - player.goldmenu.prevaiming
	local turndiff = (cmd.angleturn - player.goldmenu.prevangleturn) & ~1

	player.goldmenu.pressed[GM_CONTROL_CAMERAUP] = gmcontrols.runConditionalTimer($, aimdiff > 0)
	player.goldmenu.pressed[GM_CONTROL_CAMERADOWN] = gmcontrols.runConditionalTimer($, aimdiff < 0)

	player.goldmenu.pressed[GM_CONTROL_CAMERALEFT] = gmcontrols.runConditionalTimer($, turndiff > 0)
	player.goldmenu.pressed[GM_CONTROL_CAMERARIGHT] = gmcontrols.runConditionalTimer($, turndiff < 0)

	-- gather weapon number controls
	local weaponNum = cmd.buttons & BT_WEAPONMASK

	for i = 1, BT_WEAPONMASK do
		player.goldmenu.pressed[GM_CONTROL_WEAPON1 + i - 1] = gmcontrols.runConditionalTimer($, i == weaponNum)
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
