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

	player.goldmenu.open = false -- are we open?????????

	player.goldmenu.pressed = {} -- pressed buttons.

	-- previous button actions. maybe should go into player.goldmenu.pressed.prev.*?
	player.goldmenu.prevangleturn = player.cmd.angleturn
	player.goldmenu.prevaiming = player.cmd.aiming

	player.goldmenu.binds = {} -- binds buttons to menu actions.

	-- register keybinds.
	for menuBind, control in pairs(gmconf.defaultBinds) do
		player.goldmenu.binds[menuBind] = control
	end

	-- menus; the last item is the current menu.
	-- array'd because we might want to draw over another menu!
	player.goldmenu.menus = {gmdata.menu} -- automatically load the main menu
	player.goldmenu.menudata = {}
	table.insert(player.goldmenu.menudata, initMenuData())

	local menu = table.last(player.goldmenu.menus)
	local menudata = table.last(player.goldmenu.menudata)

	menu.style.init(menudata, menu)
end

function gmcallbacks.doMenu(player)
	-- determine if the open bind has been pressed.
	local openPressed = gmcontrols.menuBindPressed(player.goldmenu, gmconst.menuBind.open)

	-- has it been pressed for < 1 tic?
	if openPressed == 1 then
		player.goldmenu.open = not $ -- toggle menu
	end

	local menu = table.last(player.goldmenu.menus)
	local menudata = table.last(player.goldmenu.menudata)
	local curItem = menu.items[menudata.cursorPos]

	-- start (or continue) fading in if open; start (or continue) fading out if closed.
	-- this makes it so spamming open will not do funky fade snapping.
	if player.goldmenu.open then
		menudata.fadeProgress = ($ < FRACUNIT) and $ + gmconf.fadeSpeed or $
		menudata.fadeProgress = ($ > FRACUNIT) and FRACUNIT or $
	else
		menudata.fadeProgress = ($ < 0) and $ or $ - gmconf.fadeSpeed
		menudata.fadeProgress = ($ > 0) and $ or 0
	end

	if player.goldmenu.open then
		local upTics = gmcontrols.menuBindPressed(player.goldmenu, gmconst.menuBind.up)
		local downTics = gmcontrols.menuBindPressed(player.goldmenu, gmconst.menuBind.down)

		local selectTics = gmcontrols.menuBindPressed(player.goldmenu, gmconst.menuBind.select)
		local backTics = gmcontrols.menuBindPressed(player.goldmenu, gmconst.menuBind.back)

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

		if selectTics == 1 and curItem.flags == gmconst.itemFlag.subMenu and type(curItem.data) == "table" then
			local fadeStrength = menudata.fadeStrength
			local fadeProgress = menudata.fadeProgress
			local transparency = menudata.transparency

			table.insert(player.goldmenu.menus, curItem.data)
			table.insert(player.goldmenu.menudata, initMenuData())

			menu = table.last(player.goldmenu.menus)
			menudata = table.last(player.goldmenu.menudata)

			menudata.fadeStrength = fadeStrength
			menudata.fadeProgress = fadeProgress
			menudata.transparency = transparency

			menu.style.init(menudata, menu)
		end

		if backTics == 1 and #player.goldmenu.menus > 1 then
			local fadeStrength = menudata.fadeStrength
			local fadeProgress = menudata.fadeProgress
			local transparency = menudata.transparency

			table.remove(player.goldmenu.menus)
			table.remove(player.goldmenu.menudata)

			menudata.fadeStrength = fadeStrength
			menudata.fadeProgress = fadeProgress
			menudata.transparency = transparency
		end
	end

	-- fade strength used by menu drawers.
	menudata.fadeStrength = gmutil.fixedLerp(0, gmconf.maxFadeStrength, menudata.fadeProgress)
	menudata.transparency = gmutil.fixedLerp(0, 10, FRACUNIT - menudata.fadeProgress) << FF_TRANSSHIFT

	menu.style.update(menudata, menu, player)
end

function gmcallbacks.onControlsGet(player)
	gmcontrols.getMenuControls(player)

	local cmd = player.cmd

	if player.goldmenu.open then
		cmd.buttons = 0
		cmd.forwardmove = 0
		cmd.sidemove = 0

		cmd.angleturn = player.goldmenu.prevangleturn
		cmd.aiming = player.goldmenu.prevaiming

		player.mo.angle = player.goldmenu.prevangleturn << 16
		player.aiming = player.goldmenu.prevaiming << 16
	end

	player.goldmenu.prevangleturn = cmd.angleturn
	player.goldmenu.prevaiming = cmd.aiming
end

-- draw stuff

function gmcallbacks.drawMenu(v, player)
	local menudata = table.last(player.goldmenu.menudata)
	local menu = table.last(player.goldmenu.menus)

	v.fadeScreen(0xFA00, menudata.fadeStrength)

	local strFlags = V_ALLOWLOWERCASE|menudata.transparency
	local patchFlags = menudata.transparency

	if gmdebug then
		v.drawString(0, 200 - 8, menudata.fadeStrength, strFlags)

		for i = 1, gmconst.control.maxAttainable do
			local iv = player.goldmenu.pressed[i]

			if iv == nil then
				continue
			end

			v.drawString(0, (i - 1) * 4, gmconst.controlToString[i] or "???", strFlags, "small")
			v.drawString(80, (i - 1) * 4, iv, strFlags, "small-right")
		end
	end

	menu.style.drawer(v, menudata, menu, gmconf)
end

return gmcallbacks