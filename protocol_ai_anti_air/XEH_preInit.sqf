[
    "PROTOCOL_AI_ANTI_AIR_ENABLED",
    "CHECKBOX",
    ["Enable ANTI-AIR", "Enable or disable ANTI-AIR protocol"],
    ["PROTOCOL AI ANTI-AIR", "ANTI-AIR"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_ANTI_AIR_RELOCATE ",
    "CHECKBOX",
    ["Enable ANTI-AIR relocate", "Enable or disable ANTI-AIR relocation"],
    ["PROTOCOL AI ANTI-AIR", "ANTI-AIR"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_ANTI_AIR_RELOCATE_MIN_RADIUS",
    "SLIDER",
    ["ANTI-AIR Relocate Radius", "Minimum distance for ANTI-AIR relocation"],
    ["PROTOCOL AI ANTI-AIR", "ANTI-AIR"],
    [1, 10000, 300, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_ANTI_AIR_RELOCATE_MAX_RADIUS",
    "SLIDER",
    ["ANTI-AIR Relocate Radius", "Maximum distance for ANTI-AIR relocation"],
    ["PROTOCOL AI ANTI-AIR", "ANTI-AIR"],
    [1, 10000, 500, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_ANTI_AIR_SMOKE_RELOCATE",
    "CHECKBOX",
    ["Enable ANTI-AIR Smoke", "Enable smoke before ANTI-AIR relocation"],
    ["PROTOCOL AI ANTI-AIR", "ANTI-AIR"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

