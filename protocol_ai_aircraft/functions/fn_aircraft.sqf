
[] spawn
{   if (isNil "PROTOCOL_AI_AIRCRAFT_ENABLED") then {PROTOCOL_AI_AIRCRAFT_ENABLED = true};
  	if (isNil "PROTOCOL_AI_HELI") then {PROTOCOL_AI_HELI = true};
	_PROTOCOL_HELI = {
    {
        private _heli = _x;

        if (
            alive _heli &&
            {canMove _heli} &&
            {_heli isKindOf "Helicopter"} &&
            {!(_heli getVariable ["HELO_ATTACK_PROTOCOL", false])}
        ) then {
            _heli setVariable ["HELO_ATTACK_PROTOCOL", true];

            [_heli] spawn {
                params ["_heli"];

                while {alive _heli && {canMove _heli}} do {
                    private _pilot = driver _heli;

                    if (isNull _pilot || {!alive _pilot}) exitWith {
                        _heli setVariable ["HELO_ATTACK_PROTOCOL", false];
                    };

                    private _side = side group _pilot;
                    private _targets = [];

                    {
                        if (
                            alive _x &&
                            {_x != _heli} &&
                            {_x isKindOf "Man" || _x isKindOf "Car"} &&
                            {!(_x isKindOf "Air")} &&
                            {_side getFriend (side _x) < 0.6} &&
                            {_heli distance2D _x < 4500}
                        ) then {
                            _targets pushBack _x;
                        };
                    } forEach (allUnits + vehicles);

                    if (count _targets == 0) then {
                        sleep 3;
                        continue;
                    };

                    private _target = objNull;
                    private _bestScore = 1e10;

                    {
                        private _d = _heli distance2D _x;
                        private _priority = 0;

                        if (_x isKindOf "Car") then {
                            _priority = -1200;
                        };

                        if (_x isKindOf "Man") then {
                            _priority = -500;
                        };

                        private _score = _d + _priority + random 400;

                        if (_score < _bestScore) then {
                            _bestScore = _score;
                            _target = _x;
                        };
                    } forEach _targets;

                    if (isNull _target) then {
                        sleep 2;
                        continue;
                    };

                    private _weapons = weapons _heli;
                    private _rocketWeapons = [];
                    private _bombWeapons = [];
                    private _ammoState = magazinesAmmo _heli;

                    {
                        private _weapon = _x;
                        private _weaponText = toLower (
                            _weapon + " " +
                            (getText (configFile >> "CfgWeapons" >> _weapon >> "displayName"))
                        );

                        private _rocketFound = false;
                        private _bombFound = false;

                        {
                            private _mag = _x;
                            private _magText = toLower (
                                _mag + " " +
                                (getText (configFile >> "CfgMagazines" >> _mag >> "displayName"))
                            );

                            private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
                            private _ammoText = toLower _ammo;
                            private _simulation = toLower (getText (configFile >> "CfgAmmo" >> _ammo >> "simulation"));
                            private _hit = getNumber (configFile >> "CfgAmmo" >> _ammo >> "hit");
                            private _indirectHit = getNumber (configFile >> "CfgAmmo" >> _ammo >> "indirectHit");

                            private _hasAmmo = false;

                            {
                                if ((_x select 0) == _mag && {(_x select 1) > 0}) exitWith {
                                    _hasAmmo = true;
                                };
                            } forEach _ammoState;

                            if (_hasAmmo) then {
                                if (
                                    _simulation in ["shotrocket","shotmissile"] ||
                                    {_weaponText find "rocket" > -1} ||
                                    {_weaponText find "missile" > -1} ||
                                    {_weaponText find "hydra" > -1} ||
                                    {_weaponText find "ffar" > -1} ||
                                    {_weaponText find "s-5" > -1} ||
                                    {_weaponText find "s-8" > -1} ||
                                    {_weaponText find "s8" > -1} ||
                                    {_weaponText find "s-13" > -1} ||
                                    {_weaponText find "s13" > -1} ||
                                    {_weaponText find "s-24" > -1} ||
                                    {_weaponText find "s24" > -1} ||
                                    {_ammoText find "rocket" > -1} ||
                                    {_ammoText find "missile" > -1}
                                ) then {
                                    _rocketFound = true;
                                };

                                if (
                                    _magText find "bomb" > -1 ||
                                    {_weaponText find "bomb" > -1} ||
                                    {_magText find "fab" > -1} ||
                                    {_magText find "ofab" > -1} ||
                                    {_magText find "odab" > -1} ||
                                    {_magText find "gbu" > -1} ||
                                    {_magText find "mk81" > -1} ||
                                    {_magText find "mk82" > -1} ||
                                    {_magText find "mk83" > -1} ||
                                    {_magText find "mk84" > -1} ||
                                    {_magText find "cluster" > -1} ||
                                    {_simulation == "shotshell" && {_hit > 50} && {_indirectHit > 2}}
                                ) then {
                                    _bombFound = true;
                                };
                            };
                        } forEach (compatibleMagazines _weapon);

                        if (_rocketFound) then {
                            _rocketWeapons pushBackUnique _weapon;
                        };

                        if (_bombFound) then {
                            _bombWeapons pushBackUnique _weapon;
                        };
                    } forEach _weapons;

                    if (count _rocketWeapons == 0 && {count _bombWeapons == 0}) then {
                        sleep 4;
                        continue;
                    };

                    private _shooter = gunner _heli;

                    if (isNull _shooter || {!alive _shooter}) then {
                        _shooter = driver _heli;
                    };

                    if (isNull _shooter || {!alive _shooter}) then {
                        sleep 3;
                        continue;
                    };

                    private _targetPos = getPosATL _target;
                    private _targetVel = velocity _target;

                    private _predicted = [
                        (_targetPos select 0) + ((_targetVel select 0) * 1.2),
                        (_targetPos select 1) + ((_targetVel select 1) * 1.2),
                        (_targetPos select 2)
                    ];

                    private _targetDirection = _target getDir _heli;
                    private _attackSide = if ((random 1) > 0.5) then {1} else {-1};

                    private _ingress = _target getPos [1100, _targetDirection];
                    private _attackPoint = _target getPos [360, _targetDirection];
                    private _releasePoint = _target getPos [190, _targetDirection];
                    private _egress = _target getPos [1100, _targetDirection + 180];
                    private _evasiveEgress = _egress getPos [250, _targetDirection + (_attackSide * 55)];

                    group _pilot setBehaviour "COMBAT";
                    group _pilot setCombatMode "RED";
                    group _pilot setSpeedMode "FULL";

                    _pilot doMove _ingress;
                    _heli flyInHeightASL [120,120,120];

                    private _timeout = time + 25;

                    waitUntil {
                        sleep 0.1;

                        !alive _heli ||
                        !canMove _heli ||
                        isNull _target ||
                        !alive _target ||
                        (_heli distance2D _ingress < 120) ||
                        time > _timeout
                    };

                    if (!alive _heli || {!canMove _heli}) exitWith {
                        _heli setVariable ["HELO_ATTACK_PROTOCOL", false];
                    };

                    _targetDirection = _target getDir _heli;
                    _attackPoint = _target getPos [360, _targetDirection];
                    _releasePoint = _target getPos [190, _targetDirection];

                    _pilot doMove _attackPoint;
                    _heli flyInHeightASL [75,75,75];

                    _timeout = time + 18;

                    waitUntil {
                        sleep 0.05;

                        !alive _heli ||
                        !canMove _heli ||
                        isNull _target ||
                        !alive _target ||
                        (_heli distance2D _attackPoint < 110) ||
                        time > _timeout
                    };

                    if (!alive _heli || {!canMove _heli}) exitWith {
                        _heli setVariable ["HELO_ATTACK_PROTOCOL", false];
                    };

                    _shooter doTarget _target;
                    _shooter doWatch _target;
                    _shooter setCombatBehaviour "COMBAT";

                    private _useBombs = false;

                    if (_target isKindOf "Car") then {
                        _useBombs = random 1 > 0.35;
                    } else {
                        _useBombs = random 1 > 0.82;
                    };

                    if (_useBombs && {count _bombWeapons > 0}) then {
                        private _bombWeapon = selectRandom _bombWeapons;

                        _shooter selectWeapon _bombWeapon;
                        _shooter doTarget _target;
                        _shooter doWatch _target;

                        sleep (0.25 + random 0.35);

                        _shooter fireAtTarget [_target, _bombWeapon];

                        sleep (0.15 + random 0.15);

                        if (random 1 > 0.25) then {
                            _shooter fireAtTarget [_target, _bombWeapon];
                            sleep (0.15 + random 0.15);
                        };

                        if (random 1 > 0.55) then {
                            _shooter fireAtTarget [_target, _bombWeapon];
                        };
                    };

                    if (!_useBombs && {count _rocketWeapons > 0}) then {
                        private _rocketWeapon = selectRandom _rocketWeapons;

                        _shooter selectWeapon _rocketWeapon;
                        _shooter doTarget _target;
                        _shooter doWatch _target;

                        sleep (0.2 + random 0.25);

                        private _salvo = 4 + floor (random 5);

                        for "_i" from 1 to _salvo do {
                            if (alive _target && {alive _heli} && {canMove _heli}) then {
                                _shooter fireAtTarget [_target, _rocketWeapon];
                                sleep (0.08 + random 0.13);
                            };
                        };
                    };

                    if (count _bombWeapons > 0 && {count _rocketWeapons > 0}) then {
                        if (random 1 > 0.55 && {!_useBombs}) then {
                            private _bombWeapon = selectRandom _bombWeapons;

                            _pilot doMove _releasePoint;

                            waitUntil {
                                sleep 0.05;

                                !alive _heli ||
                                !canMove _heli ||
                                isNull _target ||
                                !alive _target ||
                                (_heli distance2D _releasePoint < 100)
                            };

                            if (alive _heli && {canMove _heli} && {alive _target}) then {
                                _shooter selectWeapon _bombWeapon;
                                _shooter doTarget _target;
                                _shooter doWatch _target;

                                sleep (0.2 + random 0.25);

                                _shooter fireAtTarget [_target, _bombWeapon];

                                if (random 1 > 0.5) then {
                                    sleep (0.15 + random 0.15);
                                    _shooter fireAtTarget [_target, _bombWeapon];
                                };
                            };
                        };
                    };

                    _targetDirection = _target getDir _heli;
                    _egress = _target getPos [1100, _targetDirection + 180];
                    _evasiveEgress = _egress getPos [250, _targetDirection + (_attackSide * 55)];

                    _pilot doMove _evasiveEgress;
                    _heli flyInHeightASL [140,140,140];

                    _timeout = time + 25;

                    waitUntil {
                        sleep 0.1;

                        !alive _heli ||
                        !canMove _heli ||
                        (_heli distance2D _evasiveEgress < 140) ||
                        time > _timeout
                    };

                    if (alive _heli && {canMove _heli}) then {
                        _pilot doMove (_evasiveEgress getPos [700, _attackSide * 90]);
                        _heli flyInHeightASL [170,170,170];
                    };

                    sleep (5 + random 7);
                };

                _heli setVariable ["HELO_ATTACK_PROTOCOL", false];
            };
        };
    } forEach (
        vehicles select {
            _x isKindOf "Helicopter" &&
            {alive _x} &&
            {canMove _x}
        }
    );
};
while{true} do{
	if (PROTOCOL_AI_AIRCRAFT_ENABLED && PROTOCOL_AI_HELI) then {
    call _PROTOCOL_HELI;
	};
}; 
};
[]spawn
{
    if (isNil "PROTOCOL_AI_AIRCRAFT_ENABLED") then {PROTOCOL_AI_AIRCRAFT_ENABLED = true};
	if (isNil "PROTOCOL_AI_FIGHTERS") then {PROTOCOL_AI_FIGHTERS = true};
	_PROTOCOL_FIGHTERS = {
    {
        private _aircraft = _x;

        if (
            alive _aircraft &&
            {_aircraft isKindOf "Plane"} &&
            {canMove _aircraft} &&
            {isTouchingGround _aircraft isEqualTo false}
        ) then {

            private _crew = crew _aircraft;
            private _pilot = driver _aircraft;

            if (
                !isNull _pilot &&
                {alive _pilot} &&
                {_pilot isEqualTo driver _aircraft} &&
                {_aircraft getVariable ["A3_CAS_BUSY", false] isEqualTo false}
            ) then {

                private _enemyTargets = [];

                {
                    private _u = _x;

                    if (
                        alive _u &&
                        {_u isEqualTo vehicle _u} &&
                        {_u != _pilot} &&
                        {side _pilot getFriend side _u < 0.6} &&
                        {_u distance2D _aircraft < 7000}
                    ) then {
                        _enemyTargets pushBack _u;
                    };
                } forEach allUnits;

                {
                    private _v = _x;

                    if (
                        alive _v &&
                        {_v != _aircraft} &&
                        {_v isKindOf "LandVehicle"} &&
                        {count crew _v > 0} &&
                        {side _pilot getFriend side (crew _v select 0) < 0.6} &&
                        {_v distance2D _aircraft < 7000}
                    ) then {
                        _enemyTargets pushBack _v;
                    };
                } forEach vehicles;

                _enemyTargets = _enemyTargets select {
                    alive _x &&
                    {_x distance2D _aircraft < 7000} &&
                    {!(_x getVariable ["A3_CAS_RECENTLY_ATTACKED", false])}
                };

                if (count _enemyTargets > 0) then {

                    _enemyTargets = [
                        _enemyTargets,
                        [],
                        {
                            private _t = _this;
                            private _d = _aircraft distance2D _t;
                            private _value = 0;

                            if (_t isKindOf "Man") then {
                                _value = 100;
                            };

                            if (_t isKindOf "LandVehicle") then {
                                _value = 180;
                            };

                            _value + (7000 - _d)
                        },
                        "DESCEND"
                    ] call BIS_fnc_sortBy;

                    private _target = _enemyTargets select 0;

                    if (!isNull _target && {alive _target}) then {

                        _aircraft setVariable ["A3_CAS_BUSY", true, true];
                        _target setVariable ["A3_CAS_RECENTLY_ATTACKED", true, true];

                        _pilot setSkill ["aimingAccuracy", 1];
                        _pilot setSkill ["aimingShake", 0];
                        _pilot setSkill ["aimingSpeed", 1];
                        _pilot setSkill ["spotDistance", 1];
                        _pilot setSkill ["spotTime", 1];
                        _pilot setSkill ["courage", 1];
                        _pilot setSkill ["commanding", 1];

                        _aircraft setCombatMode "RED";
                        _aircraft setBehaviour "COMBAT";
                        _aircraft setSpeedMode "FULL";
                        _aircraft flyInHeightASL [350, 350, 350];

                        private _weaponData = [];

                        {
                            private _weapon = _x;
                            private _weaponName = toLower _weapon;
                            private _weaponCfg = configFile >> "CfgWeapons" >> _weapon;
                            private _weaponMags = getArray (_weaponCfg >> "magazines");

                            private _loaded = false;
                            private _bestMag = "";

                            {
                                private _mag = _x select 0;
                                private _ammoCount = _x select 1;

                                if (
                                    _ammoCount > 0 &&
                                    {_mag in _weaponMags}
                                ) then {
                                    _loaded = true;
                                    _bestMag = _mag;
                                };
                            } forEach (magazinesAmmo _aircraft);

                            if (_loaded) then {

                                private _ammoClass = getText (
                                    configFile >>
                                    "CfgMagazines" >>
                                    _bestMag >>
                                    "ammo"
                                );

                                private _ammoName = toLower _ammoClass;
                                private _ammoCfg = configFile >> "CfgAmmo" >> _ammoClass;
                                private _sim = toLower getText (_ammoCfg >> "simulation");

                                private _airLock = getNumber (_ammoCfg >> "airLock");

                                private _combined =
                                    _weaponName +
                                    " " +
                                    (toLower _bestMag) +
                                    " " +
                                    _ammoName;

                                private _isAA =
                                    (_airLock isEqualTo 2) ||
                                    ((_combined find "aam") >= 0) ||
                                    ((_combined find "amraam") >= 0) ||
                                    ((_combined find "asraam") >= 0) ||
                                    ((_combined find "sidewinder") >= 0) ||
                                    ((_combined find "sparrow") >= 0) ||
                                    ((_combined find "r73") >= 0) ||
                                    ((_combined find "r77") >= 0) ||
                                    ((_combined find "airtoair") >= 0) ||
                                    ((_combined find "air_air") >= 0);

                                private _isMissile =
                                    !_isAA &&
                                    (
                                        (_combined find "missile") >= 0 ||
                                        ((_combined find "atgm") >= 0) ||
                                        ((_combined find "agm") >= 0) ||
                                        ((_combined find "hellfire") >= 0) ||
                                        ((_combined find "maverick") >= 0) ||
                                        ((_combined find "kh") >= 0) ||
                                        ((_sim find "shotmissile") >= 0)
                                    );

                                private _isRocket =
                                    (
                                        (_combined find "rocket") >= 0 ||
                                        ((_combined find "rocketpod") >= 0) ||
                                        ((_combined find "s8") >= 0) ||
                                        ((_combined find "s13") >= 0) ||
                                        ((_combined find "s24") >= 0) ||
                                        ((_combined find "s25") >= 0) ||
                                        ((_sim find "shotrocket") >= 0)
                                    );

                                private _isBomb =
                                    (
                                        (_combined find "bomb") >= 0 ||
                                        ((_combined find "gbu") >= 0) ||
                                        ((_combined find "jdam") >= 0) ||
                                        ((_combined find "fab") >= 0) ||
                                        ((_combined find "kab") >= 0) ||
                                        ((_combined find "mk82") >= 0) ||
                                        ((_combined find "mk83") >= 0) ||
                                        ((_combined find "mk84") >= 0) ||
                                        ((_combined find "lgb") >= 0) ||
                                        ((_combined find "odin") >= 0) ||
                                        ((_combined find "betab") >= 0)
                                    );

                                if (_isMissile) then {
                                    _weaponData pushBack [_weapon, 1, _ammoClass, _airLock];
                                };

                                if (_isRocket) then {
                                    _weaponData pushBack [_weapon, 2, _ammoClass, _airLock];
                                };

                                if (_isBomb) then {
                                    _weaponData pushBack [_weapon, 3, _ammoClass, _airLock];
                                };
                            };
                        } forEach (weapons _aircraft);

                        private _missiles = _weaponData select {
                            (_x select 1) == 1 &&
                            {(_x select 3) < 2}
                        };

                        private _rockets = _weaponData select {
                            (_x select 1) == 2 &&
                            {(_x select 3) < 2}
                        };

                        private _bombs = _weaponData select {
                            (_x select 1) == 3
                        };

                        private _entryDir = _target getDir _aircraft;
                        private _entry = _target getPos [3500, _entryDir];
                        private _exit = _target getPos [4000, _entryDir + 180];

                        _aircraft doMove _entry;

                        while {
                            alive _aircraft &&
                            {alive _target} &&
                            {_aircraft distance2D _entry >= 450}
                        } do {
                            sleep 0.1;
                        };

                        if (alive _aircraft && {alive _target}) then {

                            _aircraft flyInHeightASL [120, 120, 120];

                            _aircraft reveal [_target, 4];
                            _aircraft doTarget _target;
                            _pilot doTarget _target;
                            _pilot doWatch _target;

                            sleep 1;

                            _aircraft doMove (getPosASL _target);

                            if (count _missiles > 0 || count _rockets > 0) then {

                                private _selectedWeapon = "";
                                private _selectedType = 0;

                                if (count _missiles > 0) then {
                                    _selectedWeapon = (_missiles select 0) select 0;
                                    _selectedType = 1;
                                } else {
                                    if (count _rockets > 0) then {
                                        _selectedWeapon = (_rockets select 0) select 0;
                                        _selectedType = 2;
                                    };
                                };

                                if (_selectedWeapon != "") then {

                                    _aircraft selectWeapon _selectedWeapon;

                                    _aircraft reveal [_target, 4];
                                    _aircraft doTarget _target;
                                    _pilot doTarget _target;
                                    _pilot doWatch _target;

                                    sleep 0.5;

                                    private _attackReady = false;

                                    while {
                                        alive _aircraft &&
                                        {alive _target} &&
                                        {!_attackReady} &&
                                        {_aircraft distance2D _target >= 400}
                                    } do {

                                        sleep 0.05;

                                        if (alive _aircraft && {alive _target}) then {

                                            _aircraft reveal [_target, 4];
                                            _aircraft doTarget _target;
                                            _pilot doTarget _target;

                                            private _relDir = abs (
                                                (getDir _aircraft) -
                                                (_aircraft getDir _target)
                                            );

                                            if (_relDir > 180) then {
                                                _relDir = 360 - _relDir;
                                            };

                                            if (
                                                (_aircraft distance2D _target < 1200) &&
                                                {_relDir < 6}
                                            ) then {
                                                _attackReady = true;
                                            };
                                        };
                                    };

                                    if (alive _aircraft && {alive _target}) then {

                                        if (_selectedType == 1) then {
                                            {
                                                if (alive _aircraft && {alive _target}) then {
                                                    _aircraft reveal [_target, 4];
                                                    _aircraft doTarget _target;
                                                    _pilot doTarget _target;
                                                    _pilot doWatch _target;
                                                    _aircraft fireAtTarget [_target, _selectedWeapon];
                                                    sleep (0.18 + random 0.12);
                                                };
                                            } forEach [1,2,3,4];
                                        };

                                        if (_selectedType == 2) then {
                                            {
                                                if (alive _aircraft && {alive _target}) then {
                                                    _aircraft reveal [_target, 4];
                                                    _aircraft doTarget _target;
                                                    _pilot doTarget _target;
                                                    _pilot doWatch _target;
                                                    _aircraft fireAtTarget [_target, _selectedWeapon];
                                                    sleep (0.12 + random 0.08);
                                                };
                                            } forEach [1,2,3,4,5,6,7,8];
                                        };
                                    };
                                };
                            };
                        };

                        if (count _bombs > 0 && alive _aircraft && alive _target) then {

                            sleep 1.2;

                            private _bombWeapon = (_bombs select 0) select 0;

                            _aircraft selectWeapon _bombWeapon;
                            _aircraft reveal [_target, 4];
                            _aircraft doTarget _target;
                            _pilot doTarget _target;
                            _pilot doWatch _target;

                            _aircraft flyInHeightASL [100, 100, 100];
                            _aircraft doMove (getPosASL _target);

                            private _bombAttackReady = false;

                            while {
                                alive _aircraft &&
                                {alive _target} &&
                                {!_bombAttackReady} &&
                                {_aircraft distance2D _target >= 100}
                            } do {

                                sleep 0.05;

                                if (alive _aircraft && {alive _target}) then {

                                    _aircraft reveal [_target, 4];
                                    _aircraft doTarget _target;
                                    _pilot doTarget _target;

                                    private _relDir = abs (
                                        (getDir _aircraft) -
                                        (_aircraft getDir _target)
                                    );

                                    if (_relDir > 180) then {
                                        _relDir = 360 - _relDir;
                                    };

                                    if (
                                        (
                                            (_aircraft distance2D _target < 250) &&
                                            {_relDir < 15}
                                        ) ||
                                        {_aircraft distance2D _target < 100}
                                    ) then {
                                        _bombAttackReady = true;
                                    };
                                };
                            };

                            if (alive _aircraft && alive _target) then {
                                {
                                    if (alive _aircraft && alive _target) then {
                                        _aircraft reveal [_target, 4];
                                        _aircraft doTarget _target;
                                        _pilot doTarget _target;
                                        _pilot doWatch _target;
                                        _aircraft fireAtTarget [_target, _bombWeapon];
                                        sleep (0.2 + random 0.15);
                                    };
                                } forEach [1,2,3];
                            };
                        };

                        if (alive _aircraft) then {

                            private _breakDir = _target getDir _aircraft;
                            private _breakPoint = _target getPos [3000, _breakDir];

                            _aircraft setCombatMode "BLUE";
                            _aircraft setSpeedMode "FULL";
                            _aircraft doMove _breakPoint;

                            sleep 4;

                            _aircraft flyInHeightASL [450, 450, 450];
                            _aircraft doMove _exit;

                            sleep 8;

                            _aircraft setVariable ["A3_CAS_BUSY", false, true];

                        } else {
                            _aircraft setVariable ["A3_CAS_BUSY", false, true];
                        };

                    } else {
                        _aircraft setVariable ["A3_CAS_BUSY", false, true];
                    };

                    [_target] spawn {
                        params ["_t"];

                        sleep 45;

                        if (!isNull _t) then {
                            _t setVariable ["A3_CAS_RECENTLY_ATTACKED", false, true];
                        };
                    };
                };
            };
        };
    } forEach vehicles;
};

	while {true} do {
		if (PROTOCOL_AI_AIRCRAFT_ENABLED && PROTOCOL_AI_FIGHTERS) then {
	  call _PROTOCOL_FIGHTERS;
	  };
    };

};


