[
    "PROTOCOL_AI_JAMMING_ENABLED",
    "CHECKBOX",
    ["Enable Jamming", "Enable or disable jamming protocol"],
    ["PROTOCOL AI JAMMING", "JAMMING"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_JAMMING_RADIUS",
    "SLIDER",
    ["Jamming Radius", "Define the radius of jamming effect in meters"],
    ["PROTOCOL AI JAMMING", "JAMMING"],
    [1, 100000, 200, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_JAMMING_RADIO",
    "CHECKBOX",
    ["Jamming Radio", "enable or disable jamming radio  "],
    ["PROTOCOL AI JAMMING", "JAMMING"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_JAMMING_VOICE_CHAT",
    "CHECKBOX",
    ["Jamming Voice chat", "enable or disable jamming voice chat  "],
    ["PROTOCOL AI JAMMING", "JAMMING"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_JAMMING_CHANNELS",
    "CHECKBOX",
    ["Jamming channels", "enable or disable jamming channels  "],
    ["PROTOCOL AI JAMMING", "JAMMING"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_TFAR_JAMMING",
    "CHECKBOX",
    ["Jamming TFAR", "enable or disable jamming TFAR  "],
    ["PROTOCOL AI JAMMING", "JAMMING"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_ACRE_JAMMING",
    "CHECKBOX",
    ["Jamming ACRE2", "enable or disable jamming ACRE2  "],
    ["PROTOCOL AI JAMMING", "JAMMING"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;


[
    "PROTOCOL_AI_JAMMING_DRONES",
    "CHECKBOX",
    ["Jamming Drones and UAVs", "enable or disable jamming drones and UAVs"],
    ["PROTOCOL AI JAMMING", "JAMMING"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;



[
    "PROTOCOL_AI_JAMMING_SOUND_EFFECT",
    "CHECKBOX",
    ["Jamming sound effects", "enable or disable jamming sound effects  "],
    ["PROTOCOL AI JAMMING", "JAMMING"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;





