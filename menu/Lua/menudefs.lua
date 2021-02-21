local submenus = {}

local gmconst = lua_require("const")
local gmdata = lua_require("data")
local gmstyles = lua_require("styles")

--
-- Data definitions.
--

local secondMenu = {
	name = "A Submenu!",
	style = gmstyles.static,
	items = {
		"lol",
		"another item!",
		"static menu!"
	}
}

local thirdMenu = {
	name = "Another Submenu!",
	style = gmstyles.scroll,
	items = {
		"This one scrolls!",
		"Isn't that neat?",
	}
}

gmdata.modMenus = {
	name = "Mod options",
	style = gmstyles.scroll,
	items = {
		"lol",
		"nice",
	}
}

-- Note: should be parsable by gmdata.parseMenuInitialisation.
gmdata.menu = {
	name = "Main Menu",
	style = gmstyles.scroll,
	items = {
		{GM_ITEMFLAG_SUBMENU, "Mods...", gmdata.modMenus},
		{GM_ITEMFLAG_SUBMENU, "Menu options...", secondMenu},
	}
}

gmdata.menu = gmdata.parseMenuInitialisation($)