/*
	Modified scroll menu

	Styled after the "indev-menu" in devetopment
*/

local scroll = {}

-- Config for use by menu.lua
scroll.drawMenusBelow = false

local gmutil = lua_require("util")

local config = {
	scrollSpeed = 1*FRACUNIT/3,
	fractionMenuOpaque = 3*FRACUNIT/4,

	titleY = 12,

	lineSize = 50,
	cursorSpacing = 12,

	titleFont = "center",
	font = "normal",
	cursor = "M_CURSOR"
}

config.fontAligned = (#config.font and config.font ~= "normal") and (config.font .. "-center") or "center"
config.font = #$ and $ or "normal"

local menuItemHeights = {
	[GM_ITEMTYPE_SLIDER] = 2
}

local function getScrollFactor(menu, index)
	local scrollFactor = 0

	index = $ or menu.cursorPos

	local lastScrollFactor = 0

	for i = 1, index do
		local item = menu.items[i]

		scrollFactor = $ + lastScrollFactor
		lastScrollFactor = ((menuItemHeights[item.type] or 1) * FRACUNIT)
	end

	scrollFactor = $ + lastScrollFactor/2

	return scrollFactor
end

function scroll.init(menudata, menu)
	menudata.scrollFrac = getScrollFactor(menu)
	menudata.transitionFrac = FRACUNIT

	-- Select animation vars
	menudata.selectPosition = 0

	-- fading vars.
	menudata.fadeStrength = 0
	menudata.fadeProgress = 0
	menudata.transparency = 0
	menudata.transHalf = 0
end

function scroll.menuToggle(toggleState, menudata, menu)
	menudata.open = toggleState

	print(
		string.format(
			"Goldmenu: %s, Actual menu: %s",
			toggleState and "true" or "false",
			menu.open and "true" or "false"
		)
	)
end

function scroll.moveCursor(success, newItem, menudata, menu)
	menudata.transitionFrac = 0

	if not success then
		local sign = menu.cursorPos - newItem
		local offsetAmount = FRACUNIT/2
		local scrollFactor = getScrollFactor(menu)

		menudata.scrollFrac = scrollFactor - (sign * FRACUNIT) + (offsetAmount * sign)
	end
	menudata.selectPosition = 0
end

function scroll.update(menudata, menu, gmconf)
	local scrollFactor = getScrollFactor(menu)

	-- scroll and transition amount
	menudata.scrollFrac = $ + FixedMul(scrollFactor - $, config.scrollSpeed)
	menudata.transitionFrac = $ + FixedMul(FRACUNIT - $, config.scrollSpeed)

	-- start (or continue) selected item animation.
	if (menudata.selectPosition != 5) then
		if (leveltime & 2 == 0) then
			menudata.selectPosition = $ + 1
		end
	end

	-- start (or continue) fading in if open; start (or continue) fading out if closed.
	-- this makes it so spamming open will not do funky fade snapping.
	if menudata.open then
		menudata.fadeProgress = ($ < FRACUNIT) and $ + gmconf.fadeSpeed or $
		menudata.fadeProgress = ($ > FRACUNIT) and FRACUNIT or $
	else
		if not menu.open then -- in submenu and not exiting full menu? set to 0
			menudata.fadeProgress = 0
		else -- otherwise fade!
			menudata.fadeProgress = ($ < 0) and $ or $ - gmconf.fadeSpeed
			menudata.fadeProgress = ($ > 0) and $ or 0
		end
	end

	-- fade strength used by menu drawers.
	menudata.fadeStrength = gmutil.fixedLerp(0, gmconf.maxFadeStrength, menudata.fadeProgress)
	menudata.transparency = gmutil.fixedLerp(0, 10, FRACUNIT - menudata.fadeProgress) << FF_TRANSSHIFT
	menudata.transHalf = gmutil.fixedLerp(5, 10, FRACUNIT - menudata.fadeProgress) << FF_TRANSSHIFT

	menudata.cvarBounds = $ or {}

	for i, item in ipairs(menu.items) do
		menudata.cvarBounds[i] = $ or {}

		if item.type == GM_ITEMTYPE_SLIDER then
			menudata.cvarBounds[i].min, menudata.cvarBounds[i].max = gmutil.getCvarBounds(item.data)
		end
	end

	if not menudata.fadeProgress then
		return false -- pop menu!
	end
end

local function drawMenuTitle(v, config, menu, gmconf, strFlags)
	v.drawString(160, config.titleY, menu.name, gmconf.selectionColor|strFlags, config.titleFont)
end

local menuItemDrawers = {
	[GM_ITEMTYPE_NONE] = function(v, y, line, menudata, item, i, localStrFlags, selected)
		-- Blue selected background
		if (selected > 0) then
			v.draw(60-252/2+y, y+5, v.cachePatch("DVSL2"), localStrFlags)
		end
		-- Draw the background piece
		v.draw(60-252/2+y+selected, y, v.cachePatch("DVSL1"), localStrFlags)
		-- Draw with the level title font
		v.drawLevelTitle((60-(v.levelTitleWidth(line)/2))+y+selected, y-6, line, localStrFlags)
	end
}

local function drawMenuItem(flags, ...)
	if not menuItemDrawers[flags] then
		return menuItemDrawers[GM_ITEMTYPE_NONE](...)
	end

	return menuItemDrawers[flags](...)
end

local scrollx = 0
function scroll.drawer(v, menudata, menu, gmconf)
	if (scrollx != 417) then
		scrollx = $ + 1
	else
		scrollx = 0
	end

	-- Draw the menu background
	-- top zigzag
	v.draw(scrollx,0,v.cachePatch("DVBG2"), V_SNAPTOTOP)
	v.draw(scrollx,0,v.cachePatch("DVBG1"), V_SNAPTOTOP)
	v.draw(scrollx-417,0,v.cachePatch("DVBG2"), V_SNAPTOTOP)
	v.draw(scrollx-417,0,v.cachePatch("DVBG1"), V_SNAPTOTOP)

	-- bottom zigzag
	v.draw(-scrollx,200-23,v.cachePatch("DVBG3"), V_SNAPTOBOTTOM)
	v.draw(-scrollx,200-23,v.cachePatch("DVBG4"), V_SNAPTOBOTTOM)
	v.draw(-scrollx+417,200-23,v.cachePatch("DVBG3"), V_SNAPTOBOTTOM)
	v.draw(-scrollx+417,200-23,v.cachePatch("DVBG4"), V_SNAPTOBOTTOM)

	if not #menu.items then
		v.drawString(160, 100 - 4, "Menu is empty.", 0, config.fontAligned)
		drawMenuTitle(v, config, menu, gmconf, 0)
		return
	end

	if not menu.items[menu.cursorPos] then
		v.drawString(160, 100 - 4, string.format("ERROR: Cannot access menu, item %d", menu.cursorPos), 0, config.fontAligned)
		drawMenuTitle(v, config, menu, gmconf, 0)
		return
	end

	-- offset by the scroll amount * the line size
	local y = 100 * FRACUNIT - (menudata.scrollFrac * config.lineSize)
	y = $ - 4*FRACUNIT -- text height

	for i, item in ipairs(menu.items) do
		local line = item.text

		local heightMul = menuItemHeights[item.type] or 1

		y = $ + (heightMul * config.lineSize * FRACUNIT) / 2 -- move y position half a line

		local realY = (y + FRACUNIT/2) / FRACUNIT -- round nicely

		y = $ + (heightMul * config.lineSize * FRACUNIT) / 2 -- move y position other half of line

		if i == menu.cursorPos then
			drawMenuItem(item.type, v, realY-menudata.selectPosition, line, menudata, item, i, 0, menudata.selectPosition)
		else
			drawMenuItem(item.type, v, realY, line, menudata, item, i, 0, 0)
		end
	end

	drawMenuTitle(v, config, menu, gmconf, 0)
end

return scroll