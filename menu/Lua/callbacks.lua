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

	menudata.cursorPos = 1 -- selected item.
	menudata.prevCursorPos = 1 -- previously selected item. perserved between tics.

	-- transitioning vars.
	menudata.fadeStrength = 0
	menudata.fadeProgress = 0

	return menudata
end

function gmcallbacks.menuInit(player)
	player.goldmenu = {}

	local goldmenu = player.goldmenu

	goldmenu.open = false -- are we open?????????
	goldmenu.heldControlLock = 0 -- Locks the controls while one is held.

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
end

function gmcallbacks.doMenu(player)
	local goldmenu = player.goldmenu

	-- determine if the open bind has been pressed.
	local openPressed = gmcontrols.menuBindPressed(goldmenu, gmconst.menuBind.open)

	-- has it been pressed for < 1 tic?
	if openPressed == 1 then
		goldmenu.open = not $ -- toggle menu
		goldmenu.menus[goldmenu.curMenu].open = true
	end

	for i, menu in ipairs(goldmenu.menus) do
		local activeMenu = i == goldmenu.curMenu

		local menudata = goldmenu.menudata[i]
		local curItem = menu.items[menudata.cursorPos]

		-- start (or continue) fading in if open; start (or continue) fading out if closed.
		-- this makes it so spamming open will not do funky fade snapping.
		if goldmenu.open then
			menudata.fadeProgress = ($ < FRACUNIT) and $ + gmconf.fadeSpeed or $
			menudata.fadeProgress = ($ > FRACUNIT) and FRACUNIT or $
		else
			menudata.fadeProgress = ($ < 0) and $ or $ - gmconf.fadeSpeed
			menudata.fadeProgress = ($ > 0) and $ or 0
		end

		if goldmenu.open and activeMenu then
			local upTics = gmcontrols.menuBindPressed(goldmenu, gmconst.menuBind.up)
			local downTics = gmcontrols.menuBindPressed(goldmenu, gmconst.menuBind.down)

			local selectTics = gmcontrols.menuBindPressed(goldmenu, gmconst.menuBind.select)
			local backTics = gmcontrols.menuBindPressed(goldmenu, gmconst.menuBind.back)

			if upTics == 1 or (upTics > gmconf.holdWait and (leveltime % gmconf.ticsBetweenHoldAdvance) == 0) then
				menudata.prevCursorPos = menudata.cursorPos

				if menudata.cursorPos <= 1 then
					menu.style.moveCursorFailed(menudata, menudata.cursorPos - 1)
				else
					menudata.cursorPos = $ - 1
					menu.style.moveCursor(menudata, menudata.cursorPos)
				end
			end

			if downTics == 1 or (downTics > gmconf.holdWait and (leveltime % gmconf.ticsBetweenHoldAdvance) == 0) then
				menudata.prevCursorPos = menudata.cursorPos

				if menudata.cursorPos >= #menu.items then
					menu.style.moveCursorFailed(menudata, menudata.cursorPos + 1)
				else
					menudata.cursorPos = $ + 1
					menu.style.moveCursor(menudata, menudata.cursorPos)
				end
			end

			if selectTics == 1 and curItem
			and curItem.flags == gmconst.itemFlag.subMenu and type(curItem.data) == "table" then
				local curMenu = goldmenu.curMenu
				local newCurMenu = curMenu + 1

				local alreadyInited = goldmenu.menus[newCurMenu] == curItem.data

				goldmenu.curMenu = newCurMenu

				if not alreadyInited then
					goldmenu.menus[newCurMenu] = curItem.data
					goldmenu.menudata[newCurMenu] = initMenuData()
				end

				menu = goldmenu.menus[newCurMenu]
				menudata = goldmenu.menudata[newCurMenu]

				if not alreadyInited then
					menudata.fadeStrength = goldmenu.menudata[curMenu].fadeStrength
					menudata.fadeProgress = goldmenu.menudata[curMenu].fadeProgress
					menudata.transparency = goldmenu.menudata[curMenu].transparency

					menu.style.init(menudata, menu)
				end

				if menu.style.drawMenusBelow then
					menudata.fadeStrength = 0
					menudata.fadeProgress = 0
					menudata.transparency = 0
				end
			end

			if backTics == 1 then
				if goldmenu.curMenu > 1
					local curMenu = goldmenu.curMenu
					local newCurMenu = curMenu - 1

					goldmenu.curMenu = newCurMenu

					menu = goldmenu.menus[newCurMenu]
					menudata = goldmenu.menudata[newCurMenu]
				else
					goldmenu.open = not $
					goldmenu.heldControlLock = goldmenu.binds[gmconst.menuBind.back]
				end
			end
		end

		-- fade strength used by menu drawers.
		menudata.fadeStrength = gmutil.fixedLerp(0, gmconf.maxFadeStrength, menudata.fadeProgress)
		menudata.transparency = gmutil.fixedLerp(0, 10, FRACUNIT - menudata.fadeProgress) << FF_TRANSSHIFT

		menu.style.update(menudata, menu, player)
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

	local lowestMenuToDraw = goldmenu.curMenu

	for i = goldmenu.curMenu, 1, -1 do
		local menu = goldmenu.menus[i]

		if not menu.style.drawMenusBelow then
			break
		end

		lowestMenuToDraw = $ - 1
	end

	v.fadeScreen(0xFA00, goldmenu.menudata[1].fadeStrength)

	for i = lowestMenuToDraw, goldmenu.curMenu do			
		local menudata = goldmenu.menudata[i]
		local menu = goldmenu.menus[i]

		local strFlags = V_ALLOWLOWERCASE|menudata.transparency
		local patchFlags = menudata.transparency

		if gmdebug then
			v.drawString(0, 200 - 8, menudata.fadeStrength, strFlags)

			for i = 1, gmconst.control.maxAttainable do
				local iv = goldmenu.pressed[i]

				if iv == nil then
					continue
				end

				v.drawString(0, (i - 1) * 4, gmconst.controlToString[i] or "???", strFlags, "small")
				v.drawString(80, (i - 1) * 4, iv, strFlags, "small-right")
			end
		end

		menu.style.drawer(v, menudata, menu, gmconf)
	end
end

return gmcallbacks