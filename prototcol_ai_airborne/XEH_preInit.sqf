[
    "PROTOCOL_AI_AIRBORNE_ENABLED_PLANE",
    "CHECKBOX",
    ["Enable Airborne", "Enable or disable Airborne protocol"],
    ["PROTOCOL AI AIRBORNE", "AIRBORNE"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_AIRBORNE_ENABLED_HELICOPTER",
    "CHECKBOX",
    ["Enable Airborne from Helicopter", "Enable or disable Airborne from helicopter"],
    ["PROTOCOL AI AIRBORNE", "AIRBORNE"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    "PROTOCOL_AI_AIRBORNE_ENABLED_PLANE",
    "CHECKBOX",
    ["Enable Airborne from Plane", "Enable or disable Airborne from plane"],
    ["PROTOCOL AI AIRBORNE", "AIRBORNE"],
    true,
    1,
    {},
    false
] call CBA_fnc_addSetting;


[
    "PROTOCOL_AI_AIRBORNE_DISTANCE",
    "SLIDER",
    ["Distance airborne to enemy", "The higher the number, the further away the parachute landing will take place; the lower the number, the closer to the enemy the parachute landing will be."],
    ["PROTOCOL AI AIRBORNE", "AIRBORNE"],
    [5, 5000, 500, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;


[
    "PROTOCOL_AI_AIRBORNE_HELICOPTER_HEIGHT",
    "SLIDER",
    ["Helicopter airborne height", "The higher the number, the higher the helicopter will fly before deploying the parachute; the lower the number, the lower the helicopter will fly."],
    ["PROTOCOL AI AIRBORNE", "AIRBORNE"],
    [100, 5000, 150, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;


[
    "PROTOCOL_AI_AIRBORNE_PLANE_HEIGHT",
    "SLIDER",
    ["Plane airborne height", "The higher the number, the higher the plane will fly before deploying the parachute; the lower the number, the lower the plane will fly."],
    ["PROTOCOL AI AIRBORNE", "AIRBORNE"],
    [100, 5000, 250, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;



[
    "PROTOCOL_AI_AIRBORNE_TIME_INTERVAL",
    "SLIDER",
    ["Time interval for parachute deployment", "The higher the number, the longer the time between parachute deployments; the lower the number, the shorter the time between parachute deployments."],
    ["PROTOCOL AI AIRBORNE", "AIRBORNE"],
    [0, 60, 2, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

