local scroll = {}

-- Config for use by menu.lua
scroll.drawMenusBelow = false

local gmutil = lua_require("util")

local config = {
	scrollSpeed = 1*FRACUNIT/3,
	fractionMenuOpaque = 3*FRACUNIT/4,

	titleY = 12,

	lineSize = 14,
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
end

function scroll.update(menudata, menu, gmconf)
	local scrollFactor = getScrollFactor(menu)

	-- scroll and transition amount
	menudata.scrollFrac = $ + FixedMul(scrollFactor - $, config.scrollSpeed)
	menudata.transitionFrac = $ + FixedMul(FRACUNIT - $, config.scrollSpeed)

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
	[GM_ITEMTYPE_NONE] = function(v, y, line, menudata, item, i, localStrFlags)
		v.drawString(160, y, line, localStrFlags, config.fontAligned)
	end,

	[GM_ITEMTYPE_SLIDER] = function(v, y, line, menudata, item, i, localStrFlags, transparency)
		v.drawString(160, y - config.lineSize / 2, line, localStrFlags, config.fontAligned)
		//v.drawString(160, y + config.lineSize / 2, line, localStrFlags, config.fontAligned)

		local newY = y + config.lineSize / 2

		local left = v.cachePatch("M_SLIDEL")
		local mid = v.cachePatch("M_SLIDEM")
		local right = v.cachePatch("M_SLIDER")

		local halfMidPieces = 8

		v.draw(160 - (halfMidPieces) * mid.width - left.width - 2, newY, left, transparency)

		for ii = -halfMidPieces + 1, halfMidPieces do
			v.draw(160 - ii * mid.width, newY, mid, transparency)
		end

		v.draw(160 + (halfMidPieces - 1) * mid.width + right.width + 2, newY, right, transparency)

		local slider = v.cachePatch("M_SLIDEC")
		local sliderBoundsMath = (halfMidPieces * mid.width) + slider.width

		local cvar_min, cvar_max = menudata.cvarBounds[i].min, menudata.cvarBounds[i].max
		local cvar = item.data

		local sliderPercentage = 0

		if cvar_max - cvar_min then
			sliderPercentage = FixedDiv(cvar.value - cvar_min, cvar_max - cvar_min)
		end

		local sliderPos = gmutil.fixedLerp(160 - sliderBoundsMath, 160 + sliderBoundsMath, sliderPercentage)

		local value = cvar.value

		if cvar.flags & CV_FLOAT then
			value = string.format("%.2f", $)
		else
			value = tostring($)
		end

		v.draw(sliderPos - slider.width/2, newY, slider, transparency)
		v.drawString(160, newY, value, localStrFlags, config.fontAligned)
	end
}

local function drawMenuItem(flags, ...)
	if not menuItemDrawers[flags] then
		return menuItemDrawers[GM_ITEMTYPE_NONE](...)
	end

	return menuItemDrawers[flags](...)
end

function scroll.drawer(v, menudata, menu, gmconf)
	local strFlags = V_ALLOWLOWERCASE|menudata.transparency
	local strFlagsTrans = V_ALLOWLOWERCASE|menudata.transHalf
	local patchFlags = menudata.transparency

	local cursor = v.cachePatch(config.cursor)
	local cursorWidth = cursor.width

	local cursorPercentage = menudata.transitionFrac

	if not #menu.items then
		v.drawString(160, 100 - 4, "Menu is empty.", strFlagsTrans, config.fontAligned)
		drawMenuTitle(v, config, menu, gmconf, strFlags)
		return
	end

	if not menu.items[menu.cursorPos] then
		v.drawString(160, 100 - 4, string.format("ERROR: Cannot access menu, item %d", menu.cursorPos), strFlags, config.fontAligned)
		drawMenuTitle(v, config, menu, gmconf, strFlags)
		return
	end

	local width1 = v.stringWidth(menu.items[menu.prevCursorPos].text or "", strFlags, config.font)
	local width2 = v.stringWidth(menu.items[menu.cursorPos].text or "", strFlags, config.font)

	local heightMul1 = menuItemHeights[menu.items[menu.prevCursorPos].type] or 1
	local heightMul2 = menuItemHeights[menu.items[menu.cursorPos].type] or 1

	local lerpwidth = gmutil.fixedLerp(width1*FRACUNIT, width2*FRACUNIT, menudata.transitionFrac)
	lerpwidth = ($ + FRACUNIT/2) / FRACUNIT -- round nicely

	local lerpY = gmutil.fixedLerp(heightMul1*FRACUNIT, heightMul2*FRACUNIT, menudata.transitionFrac)
	lerpY = ($ + FRACUNIT/2) / FRACUNIT -- round nicely

	local cursorY = 100 - cursor.height/2 - ((lerpY - 1) * config.lineSize/2)

	v.draw(160 - lerpwidth/2 - config.cursorSpacing - cursor.width/2, cursorY, cursor, patchFlags)
	v.draw(160 + lerpwidth/2 + config.cursorSpacing - cursor.width/2, cursorY, cursor, patchFlags)

	-- offset by the scroll amount * the line size
	local y = 100 * FRACUNIT - (menudata.scrollFrac * config.lineSize)
	y = $ - 4*FRACUNIT -- text height

	for i, item in ipairs(menu.items) do
		local line = item.text

		local heightMul = menuItemHeights[item.type] or 1

		y = $ + (heightMul * config.lineSize * FRACUNIT) / 2 -- move y position half a line

		local menuOccludeRate = FixedDiv(180*FRACUNIT, config.fractionMenuOpaque)
		local transparency = FixedMul((y - 100*FRACUNIT) / 200, menuOccludeRate)

		local realY = (y + FRACUNIT/2) / FRACUNIT -- round nicely

		y = $ + (heightMul * config.lineSize * FRACUNIT) / 2 -- move y position other half of line

		-- only make the closest peak opaque!
		if transparency > 90*FRACUNIT
		or transparency < -90*FRACUNIT then
			continue
		end

		transparency = cos(FixedAngle($))

		//transparency = FixedMul($, config.menuOccludeRate)
		transparency = $ * v.height() / (200 * v.dupy())

		transparency = FixedMul($, menudata.fadeProgress) -- fade
		transparency = $ > FRACUNIT and FRACUNIT or $
		transparency = $ > 0 and $ or 0

		transparency = gmutil.fixedLerp(0, 10, FRACUNIT - $) << FF_TRANSSHIFT

		local localStrFlags = (strFlags & ~V_ALPHAMASK) | transparency
		local localPatchFlags = (strFlags & ~V_ALPHAMASK) | transparency

		if i == menu.cursorPos then
			localStrFlags = ($ & ~V_CHARCOLORMASK) | gmconf.selectionColor
		end

		drawMenuItem(item.type, v, realY, line, menudata, item, i, localStrFlags, transparency)
	end

	drawMenuTitle(v, config, menu, gmconf, strFlags, transparency)

	//v.drawFill(0, 100, 320, 1, 24)
end

return scroll