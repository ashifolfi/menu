local gmvars = {}

local gmconst = lua_require("const")
local gmconf = lua_require("conf")
local gmdata = lua_require("data")

function gmvars.newMenuData()
	local menudata = {}

	return menudata
end

function gmvars.newGoldMenu(player)
	player.goldmenu = {}

	local goldmenu = player.goldmenu

	goldmenu.open = false -- are we open?????????
	goldmenu.heldControlLock = 0 -- Locks the controls while one is held.

	-- background fading vars.
	goldmenu.fadeStrength = 0
	goldmenu.fadeProgress = 0
	goldmenu.transparency = 0

	-- cvar manipulation vars
	goldmenu.cvarIncrementAcceleration = FRACUNIT
	goldmenu.pressedCvarIncrementKey = GM_MENUBIND_NULL
	goldmenu.cvarIncrementDecimal = 0 -- decimal part of increment..

	goldmenu.pressed = {} -- pressed buttons.

	-- previous button actions. maybe should go into goldmenu.pressed.prev.*?
	goldmenu.prevangleturn = player.cmd.angleturn
	goldmenu.prevaiming = player.cmd.aiming

	goldmenu.binds = {} -- binds buttons to menu actions.

	-- register keybinds.
	for menuBind, control in ipairs(gmconf.defaultBinds) do
		goldmenu.binds[menuBind] = control
	end

	// a wrapper for checking if a bind is pressed
	goldmenu.bindPressed = {}
	setmetatable(goldmenu.bindPressed, {__index = function(t, k) return goldmenu.pressed[goldmenu.binds[k]] end})

	-- menus; the last item is the current menu.
	-- array'd because we might want to draw over another menu!
	goldmenu.menus = {gmdata.menu} -- automatically load the main menu
	goldmenu.menudata = {}
	table.insert(goldmenu.menudata, gmvars.newMenuData())

	goldmenu.curMenu = #goldmenu.menus

	return goldmenu
end

function gmvars.pushMenu(goldmenu, newMenu)
	local menu = goldmenu.menus[goldmenu.curMenu]
	local menudata = goldmenu.menudata[goldmenu.curMenu]

	local curMenu = goldmenu.curMenu
	local newCurMenu = curMenu + 1

	local alreadyInited = goldmenu.menus[newCurMenu] == newMenu

	goldmenu.curMenu = newCurMenu

	if not alreadyInited then
		goldmenu.menus[newCurMenu] = newMenu
		goldmenu.menudata[newCurMenu] = gmvars.newMenuData()
	end

	menu = goldmenu.menus[newCurMenu]
	menudata = goldmenu.menudata[newCurMenu]

	if not alreadyInited then
		menu.style.init(menudata, menu)
	end

	menu.open = true
	menu.style.menuToggle(menu.open, menudata, menu)

	return menu, menudata
end

function gmvars.popMenu(goldmenu)
	local menu = goldmenu.menus[goldmenu.curMenu]
	local menudata = goldmenu.menudata[goldmenu.curMenu]

	local curMenu = goldmenu.curMenu
	local newCurMenu = curMenu - 1

	menu.open = false
	menu.style.menuToggle(menu.open, menudata, menu)

	goldmenu.curMenu = newCurMenu

	menu = goldmenu.menus[newCurMenu]
	menudata = goldmenu.menudata[newCurMenu]

	return menu, menudata
end

return gmvars
