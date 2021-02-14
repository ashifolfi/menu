local gmconf = {}

local gmconst = lua_require("const")

-- Internal configuration.

gmconf.holdWait = TICRATE/4
gmconf.ticsBetweenHoldAdvance = 3 -- tics between moving to next selection

gmconf.maxFadeStrength = 12

gmconf.fadeTics = 8
gmconf.fadeSpeed = FRACUNIT / gmconf.fadeTics

gmconf.selectionColor = V_YELLOWMAP

gmconf.defaultBinds = {
	[gmconst.menuBind.open] = gmconst.control.tossFlag,
	[gmconst.menuBind.up] = gmconst.control.cameraUp,
	[gmconst.menuBind.down] = gmconst.control.cameraDown,
	[gmconst.menuBind.select] = gmconst.control.jump,
	[gmconst.menuBind.back] = gmconst.control.spin,
}

-- External configuration (you!)

local goldmenu_controls_pv = {MIN = 0, MAX = gmconst.control.maxAttainable} -- define controls range

-- define control names
for controlCode, controlName in ipairs(gmconst.controlToString) do
	goldmenu_controls_pv[controlName] = controlCode
end

gmconf.bindCvar = {}

for k, v in pairs(gmconf.defaultBinds) do
	gmconf.bindCvar[k] = CV_RegisterVar{"_goldmenu_control_" .. k, gmconst.controlToString[v], 0, menucontrols_pv, nil}
end

return gmconf