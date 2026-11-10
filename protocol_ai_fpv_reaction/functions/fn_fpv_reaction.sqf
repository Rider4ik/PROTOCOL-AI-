[] spawn {
    if (isNil "PROTOCOL_AI_FPV_REACTION_ENABLED") then {PROTOCOL_AI_FPV_REACTION_ENABLED = true};
    if (isNil "PROTOCOL_AI_FPV_REACTION_UNITS_ENABLED") then {PROTOCOL_AI_FPV_REACTION_UNITS_ENABLED = true};
    if (isNil "PROTOCOL_AI_FPV_REACTION_CARS_ENABLED") then {PROTOCOL_AI_FPV_REACTION_CARS_ENABLED = true};

    _PROTOCOL_FPV_REACTION_UNIT = {
        params ["_grp"];
        if (isNull _grp) exitWith {};
        private _units = units _grp;
        if ((count _units) == 0) exitWith {};

        {
            private _unit = _x;
            if (!alive _unit) then {continue};
            if (vehicle _unit != _unit) then {continue};

            private _fpv = objNull;

            {
                if (
                    alive _x &&
                    (_x isKindOf "Helicopter") &&
                    (_unit distance _x < 250)
                ) exitWith {
                    _fpv = _x;
                };
            } forEach allUnitsUAV;

            if (isNull _fpv) then {
                _fpv = _unit findNearestEnemy _unit;
                if (
                    isNull _fpv ||
                    !(_fpv isKindOf "Helicopter") ||
                    {_unit distance _fpv > 250}
                ) then {
                    _fpv = objNull;
                };
            };

            if (isNull _fpv) then {
                _unit setVariable ["FPV_RUN", false];
                continue;
            };

            if (_unit getVariable ["FPV_RUN", false]) then {
                continue;
            };

            _unit setVariable ["FPV_RUN", true];

            [_unit, _fpv] spawn {
                params ["_u", "_fpv"];

                if (
                    isNull _u ||
                    isNull _fpv ||
                    !alive _u ||
                    !alive _fpv
                ) exitWith {
                    if (!isNull _u) then {_u setVariable ["FPV_RUN", false]};
                };

                private _armed =
                    (primaryWeapon _u != "") ||
                    (handgunWeapon _u != "") ||
                    (secondaryWeapon _u != "");

                if (_armed) then {
                    private _cover = nearestTerrainObjects [
                        _u,
                        [
                            "TREE",
                            "SMALL TREE",
                            "BUSH",
                            "ROCK",
                            "ROCKS",
                            "WALL",
                            "FENCE",
                            "HOUSE",
                            "BUILDING"
                        ],
                        50,
                        false,
                        true
                    ];

                    private _targetPos = [];
                    private _bestCover = objNull;
                    private _availableCover = _cover select {
                        time > (_x getVariable ["FPV_COVER_CLAIMED", 0]) &&
                        {_u distance _x > 1.5}
                    };

                    if (count _availableCover > 0) then {
                        _bestCover = selectRandom (_availableCover select [0, 5 min (count _availableCover)]);
                        _bestCover setVariable ["FPV_COVER_CLAIMED", time + 30];
                    };

                    if (!isNull _bestCover) then {
                        _targetPos = _bestCover getPos [
                            2 + random 2,
                            _fpv getDir _bestCover
                        ];
                    } else {
                        private _spreadAngle = -50 + (random 100);
                        private _dir = (_fpv getDir _u) + _spreadAngle;
                        _targetPos = _u getPos [30 + (random 15), _dir];
                    };

                    _u setSpeedMode "FULL";
                    _u allowSprint true;
                    _u forceSpeed -1;
                    _u setUnitPos "UP";
                    _u doMove _targetPos;

                    private _randomPos = floor (random 2) + 1;
                    switch (_randomPos) do {
                        case 1: {_u setUnitPos "MIDDLE"};
                        case 2: {_u setUnitPos "DOWN"};
                    };

                    if (alive _u && {alive _fpv}) then {
                        _u doTarget _fpv;
                        _u doFire _fpv;
                    };

                    waitUntil {
                        sleep 0.25;
                        !alive _u || !alive _fpv || (_u distance2D _targetPos < 3)
                    };

                    if (!alive _u || !alive _fpv) exitWith {
                        if (!isNull _u) then {_u setVariable ["FPV_RUN", false]};
                    };
                } else {
                    _u setSpeedMode "FULL";
                    _u allowSprint true;
                    _u forceSpeed -1;
                    _u setUnitPos "UP";

                    private _escapeDir = (_fpv getDir _u) + (-20 + random 40);
                    private _escapePos = _u getPos [150, _escapeDir];
                    _u doMove _escapePos;

                    while {
                        alive _u &&
                        alive _fpv &&
                        (_u distance _fpv < 200)
                    } do {
                        if (_u distance _fpv <= 20) then {
                            private _randomPos = floor (random 2) + 1;
                            switch (_randomPos) do {
                                case 1: {_u setUnitPos "MIDDLE"};
                                case 2: {_u setUnitPos "DOWN"};
                            };
                            doStop _u;
                        } else {
                            _u setSpeedMode "FULL";
                            _u allowSprint true;
                            _u forceSpeed -1;
                            _u setUnitPos "UP";
                            _escapeDir = (_fpv getDir _u) + (-15 + random 30);
                            _escapePos = _u getPos [120, _escapeDir];
                            _u doMove _escapePos;
                        };
                        sleep 1.5;
                    };
                };

                if (!isNull _u && {alive _u}) then {
                    _u forceSpeed -1;
                    _u setUnitPos "AUTO";
                };
                if (!isNull _u) then {_u setVariable ["FPV_RUN", false]};
            };
        } forEach _units;
    };

    while {true} do {
        if (PROTOCOL_AI_FPV_REACTION_ENABLED && {PROTOCOL_AI_FPV_REACTION_UNITS_ENABLED}) then {
            {
                private _grp = _x;
                if (!isNull _grp && {count units _grp > 0}) then {
                    if ((units _grp findIf {vehicle _x != _x}) == -1) then {
                        [_grp] call _PROTOCOL_FPV_REACTION_UNIT;
                    };
                };
            } forEach allGroups;
        };
        sleep 1;
    };
};

