[
    "PROTOCOL_AI_CQB_ENABLED",
    "CHECKBOX",
    ["Enable CQB", "Enable or disable CQB protocol"],
    ["PROTOCOL AI CQB", "CQB"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_CQB_RADIUS",
    "SLIDER",
    ["CQB Search Radius", "Maximum distance for CQB detection"],
    ["PROTOCOL AI CQB", "CQB"],
    [1, 100, 30, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_CQB_STANCE",
    "LIST",
    ["CQB Stance", "Select CQB stance for AI units"],
    ["PROTOCOL AI CQB", "CQB"],
    [
        [0, 1, 2],
        ["Half stand, half crouch", "Standing", "Sitting"],
        0
    ],
    1,
    {},
    false
] call CBA_fnc_addSetting;


[
    "PROTOCOL_AI_CQB_GRENADE_IN_DOOR",
    "CHECKBOX",
    ["Grenade in door", "Squad leader will throw grenade in door before entering"],
    ["PROTOCOL AI CQB", "CQB"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;



[
    "PROTOCOL_AI_CQB_SPEED",
    "LIST",
    ["Speed movement", "Speed for CQB movement"],
    ["PROTOCOL AI CQB", "CQB"],
    [
        [0, 1, 2],
        ["Slow", "Medium", "Fast"],
        0
    ],
    1,
    {},
    false
] call CBA_fnc_addSetting;


[
    "PROTOCOL_AI_CQB_NoVoice",
    "CHECKBOX",
    ["No voice in building", "Disable voice in building"],
    ["PROTOCOL AI CQB", "CQB"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;


[
    "PROTOCOL_AI_CITY_TACTICS_ENABLED",
    "CHECKBOX",
    ["Enable City Tactics", "Enable or disable City Tactics protocol"],
    ["PROTOCOL AI CITY TACTICS", "CITY TACTICS"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_CITY_TACTICS_SMOKE_ENABLED",
    "CHECKBOX",
    ["Enable smoke grenades", "Enable or disable smoke grenades in City at streets"],
    ["PROTOCOL AI CITY TACTICS", "CITY TACTICS"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;



[
    "PROTOCOL_AI_ENABLED",
    "CHECKBOX",
    ["Enable PROTOCOL AI ", "Disable or enable ai protocol"],
    ["PROTOCOL AI ", "Infantry"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_DISTANCE",
    "SLIDER",
    ["Distance for detection enemy", "Distance for ai engagement"],
    ["PROTOCOL AI ", "Infantry"],
    [1, 10000000, 1200, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;




[
    "PROTOCOL_AI_SUPRESS",
    "CHECKBOX",
    ["Enable Suppress ai ", "Disable or enable suppress ai protocol"],
    ["PROTOCOL AI ", "Infantry"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_BLINDFIRE",
    "CHECKBOX",
    ["Enable Blind Fire", "Disable or enable blind fire for AI units"],
    ["PROTOCOL AI ", "Infantry"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;


[
    "PROTOCOL_AI_AUTOFORMATIONS",
    "CHECKBOX",
    ["Enable Autoformations", "Disable or enable autoformations for groups"],
    ["PROTOCOL AI ", "Infantry"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_DYNAMIC_COVER_USAGE",
    "CHECKBOX",
    ["Enable dynamic cover usage", "units will be using covers  "],
    ["PROTOCOL AI ", "Infantry"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_AGRESSIVE",
    "CHECKBOX",
    ["Enable Agressive mode", "units will be using launchers, grenades more aggressively "],
    ["PROTOCOL AI ", "Infantry"],
    false,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_CORNER_PEEK_ENABLED",
    "CHECKBOX",
    ["Enable Corner usage", "units will be using corner like real marine "],
    ["PROTOCOL AI ", "Infantry"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;


[
    "PROTOCOL_AI_STANCE_ENABLED",
    "CHECKBOX",
    ["Enable smart usage Stance", "units will employ combat stances in accordance with doctrine. "],
    ["PROTOCOL AI ", "Infantry"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_EXPLOSIVE_SUPPRESSION_ENABLED",
    "CHECKBOX",
    ["Enable agressive usage exlosive", "units will be supress with exlposive, grenades,under-barrel grenade launchers "],
    ["PROTOCOL AI ", "Infantry"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_SKILL",
    "LIST",
    ["Skill", "Select type of skill  for AI units"],
    ["PROTOCOL AI ", "Infantry tactics"],
    [
        [0, 1, 2],
        ["HUMAN", "HARD", "NONE"],
        2
    ],
    1,
    {},
    false
] call CBA_fnc_addSetting;


[
    "PROTOCOL_AI_TACTICS",
    "LIST",
    ["Tactics", "Select tactics for AI units"],
    ["PROTOCOL AI ", "Infantry tactics"],
    [
        [0, 1, 2, 3, 4, 5,6,7,8,9,10,11,12,13,14,15],
        ["DOCRTINE + ENVIRONMENT", "DOCRTINE", "ENVIRONMENT", "URBAN","FOREST","CQB", "BOUNDING_OVERWATCH",
        "PAIRS", "TRIPLET", "FIRE_AND_MANEUVER", "FLANKING", "ENCIRCLEMENT", "RECONNAISSANCE_BY_FIRE",
        "CENTRAL_PEEL", "ALL_ROUND_DEFENSE", "AMBUSH"],
        0
    ],
    1,
    {},
    false
] call CBA_fnc_addSetting;



[
    "PROTOCOL_AI_DEBUG",
    "CHECKBOX",
    ["Enable debug mode", "shows which group  and what type tactics are using  "],
    ["PROTOCOL AI ", "Infantry tactics"],
    false,
    1,
    {},
    false
] call CBA_fnc_addSetting;

/*
[
    "PROTOCOL_AI_NAVY_SEAL",
    "CHECKBOX",
    ["Enable Navy SEAL", "Disable or enable Navy SEAL protocol"],
    ["PROTOCOL AI ", "Special"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;
*/

[
    "PROTOCOL_AI_TROOPS",
    "CHECKBOX",
    ["Enable Troops tactics", "Disable or enable troops protocol"],
    ["PROTOCOL AI ", "Special"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;









