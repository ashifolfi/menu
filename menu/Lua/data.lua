-- Defines the formatting of structures and manipulates them.

local gmdata = {}

local gmconst = lua_require("const")
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

-- Note: should be parsable by gmdata.parseMenuInitialisation.
gmdata.menu = {
	name = "Main Menu",
	style = gmstyles.scroll,
	items = {
		{gmconst.itemFlag.subMenu, "A submenu...", secondMenu},
		{gmconst.itemFlag.subMenu, "Another submenu...", thirdMenu},
		"line 2",
		"short",
		"line 3",
		"scroll menu!",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"Secrets?",
		"I just LOOOVE secrets!",
	}
}

--
-- Menu management; menu registration is handled by the api or through other functions.
--

local deletedItems = {}
local deletedItemTables = {}
local deletedMenus = {}

local function newStructure(deletedStuff)
	local newStruct

	-- grab a previously deleted structure, or if impossible, create a new one.
	if not #deletedMenus then
		newStruct = {}
	else
		newStruct = table.remove(deletedStuff)
	end

	return newStruct
end

local function deleteStructure(struct, deletedStuff)
	table.insert(deletedStuff, struct)
end

-- Returns item of format: { string text, int flags, itemTable parent, menu menu, int index }
function gmdata.newItem(itemflags, itemtext, data)
	local newItem = newStructure(deletedItems)

	-- populate item with values.
	newItem.flags = itemflags or 0
	newItem.text = itemtext or ""
	newItem.data = data

	newItem.itemTable = nil -- parent itemTable
	newItem.menu = nil -- parent menu
	newItem.index = nil -- index into itemTable

	return newItem
end

-- Returns itemTable of format: { menu menu, [ item 1, [ item 2, [ ... ]]] }
function gmdata.newItemTable(menu)
	local newItemTable = newStructure(deletedItemTables)

	newItemTable.menu = menu

	return newItemTable
end

-- Returns menu of format: { string name, itemTable items, menu parent }
function gmdata.newMenu(menuname, style, itemTable, parent)
	local newMenu = newStructure(deletedMenus)

	-- populate menu with values.
	newMenu.name = menuname or ""
	newMenu.items = itemTable or {}
	newMenu.style = style or gmstyles.scroll

	newMenu.prevCursorPos = 1
	newMenu.cursorPos = 1

	newMenu.parent = parent -- parent menu

	newMenu.open = false

	return newMenu
end

-- Expected to be called like: item = gmdata.deleteItem($)
function gmdata.deleteItem(item)
	local itemTable = item.itemTable
	local index = item.index

	deleteStructure(item, deletedItems)

	if itemTable then
		table.remove(itemTable, index)

		for i, item in ipairs(itemTable) do
			item.index = i
		end
	end
end

-- Expected to be called like: itemTable = gmdata.deleteItemTable($)
function gmdata.deleteItemTable(itemTable)
	if itemTable.menu then
		itemTable.menu.items = gmdata.newItemTable()
	end

	for i, item in ipairs(itemTable) do
		item.itemTable = nil
		item.menu = nil
		item.index = nil

		-- the lua gc will take care of removing this one..
		-- can't assume no references!
	end

	return deleteStructure(itemTable, deletedItemTables)
end

-- Expected to be called like: menu = gmdata.deleteMenu($)
function gmdata.deleteMenu(menu)
	if menu.items then
		menu.items.menu = nil

		for i, item in ipairs(menu.items) do
			item.menu = nil
		end
	end

	return deleteStructure(menu, deletedMenus)
end

-- Adds item to itemTable.
-- Returns item
function gmdata.addItemToItemTable(item, itemTable, pos)
	item.itemTable = itemTable
	item.index = pos

	if itemTable.menu then
		item.menu = itemTable.menu
	end

	table.insert(itemTable, pos, item)

	for i, item in ipairs(itemTable) do
		item.index = i
	end

	return item
end

-- Adds item to menu's itemTable.
-- Returns item
function gmdata.addItemToMenu(item, menu, pos)
	return gmdata.addItemToItemTable(item, menu.items, pos)
end

-- Parses item initialisation
-- Returns item
function gmdata.parseItemInitialisation(itemInit)
	local flags, text, data

	if type(itemInit) == "string" then
		flags, text, data = 0, itemInit, nil
	elseif #itemInit then
		flags, text, data = unpack(itemInit)
	else
		flags, text, data = itemInit.flags, itemInit.text, itemInit.data
	end

	local newItem = gmdata.newItem(flags, text, data)

	if newItem.flags == gmconst.itemFlag.subMenu then
		newItem.data = gmdata.parseMenuInitialisation($)
	end

	return newItem
end

-- Parses itemTable initialisation
-- Returns itemTable
function gmdata.parseItemTableInitialisation(itemTableInit)
	local newItemTable = gmdata.newItemTable()

	for i, itemInit in ipairs(itemTableInit) do
		newItemTable[i] = gmdata.parseItemInitialisation(itemInit)
	end

	return newItemTable
end

-- Parses menu initialisation
-- Returns menu
function gmdata.parseMenuInitialisation(menuInit)
	local name, style, itemTable

	if #menuInit then
		name, style, itemTable = unpack(menuInit)
	else
		name = menuInit.name
		style = menuInit.style
		itemTable = menuInit.items
	end

	itemTable = gmdata.parseItemTableInitialisation($)

	return gmdata.newMenu(name, style or gmstyles.scroll, itemTable)
end

return gmdata