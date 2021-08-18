-- Note: **MUST** contain all possible callbacks.

local dummy = {}

-- Config for use by menu.lua
dummy.drawMenusBelow = false

local config = {}

function dummy.init(menudata, menu)
end

function dummy.menuToggle(toggleState, menudata, menu)
end

function dummy.moveCursor(success, newItem, menudata, menu)
end

function dummy.update(menudata, menu, gmconf, player)
end

function dummy.drawer(v, menudata, menu, gmconf)
end

return dummy
