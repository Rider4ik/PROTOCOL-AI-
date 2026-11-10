[
    "PROTOCOL_AI_ARTILLERY_ENABLED",
    "CHECKBOX",
    ["Enable Artillery", "Enable or disable Artillery protocol"],
    ["PROTOCOL AI ARTILLERY", "ARTILLERY"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_ARTILLERY_RELOCATE",
    "CHECKBOX",
    ["Relocate Artillery", "Enable artillery relocation after firing"],
    ["PROTOCOL AI ARTILLERY", "ARTILLERY"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_ARTILLERY_COUNTERBATTERY",
    "CHECKBOX",
    ["Counter-Battery", "Enable counter-battery artillery fire against enemy artillery"],
    ["PROTOCOL AI ARTILLERY", "ARTILLERY"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;



[
    "PROTOCOL_AI_ARTILLERY_RANDOM_ROUNDS",
    "CHECKBOX",
    ["Random Rounds", "Enable random number of rounds for Artillery"],
    ["PROTOCOL AI ARTILLERY", "ARTILLERY"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_ARTILLERY_AMOUNT_ROUND",
    "SLIDER",
    ["Artillery Rounds", "Number of rounds for Artillery if random rounds is disabled"],
    ["PROTOCOL AI ARTILLERY", "ARTILLERY"],
    [1, 40, 5, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;
