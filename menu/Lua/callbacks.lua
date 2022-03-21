local gmcallbacks = {}

local gmdebug = lua_require("debug")

local gmcontrols = lua_require("controls")
local gmconf = lua_require("conf")
local gmconst = lua_require("const")
local gmutil = lua_require("util")
local gmdata = lua_require("data")
local gmstyles = lua_require("styles")
local gmvars = lua_require("vars")
local gmitemhandlers = lua_require("itemhandlers")

-- logic and stuff

function gmcallbacks.menuInit(player)
	local goldmenu = gmvars.newGoldMenu(player)

	local menu = goldmenu.menus[goldmenu.curMenu]
	local menudata = goldmenu.menudata[goldmenu.curMenu]

	-- Refresh player controls
	gmconst.refreshSysCtrl()
	gmcontrols.plr = player

	menu.style.init(menudata, menu)
	menu.open = true
end

local function singleMenuThink(i, goldmenu, player)
	-- determine if the open bind has been pressed.
	local openPressed = goldmenu.bindPressed[GM_MENUBIND_OPEN]
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
		local upTics = goldmenu.bindPressed[GM_MENUBIND_MOVE.UP]
		local downTics = goldmenu.bindPressed[GM_MENUBIND_MOVE.DOWN]

		local selectTics = goldmenu.bindPressed[GM_MENUBIND_SELECT]
		local backTics = goldmenu.bindPressed[GM_MENUBIND_BACK]

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

		if curItem then
			if gmitemhandlers[curItem.type] then
				gmitemhandlers[curItem.type](goldmenu, curItem, player)
			end
		end

		if backTics == 1 then
			if goldmenu.curMenu > 1 then
				gmvars.popMenu(goldmenu)
			else
				goldmenu.open = not $
				goldmenu.heldControlLock = goldmenu.binds[GM_MENUBIND_BACK]

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
	local openPressed = goldmenu.bindPressed[GM_MENUBIND_OPEN]

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

	-- Check the controls (KeyDown doesn't run every frame of course)
	gmcontrols.checkControls()

	if goldmenu.heldControlLock then
		if not goldmenu.pressed[goldmenu.heldControlLock] then
			goldmenu.heldControlLock = 0
		end
	end
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

	-- Fades in the menu
	v.fadeScreen(0xFA00, goldmenu.fadeStrength)

	-- Draw the lowest level first
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

			/*for i = 1, GM_CONTROL_MAXATTAINABLE do
				local iv = goldmenu.pressed[i]

				if iv == nil then
					continue
				end

				--v.drawString(0, (i - 1) * 4, gmconst.controlToString[i] or "???", strFlags, "small")
				v.drawString(80, (i - 1) * 4, iv, strFlags, "small-right")
			end*/

			for i = 1, GM_MENUBIND_MAX do
				local iv = goldmenu.binds[i]

				if iv == nil then
					continue
				end

				v.drawString(0, (i - 1) * 4, gmconst.menuBindToString[i] or "???", strFlags, "small")
				v.drawString(80, (i - 1) * 4, goldmenu.pressed[iv], strFlags, "small-right")
			end
		end

		if menu.open or menu.style.drawMenusBelow then
			menu.style.drawer(v, menudata, menu, gmconf)
		end
	end
end

return gmcallbacks