[] spawn
{
	 if (isNil "PROTOCOL_AI_AIRCRAFT_ENABLED") then {PROTOCOL_AI_AIRCRAFT_ENABLED = true};
	if (isNil "PROTOCOL_AI_CONTERMEASURES") then {PROTOCOL_AI_CONTERMEASURES = true};
	_PROTOCOL_COUNTERMEASURE = {

	params ["_air"];

	if (
		isNull _air ||
		{!alive _air} ||
		{!canMove _air} ||
		{
			!(_air isKindOf "Helicopter") &&
			!(_air isKindOf "Plane")
		} ||
		{unitIsUAV _air} ||
		{_air getVariable ["AIR_CM_PROTOCOL", false]}
	) exitWith {};

	_air setVariable ["AIR_CM_PROTOCOL", true];

	[_air] spawn {

		params ["_air"];

		private _lastCM = -999;

		while {
			alive _air &&
			{canMove _air}
		} do {

			private _pilot = driver _air;

			if (isNull _pilot || {!alive _pilot}) exitWith {};

			private _enemyDetected = false;
			private _mySide = side group _pilot;

			{
				private _e = _x;

				if (
					alive _e &&
					{_e != _air} &&
					{_mySide getFriend (side _e) < 0.6} &&
					{_air distance2D _e <= 3500} &&
					{
						_e isKindOf "Man" ||
						{_e isKindOf "LandVehicle"} ||
						{_e isKindOf "Ship"} ||
						{_e isKindOf "Air"}
					} &&
					{(_pilot knowsAbout _e) >= 1.0}
				) exitWith {
					_enemyDetected = true;
				};

			} forEach (allUnits + vehicles);

			if (
				_enemyDetected &&
				{time - _lastCM >= 5}
			) then {

				private _cmWeapons = [];
				private _ammoState = magazinesAmmo _air;

				{
					private _weapon = _x;
					private _hasCM = false;

					{
						private _mag = _x;

						private _ammoType = getText (
							configFile >>
							"CfgMagazines" >>
							_mag >>
							"ammo"
						);

						private _simulation = toLower (
							getText (
								configFile >>
								"CfgAmmo" >>
								_ammoType >>
								"simulation"
							)
						);

						private _magText = toLower (
							_mag + " " +
							(getText (
								configFile >>
								"CfgMagazines" >>
								_mag >>
								"displayName"
							))
						);

						private _weaponText = toLower (
							_weapon + " " +
							(getText (
								configFile >>
								"CfgWeapons" >>
								_weapon >>
								"displayName"
							))
						);

						private _hasAmmo = false;

						{
							if (
								(_x select 0) == _mag &&
								{(_x select 1) > 0}
							) exitWith {
								_hasAmmo = true;
							};
						} forEach _ammoState;

						if (
							_hasAmmo &&
							{
								_simulation == "shotcm" ||
								{_magText find "flare" > -1} ||
								{_magText find "chaff" > -1} ||
								{_magText find "countermeasure" > -1} ||
								{_magText find "cm" > -1} ||
								{_weaponText find "flare" > -1} ||
								{_weaponText find "chaff" > -1} ||
								{_weaponText find "countermeasure" > -1} ||
								{_weaponText find "cm" > -1} ||
								{(toLower _weapon) find "cm" > -1}
							}
						) then {
							_hasCM = true;
						};

					} forEach (compatibleMagazines _weapon);

					if (_hasCM) then {
						_cmWeapons pushBackUnique _weapon;
					};

				} forEach (weapons _air);

				if ((count _cmWeapons) == 0) then {

					if (
						isClass (
							configFile >>
							"CfgWeapons" >>
							"CMFlareLauncher"
						) &&
						isClass (
							configFile >>
							"CfgMagazines" >>
							"168Rnd_CMFlare_Chaff_Magazine"
						)
					) then {

						_air addMagazine "168Rnd_CMFlare_Chaff_Magazine";
						_air addWeapon "CMFlareLauncher";

						sleep 0.2;

						_cmWeapons = ["CMFlareLauncher"];
					};
				};

				if ((count _cmWeapons) > 0) then {

					private _cmWeapon = selectRandom _cmWeapons;
					private _burstCount = 8 + floor (random 6);

					_lastCM = time;

					for "_i" from 1 to _burstCount do {

						if (
							alive _air &&
							{canMove _air}
						) then {

							[_air, _cmWeapon] call BIS_fnc_fire;

							sleep (0.12 + random 0.16);
						};
					};
				};
			};

			sleep 0.25;
		};

		_air setVariable ["AIR_CM_PROTOCOL", false];
	};
};

	while {true} do {
         if(PROTOCOL_AI_AIRCRAFT_ENABLED && PROTOCOL_AI_CONTERMEASURES) then {
		{
			if (
				alive _x &&
				{canMove _x} &&
				{_x isKindOf "Air"} &&
				{!(_x getVariable ["AIR_CM_PROTOCOL", false])}
			) then {

				[_x] call _PROTOCOL_COUNTERMEASURE;

			};

		} forEach vehicles;

		sleep 1;
	};

	};

};


