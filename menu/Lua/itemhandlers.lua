local gmitemhandlers = {}

local gmconst = lua_require("const")
local gmconf = lua_require("conf")
local gmvars = lua_require("vars")

gmitemhandlers[GM_ITEMTYPE_SUBMENU] = function(goldmenu, item, player)
	local selectTics = goldmenu.bindPressed[GM_MENUBIND_SELECT]

	if type(item.data) ~= "table" then
		return
	end

	if selectTics == 1 then
		gmvars.pushMenu(goldmenu, item.data)
	end
end

gmitemhandlers[GM_ITEMTYPE_SLIDER] = function(goldmenu, item, player)
	local leftTics = goldmenu.bindPressed[GM_MENUBIND_LEFT]
	local rightTics = goldmenu.bindPressed[GM_MENUBIND_RIGHT]

	if userdataType(item.data) ~= "consvar_t" then
		return
	end

	if not goldmenu.bindPressed[goldmenu.pressedCvarIncrementKey] then
		goldmenu.pressedCvarIncrementKey = GM_MENUBIND_NULL
		goldmenu.cvarIncrementVelocity = 0
	end

	goldmenu.pressedCvarIncrementKey = $ or (leftTics and GM_MENUBIND_LEFT) or (rightTics and GM_MENUBIND_RIGHT) or GM_MENUBIND_NULL

	if goldmenu.pressedCvarIncrementKey then
		local sign = (goldmenu.pressedCvarIncrementKey == GM_MENUBIND_RIGHT and 1) or (goldmenu.pressedCvarIncrementKey == GM_MENUBIND_LEFT and -1) or 0
		local cvar = item.data

		local pressedTics = goldmenu.bindPressed[goldmenu.pressedCvarIncrementKey]

		if pressedTics == 1 then
			COM_BufInsertText(player, cvar.name .. " " .. cvar.value + sign)
		end

		-- didnt want to keep track of this, but mathematics itself has forced my hand
		-- fn(x) = xy^(n+1) + (n+1)xy^n + (n+1)xy^(n-1) + ... (n+1)xy^2 + (n+1)xy + x
		-- for the function f(x) = x + xy
		goldmenu.cvarIncrementVelocity = $ or 1

		if goldmenu.cvarIncrementVelocity < INT32_MAX then
			local prevVel = goldmenu.cvarIncrementVelocity
			goldmenu.cvarIncrementVelocity = $ + (FixedMul($, gmconf.cvarIncrementAcceleration) or 1)

			if goldmenu.cvarIncrementVelocity < prevVel then
				goldmenu.cvarIncrementVelocity = INT32_MAX
			end
		end

		if goldmenu.cvarIncrementVelocity < 1<<15 then
			goldmenu.cvarIncrementDecimal = $ + gmconf.cvarBaseIncrement * goldmenu.cvarIncrementVelocity
			COM_BufInsertText(player, cvar.name .. " " .. cvar.value + sign * FixedInt(goldmenu.cvarIncrementDecimal))
			goldmenu.cvarIncrementDecimal = $ & ~0xFFFF0000 -- decimal only
		else
			local inc = sign * FixedMul(goldmenu.cvarIncrementVelocity, gmconf.cvarBaseIncrement)
			goldmenu.cvarIncrementDecimal = 0
			COM_BufInsertText(player, cvar.name .. " " .. cvar.value + inc)
		end
	else
		goldmenu.cvarIncrementDecimal = 0
	end
end

return gmitemhandlers