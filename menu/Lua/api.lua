local goldmenu = {} -- the api, visible as `gmapi` internally

local gmconst = lua_require("const")
local gmcontrols = lua_require("controls")
local gmdata = lua_require("data")

--[[
	external useful functions
]]

function goldmenu.newItem(...)
	-- body
end

function goldmenu.newMenu(style, ...)
	local inTable
	local args = {...}

	-- input table
	if type(args[1]) == "table" and #args == 1 then
		inTable = args[1]
	end

	local name

	if inTable then
		name = inTable.name or inTable[1]
	else
		name = args[1]
	end

	return gmdata.newMenu(name, style or gmstyles.scroll, {})
end

function goldmenu.newSubMenu(...)
	-- body
end

function goldmenu.registerMenu(menu)
	table.insert(gmdata.modMenu, menu)
end

goldmenu.control = gmconst.control
goldmenu.bind = gmconst.menuBind
goldmenu.bindPressed = gmcontrols.menuBindPressed

setmetatable(goldmenu, {__metatable = true})

rawset(_G, "goldmenu", goldmenu)

return goldmenu -- visible as `gmapi` internally