private _cScriptSettings = "cScripts Mission Settings";

// 1; Mission
[ // Mission Type
    QEGVAR(Settings,setMissionType),
    "LIST",
    ["Mission Type", "This will deside on what kind of startup hint you get on mission start."],
    [_cScriptSettings, "1; Mission"],
    [[0,1,2,3], ["Custom", "Operation", "Training", "Public"], 1],
    true,
    {},
    true
] call CBA_fnc_addSetting;


// 3; Player
[ // Documents
    QEGVAR(Settings,showDiaryRecords),
    "CHECKBOX",
    ["Documents","Allow the mission to write diary help documents."],
    [_cScriptSettings, "3; Player"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;

// 4; Staging

[ // Show all loadouts
    QEGVAR(Settings,showAllLoadouts),
    "CHECKBOX",
    ["Show all loadouts","Allow the selection of any loadouts from the personal selection menu."],
    [_cScriptSettings, "4; Staging"],
    false,
    true,
    {
        params ["_value"];
        { EGVAR(Staging,showAllLoadouts) = _value; } remoteExecCall ["call"];
    },
    false
] call CBA_fnc_addSetting;
[ // Use Filtered Arsenal
    QEGVAR(Settings,useFilteredArsenal),
    "CHECKBOX",
    ["Use Filtered Arsenal","Use a filtered or show all items in the staging arsenal."],
    [_cScriptSettings, "4; Staging"],
    true,
    true,
    {},
    false
] call CBA_fnc_addSetting;



// 6; Item Replacement system
[ // Enable
    QEGVAR(Settings,allowReplaceItem),
    "CHECKBOX",
    ["Enable","Allow objects to be replaced with streamlined gear for consistency."],
    [_cScriptSettings, "6; Item Replacement"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;
[ // Medical Items
    QEGVAR(Settings,replaceMedical),
    "LIST",
    ["Medical Items","Allow medical items to be replaced with our custom ones.\nNote: this system will not be disabled if the ace medical convert items is enabled."],
    [_cScriptSettings, "6; Item Replacement"],
    [[0,1], ["Disabled", "Convert medical equipment"], 1],
    true,
    {},
    true
] call CBA_fnc_addSetting;

// 7; Combat Jump Simulation
[ // Simulation Type
    QEGVAR(Settings,jumpSimulation),
    "LIST",
    ["Simulation Type","Combat jump simulation is a system that checks for lose equiped gear in the form of;\nnight vision googles, hats or glasses and make you lose the on a combat jump.\n    None: No simulation is done.\n    Basic: Lose gear unassigned.\n    Advanced: Lose gear is removed."],
    [_cScriptSettings, "7; Combat Jump Simulation"],
    [[0,1,2], ["None", "Basic", "Advanced"], 2],
    true,
    {},
    true
] call CBA_fnc_addSetting;
[ // Include Night Vision Googles
    QEGVAR(Settings,jumpSimulationNVG),
    "CHECKBOX",
    ["Include Night Vision Googles","Include equiped Night Vison Googles in the simulation."],
    [_cScriptSettings, "7; Combat Jump Simulation"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;
[ // Include Non-combat Googles
    QEGVAR(Settings,jumpSimulationGlasses),
    "CHECKBOX",
    ["Include Non-combat Googles","Include Non-combat Googles in the simulation. This refere to sunshades and simular non-safety googles."],
    [_cScriptSettings, "7; Combat Jump Simulation"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;
[ // Include Non-combat Headgear
    QEGVAR(Settings,jumpSimulationHat),
    "CHECKBOX",
    ["Include Non-combat Headgear","Include Non-combat Headgear in the simulation. This refere to hats bandanas and baretes."],
    [_cScriptSettings, "7; Combat Jump Simulation"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;


// 8; Zeus
[ // Enable Custom Zeus Moduels
    QEGVAR(Settings,enable7cavZeusModules),
    "CHECKBOX",
    ["Enable Custom Zeus Moduels","Allow mission to add 7Cav moduels using the Achilles or ZEN framework."],
    [_cScriptSettings, "8; Zeus"],
    true,
    true,
    {},
    true
] call CBA_fnc_addSetting;


