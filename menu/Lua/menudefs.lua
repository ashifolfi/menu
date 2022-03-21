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

gmdata.thirdMenu = {
	name = "Another Submenu!",
	style = gmstyles.scroll,
	items = {}
}

gmdata.modMenus = {
	name = "Mod options",
	style = gmstyles.scroll,
	items = {
		"lol",
		"nice",
	}
}

//local possibleValue = {MIN = 0, MAX = 99999990}
//local cv_slidervar = CV_RegisterVar{"slidervar", 0, CV_CALL, possibleValue, function(c) if consoleplayer then consoleplayer.score = c.value end end}

local possibleValue = {MIN = 0, MAX = 200*FRACUNIT}
local cv_slidervar = CV_RegisterVar{"slidervar", 0, CV_FLOAT, possibleValue}

-- Note: should be parsable by gmdata.parseMenuInitialisation.
gmdata.menu = {
	name = "",
	style = gmstyles.indevscroll,
	items = {
		{GM_ITEMTYPE_SUBMENU, 0, "Single Player", gmdata.modMenus},
		{GM_ITEMTYPE_SUBMENU, 0, "Multiplayer", gmdata.modMenus},
		{GM_ITEMTYPE_SUBMENU, 0, "Extras", gmdata.modMenus},
		{GM_ITEMTYPE_SUBMENU, 0, "Addons", gmdata.modMenus},
		{GM_ITEMTYPE_SUBMENU, 0, "Options", gmdata.modMenus},
		{GM_ITEMTYPE_SUBMENU, 0, "Quit Game", gmdata.modMenus}
	}
}

gmdata.menu = gmdata.parseMenuInitialisation($)
