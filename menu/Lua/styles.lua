local gmstyles = {}

gmstyles.dummy = lua_require("menuStyles/dummy")

local function initialiseStyle(stylename)
	local style = lua_require("menuStyles/" .. stylename)

	for k, v in pairs(gmstyles.dummy) do
		if not style[k] then
			style[k] = v
		end
	end

	return style
end

gmstyles.scroll = initialiseStyle("scroll")
gmstyles.static = initialiseStyle("static")

return gmstyles
