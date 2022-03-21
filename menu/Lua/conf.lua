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

-- Default binds utilize GC_ constants to ensure everything works
-- no matter the control method.
-- Any binds made from there on out use standard keycodes translated
-- into readable key/button names
gmconf.defaultBinds = {
	[GM_MENUBIND_OPEN] = GM_MENUCTRL_OPEN,
	[GM_MENUBIND_SELECT] = GM_MENUCTRL_SELECT,
	[GM_MENUBIND_BACK] = GM_MENUCTRL_BACK,
	[GM_MENUBIND_MOVE.UP] = GM_MENUCTRL_MOVE.UP,
	[GM_MENUBIND_MOVE.DOWN] = GM_MENUCTRL_MOVE.DOWN,
	[GM_MENUBIND_MOVE.LEFT] = GM_MENUCTRL_MOVE.LEFT,
	[GM_MENUBIND_MOVE.RIGHT] = GM_MENUCTRL_MOVE.RIGHT,
}

-- External configuration (you!)

local goldmenu_controls_pv = {MIN = 0, MAX = GM_CONTROL_MAXATTAINABLE} -- define controls range

return gmconf
