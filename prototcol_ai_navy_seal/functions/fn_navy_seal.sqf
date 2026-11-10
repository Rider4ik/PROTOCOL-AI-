
[] spawn {
    private _findShallowWater = {
        params ["_center"];

        private _result = [];

        for "_r" from 5 to 80 step 5 do {
            private _ring = [];

            for "_a" from 0 to 315 step 45 do {
                private _p = [
                    (_center select 0) + (sin _a * _r),
                    (_center select 1) + (cos _a * _r),
                    0
                ];

                if (surfaceIsWater _p) then {
                    private _depth = -(getTerrainHeightASL _p);

                    if (
                        _depth >= 0.1 &&
                        {_depth <= 0.1}
                    ) then {
                        _ring pushBack _p;
                    };
                };
            };

            if (count _ring > 0) exitWith {
                _result = selectRandom _ring;
            };
        };

        _result
    };

    private _isGroupOnLand = {
        params ["_grp", "_boat"];

        private _members = units _grp select {
            alive _x &&
            {_x != driver _boat} &&
            {vehicle _x != _boat}
        };

        if (count _members == 0) exitWith {
            false
        };

        ({!surfaceIsWater (getPosATL _x)} count _members) == count _members
    };

    private _fireAt = {
        params ["_unit", "_target"];

        if (
            alive _unit &&
            alive _target &&
            {vehicle _unit == _unit}
        ) then {
            private _lastFire = _unit getVariable [
                "PROTOCOL_NAVAL_LAST_FIRE",
                -10
            ];

            if (diag_tickTime - _lastFire >= 0.7) then {
                _unit doFire _target;

                _unit setVariable [
                    "PROTOCOL_NAVAL_LAST_FIRE",
                    diag_tickTime
                ];
            };
        };
    };

    private _issueMove = {
        params ["_unit", "_movePos"];

        if (
            alive _unit &&
            {!surfaceIsWater _movePos}
        ) then {
            private _lastMovePos = _unit getVariable [
                "PROTOCOL_NAVAL_LAST_MOVE_POS",
                []
            ];

            if (
                _lastMovePos isEqualTo [] ||
                {_lastMovePos distance2D _movePos > 10} ||
                {_unit distance2D _lastMovePos < 4}
            ) then {
                _unit doMove _movePos;

                _unit setVariable [
                    "PROTOCOL_NAVAL_LAST_MOVE_POS",
                    _movePos
                ];
            };
        };
    };

    private _findEnemy = {
        params ["_grp", "_pos", "_radius"];

        private _enemies = allUnits select {
            alive _x &&
            {side _x != side _grp} &&
            {_x distance2D _pos < _radius} &&
            {!(_x isKindOf "Animal")} &&
            {
                isNull objectParent _x ||
                {vehicle _x isKindOf "LandVehicle"} ||
                {vehicle _x isKindOf "Man"}
            }
        };

        if (count _enemies > 0) then {
            _enemies select 0
        } else {
            objNull
        }
    };

    private _getGroupBoat = {
        params ["_grp"];

        private _boats = [];

        {
            if (
                alive _x &&
                {vehicle _x != _x} &&
                {vehicle _x isKindOf "Ship"}
            ) then {
                _boats pushBackUnique (vehicle _x);
            };
        } forEach (units _grp);

        if (count _boats > 0) then {
            _boats select 0
        } else {
            objNull
        };
    };

    while {true} do {

        {
            private _grp = _x;

            if (
                isNull _grp ||
                {count units _grp == 0}
            ) then {
                continue;
            };

            private _units = units _grp select {
                alive _x
            };

            if (count _units == 0) then {
                continue;
            };

            private _boat = [
                _grp
            ] call _getGroupBoat;

            if (isNull _boat) then {
                continue;
            };

            private _boatDriver = driver _boat;
            private _boatController = _boatDriver;

            if (isNull _boatController) then {
                _boatController = commander _boat;
            };

            private _hasWaypoint = count waypoints _grp > 0;

            private _dismounted = _grp getVariable [
                "PROTOCOL_NAVAL_ASSAULT_DISMOUNTED",
                false
            ];

            if (_dismounted) then {
                {
                    if (
                        alive _x &&
                        {_x != _boatDriver} &&
                        {vehicle _x == _boat}
                    ) then {
                        unassignVehicle _x;
                        moveOut _x;
                        sleep 1;
                        
                    };
                } forEach _units;

                _boat lockCargo true;
            };

            if (
                !_dismounted &&
                {!(_grp getVariable [
                    "PROTOCOL_NAVAL_ASSAULT_ACTIVE",
                    false
                ])}
            ) then {

                private _enemies = allUnits select {
                    alive _x &&
                    {side _x != side _grp} &&
                    {_x distance2D _boat < 800} &&
                    {!(_x isKindOf "Animal")}
                };

                if (count _enemies > 0) then {

                    _grp setVariable [
                        "PROTOCOL_NAVAL_ASSAULT_ACTIVE",
                        true
                    ];

                    _grp setVariable [
                        "PROTOCOL_NAVAL_REBOARD_ALLOWED",
                        false
                    ];

                    private _enemy = selectRandom _enemies;
                    private _enemyPos = getPosATL _enemy;
                    private _boatPos = getPosATL _boat;

                    _grp setBehaviour "COMBAT";
                    _grp setCombatMode "RED";
                    _grp setSpeedMode "FULL";
                    _grp setFormation "WEDGE";
                    _grp enableAttack true;

                    private _dirToBoat = [
                        _enemyPos,
                        _boatPos
                    ] call BIS_fnc_dirTo;

                    private _shoreWaterPos = [];
                    private _probeDistance = 5;

                    while {
                        _probeDistance < 1000 &&
                        {_shoreWaterPos isEqualTo []}
                    } do {

                        private _probePos = [
                            (_enemyPos select 0) + (sin _dirToBoat * _probeDistance),
                            (_enemyPos select 1) + (cos _dirToBoat * _probeDistance),
                            0
                        ];

                        if (surfaceIsWater _probePos) then {
                            _shoreWaterPos = _probePos;
                        };

                        _probeDistance = _probeDistance + 5;
                    };

                    private _landingPos = [];

                    if !(_shoreWaterPos isEqualTo []) then {

                        private _shallow = [];

                        for "_r" from 2 to 60 step 2 do {

                            for "_a" from -90 to 90 step 15 do {

                                private _angle = _dirToBoat + _a;

                                private _probePos = [
                                    (_shoreWaterPos select 0) + (sin _angle * _r),
                                    (_shoreWaterPos select 1) + (cos _angle * _r),
                                    0
                                ];

                                if (surfaceIsWater _probePos) then {

                                    private _depth =
                                        -(getTerrainHeightASL _probePos);

                                    if (
                                        _depth >= 0.1 &&
                                        {_depth <= 0.1}
                                    ) then {
                                        _shallow pushBack _probePos;
                                    };
                                };
                            };

                            if (count _shallow > 0) exitWith {};
                        };

                        if (count _shallow > 0) then {
                            _landingPos = selectRandom _shallow;
                        } else {
                            _landingPos = _shoreWaterPos;
                        };

                    } else {

                        private _fallbackDir = [
                            _boatPos,
                            _enemyPos
                        ] call BIS_fnc_dirTo;

                        _landingPos = [
                            (_boatPos select 0) + (sin _fallbackDir * 80),
                            (_boatPos select 1) + (cos _fallbackDir * 80),
                            0
                        ];
                    };

                    if (!isNull _boatController) then {
                        _boatController doMove _landingPos;
                    };

                    private _approachStart = diag_tickTime;
                    private _disembark = false;

                    while {
                        alive _boat &&
                        {!_disembark}
                    } do {

                        private _boatNow = getPosATL _boat;

                        private _depthNow = if (
                            surfaceIsWater _boatNow
                        ) then {
                            -(getTerrainHeightASL _boatNow)
                        } else {
                            -1
                        };

                        private _enemyNow = allUnits select {
                            alive _x &&
                            {side _x != side _grp} &&
                            {_x distance2D _boat < 300} &&
                            {!(_x isKindOf "Animal")}
                        };

                        if (count _enemyNow > 0) then {
                            _enemy = selectRandom _enemyNow;
                            _enemyPos = getPosATL _enemy;
                        };

                        if (
                            _boat distance2D _landingPos < 35 ||
                            {
                                _depthNow >= 0.1 &&
                                {_depthNow <= 0.1} &&
                                {_boat distance2D _landingPos < 90}
                            } ||
                            {
                                count _enemyNow > 0 &&
                                {_boat distance2D _landingPos < 110} &&
                                {_depthNow >= 0.1} &&
                                {_depthNow <= 0.1}
                            } ||
                            {
                                diag_tickTime - _approachStart > 45 &&
                                {_depthNow >= 0.1 } &&
                                {_depthNow <= 0.1}
                            }
                        ) then {
                            _disembark = true;
                        };

                        if (
                            !_disembark &&
                            {diag_tickTime - _approachStart > 20}
                        ) then {

                            private _emergencyLanding = [
                                getPosATL _boat
                            ] call _findShallowWater;

                            if !(_emergencyLanding isEqualTo []) then {

                                _landingPos = _emergencyLanding;

                                if (!isNull _boatController) then {
                                    _boatController doMove _landingPos;
                                };
                            };
                        };

                        sleep 0.25;
                    };

                    if (alive _boat) then {

                        doStop _boat;

                        {
                            if (
                                alive _x &&
                                {_x != _boatDriver} &&
                                {vehicle _x == _boat}
                            ) then {
                                unassignVehicle _x;
                                doGetOut _x;
                            };
                        } forEach _units;

                        sleep 0.2;

                        {
                            if (
                                alive _x &&
                                {_x != _boatDriver} &&
                                {vehicle _x == _boat}
                            ) then {
                                unassignVehicle _x;
                                moveOut _x;
                                sleep 1;
                            };
                        } forEach _units;

                        private _exitStart = diag_tickTime;

                        while {
                            diag_tickTime - _exitStart < 4 &&
                            {
                                count (
                                    _units select {
                                        alive _x &&
                                        {_x != _boatDriver} &&
                                        {vehicle _x == _boat}
                                    }
                                ) > 0
                            }
                        } do {

                            {
                                if (
                                    alive _x &&
                                    {_x != _boatDriver} &&
                                    {vehicle _x == _boat}
                                ) then {
                                    unassignVehicle _x;
                                    moveOut _x;
                                    sleep 1;
                                };
                            } forEach _units;

                            sleep 0.15;
                        };

                        {
                            if (
                                alive _x &&
                                {_x != _boatDriver} &&
                                {vehicle _x == _boat}
                            ) then {
                                unassignVehicle _x;
                                moveOut _x;
                                sleep 1;
                            };
                        } forEach _units;

                        _boat lockCargo true;

                        sleep 0.5;

                        _grp setVariable [
                            "PROTOCOL_NAVAL_ASSAULT_DISMOUNTED",
                            true
                        ];

                        _grp setVariable [
                            "PROTOCOL_NAVAL_REBOARD_ALLOWED",
                            false
                        ];

                        private _groundUnits = _units select {
                            alive _x &&
                            {_x != _boatDriver} &&
                            {vehicle _x == _x}
                        };

                        {
                            _x setVariable [
                                "PROTOCOL_NAVAL_LAST_MOVE_POS",
                                []
                            ];

                            _x setVariable [
                                "PROTOCOL_NAVAL_LAST_FIRE",
                                -10
                            ];

                            _x setUnitPos "AUTO";
                        } forEach _groundUnits;

                        if (
                            count _groundUnits > 0 &&
                            {!isNull _boatDriver} &&
                            {leader _grp == _boatDriver}
                        ) then {
                            _grp selectLeader (_groundUnits select 0);
                        };

                        if (count _groundUnits > 0) then {

                            _grp setBehaviour "COMBAT";
                            _grp setCombatMode "RED";
                            _grp setSpeedMode "FULL";
                            _grp setFormation "WEDGE";
                            _grp enableAttack true;

                            private _supportUnits = [];
                            private _assaultUnits = [];

                            {
                                if ((_forEachIndex mod 2) == 0) then {
                                    _supportUnits pushBack _x;
                                } else {
                                    _assaultUnits pushBack _x;
                                };
                            } forEach _groundUnits;

                            if (
                                count _assaultUnits == 0 &&
                                {count _supportUnits > 0}
                            ) then {
                                _assaultUnits = [
                                    _supportUnits deleteAt 0
                                ];
                            };

                            private _enemyCheck = [
                                _grp,
                                _landingPos,
                                500
                            ] call _findEnemy;

                            if (!isNull _enemyCheck) then {
                                _enemy = _enemyCheck;
                            } else {
                                _enemy = objNull;
                            };

                            private _lastMove = diag_tickTime;
                            private _lastCoverSearch = -10;
                            private _lastCombatOrder = -10;
                            private _assaultTargets = [];
                            private _supportTargets = [];

                            while {
                                count (
                                    _groundUnits select {
                                        alive _x
                                    }
                                ) > 0
                            } do {

                                private _aliveUnits =
                                    _groundUnits select {
                                        alive _x
                                    };

                                if (count _aliveUnits == 0) exitWith {};

                                private _nearEnemies = allUnits select {
                                    alive _x &&
                                    {side _x != side _grp} &&
                                    {
                                        _x distance2D (
                                            getPosATL (
                                                _aliveUnits select 0
                                            )
                                        ) < 500
                                    } &&
                                    {!(_x isKindOf "Animal")}
                                };

                                if (count _nearEnemies > 0) then {
                                    _enemy = selectRandom _nearEnemies;
                                } else {
                                    if (
                                        isNull _enemy ||
                                        {!alive _enemy}
                                    ) then {
                                        _enemy = objNull;
                                    };
                                };

                                if (
                                    !isNull _enemy &&
                                    {alive _enemy}
                                ) then {

                                    _enemyPos = getPosATL _enemy;

                                    private _centerUnit =
                                        _aliveUnits select 0;

                                    private _centerPos =
                                        getPosATL _centerUnit;

                                    private _attackDir = [
                                        _centerPos,
                                        _enemyPos
                                    ] call BIS_fnc_dirTo;

                                    private _distanceToEnemy =
                                        _centerPos distance2D _enemy;

                                    if (
                                        diag_tickTime -
                                        _lastCoverSearch > 2
                                    ) then {

                                        _assaultTargets = [];
                                        _supportTargets = [];

                                        private _advanceDistance =
                                            if (_distanceToEnemy > 180) then {
                                                35
                                            } else {
                                                20
                                            };

                                        private _advancePos = [
                                            (_centerPos select 0) +
                                            (sin _attackDir * _advanceDistance),
                                            (_centerPos select 1) +
                                            (cos _attackDir * _advanceDistance),
                                            0
                                        ];

                                        {
                                            if (alive _x) then {

                                                private _lane =
                                                    ((_forEachIndex mod 3) - 1) *
                                                    (5 + random 2);

                                                private _laneDir =
                                                    _attackDir + 90;

                                                private _individualPos = [
                                                    (_advancePos select 0) +
                                                    (sin _laneDir * _lane),
                                                    (_advancePos select 1) +
                                                    (cos _laneDir * _lane),
                                                    0
                                                ];

                                                private _cover =
                                                    selectBestPlaces [
                                                        _individualPos,
                                                        35,
                                                        "(7 * trees + 5 * bushes + 5 * houses + 4 * rocks + 3 * forest) * (1 - sea)",
                                                        18,
                                                        5
                                                    ];

                                                if (
                                                    count _cover > 0 &&
                                                    {!surfaceIsWater (
                                                        (_cover select 0) select 0
                                                    )}
                                                ) then {
                                                    _individualPos =
                                                        (_cover select 0) select 0;
                                                };

                                                _assaultTargets pushBack [
                                                    _x,
                                                    _individualPos
                                                ];
                                            };
                                        } forEach _assaultUnits;

                                        {
                                            if (alive _x) then {

                                                private _supportSide =
                                                    if (
                                                        (_forEachIndex mod 2) == 0
                                                    ) then {
                                                        -1
                                                    } else {
                                                        1
                                                    };

                                                private _supportDir =
                                                    _attackDir +
                                                    (
                                                        _supportSide *
                                                        (55 + random 25)
                                                    );

                                                private _supportDistance =
                                                    35 + random 25;

                                                private _supportPos = [
                                                    (_advancePos select 0) +
                                                    (sin _supportDir * _supportDistance),
                                                    (_advancePos select 1) +
                                                    (cos _supportDir * _supportDistance),
                                                    0
                                                ];

                                                private _cover =
                                                    selectBestPlaces [
                                                        _supportPos,
                                                        45,
                                                        "(8 * trees + 6 * bushes + 5 * houses + 4 * rocks + 3 * forest) * (1 - sea)",
                                                        20,
                                                        5
                                                    ];

                                                if (
                                                    count _cover > 0 &&
                                                    {!surfaceIsWater (
                                                        (_cover select 0) select 0
                                                    )}
                                                ) then {
                                                    _supportPos =
                                                        (_cover select 0) select 0;
                                                };

                                                _supportTargets pushBack [
                                                    _x,
                                                    _supportPos
                                                ];
                                            };
                                        } forEach _supportUnits;

                                        _lastCoverSearch = diag_tickTime;
                                    };

                                    if (
                                        diag_tickTime -
                                        _lastCombatOrder > 0.75
                                    ) then {

                                        {
                                            _x params [
                                                "_unit",
                                                "_movePos"
                                            ];

                                            if (
                                                alive _unit &&
                                                {_unit distance2D _enemy > 15}
                                            ) then {
                                                [
                                                    _unit,
                                                    _movePos
                                                ] call _issueMove;

                                                [
                                                    _unit,
                                                    _enemy
                                                ] call _fireAt;
                                            };
                                        } forEach _assaultTargets;

                                        {
                                            _x params [
                                                "_unit",
                                                "_movePos"
                                            ];

                                            if (alive _unit) then {
                                                if (
                                                    _unit distance2D _enemy > 45
                                                ) then {
                                                    [
                                                        _unit,
                                                        _movePos
                                                    ] call _issueMove;
                                                };
                                            };
                                        } forEach _supportTargets;

                                        if (_distanceToEnemy <= 90) then {
                                            {
                                                if (alive _x) then {
                                                    [
                                                        _x,
                                                        _enemy
                                                    ] call _fireAt;
                                                };
                                            } forEach _aliveUnits;
                                        };

                                        _lastCombatOrder =
                                            diag_tickTime;
                                    };

                                    {
                                        if (
                                            alive _x &&
                                            {damage _x > 0.35}
                                        ) then {

                                            private _retreat =
                                                selectBestPlaces [
                                                    getPosATL _x,
                                                    45,
                                                    "(8 * trees + 6 * bushes + 5 * houses + 4 * rocks + 3 * forest) * (1 - sea)",
                                                    20,
                                                    5
                                                ];

                                            if (count _retreat > 0) then {

                                                private _retreatPos =
                                                    (_retreat select 0) select 0;

                                                if (
                                                    !surfaceIsWater _retreatPos
                                                ) then {
                                                    [
                                                        _x,
                                                        _retreatPos
                                                    ] call _issueMove;

                                                    [
                                                        _x,
                                                        _enemy
                                                    ] call _fireAt;
                                                };
                                            };
                                        };
                                    } forEach _aliveUnits;
                                };

                                if (
                                    diag_tickTime - _lastMove > 2 &&
                                    {!isNull _enemy} &&
                                    {alive _enemy}
                                ) then {

                                    private _newEnemies = allUnits select {
                                        alive _x &&
                                        {side _x != side _grp} &&
                                        {_x distance2D _enemy < 450} &&
                                        {!(_x isKindOf "Animal")}
                                    };

                                    if (count _newEnemies > 0) then {
                                        _enemy =
                                            selectRandom _newEnemies;
                                    };

                                    _lastMove = diag_tickTime;
                                };

                                {
                                    if (
                                        alive _x &&
                                        {_x != _boatDriver} &&
                                        {vehicle _x == _boat}
                                    ) then {
                                        unassignVehicle _x;
                                        moveOut _x;
                                        sleep 1;
                                    };
                                } forEach _units;

                                _boat lockCargo true;

                                sleep 0.35;
                            };

                            {
                                if (alive _x) then {
                                    _x setUnitPos "AUTO";
                                    _x doFollow leader _grp;

                                    _x setVariable [
                                        "PROTOCOL_NAVAL_LAST_MOVE_POS",
                                        []
                                    ];
                                };
                            } forEach _groundUnits;
                        };
                    };

                    _grp setVariable [
                        "PROTOCOL_NAVAL_ASSAULT_ACTIVE",
                        false
                    ];
                };
            };
        } forEach allGroups;

        sleep 1;
    };
};
[] spawn {
    private _findShallowWater = {
        params ["_center"];
        private _result = [];
        for "_r" from 5 to 80 step 5 do {
            private _ring = [];
            for "_a" from 0 to 315 step 45 do {
                private _p = [ (_center select 0) + (sin _a * _r), (_center select 1) + (cos _a * _r), 0 ];
                if (surfaceIsWater _p) then {
                    private _depth = -(getTerrainHeightASL _p);
                    if ( _depth >= 0.09 && {_depth <= 0.11} ) then { _ring pushBack _p; };
                };
            };
            if (count _ring > 0) exitWith { _result = selectRandom _ring; };
        };
        _result
    };
    private _isGroupOnLand = {
        params ["_grp", "_boat"];
        private _members = units _grp select { alive _x && {_x != driver _boat} && {vehicle _x != _boat} };
        if (count _members == 0) exitWith { false };
        ({!surfaceIsWater (getPosATL _x)} count _members) == count _members
    };
    private _fireAt = {
        params ["_unit", "_target"];
        if ( alive _unit && alive _target && {vehicle _unit == _unit} ) then {
            private _lastFire = _unit getVariable [ "PROTOCOL_NAVAL_LAST_FIRE", -10 ];
            if (diag_tickTime - _lastFire >= 0.7) then {
                _unit doFire _target;
                _unit setVariable [ "PROTOCOL_NAVAL_LAST_FIRE", diag_tickTime ];
            };
        };
    };
    private _issueMove = {
        params ["_unit", "_movePos"];
        if ( alive _unit && {!surfaceIsWater _movePos} ) then {
            private _lastMovePos = _unit getVariable [ "PROTOCOL_NAVAL_LAST_MOVE_POS", [] ];
            if ( _lastMovePos isEqualTo [] || {_lastMovePos distance2D _movePos > 10} || {_unit distance2D _lastMovePos < 4} ) then {
                _unit doMove _movePos;
                _unit setVariable [ "PROTOCOL_NAVAL_LAST_MOVE_POS", _movePos ];
            };
        };
    };
    private _findEnemy = {
        params ["_grp", "_pos", "_radius"];
        private _enemies = allUnits select { alive _x && {side _x != side _grp} && {_x distance2D _pos < _radius} && {!(_x isKindOf "Animal")} && { isNull objectParent _x || {vehicle _x isKindOf "LandVehicle"} || {vehicle _x isKindOf "Man"} } };
        if (count _enemies > 0) then { _enemies select 0 } else { objNull };
    };
    private _getGroupBoat = {
        params ["_grp"];
        private _boats = [];
        {
            if ( alive _x && {vehicle _x != _x} && {vehicle _x isKindOf "Ship"} ) then { _boats pushBackUnique (vehicle _x); };
        } forEach (units _grp);
        if (count _boats > 0) then { _boats select 0 } else { objNull };
    };
    while {true} do {
        {
            private _grp = _x;
            if ( isNull _grp || {count units _grp == 0} ) then { continue; };
            private _units = units _grp select { alive _x };
            if (count _units == 0) then { continue; };
            private _boat = [ _grp ] call _getGroupBoat;
            if (isNull _boat) then { continue; };
            private _boatDriver = driver _boat;
            private _boatController = _boatDriver;
            if (isNull _boatController) then { _boatController = commander _boat; };
            private _hasWaypoint = count waypoints _grp > 0;
            private _dismounted = _grp getVariable [ "PROTOCOL_NAVAL_ASSAULT_DISMOUNTED", false ];
            if (_dismounted) then {
                {
                    if ( alive _x && {_x != _boatDriver} && {vehicle _x == _boat} ) then {
                        unassignVehicle _x; moveOut _x; sleep 1;
                    };
                } forEach _units;
                _boat lockCargo true;
            };
            if ( !_dismounted && {!(_grp getVariable [ "PROTOCOL_NAVAL_ASSAULT_ACTIVE", false ])} ) then {
                private _enemies = allUnits select { alive _x && {side _x != side _grp} && {_x distance2D _boat < 800} && {!(_x isKindOf "Animal")} };
                if (count _enemies > 0) then {
                    _grp setVariable [ "PROTOCOL_NAVAL_ASSAULT_ACTIVE", true ];
                    _grp setVariable [ "PROTOCOL_NAVAL_REBOARD_ALLOWED", false ];
                    private _enemy = selectRandom _enemies;
                    private _enemyPos = getPosATL _enemy;
                    private _boatPos = getPosATL _boat;
                    _grp setBehaviour "COMBAT";
                    _grp setCombatMode "RED";
                    _grp setSpeedMode "FULL";
                    _grp setFormation "WEDGE";
                    _grp enableAttack true;
                    private _dirToBoat = [ _enemyPos, _boatPos ] call BIS_fnc_dirTo;
                    private _shoreWaterPos = [];
                    private _probeDistance = 5;
                    while { _probeDistance < 1000 && {_shoreWaterPos isEqualTo []} } do {
                        private _probePos = [ (_enemyPos select 0) + (sin _dirToBoat * _probeDistance), (_enemyPos select 1) + (cos _dirToBoat * _probeDistance), 0 ];
                        if (surfaceIsWater _probePos) then { _shoreWaterPos = _probePos; };
                        _probeDistance = _probeDistance + 5;
                    };
                    private _landingPos = [];
                    if !(_shoreWaterPos isEqualTo []) then {
                        private _shallow = [];
                        for "_r" from 2 to 60 step 2 do {
                            for "_a" from -90 to 90 step 15 do {
                                private _angle = _dirToBoat + _a;
                                private _probePos = [ (_shoreWaterPos select 0) + (sin _angle * _r), (_shoreWaterPos select 1) + (cos _angle * _r), 0 ];
                                if (surfaceIsWater _probePos) then {
                                    private _depth = -(getTerrainHeightASL _probePos);
                                    if ( _depth >= 0.09 && {_depth <= 0.11} ) then { _shallow pushBack _probePos; };
                                };
                            };
                            if (count _shallow > 0) exitWith {};
                        };
                        if (count _shallow > 0) then { _landingPos = selectRandom _shallow; } else { _landingPos = _shoreWaterPos; };
                    } else {
                        private _fallbackDir = [ _boatPos, _enemyPos ] call BIS_fnc_dirTo;
                        _landingPos = [ (_boatPos select 0) + (sin _fallbackDir * 80), (_boatPos select 1) + (cos _fallbackDir * 80), 0 ];
                    };
                    if (!isNull _boatController) then { _boatController doMove _landingPos; };
                    private _approachStart = diag_tickTime;
                    private _disembark = false;
                    while { alive _boat && {!_disembark} } do {
                        private _boatNow = getPosATL _boat;
                        private _depthNow = if ( surfaceIsWater _boatNow ) then { -(getTerrainHeightASL _boatNow) } else { -1 };
                        private _enemyNow = allUnits select { alive _x && {side _x != side _grp} && {_x distance2D _boat < 300} && {!(_x isKindOf "Animal")} };
                        if (count _enemyNow > 0) then { _enemy = selectRandom _enemyNow; _enemyPos = getPosATL _enemy; };
                        if ( _boat distance2D _landingPos < 35 || { _depthNow >= 0.09 && {_depthNow <= 0.11} && {_boat distance2D _landingPos < 90} } || { count _enemyNow > 0 && {_boat distance2D _landingPos < 110} && {_depthNow >= 0.09} && {_depthNow <= 0.11} } || { diag_tickTime - _approachStart > 45 && {_depthNow >= 0.09 } && {_depthNow <= 0.11} } ) then { _disembark = true; };
                        if ( !_disembark && {diag_tickTime - _approachStart > 20} ) then {
                            private _emergencyLanding = [ getPosATL _boat ] call _findShallowWater;
                            if !(_emergencyLanding isEqualTo []) then {
                                _landingPos = _emergencyLanding;
                                if (!isNull _boatController) then { _boatController doMove _landingPos; };
                            };
                        };
                        sleep 0.25;
                    };
                    if (alive _boat) then {
                        doStop _boat;
                        {
                            if ( alive _x && {_x != _boatDriver} && {vehicle _x == _boat} ) then { unassignVehicle _x; doGetOut _x; };
                        } forEach _units;
                        sleep 0.2;
                        {
                            if ( alive _x && {_x != _boatDriver} && {vehicle _x == _boat} ) then { unassignVehicle _x; moveOut _x; sleep 1; };
                        } forEach _units;
                        private _exitStart = diag_tickTime;
                        while { diag_tickTime - _exitStart < 4 && { count ( _units select { alive _x && {_x != _boatDriver} && {vehicle _x == _boat} } ) > 0 } } do {
                            {
                                if ( alive _x && {_x != _boatDriver} && {vehicle _x == _boat} ) then { unassignVehicle _x; moveOut _x; sleep 1; };
                            } forEach _units;
                            sleep 0.15;
                        };
                        {
                            if ( alive _x && {_x != _boatDriver} && {vehicle _x == _boat} ) then { unassignVehicle _x; moveOut _x; sleep 1; };
                        } forEach _units;
                        _boat lockCargo true;
                        sleep 0.5;
                        _grp setVariable [ "PROTOCOL_NAVAL_ASSAULT_DISMOUNTED", true ];
                        _grp setVariable [ "PROTOCOL_NAVAL_REBOARD_ALLOWED", false ];
                        private _groundUnits = _units select { alive _x && {_x != _boatDriver} && {vehicle _x == _x} };
                        {
                            _x setVariable [ "PROTOCOL_NAVAL_LAST_MOVE_POS", [] ];
                            _x setVariable [ "PROTOCOL_NAVAL_LAST_FIRE", -10 ];
                            _x setUnitPos "AUTO";
                        } forEach _groundUnits;
                        if ( count _groundUnits > 0 && {!isNull _boatDriver} && {leader _grp == _boatDriver} ) then { _grp selectLeader (_groundUnits select 0); };
                        if (count _groundUnits > 0) then {
                            private _smoker = _groundUnits select 0;
                            _smoker addMagazine "SmokeShell";
                            _smoker forceWeaponFire ["SmokeShellMuzzle", "SmokeShellMuzzle"];
                            _grp setBehaviour "COMBAT";
                            _grp setCombatMode "RED";
                            _grp setSpeedMode "FULL";
                            _grp setFormation "WEDGE";
                            _grp enableAttack true;
                            private _supportUnits = [];
                            private _assaultUnits = [];
                            {
                                if ((_forEachIndex mod 2) == 0) then { _supportUnits pushBack _x; } else { _assaultUnits pushBack _x; };
                            } forEach _groundUnits;
                            if ( count _assaultUnits == 0 && {count _supportUnits > 0} ) then { _assaultUnits = [ _supportUnits deleteAt 0 ]; };
                            private _enemyCheck = [ _grp, _landingPos, 500 ] call _findEnemy;
                            if (!isNull _enemyCheck) then { _enemy = _enemyCheck; } else { _enemy = objNull; };
                            private _lastMove = diag_tickTime;
                            private _lastCoverSearch = -10;
                            private _lastCombatOrder = -10;
                            private _assaultTargets = [];
                            private _supportTargets = [];
                            while { count ( _groundUnits select { alive _x } ) > 0 } do {
                                private _aliveUnits = _groundUnits select { alive _x };
                                if (count _aliveUnits == 0) exitWith {};
                                private _nearEnemies = allUnits select { alive _x && {side _x != side _grp} && { _x distance2D ( getPosATL ( _aliveUnits select 0 ) ) < 500 } && {!(_x isKindOf "Animal")} };
                                if (count _nearEnemies > 0) then { _enemy = selectRandom _nearEnemies; } else { if ( isNull _enemy || {!alive _enemy} ) then { _enemy = objNull; }; };
                                if ( !isNull _enemy && {alive _enemy} ) then {
                                    _enemyPos = getPosATL _enemy;
                                    private _centerUnit = _aliveUnits select 0;
                                    private _centerPos = getPosATL _centerUnit;
                                    private _attackDir = [ _centerPos, _enemyPos ] call BIS_fnc_dirTo;
                                    private _distanceToEnemy = _centerPos distance2D _enemy;
                                    if ( diag_tickTime - _lastCoverSearch > 2 ) then {
                                        _assaultTargets = [];
                                        _supportTargets = [];
                                        private _advanceDistance = if (_distanceToEnemy > 180) then { 35 } else { 20 };
                                        private _advancePos = [ (_centerPos select 0) + (sin _attackDir * _advanceDistance), (_centerPos select 1) + (cos _attackDir * _advanceDistance), 0 ];
                                        {
                                            if (alive _x) then {
                                                private _lane = ((_forEachIndex mod 3) - 1) * (5 + random 2);
                                                private _laneDir = _attackDir + 90;
                                                private _individualPos = [ (_advancePos select 0) + (sin _laneDir * _lane), (_advancePos select 1) + (cos _laneDir * _lane), 0 ];
                                                if (surfaceIsWater getPosATL _x) then {
                                                    private _land = selectBestPlaces [getPosATL _x, 300, "1 - sea", 20, 1];
                                                    if (count _land > 0) then { _individualPos = (_land select 0) select 0; };
                                                } else {
                                                    private _cover = selectBestPlaces [ _individualPos, 35, "(7 * trees + 5 * bushes + 5 * houses + 4 * rocks + 3 * forest) * (1 - sea)", 18, 5 ];
                                                    if ( count _cover > 0 && {!surfaceIsWater ( (_cover select 0) select 0 )} ) then { _individualPos = (_cover select 0) select 0; };
                                                };
                                                _assaultTargets pushBack [ _x, _individualPos ];
                                            };
                                        } forEach _assaultUnits;
                                        {
                                            if (alive _x) then {
                                                private _supportSide = if ( (_forEachIndex mod 2) == 0 ) then { -1 } else { 1 };
                                                private _supportDir = _attackDir + ( _supportSide * (55 + random 25) );
                                                private _supportDistance = 35 + random 25;
                                                private _supportPos = [ (_advancePos select 0) + (sin _supportDir * _supportDistance), (_advancePos select 1) + (cos _supportDir * _supportDistance), 0 ];
                                                if (surfaceIsWater getPosATL _x) then {
                                                    private _land = selectBestPlaces [getPosATL _x, 300, "1 - sea", 20, 1];
                                                    if (count _land > 0) then { _supportPos = (_land select 0) select 0; };
                                                } else {
                                                    private _cover = selectBestPlaces [ _supportPos, 45, "(8 * trees + 6 * bushes + 5 * houses + 4 * rocks + 3 * forest) * (1 - sea)", 20, 5 ];
                                                    if ( count _cover > 0 && {!surfaceIsWater ( (_cover select 0) select 0 )} ) then { _supportPos = (_cover select 0) select 0; };
                                                };
                                                _supportTargets pushBack [ _x, _supportPos ];
                                            };
                                        } forEach _supportUnits;
                                        _lastCoverSearch = diag_tickTime;
                                    };
                                    if ( diag_tickTime - _lastCombatOrder > 0.75 ) then {
                                        {
                                            _x params [ "_unit", "_movePos" ];
                                            if ( alive _unit && {_unit distance2D _enemy > 15} ) then {
                                                [ _unit, _movePos ] call _issueMove;
                                                [ _unit, _enemy ] call _fireAt;
                                            };
                                        } forEach _assaultTargets;
                                        {
                                            _x params [ "_unit", "_movePos" ];
                                            if (alive _unit) then {
                                                if ( _unit distance2D _enemy > 45 ) then {
                                                    [ _unit, _movePos ] call _issueMove;
                                                };
                                            };
                                        } forEach _supportTargets;
                                        if (_distanceToEnemy <= 90) then {
                                            { if (alive _x) then { [ _x, _enemy ] call _fireAt; }; } forEach _aliveUnits;
                                        };
                                        _lastCombatOrder = diag_tickTime;
                                    };
                                    {
                                        if ( alive _x && {damage _x > 0.35} ) then {
                                            private _retreat = selectBestPlaces [ getPosATL _x, 45, "(8 * trees + 6 * bushes + 5 * houses + 4 * rocks + 3 * forest) * (1 - sea)", 20, 5 ];
                                            if (count _retreat > 0) then {
                                                private _retreatPos = (_retreat select 0) select 0;
                                                if ( !surfaceIsWater _retreatPos ) then { [ _x, _retreatPos ] call _issueMove; [ _x, _enemy ] call _fireAt; };
                                            };
                                        };
                                    } forEach _aliveUnits;
                                };
                                if ( diag_tickTime - _lastMove > 2 && {!isNull _enemy} && {alive _enemy} ) then {
                                    private _newEnemies = allUnits select { alive _x && {side _x != side _grp} && {_x distance2D _enemy < 450} && {!(_x isKindOf "Animal")} };
                                    if (count _newEnemies > 0) then { _enemy = selectRandom _newEnemies; };
                                    _lastMove = diag_tickTime;
                                };
                                {
                                    if ( alive _x && {_x != _boatDriver} && {vehicle _x == _boat} ) then { unassignVehicle _x; moveOut _x; sleep 1; };
                                } forEach _units;
                                _boat lockCargo true;
                                sleep 0.35;
                            };
                            {
                                if (alive _x) then {
                                    _x setUnitPos "AUTO";
                                    _x doFollow leader _grp;
                                    _x setVariable [ "PROTOCOL_NAVAL_LAST_MOVE_POS", [] ];
                                };
                            } forEach _groundUnits;
                        };
                    };
                    _grp setVariable [ "PROTOCOL_NAVAL_ASSAULT_ACTIVE", false ];
                };
            };
        } forEach allGroups;
        sleep 1;
    };
};