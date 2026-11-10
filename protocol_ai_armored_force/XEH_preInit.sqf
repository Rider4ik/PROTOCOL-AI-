[
    "PROTOCOL_AI_ARMORED_FORCE_ENABLED",
    "CHECKBOX",
    ["Enable Armored Force", "Enable or disable Armored Force protocol"],
    ["PROTOCOL AI Armored Force", "Armored Force"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_ARMORED_FORCE_RADIUS",
    "SLIDER",
    ["Armored Force Search Radius", "Maximum distance for Armored Force detection and engagement"],
    ["PROTOCOL AI Armored Force", "Armored Force"],
    [10, 1000, 70, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_ARMORED_FORCE_SMOKE_USAGE",
    "CHECKBOX",
    ["Enable Armored Force Smoke Usage", "Enable or disable smoke usage for Armored Force"],
    ["PROTOCOL AI Armored Force", "Armored Force"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;


[
    "PROTOCOL_ATGM_USAGE",
    "CHECKBOX",
    ["Enable ATGM Usage", "Enable or disable ATGM usage"],
    ["PROTOCOL AI Armored Force", "Armored Force"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;


[
    "PROTOCOL_AI_ARMORED_FORCE_COVER_USAGE",
    "CHECKBOX",
    ["Enable Cover Usage for vehicles", "Enable or disable cover usage"],
    ["PROTOCOL AI Armored Force", "Armored Force"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;







