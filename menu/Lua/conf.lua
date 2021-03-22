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

gmconf.defaultBinds = {
	[GM_MENUBIND_OPEN] = GM_CONTROL_TOSSFLAG,
	[GM_MENUBIND_UP] = GM_CONTROL_CAMERAUP,
	[GM_MENUBIND_DOWN] = GM_CONTROL_CAMERADOWN,
	[GM_MENUBIND_LEFT] = GM_CONTROL_CAMERALEFT,
	[GM_MENUBIND_RIGHT] = GM_CONTROL_CAMERARIGHT,
	[GM_MENUBIND_SELECT] = GM_CONTROL_JUMP,
	[GM_MENUBIND_BACK] = GM_CONTROL_SPIN,
}

-- External configuration (you!)

local goldmenu_controls_pv = {MIN = 0, MAX = GM_CONTROL_MAXATTAINABLE} -- define controls range

-- define control names
for controlCode, controlName in ipairs(gmconst.controlToString) do
	goldmenu_controls_pv[controlName] = controlCode
end

gmconf.bindCvar = {}

for i, v in ipairs(gmconf.defaultBinds) do
	local str = gmconst.menuBindToString[i]

	gmconf.bindCvar[i] = CV_RegisterVar{"_goldmenu_control_" .. str, gmconst.controlToString[v], 0, menucontrols_pv, nil}
end

return gmconf