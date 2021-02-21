local gmcallbacks = {}

local gmdebug = lua_require("debug")

local gmcontrols = lua_require("controls")
local gmconf = lua_require("conf")
local gmconst = lua_require("const")
local gmutil = lua_require("util")
local gmdata = lua_require("data")
local gmstyles = lua_require("styles")

-- logic and stuff

local function initMenuData()
	local menudata = {}

	return menudata
end

function gmcallbacks.menuInit(player)
	player.goldmenu = {}

	local goldmenu = player.goldmenu

	goldmenu.open = false -- are we open?????????
	goldmenu.heldControlLock = 0 -- Locks the controls while one is held.

	-- background fading vars.
	goldmenu.fadeStrength = 0
	goldmenu.fadeProgress = 0
	goldmenu.transparency = 0

	goldmenu.pressed = {} -- pressed buttons.

	-- previous button actions. maybe should go into goldmenu.pressed.prev.*?
	goldmenu.prevangleturn = player.cmd.angleturn
	goldmenu.prevaiming = player.cmd.aiming

	goldmenu.binds = {} -- binds buttons to menu actions.

	-- register keybinds.
	for menuBind, control in pairs(gmconf.defaultBinds) do
		goldmenu.binds[menuBind] = control
	end

	-- menus; the last item is the current menu.
	-- array'd because we might want to draw over another menu!
	goldmenu.menus = {gmdata.menu} -- automatically load the main menu
	goldmenu.menudata = {}
	table.insert(goldmenu.menudata, initMenuData())

	goldmenu.curMenu = #goldmenu.menus

	local menu = goldmenu.menus[goldmenu.curMenu]
	local menudata = goldmenu.menudata[goldmenu.curMenu]

	menu.style.init(menudata, menu)
	menu.open = true
end

local function setMenuOpen(open, menu, menudata)
	menu.open = open
	menu.style.menuToggle(menu.open, menudata, menu)
end

local function pushMenu(goldmenu, newMenu)
	local menu = goldmenu.menus[goldmenu.curMenu]
	local menudata = goldmenu.menudata[goldmenu.curMenu]

	local curMenu = goldmenu.curMenu
	local newCurMenu = curMenu + 1

	local alreadyInited = goldmenu.menus[newCurMenu] == newMenu

	goldmenu.curMenu = newCurMenu

	if not alreadyInited then
		goldmenu.menus[newCurMenu] = newMenu
		goldmenu.menudata[newCurMenu] = initMenuData()
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

local function popMenu(goldmenu)
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

local function singleMenuThink(i, goldmenu, player)
	-- determine if the open bind has been pressed.
	local openPressed = gmcontrols.menuBindPressed(goldmenu, gmconst.menuBind.open)
	local activeMenu = i == goldmenu.curMenu

	local menu = goldmenu.menus[i]
	local menudata = goldmenu.menudata[i]

	local curItem = menu.items[menu.cursorPos]

	-- start (or continue) fading in if open; start (or continue) fading out if closed.
	-- this makes it so spamming open will not do funky fade snapping.
	if goldmenu.open then
		goldmenu.fadeProgress = ($ < FRACUNIT) and $ + gmconf.fadeSpeed or $
		goldmenu.fadeProgress = ($ > FRACUNIT) and FRACUNIT or $
	else
		goldmenu.fadeProgress = ($ < 0) and $ or $ - gmconf.fadeSpeed
		goldmenu.fadeProgress = ($ > 0) and $ or 0
	end

	if openPressed == 1 and i <= goldmenu.curMenu then
		menu.style.menuToggle(goldmenu.open, menudata, menu)
	end

	if goldmenu.open and activeMenu then
		local upTics = gmcontrols.menuBindPressed(goldmenu, gmconst.menuBind.up)
		local downTics = gmcontrols.menuBindPressed(goldmenu, gmconst.menuBind.down)

		local selectTics = gmcontrols.menuBindPressed(goldmenu, gmconst.menuBind.select)
		local backTics = gmcontrols.menuBindPressed(goldmenu, gmconst.menuBind.back)

		if upTics == 1 or (upTics > gmconf.holdWait and (leveltime % gmconf.ticsBetweenHoldAdvance) == 0) then
			menu.prevCursorPos = menu.cursorPos

			if menu.cursorPos <= 1 then
				menu.style.moveCursor(false, menu.cursorPos - 1, menudata, menu)
			else
				menu.cursorPos = $ - 1
				menu.style.moveCursor(true, menu.cursorPos, menudata, menu)
			end
		end

		if downTics == 1 or (downTics > gmconf.holdWait and (leveltime % gmconf.ticsBetweenHoldAdvance) == 0) then
			menu.prevCursorPos = menu.cursorPos

			if menu.cursorPos >= #menu.items then
				menu.style.moveCursor(false, menu.cursorPos + 1, menudata, menu)
			else
				menu.cursorPos = $ + 1
				menu.style.moveCursor(true, menu.cursorPos, menudata, menu)
			end
		end

		if selectTics == 1 and curItem and curItem.flags == gmconst.itemFlag.subMenu and type(curItem.data) == "table" then
			pushMenu(goldmenu, curItem.data)
		end

		if backTics == 1 then
			if goldmenu.curMenu > 1 then
				popMenu(goldmenu)
			else
				goldmenu.open = not $
				goldmenu.heldControlLock = goldmenu.binds[gmconst.menuBind.back]

				menu.style.menuToggle(goldmenu.open, menudata, menu)
			end
		end
	end

	-- fade strength used by menu drawers.
	goldmenu.fadeStrength = gmutil.fixedLerp(0, gmconf.maxFadeStrength, goldmenu.fadeProgress)
	goldmenu.transparency = gmutil.fixedLerp(0, 10, FRACUNIT - goldmenu.fadeProgress) << FF_TRANSSHIFT

	menu.style.update(menudata, menu, gmconf, player)
