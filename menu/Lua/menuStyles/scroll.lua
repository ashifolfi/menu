local scroll = {}

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

function scroll.init(menudata)
	menudata.scrollFrac = FRACUNIT
	menudata.transitionFrac = FRACUNIT
end

function scroll.moveCursor(menudata, newItem)
	menudata.transitionFrac = 0
end

function scroll.moveCursorFailed(menudata, itemTried)
	local sign = menudata.cursorPos - itemTried
	local offsetAmount = FRACUNIT/2

	menudata.transitionFrac = 0
	menudata.scrollFrac = itemTried * FRACUNIT + (offsetAmount * sign)
end

function scroll.update(menudata)
	-- scroll and transition amount
	menudata.scrollFrac = $ + FixedMul((menudata.cursorPos * FRACUNIT) - $, config.scrollSpeed)
	menudata.transitionFrac = $ + FixedMul(FRACUNIT - $, config.scrollSpeed)
end

function scroll.drawer(v, menudata, menu, gmconf)
	local strFlags = V_ALLOWLOWERCASE|menudata.transparency
	local patchFlags = menudata.transparency

	local cursor = v.cachePatch(config.cursor)
	local cursorWidth = cursor.width

	local cursorPercentage = menudata.transitionFrac

	if not menu.items[menudata.cursorPos] then
		v.drawString(160, 100 - 4, string.format("ERROR: Cannot access menu, item %d", menudata.cursorPos), strFlags, config.fontAligned)
		return
	end

	local width1 = v.stringWidth(menu.items[menudata.prevCursorPos].text or "", strFlags, config.font)
	local width2 = v.stringWidth(menu.items[menudata.cursorPos].text or "", strFlags, config.font)

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

		if i == menudata.cursorPos then
			localStrFlags = ($ & ~V_CHARCOLORMASK) | gmconf.selectionColor
		end

		v.drawString(160, y, line, localStrFlags, config.fontAligned)
	end

	v.drawString(160, config.titleY, menu.name, gmconf.selectionColor|strFlags, config.titleFont)

	//v.drawFill(0, 100, 320, 1, 24)
end

return scroll