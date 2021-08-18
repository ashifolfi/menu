local gmutil = {}

function gmutil.fixedLerp(a, b, v)
	return a + FixedMul(b - a, v)
end

local cvarBounds = {}

// gets the MIN and MAX of a cvar's PossibleValue. SRB2 didn't expose PossibleValue when this was originally written.
function gmutil.getCvarBounds(cvar)
	local cvar_min, cvar_max = INT32_MIN + 1, INT32_MAX

	// forwards-compatibility with possible future srb2 versions
	if cvar.PossibleValue then
		cvar_min = cvar.PossibleValue.MIN or $
		cvar_max = cvar.PossibleValue.MAX or $

		return cvar_min, cvar_max
	end

	local commandFormat

	if cvar.flags & CV_FLOAT then
		commandFormat = "%s %f"

		-- CV_FLOAT cvars are picky about bounds
		cvar_min = -32767 * FRACUNIT
		cvar_max = 32767 * FRACUNIT
	else
		commandFormat = "%s %d"
	end

	if cvarBounds[cvar] then
		return cvarBounds[cvar].min, cvarBounds[cvar].max
	end

	if cvar.value == nil then
		return 0, 0
	end

	local cvar_value_tmp = cvar.value or 0
	COM_BufInsertText(nil, string.format(commandFormat, cvar.name, cvar_min))
	cvar_min = cvar.value
	COM_BufInsertText(nil, string.format(commandFormat, cvar.name, cvar_max))
	cvar_max = cvar.value
	COM_BufInsertText(nil, string.format(commandFormat, cvar.name, cvar_value_tmp))

	cvarBounds[cvar] = {min = cvar_min, max = cvar_max}

	return cvar_min, cvar_max
end

function gmutil.setCvarValue(player, cvar, value)
	local commandFormat = "%s %d"

	if cvar.flags & CV_FLOAT then
		commandFormat = "%s %.2f"
	end

	COM_BufInsertText(player, string.format(commandFormat, cvar.name, value))
end

-- lol
function table.last(readTable)
	return readTable[#readTable]
end

return gmutil