end

function gmcallbacks.doMenu(player)
	local goldmenu = player.goldmenu

	-- determine if the open bind has been pressed.
	local openPressed = gmcontrols.menuBindPressed(goldmenu, gmconst.menuBind.open)

	-- has it been pressed for < 1 tic?
	if openPressed == 1 then
		goldmenu.open = not $ -- toggle menu
	end

	for i, menu in ipairs(goldmenu.menus) do
		singleMenuThink(i, goldmenu, player)
	end
end

function gmcallbacks.onControlsGet(player)
	local goldmenu = player.goldmenu

	gmcontrols.getMenuControls(player)

	local cmd = player.cmd

	if goldmenu.heldControlLock then
		if not goldmenu.pressed[goldmenu.heldControlLock] then
			goldmenu.heldControlLock = 0
		end
	end

	if goldmenu.open or goldmenu.heldControlLock then
		cmd.buttons = 0
		cmd.forwardmove = 0
		cmd.sidemove = 0

		cmd.angleturn = goldmenu.prevangleturn
		cmd.aiming = goldmenu.prevaiming

		player.mo.angle = goldmenu.prevangleturn << 16
		player.aiming = goldmenu.prevaiming << 16
	end

	goldmenu.prevangleturn = cmd.angleturn
	goldmenu.prevaiming = cmd.aiming
end

-- draw stuff

function gmcallbacks.drawMenu(v, player)
	local goldmenu = player.goldmenu

	if goldmenu.fadeProgress == 0 then
		return
	end

	local lowestMenuToDraw = goldmenu.curMenu

	for i = #goldmenu.menus, 1, -1 do
		local menu = goldmenu.menus[i]

		if not menu.style.drawMenusBelow then
			break
		end

		lowestMenuToDraw = $ - 1
	end

	v.fadeScreen(0xFA00, goldmenu.fadeStrength)

	for i = lowestMenuToDraw, #goldmenu.menus do
		local menudata = goldmenu.menudata[i]
		local menu = goldmenu.menus[i]

		if not menu or not menudata then
			continue
		end

		local strFlags = V_ALLOWLOWERCASE|goldmenu.transparency
		local patchFlags = goldmenu.transparency

		if gmdebug then
			v.drawString(0, 200 - 8, goldmenu.fadeStrength, strFlags)

			for i = 1, gmconst.control.maxAttainable do
				local iv = goldmenu.pressed[i]

				if iv == nil then
					continue
				end

				v.drawString(0, (i - 1) * 4, gmconst.controlToString[i] or "???", strFlags, "small")
				v.drawString(80, (i - 1) * 4, iv, strFlags, "small-right")
			end
		end

		if menu.open or menu.style.drawMenusBelow then
			menu.style.drawer(v, menudata, menu, gmconf)
		end
	end
end

return gmcallbacks