[] spawn {
    _PROTOCOL_FPV_REACTION_CAR = {
        params ["_grp"];
        if (isNull _grp) exitWith {};

        {
            private _unit = _x;
            private _veh = vehicle _unit;

            if (
                _veh == _unit ||
                {_veh getVariable ["isFleeingHeli", false]}
            ) then {
                continue;
            };

            private _airTargets = _veh nearEntities ["Air", 3000];
            private _enemy = objNull;

            {
                if (
                    alive _x &&
                    {_x != _veh} &&
                    {(side _x) getFriend (side _veh) < 0.6} &&
                    {_x isKindOf "Helicopter" || {_x isKindOf "UAV"}}
                ) exitWith {
                    _enemy = _x;
                };
            } forEach _airTargets;

            if (isNull _enemy) then {
                continue;
            };

            _veh setVariable ["isFleeingHeli", true];

            [_veh, _grp, _enemy] spawn {
                params ["_veh", "_grp", "_enemy"];

                if (isNull _veh || {!alive _veh}) exitWith {
                    if (!isNull _veh) then {_veh setVariable ["isFleeingHeli", false]};
                };

                private _driver = driver _veh;
                if (isNull _driver) exitWith {
                    _veh setVariable ["isFleeingHeli", false];
                };

                private _escapeDir = _enemy getDir _veh;
                private _escapePos = _veh getPos [2000, _escapeDir];

                _grp setSpeedMode "FULL";
                _grp setBehaviour "CARELESS";
                _driver forceSpeed 0;
                _driver doMove (getPos _veh);

                waitUntil {
                    sleep 0.25;
                    !alive _veh ||
                    {isNull (driver _veh)} ||
                    {abs speed _veh < 1}
                };

                if (isNull _veh || {!alive _veh} || {isNull (driver _veh)}) exitWith {
                    if (!isNull _veh) then {_veh setVariable ["isFleeingHeli", false]};
                };

                sleep 1;

                {
                    private _person = _x select 0;
                    private _role = _x select 1;
                    if (
                        alive _person &&
                        {!(_role in ["driver", "gunner", "commander"])}
                    ) then {
                        unassignVehicle _person;
                        moveOut _person;
                        sleep 1;
                    };
                } forEach fullCrew _veh;

                _veh limitSpeed 200;
                sleep 2;

                if (alive _veh && {!isNull (driver _veh)}) then {
                    _driver forceSpeed -1;
                    _driver doMove _escapePos;
                };

                sleep 120;

                if (!isNull _veh && {alive _veh}) then {
                    _veh setVariable ["isFleeingHeli", false];
                    if (!isNull _grp) then {
                        _grp setBehaviour "AWARE";
                        _grp setSpeedMode "NORMAL";
                    };
                };
            };
        } forEach units _grp;
    };

    while {true} do {
        if (PROTOCOL_AI_FPV_REACTION_ENABLED && {PROTOCOL_AI_FPV_REACTION_CARS_ENABLED}) then {
            {
                private _grp = _x;
                if (!isNull _grp && {count units _grp > 0}) then {
                    [_grp] call _PROTOCOL_FPV_REACTION_CAR;
                };
            } forEach allGroups;
        };
        sleep 2;
    };
};



