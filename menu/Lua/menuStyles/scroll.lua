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

function scroll.init(menudata, menu)
	menudata.scrollFrac = menu.cursorPos * FRACUNIT
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

		menudata.scrollFrac = newItem * FRACUNIT + (offsetAmount * sign)
	end
end

function scroll.update(menudata, menu, gmconf)
	-- scroll and transition amount
	menudata.scrollFrac = $ + FixedMul((menu.cursorPos * FRACUNIT) - $, config.scrollSpeed)
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

	if not menudata.fadeProgress then
		return false -- pop menu!
	end
end

local function drawMenuTitle(v, config, menu, gmconf, strFlags)
	v.drawString(160, config.titleY, menu.name, gmconf.selectionColor|strFlags, config.titleFont)
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

	local lerpwidth = gmutil.fixedLerp(width1*FRACUNIT, width2*FRACUNIT, menudata.transitionFrac)
	lerpwidth = ($ + FRACUNIT/2) / FRACUNIT -- round nicely

	local cursorY = 100 - cursor.height/2

	v.draw(160 - lerpwidth/2 - config.cursorSpacing - cursor.width/2, cursorY, cursor, patchFlags)
	v.draw(160 + lerpwidth/2 + config.cursorSpacing - cursor.width/2, cursorY, cursor, patchFlags)

	for i, item in ipairs(menu.items) do
		local line = item.text

		local y = 100 * FRACUNIT
		y = $ + (i * config.lineSize) * FRACUNIT -- place all other lines below the first one.
		y = $ - (menudata.scrollFrac * config.lineSize) -- offset by the scroll amount * the line size

		local menuOccludeRate = FixedDiv(180*FRACUNIT, config.fractionMenuOpaque)
		local transparency = FixedMul((y - 100*FRACUNIT) / 200, menuOccludeRate)

		y = $ - 4*FRACUNIT -- text height
		y = ($ + FRACUNIT/2) / FRACUNIT -- round nicely

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

		if i == menu.cursorPos then
			localStrFlags = ($ & ~V_CHARCOLORMASK) | gmconf.selectionColor
		end

		v.drawString(160, y, line, localStrFlags, config.fontAligned)
	end

	drawMenuTitle(v, config, menu, gmconf, strFlags)

	//v.drawFill(0, 100, 320, 1, 24)
end

return scroll