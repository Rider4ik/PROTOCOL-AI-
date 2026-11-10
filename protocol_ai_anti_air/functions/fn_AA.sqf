[] spawn {
	if (isNil "PROTOCOL_AI_ANTI_AIR_ENABLED") then {
		PROTOCOL_AI_ANTI_AIR_ENABLED = true
	};

	if (isNil "PROTOCOL_AI_ANTI_AIR_RELOCATE") then {
		PROTOCOL_AI_ANTI_AIR_RELOCATE = true
	};

	if (isNil "PROTOCOL_AI_ANTI_AIR_RELOCATE_MIN_RADIUS") then {
		PROTOCOL_AI_ANTI_AIR_RELOCATE_MIN_RADIUS = 300
	};

	if (isNil "PROTOCOL_AI_ANTI_AIR_RELOCATE_MAX_RADIUS") then {
		PROTOCOL_AI_ANTI_AIR_RELOCATE_MAX_RADIUS = 500
	};

	if (isNil "PROTOCOL_AI_ANTI_AIR_SMOKE_RELOCATE") then {
		PROTOCOL_AI_ANTI_AIR_SMOKE_RELOCATE = true
	};

	_PROTOCOL_ANTI_AIR = {

		_isAA = {
			params ["_veh"];

			if (isNull _veh) exitWith {false};
			if (!alive _veh) exitWith {false};
			if !(_veh isKindOf "LandVehicle") exitWith {false};

			if (_veh getVariable ["AA_IsAirDefense", false]) exitWith {true};

			private _cfgVeh = configFile >> "CfgVehicles" >> (typeOf _veh);
			private _editorSubcategory = getText (_cfgVeh >> "editorSubcategory");

			if (_editorSubcategory isEqualTo "EdSubcat_AAs") exitWith {true};

			false
		};

		_isMissileTarget = {
			params ["_obj"];

			if (isNull _obj) exitWith {false};
			if (!alive _obj) exitWith {false};

			private _cfgAmmo = configFile >> "CfgAmmo" >> (typeOf _obj);

			if (!isClass _cfgAmmo) exitWith {false};

			private _simulation = toLower (getText (_cfgAmmo >> "simulation"));
			private _typeText = toLower (typeOf _obj);
			private _weaponType = toLower (getText (_cfgAmmo >> "weaponType"));

			if (_simulation in ["shotmissile", "shotrocket"]) exitWith {true};
			if (_weaponType in ["missileaa", "missileat", "missileaaat", "rocket"]) exitWith {true};
			if (_typeText find "missile" > -1) exitWith {true};
			if (_typeText find "rocket" > -1) exitWith {true};

			false
		};

		_findMissileTarget = {
			params ["_veh", ["_maxDist", 15000]];

			private _target = objNull;
			private _bestScore = -1e20;

			private _missiles = nearestObjects [
				_veh,
				[
					"MissileCore",
					"RocketCore",
					"MissileBase",
					"RocketBase"
				],
				_maxDist
			];

			{
				private _candidate = _x;

				if (isNull _candidate) then {
					continue
				};

				if (!alive _candidate) then {
					continue
				};

				if !([_candidate] call _isMissileTarget) then {
					continue
				};

				private _distance = _veh distance _candidate;

				if (_distance > _maxDist) then {
					continue
				};

				private _relative = (getPosASL _veh) vectorDiff (getPosASL _candidate);
				private _velocity = velocity _candidate;
				private _closing = _velocity vectorDotProduct _relative;

				private _score = (_maxDist - _distance);

				if (_closing > 20) then {
					_score = _score + (_closing * 20)
				};

				if (_closing > 100) then {
					_score = _score + 10000
				};

				if (_closing > 300) then {
					_score = _score + 20000
				};

				if (_score > _bestScore) then {
					_bestScore = _score;
					_target = _candidate
				};

			} forEach _missiles;

			_target
		};

		_findAAMissileWeapon = {
			params ["_veh", "_gunner"];

			if (isNull _veh) exitWith {""};
			if (isNull _gunner) exitWith {""};

			private _weapons = [];

			private _role = assignedVehicleRole _gunner;

			if (
				count _role > 1 &&
				{(_role select 0) isEqualTo "Turret"}
			) then {
				private _turretPath = _role select 1;
				_weapons = _veh weaponsTurret _turretPath;
			};

			if (_weapons isEqualTo []) then {
				_weapons = weapons _gunner
			};

			private _bestWeapon = "";
			private _bestScore = -1;

			{
				private _weapon = _x;
				private _weaponCfg = configFile >> "CfgWeapons" >> _weapon;
				private _magazines = getArray (_weaponCfg >> "magazines");

				{
					private _mag = _x;
					private _magCfg = configFile >> "CfgMagazines" >> _mag;
					private _ammo = getText (_magCfg >> "ammo");

					if (_ammo isEqualTo "") then {
						continue
					};

					private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;

					if (!isClass _ammoCfg) then {
						continue
					};

					private _simulation = toLower (getText (_ammoCfg >> "simulation"));
					private _weaponType = toLower (getText (_ammoCfg >> "weaponType"));

					if !(
						_simulation in ["shotmissile", "shotrocket"] ||
						_weaponType in ["missileaa", "missileat", "missileaaat", "rocket"]
					) then {
						continue
					};

					private _airLock = getNumber (_ammoCfg >> "airLock");
					private _irLock = getNumber (_ammoCfg >> "irLock");
					private _laserLock = getNumber (_ammoCfg >> "laserLock");

					private _score =
						(_airLock * 100) +
						(_irLock * 50) +
						(_laserLock * 50);

					if (_airLock > 0) then {
						_score = _score + 1000
					};

					if (_score > _bestScore) then {
						_bestScore = _score;
						_bestWeapon = _weapon
					};

				} forEach _magazines;

			} forEach _weapons;

			_bestWeapon
		};

		_findHidePosition = {
			params [
				"_veh",
				["_minDist", PROTOCOL_AI_ANTI_AIR_RELOCATE_MIN_RADIUS],
				["_maxDist", PROTOCOL_AI_ANTI_AIR_RELOCATE_MAX_RADIUS],
				["_origin", []]
			];

			if (isNull _veh) exitWith {[]};

			if (_origin isEqualTo []) then {
				_origin = getPosATL _veh
			};

			private _bestPos = [];

			for "_pass" from 0 to 1 do {

				for "_i" from 0 to 100 do {

					private _dir = random 360;

					private _dist =
						if (_maxDist <= _minDist) then {
							_minDist
						} else {
							_minDist + random (_maxDist - _minDist)
						};

					private _candidate = _origin getPos [_dist, _dir];
					_candidate set [2, 0];

					private _realDistance = _origin distance2D _candidate;

					if (
						_realDistance < _minDist ||
						{_realDistance > (_maxDist + 25)}
					) then {
						continue
					};

					if (surfaceIsWater _candidate) then {
						continue
					};

					private _vegetation = nearestTerrainObjects [
						_candidate,
						[
							"TREE",
							"SMALL TREE",
							"BUSH",
							"FOREST",
							"FOREST BORDER"
						],
						45,
						false
					];

					if (_pass isEqualTo 0 && {_vegetation isEqualTo []}) then {
						continue
					};

					private _asl = getTerrainHeightASL _candidate;

					private _p1 = _candidate getPos [15, 0];
					private _p2 = _candidate getPos [15, 180];
					private _p3 = _candidate getPos [15, 90];
					private _p4 = _candidate getPos [15, 270];

					private _h1 = getTerrainHeightASL _p1;
					private _h2 = getTerrainHeightASL _p2;
					private _h3 = getTerrainHeightASL _p3;
					private _h4 = getTerrainHeightASL _p4;

					private _maxSlopeDiff = [
						abs (_asl - _h1),
						abs (_asl - _h2),
						abs (_asl - _h3),
						abs (_asl - _h4)
					] call BIS_fnc_greatestNum;

					if (_maxSlopeDiff > 8) then {
						continue
					};

					private _roads = _candidate nearRoads 35;

					if !(_roads isEqualTo []) then {
						continue
					};

					private _nearObjects = nearestObjects [
						_candidate,
						[
							"LandVehicle",
							"Building",
							"House"
						],
						15
					];

					if !(_nearObjects isEqualTo []) then {
						continue
					};

					_bestPos = _candidate;
					break
				};

				if !(_bestPos isEqualTo []) then {
					break
				};
			};

			if (_bestPos isEqualTo []) then {
				private _safePos = [
					_origin,
					_minDist,
					_maxDist,
					20,
					0,
					0.5,
					0
				] call BIS_fnc_findSafePos;

				if !(_safePos isEqualTo []) then {

					private _safeDistance = _origin distance2D _safePos;

					if (
						_safeDistance >= _minDist &&
						{_safeDistance <= (_maxDist + 100)} &&
						{!surfaceIsWater _safePos}
					) then {
						_bestPos = _safePos
					};
				};
			};

			_bestPos
		};

		_startRelocation = {
			params ["_veh"];

			private _origin = getPosATL _veh;

			_veh setVariable [
				"AA_RELOCATE_ORIGIN",
				_origin,
				true
			];

			_veh setVariable [
				"AA_RELOCATE_TIME",
				time,
				true
			];

			_veh setVariable [
				"AA_RELOCATING_START",
				time,
				true
			];

			_veh setVariable [
				"AA_LAST_MOVE_TIME",
				time,
				true
			];

			_veh setVariable [
				"AA_LAST_MOVE_DISTANCE",
				0,
				true
			];

			_veh setVariable [
				"AA_RELOCATE_RETRIES",
				0,
				true
			];

			_veh setVariable [
				"AA_STATE",
				"RELOCATE",
				true
			];

			_veh setVariable [
				"AA_TARGET",
				objNull,
				true
			];

			_veh setVariable [
				"AA_TARGET_IS_MISSILE",
				false,
				true
			];

			_veh setVariable [
				"AA_ENGAGED",
				false,
				true
			];
		};

		_engageTarget = {
			params ["_veh", "_target", "_targetIsMissile"];

			if (isNull _veh) exitWith {};
			if (isNull _target) exitWith {};
			if (!alive _veh) exitWith {};
			if (!alive _target) exitWith {};

			private _gunner = gunner _veh;

			if (isNull _gunner) exitWith {};
			if (!alive _gunner) exitWith {};

			_veh reveal [_target, 4];
			_gunner reveal [_target, 4];

			_gunner doWatch _target;
			_gunner doTarget _target;

			if (_targetIsMissile) then {

				private _aaWeapon = [
					_veh,
					_gunner
				] call _findAAMissileWeapon;

				if !(_aaWeapon isEqualTo "") then {

					if ((currentWeapon _gunner) != _aaWeapon) then {
						_gunner selectWeapon _aaWeapon
					};

					_gunner doWatch _target;
					_gunner doTarget _target;

					sleep 0.05;

					if (
						alive _veh &&
						{alive _target} &&
						{alive _gunner}
					) then {

						private _fired = _veh fireAtTarget [
							_target,
							_aaWeapon
						];

						if (!_fired) then {
							_gunner doFire _target
						};
					};
				} else {
					_gunner doFire _target
				};

			} else {
				_gunner doFire _target
			};
		};

		while {true} do {

			if (!PROTOCOL_AI_ANTI_AIR_ENABLED) exitWith {};

			{
				private _grp = _x;

				if (isNull _grp) then {
					continue
				};

				private _units = units _grp;

				if (_units isEqualTo []) then {
					continue
				};

				private _aaVehicles = [];

				{
					private _unit = _x;

					if (isNull _unit) then {
						continue
					};

					if (!alive _unit) then {
						continue
					};

					private _veh = vehicle _unit;

					if (_veh isEqualTo _unit) then {
						continue
					};

					if (isNull _veh) then {
						continue
					};

					if (!alive _veh) then {
						continue
					};

					if !(_veh isKindOf "LandVehicle") then {
						continue
					};

					if !([_veh] call _isAA) then {
						continue
					};

					_aaVehicles pushBackUnique _veh;

				} forEach _units;

				if (_aaVehicles isEqualTo []) then {
					continue
				};

				{
					private _veh = _x;

					if (isNull _veh) then {
						continue
					};

					if (!alive _veh) then {
						continue
					};

					if !([_veh] call _isAA) then {
						continue
					};

					if (
						isNil {_veh getVariable "AA_PROTOCOL_VERSION"} ||
						{
							(_veh getVariable ["AA_PROTOCOL_VERSION", 0]) != 4
						}
					) then {

						_veh setVariable [
							"AA_PROTOCOL_VERSION",
							4,
							true
						];

						_veh setVariable [
							"AA_STATE",
							"WAITING",
							true
						];

						_veh setVariable [
							"AA_TARGET",
							objNull,
							true
						];

						_veh setVariable [
							"AA_TARGET_IS_MISSILE",
							false,
							true
						];

						_veh setVariable [
							"AA_HidePosition",
							getPosATL _veh,
							true
						];

						_veh setVariable [
							"AA_RELOCATE_TIME",
							-1,
							true
						];

						_veh setVariable [
							"AA_RELOCATING_START",
							-1,
							true
						];

						_veh setVariable [
							"AA_ENGAGED",
							false,
							true
						];

						_veh setVariable [
							"AA_RELOCATE_ORIGIN",
							getPosATL _veh,
							true
						];

						_veh setVariable [
							"AA_LAST_MOVE_TIME",
							-1,
							true
						];

						_veh setVariable [
							"AA_LAST_MOVE_DISTANCE",
							-1,
							true
						];

						_veh setVariable [
							"AA_RELOCATE_RETRIES",
							0,
							true
						];

						_veh setVehicleRadar 1;

						private _initialDriver = driver _veh;

						if (!isNull _initialDriver) then {
							_initialDriver disableAI "PATH"
						};
					};

					private _state = _veh getVariable [
						"AA_STATE",
						"WAITING"
					];

					if (_state isEqualTo "WAITING") then {

						private _target = [
							_veh,
							15000
						] call _findMissileTarget;

						private _targetIsMissile = !isNull _target;

						if (isNull _target) then {

							private _targets = nearestObjects [
								_veh,
								[
									"Plane",
									"Helicopter",
									"UAV"
								],
								8000
							];

							private _bestPriority = -1;

							{
								private _targetCandidate = _x;

								if (!alive _targetCandidate) then {
									continue
								};

								if (
									side _targetCandidate
									isEqualTo
									side _veh
								) then {
									continue
								};

								private _distance =
									_veh distance _targetCandidate;

								if (_distance > 7500) then {
									continue
								};

								private _priority = 0;

								if (_targetCandidate isKindOf "Plane") then {
									_priority = 80
								} else {
									if (_targetCandidate isKindOf "Helicopter") then {
										_priority = 60
									} else {
										if (_targetCandidate isKindOf "UAV") then {
											_priority = 40
										};
									};
								};

								_priority =
									_priority +
									((7500 - _distance) / 100);

								if (_priority > _bestPriority) then {
									_bestPriority = _priority;
									_target = _targetCandidate
								};

							} forEach _targets;

							_targetIsMissile = false;
						};

						if (!isNull _target) then {

							_veh setVariable [
								"AA_TARGET",
								_target,
								true
							];

							_veh setVariable [
								"AA_TARGET_IS_MISSILE",
								_targetIsMissile,
								true
							];

							_veh setVariable [
								"AA_STATE",
								"ENGAGING",
								true
							];

							_veh setVariable [
								"AA_ENGAGED",
								true,
								true
							];

							_veh setVehicleRadar 1;

							[
								_veh,
								_target,
								_targetIsMissile
							] call _engageTarget;
						};

						continue
					};

					if (_state isEqualTo "ENGAGING") then {

						private _target = _veh getVariable [
							"AA_TARGET",
							objNull
						];

						private _targetIsMissile =
							_veh getVariable [
								"AA_TARGET_IS_MISSILE",
								false
							];

						if (isNull _target) then {
							[_veh] call _startRelocation;
							continue
						};

						if (!alive _target) then {
							[_veh] call _startRelocation;
							continue
						};

						private _maxEngageDistance =
							if (_targetIsMissile) then {
								15000
							} else {
								7500
							};

						if (
							_veh distance _target >
							_maxEngageDistance
						) then {
							[_veh] call _startRelocation;
							continue
						};

						private _gunner = gunner _veh;

						if (
							!isNull _gunner &&
							{alive _gunner}
						) then {

							_veh reveal [_target, 4];
							_gunner reveal [_target, 4];

							if (_targetIsMissile) then {

								private _aaWeapon = [
									_veh,
									_gunner
								] call _findAAMissileWeapon;

								_gunner doWatch _target;
								_gunner doTarget _target;

								if !(_aaWeapon isEqualTo "") then {

									if (
										(currentWeapon _gunner) !=
										_aaWeapon
									) then {
										_gunner selectWeapon _aaWeapon
									};

									sleep 0.05;

									if (
										alive _veh &&
										{alive _target} &&
										{alive _gunner}
									) then {

										private _fireResult =
											_veh fireAtTarget [
												_target,
												_aaWeapon
											];

										if (!_fireResult) then {
											_gunner doFire _target
										};
									};

								} else {
									_gunner doFire _target
								};

							} else {

								_gunner doWatch _target;
								_gunner doTarget _target;
								_gunner doFire _target;
							};
						};

						continue
					};

					if (_state isEqualTo "RELOCATE") then {

						private _relocateTime =
							_veh getVariable [
								"AA_RELOCATE_TIME",
								-1
							];

						if (_relocateTime < 0) then {

							_veh setVariable [
								"AA_RELOCATE_TIME",
								time,
								true
							];

							continue
						};

						if (
							time - _relocateTime < 5
						) then {
							continue
						};

						private _origin =
							_veh getVariable [
								"AA_RELOCATE_ORIGIN",
								getPosATL _veh
							];

						private _newHidePos = [
							_veh,
							PROTOCOL_AI_ANTI_AIR_RELOCATE_MIN_RADIUS,
							PROTOCOL_AI_ANTI_AIR_RELOCATE_MAX_RADIUS,
							_origin
						] call _findHidePosition;

						if (_newHidePos isEqualTo []) then {

							private _safePos = [
								_origin,
								PROTOCOL_AI_ANTI_AIR_RELOCATE_MIN_RADIUS,
								PROTOCOL_AI_ANTI_AIR_RELOCATE_MAX_RADIUS,
								20,
								0,
								0.5,
								0
							] call BIS_fnc_findSafePos;

							if !(_safePos isEqualTo []) then {

								private _safeDistance =
									_origin distance2D _safePos;

								if (
									_safeDistance >=
									PROTOCOL_AI_ANTI_AIR_RELOCATE_MIN_RADIUS &&
									{
										_safeDistance <=
										(PROTOCOL_AI_ANTI_AIR_RELOCATE_MAX_RADIUS + 100)
									}
								) then {
									_newHidePos = _safePos
								};
							};
						};

						if !(_newHidePos isEqualTo []) then {

							_veh setVariable [
								"AA_HidePosition",
								_newHidePos,
								true
							];

							_veh setVariable [
								"AA_RELOCATING_START",
								time,
								true
							];

							_veh setVariable [
								"AA_LAST_MOVE_TIME",
								time,
								true
							];

							_veh setVariable [
								"AA_LAST_MOVE_DISTANCE",
								_veh distance2D _newHidePos,
								true
							];

							_veh setVariable [
								"AA_RELOCATE_RETRIES",
								0,
								true
							];

							_veh setVehicleRadar 0;

							private _driver = driver _veh;

							if (PROTOCOL_AI_ANTI_AIR_RELOCATE) then {

								if (
									!isNull _driver &&
									{alive _driver}
								) then {

									_driver enableAI "PATH";
									_driver setBehaviour "CARELESS";
									_driver setSpeedMode "FULL";

									_veh setDestination [
										_newHidePos,
										"VEHICLE PLANNED",
										true
									];

									_driver doMove _newHidePos;
								};

								_veh setVariable [
									"AA_STATE",
									"RELOCATING",
									true
								];

								if (
									PROTOCOL_AI_ANTI_AIR_SMOKE_RELOCATE
								) then {

									private _smokePos =
										getPosATL _veh;

									"SmokeShellPurple" createVehicle _smokePos;
									sleep 1;

									if (alive _veh) then {
										"SmokeShellPurple" createVehicle _smokePos
									};

									sleep 1;

									if (alive _veh) then {
										"SmokeShellPurple" createVehicle _smokePos
									};
								};

							} else {

								_veh setVariable [
									"AA_STATE",
									"WAITING",
									true
								];

								_veh setVariable [
									"AA_RELOCATE_TIME",
									-1,
									true
								];

								_veh setVariable [
									"AA_ENGAGED",
									false,
									true
								];

								_veh setVehicleRadar 1;
							};

						} else {

							_veh setVariable [
								"AA_RELOCATE_TIME",
								time,
								true
							];
						};

						continue
					};

					if (_state isEqualTo "RELOCATING") then {

						private _hidePos =
							_veh getVariable [
								"AA_HidePosition",
								[]
							];

						private _relocatingStart =
							_veh getVariable [
								"AA_RELOCATING_START",
								-1
							];

						if (_hidePos isEqualTo []) then {

							private _driver = driver _veh;

							if (!isNull _driver) then {
								_driver disableAI "PATH";
								doStop _driver
							};

							doStop _veh;

							_veh setVariable [
								"AA_STATE",
								"WAITING",
								true
							];

							_veh setVehicleRadar 1;

							continue
						};

						private _distanceToHide =
							_veh distance2D _hidePos;

						private _origin =
							_veh getVariable [
								"AA_RELOCATE_ORIGIN",
								getPosATL _veh
							];

						private _distanceFromOrigin =
							_origin distance2D _veh;

						if (
							_distanceFromOrigin >=
							(PROTOCOL_AI_ANTI_AIR_RELOCATE_MIN_RADIUS - 25) &&
							{_distanceToHide < 30}
						) then {

							private _driver = driver _veh;

							if (!isNull _driver) then {
								_driver disableAI "PATH";
								doStop _driver
							};

							doStop _veh;
							_veh setVelocity [0,0,0];

							_veh setVariable [
								"AA_RELOCATING_START",
								-1,
								true
							];

							_veh setVariable [
								"AA_RELOCATE_TIME",
								-1,
								true
							];

							_veh setVariable [
								"AA_STATE",
								"WAITING",
								true
							];

							_veh setVariable [
								"AA_TARGET",
								objNull,
								true
							];

							_veh setVariable [
								"AA_TARGET_IS_MISSILE",
								false,
								true
							];

							_veh setVariable [
								"AA_ENGAGED",
								false,
								true
							];

							_veh setVariable [
								"AA_HidePosition",
								getPosATL _veh,
								true
							];

							_veh setVehicleRadar 1;

							continue
						};

						private _driver = driver _veh;

						if (
							!isNull _driver &&
							{alive _driver}
						) then {

							if (
								time -
								(_veh getVariable [
									"AA_LAST_MOVE_TIME",
									time
								]) > 4
							) then {

								private _oldDistance =
									_veh getVariable [
										"AA_LAST_MOVE_DISTANCE",
										_distanceToHide
									];

								if (
									_distanceToHide >
									30 &&
									{
										(
											_oldDistance -
											_distanceToHide
										) < 5
									}
								) then {

									private _retry =
										(_veh getVariable [
											"AA_RELOCATE_RETRIES",
											0
										]) + 1;

									_veh setVariable [
										"AA_RELOCATE_RETRIES",
										_retry,
										true
									];

									if (_retry < 4) then {

										_veh setDestination [
											_hidePos,
											"VEHICLE PLANNED",
											true
										];

										_driver enableAI "PATH";
										_driver doMove _hidePos;

									} else {

										private _newPos = [
											_veh,
											PROTOCOL_AI_ANTI_AIR_RELOCATE_MIN_RADIUS,
											PROTOCOL_AI_ANTI_AIR_RELOCATE_MAX_RADIUS,
											_origin
										] call _findHidePosition;

										if !(_newPos isEqualTo []) then {

											_hidePos = _newPos;

											_veh setVariable [
												"AA_HidePosition",
												_newPos,
												true
											];

											_veh setVariable [
												"AA_RELOCATE_RETRIES",
												0,
												true
											];

											_veh setDestination [
												_newPos,
												"VEHICLE PLANNED",
												true
											];

											_driver enableAI "PATH";
											_driver doMove _newPos;
										};
									};

									_veh setVariable [
										"AA_LAST_MOVE_TIME",
										time,
										true
									];
								};

								_veh setVariable [
									"AA_LAST_MOVE_DISTANCE",
									_distanceToHide,
									true
								];

								_veh setVariable [
									"AA_LAST_MOVE_TIME",
									time,
									true
								];
							};
						};

						if (
							_relocatingStart > 0 &&
							{
								time - _relocatingStart > 180
							}
						) then {

							private _newPos = [
								_veh,
								PROTOCOL_AI_ANTI_AIR_RELOCATE_MIN_RADIUS,
								PROTOCOL_AI_ANTI_AIR_RELOCATE_MAX_RADIUS,
								_origin
							] call _findHidePosition;

							if !(_newPos isEqualTo []) then {

								_veh setVariable [
									"AA_HidePosition",
									_newPos,
									true
								];

								_veh setVariable [
									"AA_RELOCATING_START",
									time,
									true
								];

								_veh setVariable [
									"AA_RELOCATE_RETRIES",
									0,
									true
								];

								private _newDriver = driver _veh;

								if (
									!isNull _newDriver &&
									{alive _newDriver}
								) then {

									_newDriver enableAI "PATH";

									_veh setDestination [
										_newPos,
										"VEHICLE PLANNED",
										true
									];

									_newDriver doMove _newPos;
								};
							};
						};

						continue
					};

					private _driver = driver _veh;

					if (!isNull _driver) then {
						_driver disableAI "PATH";
						doStop _driver
					};

					doStop _veh;

					_veh setVariable [
						"AA_STATE",
						"WAITING",
						true
					];

					_veh setVariable [
						"AA_TARGET",
						objNull,
						true
					];

					_veh setVariable [
						"AA_TARGET_IS_MISSILE",
						false,
						true
					];

					_veh setVariable [
						"AA_RELOCATE_TIME",
						-1,
						true
					];

					_veh setVariable [
						"AA_RELOCATING_START",
						-1,
						true
					];

					_veh setVariable [
						"AA_ENGAGED",
						false,
						true
					];

					_veh setVehicleRadar 1;

				} forEach _aaVehicles;

			} forEach allGroups;

			sleep 0.5;
		};
	};

	[] spawn _PROTOCOL_ANTI_AIR;
};