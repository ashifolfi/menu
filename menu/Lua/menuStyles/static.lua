local static = {}

-- Config for use by menu.lua
static.drawMenusBelow = true

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

function static.init(menudata, menu)
end

function static.moveCursor(menudata, newItem)
end

function static.moveCursorFailed(menudata, itemTried)
end

function static.update(menudata)
end

function static.drawer(v, menudata, menu, gmconf)
	local strFlags = V_ALLOWLOWERCASE|menudata.transparency
	local patchFlags = menudata.transparency

	local cursor = v.cachePatch(config.cursor)
	local cursorWidth = cursor.width

	local cursorY = config.y + menudata.cursorPos * config.lineSpacing

	v.draw(config.x - cursorWidth - config.cursorSpacing, cursorY, cursor, patchFlags)

	for i, item in ipairs(menu.items) do
		local line = item.text

		local localStrFlags = (strFlags & ~V_ALPHAMASK) | menudata.transparency

		if i == menudata.cursorPos then
			localStrFlags = ($ & ~V_CHARCOLORMASK) | gmconf.selectionColor
		end

		v.drawString(config.x, config.y + i * config.lineSpacing, line, localStrFlags, config.font)
	end

	v.drawString(160, config.titleY, menu.name, gmconf.selectionColor|strFlags, config.titleFont)

	//v.drawFill(0, 100, 320, 1, 24)
end

return static