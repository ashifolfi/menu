-- GoldMenu constants.

local gmconst = {}

-- Selectable controls
gmconst.control = {
	moveUp = 1,
	moveDown = 2,
	moveLeft = 3,
	moveRight = 4,
	cameraUp = 5,
	cameraDown = 6,
	cameraLeft = 7,
	cameraRight = 8,

	jump = 9,
	spin = 10,
	firePrimary = 11,
	fireSecondary = 12,
	tossFlag = 13,
	custom1 = 14,
	custom2 = 15,
	custom3 = 16,

	weaponPrev = 17,
	weaponNext = 18,

	weapon1 = 19,
	weapon2 = 20,
	weapon3 = 21,
	weapon4 = 22,
	weapon5 = 23,
	weapon6 = 24,
	weapon7 = 25,
	weapon8 = 26,
	weapon9 = 27,
	weapon10 = 28,
	weapon11 = 29,
	weapon12 = 30,
	weapon13 = 31,
	weapon14 = 32,
	weapon15 = 33,
	weapon16 = 34,
}

gmconst.control.null = 0

gmconst.control.max = 35
gmconst.control.maxAttainable = gmconst.control.weapon1 + 7 - 1

-- Converts a menu control to a string..
gmconst.controlToString = {
	[gmconst.control.null] = "None",

	[gmconst.control.moveUp] = "Move Forward",
	[gmconst.control.moveDown] = "Move Backward",
	[gmconst.control.moveLeft] = "Move Left",
	[gmconst.control.moveRight] = "Move Right",

	[gmconst.control.cameraUp] = "Look Up",
	[gmconst.control.cameraDown] = "Look Down",
	[gmconst.control.cameraLeft] = "Look Left",
	[gmconst.control.cameraRight] = "Look Right",

	[gmconst.control.jump] = "Jump",
	[gmconst.control.spin] = "Spin",

	[gmconst.control.firePrimary] = "Fire",
	[gmconst.control.fireSecondary] = "Fire Normal",
	[gmconst.control.tossFlag] = "Toss Flag",
	[gmconst.control.custom1] = "Custom Action 1",
	[gmconst.control.custom2] = "Custom Action 2",
	[gmconst.control.custom3] = "Custom Action 3",

	[gmconst.control.weaponPrev] = "Prev Weapon",
	[gmconst.control.weaponNext] = "Next Weapon",

	[gmconst.control.weapon1] = "Weapon 1",
	[gmconst.control.weapon2] = "Weapon 2",
	[gmconst.control.weapon3] = "Weapon 3",
	[gmconst.control.weapon4] = "Weapon 4",
	[gmconst.control.weapon5] = "Weapon 5",
	[gmconst.control.weapon6] = "Weapon 6",
	[gmconst.control.weapon7] = "Weapon 7",

	[gmconst.control.weapon8] = "Weapon 8",
	[gmconst.control.weapon9] = "Weapon 9",
	[gmconst.control.weapon10] = "Weapon 10",
	[gmconst.control.weapon11] = "Weapon 11",
	[gmconst.control.weapon12] = "Weapon 12",
	[gmconst.control.weapon13] = "Weapon 13",
	[gmconst.control.weapon14] = "Weapon 14",

	[gmconst.control.weapon15] = "Weapon 15",
	[gmconst.control.weapon16] = "Weapon 16"
}

-- converts button inputs (where possible) into menu controls directly.
gmconst.playerButtonToControl = {
	[BT_WEAPONNEXT] = gmconst.control.weaponNext,
	[BT_WEAPONPREV] = gmconst.control.weaponPrev,

	[BT_ATTACK]     = gmconst.control.firePrimary,
	[BT_SPIN]       = gmconst.control.spin,
	[BT_TOSSFLAG]   = gmconst.control.tossFlag,
	[BT_JUMP]       = gmconst.control.jump,
	[BT_FIRENORMAL] = gmconst.control.fireSecondary,

	[BT_CUSTOM1]    = gmconst.control.custom1,
	[BT_CUSTOM2]    = gmconst.control.custom2,
	[BT_CUSTOM3]    = gmconst.control.custom3,
}

gmconst.menuBind = {
	open = 1,
	up = 2,
	down = 3,
	select = 4,
	back = 5,
}

gmconst.itemFlag = {
	none = 0,
	subMenu = 1
}

return gmconst