-- GoldMenu constants.

-- New Control Constants
-- Allow for the use of for statements in
-- the control handler
local const = {
	GM_CONTROL_NULL = 0,
	
	-- System Keys
	GM_CONTROL_CONSOLE = {},
	GM_CONTROL_SYSMENU = {},
	GM_CONTROL_PAUSE = {},

	GM_CONTROL_MAX = 35,
	
	// Menu binds

	GM_MENUBIND_NULL = 0,

	GM_MENUCTRL_OPEN = {0,0},
	GM_MENUCTRL_SELECT = {0,0},
	GM_MENUCTRL_BACK = {0,0},
	GM_MENUCTRL_MOVE = {
		UP = {0,0}, DOWN = {0,0}, LEFT = {0,0}, RIGHT = {0,0},
	},
	
	GM_MENUBIND_OPEN = 1,
	GM_MENUBIND_SELECT = 2,
	GM_MENUBIND_BACK = 3,
	GM_MENUBIND_MOVE = {
		UP = 4, DOWN = 5, LEFT = 6, RIGHT = 7,
	},

	GM_MENUBIND_MAX = 8,

	// Menu item types

	GM_ITEMTYPE_NONE = 0,
	GM_ITEMTYPE_SUBMENU = 1,
	GM_ITEMTYPE_SLIDER = 2,
}

for k, v in pairs(const) do
	rawset(_G, k, v)
end

local gmconst = {}

-- Refresh our system keys.
function gmconst.refreshSysCtrl()
	GM_CONTROL_PAUSE[1],GM_CONTROL_PAUSE[2] = input.gameControlToKeyNum(GC_PAUSE)
	GM_CONTROL_SYSMENU[1],GM_CONTROL_SYSMENU[2] = input.gameControlToKeyNum(GC_SYSTEMMENU)
	GM_CONTROL_CONSOLE[1],GM_CONTROL_CONSOLE[2] = input.gameControlToKeyNum(GC_CONSOLE)
	GM_MENUCTRL_OPEN[1],GM_MENUCTRL_OPEN[2] = input.gameControlToKeyNum(GC_TOSSFLAG)
	GM_MENUCTRL_SELECT[1],GM_MENUCTRL_SELECT[2] = input.gameControlToKeyNum(GC_JUMP)
	GM_MENUCTRL_BACK[1],GM_MENUCTRL_BACK[2] = input.gameControlToKeyNum(GC_SPIN)
	GM_MENUCTRL_MOVE.UP[1],GM_MENUCTRL_MOVE.UP[2] = input.gameControlToKeyNum(GC_FORWARD)
	GM_MENUCTRL_MOVE.DOWN[1],GM_MENUCTRL_MOVE.DOWN[2] = input.gameControlToKeyNum(GC_BACKWARD)
	GM_MENUCTRL_MOVE.LEFT[1],GM_MENUCTRL_MOVE.LEFT[2] = input.gameControlToKeyNum(GC_STRAFELEFT)
	GM_MENUCTRL_MOVE.RIGHT[1],GM_MENUCTRL_MOVE.RIGHT[2] = input.gameControlToKeyNum(GC_STRAFERIGHT)
end

gmconst.menuBindToString = {
	[GM_MENUBIND_OPEN] = "Open",
	[GM_MENUBIND_MOVE.UP] = "Up",
	[GM_MENUBIND_MOVE.DOWN] = "Down",
	[GM_MENUBIND_MOVE.LEFT] = "Left",
	[GM_MENUBIND_MOVE.RIGHT] = "Right",
	[GM_MENUBIND_SELECT] = "Select",
	[GM_MENUBIND_BACK] = "Back",
}

return gmconst
