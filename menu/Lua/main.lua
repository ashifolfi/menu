--[[
	Hello Lua scripters, I bet you're wondering what's up with this ultra weird setup.
	This setup is a method in which I distribute data between files without requiring many _G rawsets.

	Are you looking for the API? If so, check ./api.lua. The global variable is `gmapi`.

	`init.lua` directly loads this file, and defines `lua_require': a `require` clone for SRB2.
	Any file `lua_require`'d will be cached for future retrieval; loading them here is not a waste.

	Make sure to not 'lua_require' files that are requiring your file!

	Everything below the `lua_require`s is just initialisation code.
	Have fun looking through the code!

	~ Golden
]]

local gmdebug = lua_require("debug") -- Boolean; debug mode. // no depends

local gmconst = lua_require("const") -- Shared constants. // no depends
local gmutil = lua_require("util") -- Utility functions. // no depends
local gmstyles = lua_require("styles") -- Definitions for default menu styles. // depends: 'util' (for menuStyles)

local gmconf = lua_require("conf") -- GoldMenu configuration. // depends: 'const'
local gmcontrols = lua_require("controls") -- Misc. functions // depends: 'conf', 'const'
local gmdata = lua_require("data") -- Data management and structure definition. // depends: 'const', 'styles'

local gmmenudefs = lua_require("menudefs") -- Defines default menus. // depends: 'const', 'data', 'styles'
local gmvars = lua_require("vars") -- Functions to manipulate goldmenu player-specific variables. // depends: 'conf', 'const', 'data'
local gmapi = lua_require("api") -- Lua scripter API. // depends: 'const', 'control', 'data'
local gmitemhandlers = lua_require("itemhandlers") -- Defines default menus. // depends: 'const', 'conf', 'vars', 'util'
local gmcallbacks = lua_require("callbacks") -- Hooked functions. // depends: 'debug', 'controls', 'conf', 'const', 'util', 'data', 'styles', 'vars'

-- crappy hooks that i have to do to get srb2 to run our functions

addHook("PlayerSpawn", gmcallbacks.menuInit)

-- playerspawn but except it runs at mod startup
if maptol then
	for player in players.iterate do
		gmcallbacks.menuInit(player)
	end
end

addHook("PreThinkFrame", function()
	for player in players.iterate do
		gmcallbacks.onControlsGet(player)
	end
end)

addHook("PlayerThink", gmcallbacks.doMenu)

//if gmdebug then
	hud.disable("score")
	hud.disable("time")
	hud.disable("rings")
	hud.disable("lives")
//end

hud.add(gmcallbacks.drawMenu, "titlecard") -- we dont really need the camera, and i'd like to draw above things
