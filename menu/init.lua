// stripped down require implementation

local lua_loading = {}
local lua_loadingOrder = {}
local lua_package, lua_require

local lua_notice

local debugmode = false

local function stringLoadingOrder()
	local loading = "(init)"

	for i, v in ipairs(lua_loadingOrder) do
		loading = loading .. " > " .. v
	end

	return loading
end

local function debugLoadingOrder(modname)
	table.insert(lua_loadingOrder, modname)

	lua_notice("%s", stringLoadingOrder())
end

local function popFromLoadingOrder(modname)
	table.remove(lua_loadingOrder)

	lua_notice("%s <", stringLoadingOrder())
end

function lua_notice(format, ...)
	if not debugmode then
		return
	end

	local str = string.format(format, ...)

	str = string.format("\x88%s\x80: %s", "lua_require()", str)

	if consoleplayer then
		CONS_Printf(consoleplayer, str)
	else
		print(str)
	end
end

lua_package = {
	loaded = {},
	loaders = {
		function(modname)
			debugLoadingOrder(modname)

			if lua_loading[modname] then
				return error(string.format("'%s' is already loading; cannot require.", modname))
			end

			lua_loading[modname] = true // Just in case
			local success, module = pcall(dofile, modname .. ".lua") // A mod loaded using this
			lua_loading[modname] = false // Requires a file already being loaded

			popFromLoadingOrder(modname)

			if success then
				lua_package.loaded[modname] = module
				return module
			else
				error("Error loading " .. modname .. ": " .. module)
			end
		end
	}
}

function lua_require(modname)
	if not lua_package.loaded[modname] then
		local successful = false

		//lua_notice("loading module '%s' for the first time...", modname)

		for i, loader in ipairs(lua_package.loaders) do
			local ret = {pcall(loader, modname)}
			successful = table.remove(ret, 1)
			local module_or_error = table.remove(ret, 1)

			if successful then
				if module_or_error ~= nil then
					lua_package.loaded[modname] = module_or_error
				end

				break
			else
				print(module_or_error)
			end
		end

		if successful and not lua_package.loaded[modname] == nil then
			lua_package.loaded[modname] = true
		end
	else
		lua_notice("* %s", modname)
	end

	return lua_package.loaded[modname]
end

//rawset(_G, "lua_package", lua_package)
rawset(_G, "lua_require", lua_require)

debugmode = lua_require("debug")
lua_notice("Debug mode is ON") -- only prints when debug mode is on LOL

local main = lua_require("main")

_G.lua_require = nil
