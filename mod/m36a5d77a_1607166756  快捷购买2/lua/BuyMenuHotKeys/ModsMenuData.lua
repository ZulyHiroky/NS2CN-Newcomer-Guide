-- define OP_TT_ColorPicker just incase ns2plus hasn't been loaded
--Script.Load("lua/menu2/widgets/GUIMenuColorPickerWidget.lua") -- doesn't get loaded by vanilla menu
--OP_TT_ColorPicker = OP_TT_ColorPicker or GetMultiWrappedClass(GUIMenuColorPickerWidget, {"Option", "Tooltip"})

local menu =
{
	categoryName = "BuyMenuHotKeys",
	entryConfig =
	{
		name = "BuyMenuHotKeysEntry",
		class = GUIMenuCategoryDisplayBoxEntry,
		params =
		{
			label = "Buy Menu Hotkeys Options",
		},
	},
	contentsConfig = ModsMenuUtils.CreateBasicModsMenuContents
	{
		layoutName = "BuyMenuHotkeysOptions",
		contents =
		{
			-----General
			{
				name = "kBMHKHeaderGeneral",
				class = GUIMenuText,
				params = {
					text = "General Options"
				},
			},
			{
				name = "bmhk_showlabels",
				class = OP_TT_Checkbox,
				params =
				{
					optionPath = "bmhk_showlabels",
					optionType = "bool",
					default = true,
					tooltip = "Shows Keybind labels in all buymenus",
				},
			
				properties =
				{
					{"Label", "Show BMHK Labels"},
				},
			},
			-----Aliens
			{
				name = "kBMHKHeaderAliens",
				class = GUIMenuText,
				params = {
					text = "ALIEN BUY MENU HOTKEYS"
				},
			},
			{
				name = "bmhk_evolve",
				class = OP_Keybind,
				params = {
					optionPath = "input/bmhk_evolve",
					optionType = "string",
					default = "NumPadEnter",

					bindGroup = "bmhk_alien",
				},
				properties = {
					{ "Label", "Evolve Key" },
				},
			},
			-----Lifeforms
			{
				name = "bmhk_gorge",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_gorge",
					optionType = "string",
					default = "1",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Gorge"},
				},
			},
			{
				name = "bmhk_skulk",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_skulk",
					optionType = "string",
					default = "2",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Skulk"},
				},
			},
			{
				name = "bmhk_lerk",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_lerk",
					optionType = "string",
					default = "3",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Lerk"},
				},
			},
			{
				name = "bmhk_fade",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_fade",
					optionType = "string",
					default = "4",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Fade"},
				},
			},
			{
				name = "bmhk_onos",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_onos",
					optionType = "string",
					default = "5",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Onos"},
				},
			},
			-----Abilities Shells
			{
				name = "bmhk_regeneration",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_regeneration",
					optionType = "string",
					default = "NumPad1",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Regeneration"},
				},
			},
			{
				name = "bmhk_carapace",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_carapace",
					optionType = "string",
					default = "NumPad2",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Carapace"},
				},
			},
			{
				name = "bmhk_vampirism",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_vampirism",
					optionType = "string",
					default = "NumPad3",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Vampirism"},
				},
			},
			-----Abilities Spurs
			{
				name = "bmhk_adrenaline",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_adrenaline",
					optionType = "string",
					default = "NumPad4",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Adrenaline"},
				},
			},
			{
				name = "bmhk_celerity",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_celerity",
					optionType = "string",
					default = "NumPad5",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Celerity"},
				},
			},
			{
				name = "bmhk_crush",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_crush",
					optionType = "string",
					default = "NumPad6",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Crush"},
				},
			},
			-----Abilities Veils
			{
				name = "bmhk_camouflage",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_camouflage",
					optionType = "string",
					default = "NumPad7",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Camouflage"},
				},
			},
			{
				name = "bmhk_focus",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_focus",
					optionType = "string",
					default = "NumPad8",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Focus"},
				},
			},
			{
				name = "bmhk_aura",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_aura",
					optionType = "string",
					default = "NumPad9",

					bindGroup = "bmhk_alien",
				},
				properties =
				{
					{"Label", "Select Aura"},
				},
			},
			-----Marines
			-----Armory
			{
				name = "kBMHKHeaderMarinesArmory",
				class = GUIMenuText,
				params = {
					text = "ARMORY BUY MENU HOTKEYS"
				},
			},
			{
				name = "bmhk_welder",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_welder",
					optionType = "string",
					default = "1",

					bindGroup = "bmhk_armory",
				},
				properties =
				{
					{"Label", "Purchase Welder"},
				},
			},
			{
				name = "bmhk_mines",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_mines",
					optionType = "string",
					default = "2",

					bindGroup = "bmhk_armory",
				},
				properties =
				{
					{"Label", "Purchase Mines"},
				},
			},
			{
				name = "bmhk_shotgun",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_shotgun",
					optionType = "string",
					default = "3",

					bindGroup = "bmhk_armory",
				},
				properties =
				{
					{"Label", "Purchase Shotgun"},
				},
			},
			{
				name = "bmhk_cluster",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_cluster",
					optionType = "string",
					default = "4",

					bindGroup = "bmhk_armory",
				},
				properties =
				{
					{"Label", "Purchase Cluster Grenades"},
				},
			},
			{
				name = "bmhk_nervegas",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_nervegas",
					optionType = "string",
					default = "5",

					bindGroup = "bmhk_armory",
				},
				properties =
				{
					{"Label", "Purchase Nerve Gas"},
				},
			},
			{
				name = "bmhk_pulse",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_pulse",
					optionType = "string",
					default = "6",

					bindGroup = "bmhk_armory",
				},
				properties =
				{
					{"Label", "Purchase Pulse Grenades"},
				},
			},
			{
				name = "bmhk_gl",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_gl",
					optionType = "string",
					default = "7",

					bindGroup = "bmhk_armory",
				},
				properties =
				{
					{"Label", "Purchase Grenade Launcher"},
				},
			},
			{
				name = "bmhk_flamethrower",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_flamethrower",
					optionType = "string",
					default = "8",

					bindGroup = "bmhk_armory",
				},
				properties =
				{
					{"Label", "Purchase Flamethrower"},
				},
			},
			{
				name = "bmhk_hmg",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_hmg",
					optionType = "string",
					default = "9",

					bindGroup = "bmhk_armory",
				},
				properties =
				{
					{"Label", "Purchase HMG"},
				},
			},
            -----Prototype Lab
			{
				name = "kBMHKHeaderMarinesPrototypeLab",
				class = GUIMenuText,
				params = {
					text = "PROTOTYPELAB BUY MENU HOTKEYS"
				},
			},
			{
				name = "bmhk_jetpack",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_jetpack",
					optionType = "string",
					default = "1",

					bindGroup = "bmhk_protolab",
				},
				properties =
				{
					{"Label", "Purchase Jetpack"},
				},
			},
			{
				name = "bmhk_exomini",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_exomini",
					optionType = "string",
					default = "2",

					bindGroup = "bmhk_protolab",
				},
				properties =
				{
					{"Label", "Purchase Minigun Exo"},
				},
			},
			{
				name = "bmhk_exorail",
				class = OP_Keybind,
				params =
				{
					optionPath = "input/bmhk_exorail",
					optionType = "string",
					default = "3",

					bindGroup = "bmhk_protolab",
				},
				properties =
				{
					{"Label", "Purchase Railgun Exo"},
				},
			},
		},
	}
}
table.insert(gModsCategories, menu)