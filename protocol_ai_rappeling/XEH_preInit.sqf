[
    "PROTOCOL_AI_RAPPELING_ENABLED",
    "CHECKBOX",
    ["Enable Rappeling", "Enable or disable Rappeling protocol"],
    ["PROTOCOL AI RAPPELING", "RAPPELING"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_RAPPELING_HEIGHT",
    "SLIDER",
    ["Rappeling Height", "Maximum height for Rappeling"],
    ["PROTOCOL AI RAPPELING", "RAPPELING"],
    [10, 100000, 20, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;



[
    "PROTOCOL_AI_RAPPELING_INTO_BUILDING",
    "CHECKBOX",
    ["Rappeling into Building", "Enable or disable Rappeling into buildings"],
    ["PROTOCOL AI RAPPELING", "RAPPELING"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;


