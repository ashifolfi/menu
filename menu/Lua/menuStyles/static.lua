local static = {}

-- Config for use by menu.lua
static.drawMenusBelow = true

local gmutil = lua_require("util")

local config = {
	x = 32,
	y = 48,

	titleY = 12,

	cursorSpacing = 4,
	lineSpacing = 12,
	font = "left",
	titleFont = "center",

	cursor = "M_CURSOR"
}

config.fontAligned = (#config.font and config.font ~= "normal") and (config.font .. "-center") or "center"
config.font = #$ and $ or "normal"

function static.init(menudata)
	-- fading vars.
	menudata.fadeStrength = 0
	menudata.fadeProgress = 0
	menudata.transparency = 0
end

function static.menuToggle(toggleState, menudata, menu)
	menudata.open = toggleState
end

function static.update(menudata, menu, gmconf)
	-- start (or continue) fading in if open; start (or continue) fading out if closed.
	-- this makes it so spamming open will not do funky fade snapping.
	if menudata.open then
		menudata.fadeProgress = ($ < FRACUNIT) and $ + gmconf.fadeSpeed or $
		menudata.fadeProgress = ($ > FRACUNIT) and FRACUNIT or $
	else
		menudata.fadeProgress = ($ < 0) and $ or $ - gmconf.fadeSpeed
		menudata.fadeProgress = ($ > 0) and $ or 0
	end

	-- fade strength used by menu drawers.
	menudata.fadeStrength = gmutil.fixedLerp(0, gmconf.maxFadeStrength, menudata.fadeProgress)
	menudata.transparency = gmutil.fixedLerp(0, 10, FRACUNIT - menudata.fadeProgress) << FF_TRANSSHIFT
end

function static.drawer(v, menudata, menu, gmconf)
	local strFlags = V_ALLOWLOWERCASE|menudata.transparency
	local patchFlags = menudata.transparency

	local cursor = v.cachePatch(config.cursor)
	local cursorWidth = cursor.width

	local cursorY = config.y + menu.cursorPos * config.lineSpacing

	v.draw(config.x - cursorWidth - config.cursorSpacing, cursorY, cursor, patchFlags)

	for i, item in ipairs(menu.items) do
		local line = item.text

		local localStrFlags = (strFlags & ~V_ALPHAMASK) | menudata.transparency

		if i == menu.cursorPos then
			localStrFlags = ($ & ~V_CHARCOLORMASK) | gmconf.selectionColor
		end

		v.drawString(config.x, config.y + i * config.lineSpacing, line, localStrFlags, config.font)
	end

	v.drawString(160, config.titleY, menu.name, gmconf.selectionColor|strFlags, config.titleFont)

	//v.drawFill(0, 100, 320, 1, 24)
end

return static