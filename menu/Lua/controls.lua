/*
	Rewritten to utilize the new lua inputs.
	
	- Ashi
*/

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

gmcontrols.plr = {}

-- We use this to constantly check in on what we're pressing or not
-- KeyDown doesn't run every frame but we can keep an eye on what's being
-- pressed via a special table
-- Said table isn't exactly elegant but it doesn't need to be.
function gmcontrols.checkControls()
	if gmcontrols.plr.ctrl_pressed == nil then
		gmcontrols.plr.ctrl_pressed = {}
	end
	
	local player = gmcontrols.plr
	local inputs = gmcontrols.plr.ctrl_pressed
	
	if inputs.move == nil then
		inputs.move = {}
		for k, u in pairs(GM_MENUCTRL_MOVE) do
			inputs.move[k] = false
		end
	end
	
	-- Adapted from getMenuControls
	-- gather movement controls
	for k, u in pairs(GM_MENUCTRL_MOVE) do
		player.goldmenu.pressed[GM_MENUCTRL_MOVE[k]] = gmcontrols.runConditionalTimer($, inputs.move[k])
	end
	
	player.goldmenu.pressed[GM_MENUCTRL_SELECT] = gmcontrols.runConditionalTimer($, inputs[GM_MENUCTRL_SELECT])
	player.goldmenu.pressed[GM_MENUCTRL_BACK] = gmcontrols.runConditionalTimer($, inputs[GM_MENUCTRL_BACK])
	player.goldmenu.pressed[GM_MENUCTRL_OPEN] = gmcontrols.runConditionalTimer($, inputs[GM_MENUCTRL_OPEN])
	
end

-- New Super Control Handler U Deluxe (Now with funky mode)
addHook("KeyDown", function(key)
	local inputs = gmcontrols.plr.ctrl_pressed 	-- shortcuts
	
	-- Put this here because it's the open key
	for i=1,2 do -- Less lines of code overall
		if key.num == GM_MENUCTRL_OPEN[i] then
			inputs[GM_MENUCTRL_OPEN] = true; return true
		end
		
		if not(gmcontrols.plr.goldmenu.open) then return end
		
		for k, u in pairs(GM_MENUCTRL_MOVE) do
			if key.num == GM_MENUCTRL_MOVE[k][i] then
				inputs.move[k] = true; return true
			end
		end
		
		if key.num == GM_MENUCTRL_SELECT[i] then
			inputs[GM_MENUCTRL_SELECT] = true; return true
		end
		
		if key.num == GM_MENUCTRL_BACK[i] then
			inputs[GM_MENUCTRL_BACK] = true; return true
		end
		
		if key.num == GM_CONTROL_CONSOLE[i] then
		-- The only control we should NEVER block is console
		-- unless we're in a record attack mode, then :shitsfree:
			return false
		end
		-- block everything else
		return true
	end
end)

addHook("KeyUp", function(key)
	local inputs = gmcontrols.plr.ctrl_pressed 	-- shortcuts
	
	-- Put this here because it's the open key
	for i=1,2 do -- Less lines of code overall
		if key.num == GM_MENUCTRL_OPEN[i] then
			inputs[GM_MENUCTRL_OPEN] = false; return true
		end
		
		if not(gmcontrols.plr.goldmenu.open) then return end
		
		for k, u in pairs(GM_MENUCTRL_MOVE) do
			if key.num == GM_MENUCTRL_MOVE[k][i] then
				inputs.move[k] = false; return true
			end
		end
		
		if key.num == GM_MENUCTRL_SELECT[i] then
			inputs[GM_MENUCTRL_SELECT] = false; return true
		end
		
		if key.num == GM_MENUCTRL_BACK[i] then
			inputs[GM_MENUCTRL_BACK] = false; return true
		end
		
		if key.num == GM_CONTROL_CONSOLE[i] then
		-- The only control we should NEVER block is console
		-- unless we're in a record attack mode, then :shitsfree:
			return false
		end
		-- block everything else
		return true
	end
end)

return gmcontrols
