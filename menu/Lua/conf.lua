local gmconf = {}

local gmconst = lua_require("const")

-- Internal configuration.

gmconf.holdWait = TICRATE/4
gmconf.ticsBetweenHoldAdvance = 3 -- tics between moving to next selection
gmconf.cvarIncrementAcceleration = FRACUNIT/12
gmconf.cvarBaseIncrement = FRACUNIT/32
gmconf.cvarFloatBaseIncrement = FRACUNIT/100

gmconf.maxFadeStrength = 12

gmconf.fadeTics = 8
gmconf.fadeSpeed = FRACUNIT / gmconf.fadeTics

gmconf.selectionColor = V_YELLOWMAP

-- used for both default and loaded bindings. 
gmconf.defaultBinds = {
	[GM_MENUBIND_OPEN] = GM_MENUCTRL_OPEN,
	[GM_MENUBIND_SELECT] = GM_MENUCTRL_SELECT,
	[GM_MENUBIND_BACK] = GM_MENUCTRL_BACK,
	[GM_MENUBIND_MOVE.UP] = GM_MENUCTRL_MOVE.UP,
	[GM_MENUBIND_MOVE.DOWN] = GM_MENUCTRL_MOVE.DOWN,
	[GM_MENUBIND_MOVE.LEFT] = GM_MENUCTRL_MOVE.LEFT,
	[GM_MENUBIND_MOVE.RIGHT] = GM_MENUCTRL_MOVE.RIGHT,
}

-- Saves the config file
-- TODO: Write this to use goldmenu.binds instead
function gmconf.saveConfig(goldmenu)
	local file = io.openlocal("client/MOD/menu_config.cfg", "w+")
	
	file:write("bindings = {\n"..
		'[GM_MENUBIND_OPEN] = "'..GM_MENUCTRL_OPEN[1]..','..GM_MENUCTRL_OPEN[2]..'"\n'..
		'[GM_MENUBIND_SELECT] = "'..GM_MENUCTRL_SELECT[1]..','..GM_MENUCTRL_SELECT[2]..'"\n'..
		'[GM_MENUBIND_BACK] = "'..GM_MENUCTRL_BACK[1]..','..GM_MENUCTRL_BACK[2]..'"\n'..
		'[GM_MENUBIND_MOVE.UP] = "'..GM_MENUCTRL_MOVE.UP[1]..','..GM_MENUCTRL_MOVE.UP[2]..'"\n'..
		'[GM_MENUBIND_MOVE.DOWN] = "'..GM_MENUCTRL_MOVE.DOWN[1]..','..GM_MENUCTRL_MOVE.DOWN[2]..'"\n'..
		'[GM_MENUBIND_MOVE.LEFT] = "'..GM_MENUCTRL_MOVE.LEFT[1]..','..GM_MENUCTRL_MOVE.LEFT[2]..'"\n'..
		'[GM_MENUBIND_MOVE.RIGHT] = "'..GM_MENUCTRL_MOVE.RIGHT[1]..','..GM_MENUCTRL_MOVE.RIGHT[2]..'"\n'..
		'}')

	file:close()
end

-- Loads the config file. If it doesn't exist it loads defaults
function gmconf.loadConfig(goldmenu)
	local file = io.openlocal("client/MOD/menu_config.cfg", "r")

	local save = file:read("*a")

	if save == nil then
		print("No config present. Creating config...")
		gmconst.loadDefaultCtrl()
		-- save defaults
		gmconf.saveConfig()
	else
		-- Re-register control variables
		goldmenu.binds[GM_MENUBIND_OPEN] = {tonumber(save:match('%[GM_MENUBIND_OPEN%]%s*=%s*"?(%d+),%d+"?')),
											tonumber(save:match('%[GM_MENUBIND_OPEN%]%s*=%s*"?%d+,(%d+)"?'))}
		goldmenu.binds[GM_MENUBIND_SELECT] = {tonumber(save:match('%[GM_MENUBIND_SELECT%]%s*=%s*"?(%d+),%d+"?')),
											tonumber(save:match('%[GM_MENUBIND_SELECT%]%s*=%s*"?%d+,(%d+)"?'))}
		goldmenu.binds[GM_MENUBIND_BACK] = {tonumber(save:match('%[GM_MENUBIND_BACK%]%s*=%s*"?(%d+),%d+"?')),
											tonumber(save:match('%[GM_MENUBIND_BACK%]%s*=%s*"?%d+,(%d+)"?'))}
		for k, u in pairs(GM_MENUCTRL_MOVE) do
			goldmenu.binds[GM_MENUBIND_MOVE[k]] = {tonumber(save:match('%[GM_MENUBIND_MOVE.'..tostring(k)..'%]%s*=%s*"?(%d+),%d+"?')),
													tonumber(save:match('%[GM_MENUBIND_MOVE.'..tostring(k)..'%]%s*=%s*"?%d+,(%d+)"?'))}
		end
	end

end

-- External configuration (you!)

local goldmenu_controls_pv = {MIN = 0, MAX = GM_CONTROL_MAXATTAINABLE} -- define controls range

return gmconf
