
[] spawn {
    if (isNil "PROTOCOL_AI_ARMORED_FORCE_ENABLED") then {PROTOCOL_AI_ARMORED_FORCE_ENABLED = true};
    if (isNil "PROTOCOL_AI_ARMORED_FORCE_RADIUS") then {PROTOCOL_AI_ARMORED_FORCE_RADIUS = 70};
    if (isNil "PROTOCOL_AI_ARMORED_FORCE_SMOKE_USAGE") then {PROTOCOL_AI_ARMORED_FORCE_SMOKE_USAGE = true};
    if (isNil "PROTOCOL_ATGM_USAGE") then {PROTOCOL_ATGM_USAGE = true};
    if (isNil "PROTOCOL_AI_ARMORED_FORCE_COVER_USAGE") then {PROTOCOL_AI_ARMORED_FORCE_COVER_USAGE = true};

	_moveToCover = {
	params ["_veh"];
		private _covers = nearestTerrainObjects [
	_veh,
	 [
"BUILDING",
"BUSH",
"BUNKER",
"BUSSTOP",
"CHAPEL",
"CHURCH",
"CROSS",
"FENCE",
"FOREST",
"FORTRESS",
"FUELSTATION",
"HOSPITAL",
"HOUSE",
"LIGHTHOUSE",
"POWERSOLAR",
"POWERWAVE",
"POWERWIND",
"RAILWAY",
"ROCKS",
"RUIN",
"SHIPWRECK",
"SMALL TREE",
"TOURISM",
"TRANSMITTER",
"TREE",
"VIEW-TOWER",
"WALL",
"WATERTOWER"
],
	20
	];

	if (count _covers > 0) then {

	private _cover = selectRandom _covers;
	private _pos = getPosATL _cover;
private _dir = _veh getDir _pos;

private _offset = [
	(_pos select 0) - (sin _dir) * 0.6,
	(_pos select 1) - (cos _dir) * 0.6,
	(_pos select 2)
];
	_veh doMove _offset;
	};
};
_PROTOCOL_ARMORED_FORCE = {
	{
		private _veh = vehicle _x;

		if (_veh isKindOf "LandVehicle" && {alive _veh} && {canMove _veh} && {driver _veh == _x}  {!(_veh isKindOf "Car")} &&
    {!(_veh isKindOf "Truck")} ) then {
			private _driver = driver _veh;
			private _gunner = gunner _veh;	  
			private _weapons = weapons _veh;
			private _atgmWeapons = [];
			private _ammoState = magazinesAmmo _veh;
						
						{
						private _weapon = _x;
						private _weaponText = toLower (
							_weapon + " " +
							(getText (configFile >> "CfgWeapons" >> _weapon >> "displayName"))
						);

						private _atgmFound = false;

						{
							private _mag = _x;
							private _magText = toLower (
								_mag + " " +
								(getText (configFile >> "CfgMagazines" >> _mag >> "displayName"))
							);

							private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
							private _ammoText = toLower _ammo;
							private _simulation = toLower (getText (configFile >> "CfgAmmo" >> _ammo >> "simulation"));

							private _hasAmmo = false;

							{
								if ((_x select 0) == _mag && {(_x select 1) > 0}) exitWith {
									_hasAmmo = true;
								};
							} forEach _ammoState;
						   
							if (_hasAmmo) then {
								if (
									/*
									_simulation == "shotmissile" 
									{_simulation == "shotdirectional"} ||
									*/
									//_weaponText find "ptur" > -1 ||
								   // _weaponText find "atgm" > -1 ||
									_weaponText find "tow" > -1  ||
								  //  {_weaponText find "kornet" > -1} ||
									{_weaponText find "konkurs" > -1} ||
								   // {_weaponText find "metis" > -1} ||
									{_weaponText find "malyutka" > -1} ||
									{_weaponText find "shturm" > -1} ||
									{_weaponText find "ataka" > -1} ||
									{_weaponText find "refleks" > -1} ||
									{_weaponText find "svir" > -1} ||
									{_weaponText find "invvar" > -1} ||
									{_weaponText find "bastion" > -1} ||
									{_weaponText find "arcan" > -1} ||
								   // {_weaponText find "titan" > -1} ||
									{_weaponText find "stryker" > -1} ||
								  //  {_weaponText find "baryer" > -1} ||
								  //  {_weaponText find "barier" > -1} ||
									//{_magText find "ptur" > -1} ||
									//{_magText find "atgm" > -1} ||
									{_magText find "tow" > -1} ||
									//{_magText find "kornet" > -1} ||
									{_magText find "konkurs" > -1} ||
								   // {_magText find "metis" > -1} ||
									{_magText find "9m" > -1} ||
									{_magText find "bgm" > -1} ||
									 {_magText find "baryer" > -1} ||
									 {_magText find "barier" > -1} 
									//{_ammoText find "missile" > -1} ||
									//{_ammoText find "ptur" > -1} ||
									//{_ammoText find "atgm" > -1}
									
								) then {
									_atgmFound = true;
								};
								
							};
							
						} forEach (compatibleMagazines _weapon);

						if (_atgmFound) then {
							_atgmWeapons pushBackUnique _weapon;
						};
			} forEach _weapons;
			
			private _atgmWeapon = selectRandom _atgmWeapons;


			if (isNull _gunner) then { continue; };

			private _targets = _gunner targets [true, 600];
			if (_targets isEqualTo []) then {
				_veh forceSpeed -1;
				continue;
			};

			private _target = _targets select 0;
			if (!alive _target) then {
				_veh forceSpeed -1;
				continue;
			};

			private _targetPos = getPosATL _target;
			private _dist = _veh distance _target;

            if(PROTOCOL_AI_ARMORED_FORCE_SMOKE_USAGE) then {			
			if (isNil {_veh getVariable "smokeDeployed"}) then {

	private _smokeFired = false;
	private _turretPaths = [[-1]];
	_turretPaths append (allTurrets _veh);

	{
		if (!_smokeFired) then {

			private _turretPath = _x;
			private _operator = _veh turretUnit _turretPath;

			if (!isNull _operator && {alive _operator}) then {

				private _turretWeapons = _veh weaponsTurret _turretPath;

				{
					if (!_smokeFired) then {

						private _w = _x;
						private _wl = toLower _w;

						private _displayName = toLower (
							getText (configFile >> "CfgWeapons" >> _w >> "displayName")
						);

						private _description = toLower (
							getText (configFile >> "CfgWeapons" >> _w >> "descriptionShort")
						);

						private _simulation = toLower (
							getText (configFile >> "CfgWeapons" >> _w >> "simulation")
						);

						private _isSmoke =
							(_wl find "smoke" > -1) ||
							(_wl find "smokegen" > -1) ||
							(_wl find "smokelauncher" > -1) ||
							(_wl find "902a" > -1) ||
							(_wl find "902v" > -1) ||
							(_displayName find "smoke" > -1) ||
							(_description find "smoke" > -1) ||
							(
								_simulation == "cmlauncher" &&
								(
									(_displayName find "launcher" > -1) ||
									(_displayName find "smoke" > -1)
								)
							);

						if (_isSmoke) then {

							private _oldWeapon = _veh currentWeaponTurret _turretPath;

							_veh selectWeaponTurret [
								_w,
								_turretPath
							];

							private _result = [
								_veh,
								_w,
								_turretPath
							] call BIS_fnc_fire;

							if (_result) then {
								_smokeFired = true;
							};

							if (_oldWeapon != "" && {!isNull _operator} && {alive _operator}) then {
								_veh selectWeaponTurret [
									_oldWeapon,
									_turretPath
								];
							};
						};
					};
				} forEach _turretWeapons;
			};
		};
	} forEach _turretPaths;

	if (_smokeFired) then {
        
		_veh setVariable ["smokeDeployed", true];
		if(PROTOCOL_AI_ARMORED_FORCE_COVER_USAGE) then {
        [_veh] call _moveToCover;
		};
		[_veh] spawn {
			params ["_v"];
		   
			sleep 42;

			if (!isNull _v && {alive _v}) then {
				_v setVariable ["smokeDeployed", nil];
			};
		};
	};
};

};

			if (_dist <= PROTOCOL_AI_ARMORED_FORCE_RADIUS) then {
				//_veh forceSpeed 0;
			   
			   
				//_veh  doMove _coverPos;
				_gunner doWatch _target;

				private _weapons = _veh weaponsTurret [0];
				if (_weapons isNotEqualTo []) then {
					if (isNil {_veh getVariable "lastFire"}) then {
						_veh setVariable ["lastFire", true];
						private _targetPos = getPosASL _target;
						private _targetVel = velocity _target;
						private _leadPos = _targetPos vectorAdd (_targetVel vectorMultiply 1.0);
						_gunner doWatch _leadPos;
						if (PROTOCOL_ATGM_USAGE && {_atgmWeapons isNotEqualTo []}) then {
						_gunner fireAtTarget [_target, _atgmWeapon];
						};
						_gunner fireAtTarget [_target, _weapons select 0];
					    if(PROTOCOL_AI_ARMORED_FORCE_COVER_USAGE) then {
						[_veh] call _moveToCover;
						};
															  
						[_veh] spawn {
							params ["_v"];
							sleep 2;
							_v setVariable ["lastFire", nil];
						};
					};
				};
			} else {
				
				if (_dist <= 1000) then {
					//_veh forceSpeed 0;
					[_veh] call _moveToCover;
					_gunner doWatch _target;
					private _weapons = _veh weaponsTurret [0];
					private _weapons = weapons _veh;
					if (_weapons isNotEqualTo [] && {isNil {_veh getVariable "lastFire"}}) then {
						_veh setVariable ["lastFire", true];
						_gunner reveal _target;
						_gunner doTarget _target;
						_gunner doWatch _target;
						if (PROTOCOL_ATGM_USAGE && {_atgmWeapons isNotEqualTo []}) then {
                        _gunner fireAtTarget [_target, _atgmWeapon];
						};
						_gunner fireAtTarget [_target, _weapons select 0];

						private _shots = (_veh getVariable ["shotsCycle", 0]) + 1;
						_veh setVariable ["shotsCycle", _shots];

						[_veh] spawn {
							params ["_v"];
							sleep 2;
							_v setVariable ["lastFire", nil];
						};

						
						if (_shots >= (2 + floor random 3) && {isNil {_veh getVariable "maneuvering"}}) then {
							_veh setVariable ["shotsCycle", 0];
							_veh setVariable ["maneuvering", true];

							[_veh, _target] spawn {
								params ["_v", "_enemy"];
								private _drv = driver _v;

								if (isNull _drv) exitWith {
									_v setVariable ["maneuvering", nil];
								};

								private _enemyPos = getPosATL _enemy;
								private _dir = _enemyPos getDir (getPosATL _v);
								private _angles = [90, -90, 140, -140, 180];
								private _angle = selectRandom _angles;
								private _radius = 70 + random 75;
								private _movePos = _enemyPos getPos [_radius, _dir + _angle];

								//_v forceSpeed -1;
								//_v limitSpeed 18;
								_drv doMove _movePos;

								private _time = time + 10;
								/*
								waitUntil {
									sleep 0.5;
									!alive _v || {!canMove _v} || {(_v distance2D _movePos) < 8} || {time > _time}
								};
								*/
								//_v limitSpeed -1;
								_v setVariable ["maneuvering", nil];
							};
						};
					};

				  
					if (isNil {_veh getVariable "retreating"} && {isNil {_veh getVariable "maneuvering"}}) then {
						_veh setVariable ["retreating", true];

						[_veh] spawn {
							params ["_v"];
							sleep 2;

							private _backPos = _v getPos [-20, getDir _v];
							(driver _v) doMove _backPos;
							//_v limitSpeed 10;

							sleep 5;
							//_v limitSpeed -1;
							_v setVariable ["retreating", nil];
						};
					};
				} else {
					//_veh forceSpeed -1;
					_driver doMove _targetPos;
				};
			};
		};
	} forEach allUnits;
};

	while {true} do {
         if(PROTOCOL_AI_ARMORED_FORCE_ENABLED) then {
		{
			private _grp = _x;

			if (
				!isNull _grp &&
				{count units _grp > 0} &&
				{(units _grp findIf {vehicle _x != _x}) > -1}
			) then {

				[_grp] call _PROTOCOL_ARMORED_FORCE;
			};

		} forEach allGroups;

		sleep 0.5;
	  };
	};
};