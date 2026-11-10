[] spawn {
	if (isNil "PROTOCOL_AI_RAPPELING_ENABLED") then {PROTOCOL_AI_RAPPELING_ENABLED = true};
	if (isNil "PROTOCOL_AI_RAPPELING_HEIGHT") then {PROTOCOL_AI_RAPPELING_HEIGHT = 20};
	if (isNil "PROTOCOL_AI_RAPPELING_INTO_BUILDING") then {PROTOCOL_AI_RAPPELING_INTO_BUILDING = true};

	while {true} do {
		if (PROTOCOL_AI_RAPPELING_ENABLED) then {
			{
				private _veh = _x;

				if (alive _veh && {_veh isKindOf "Helicopter"}) then {
					private _cargo = (crew _veh) select {
						alive _x &&
						{vehicle _x == _veh} &&
						{toLower ((assignedVehicleRole _x) param [0, ""]) == "cargo"}
					};

					if !(_cargo isEqualTo []) then {
						private _dropGroup = _veh getVariable ["buildingRappelCargoGroup", grpNull];

						if (isNull _dropGroup) then {
							_dropGroup = createGroup [side (_cargo select 0), false];

							if (!isNull _dropGroup) then {
								_veh setVariable ["buildingRappelCargoGroup", _dropGroup, true];
							};
						};

						if (!isNull _dropGroup) then {
							private _cargoToJoin = _cargo select {
								group _x != _dropGroup
							};

							if !(_cargoToJoin isEqualTo []) then {
								_cargoToJoin joinSilent _dropGroup;
							};

							if (
								!(_veh getVariable ["buildingRappelDone", false]) &&
								{!(_veh getVariable ["buildingRappelActive", false])}
							) then {
								private _grp = _dropGroup;
								private _enemies = (_veh nearEntities ["Man", 600]) select {
									alive _x &&
									{side _x != side _grp}
								};

								if (PROTOCOL_AI_RAPPELING_INTO_BUILDING) then {
									private _buildingEnemies = _enemies select {
										insideBuilding _x > 0.5
									};

									if !(_buildingEnemies isEqualTo []) then {
										_enemies = _buildingEnemies;
									};
								};

								if !(_enemies isEqualTo []) then {
									private _enemy = _enemies select 0;
									private _targetASL = [];
									private _hoverAGL = [];

									if (PROTOCOL_AI_RAPPELING_INTO_BUILDING) then {
										private _building = objNull;

										if (insideBuilding _enemy > 0.5) then {
											_building = nearestBuilding _enemy;
										} else {
											private _buildings = nearestObjects [
												_enemy,
												["House"],
												250,
												true
											];

											if !(_buildings isEqualTo []) then {
												_building = _buildings select 0;
											};
										};

										if (!isNull _building && {alive _enemy}) then {
											private _box = boundingBoxReal _building;
											private _min = _box select 0;
											private _max = _box select 1;

											private _roofLocal = [
												(((_min select 0) + (_max select 0)) / 2),
												(((_min select 1) + (_max select 1)) / 2),
												(_max select 2) + 0.5
											];

											private _roofAGL = _building modelToWorld _roofLocal;
											_targetASL = AGLToASL _roofAGL;

											private _hoverASL = +_targetASL;
											_hoverASL set [2, (_targetASL select 2) + 25];

											_hoverAGL = ASLToAGL _hoverASL;
										};
									} else {
										private _landPos = [];

										for "_i" from 1 to 40 do {
											if (_landPos isEqualTo []) then {
												private _candidate = _enemy getPos [
													30 + random 70,
													random 360
												];

												_candidate set [2, 0];

												if (
													!surfaceIsWater _candidate &&
													{
														(nearestTerrainObjects [
															_candidate,
															["HOUSE", "TREE", "SMALL TREE", "BUSH"],
															12
														]) isEqualTo []
													}
												) then {
													_landPos = _candidate;
												};
											};
										};

										if (_landPos isEqualTo []) then {
											_landPos = _enemy getPos [60, random 360];
										};

										_landPos set [2, 0];
										_targetASL = ATLToASL _landPos;

										private _hoverASL = +_targetASL;
										_hoverASL set [2, (_targetASL select 2) + 25];

										_hoverAGL = ASLToAGL _hoverASL;
									};

									if !(_targetASL isEqualTo []) then {
										private _pilot = driver _veh;

										if (!isNull _pilot && {alive _pilot}) then {
											_veh setVariable ["buildingRappelActive", true, true];

											[
												_veh,
												_targetASL,
												_hoverAGL
											] spawn {
												params ["_veh", "_targetASL", "_hoverAGL"];

												private _pilot = driver _veh;
												private _timeout = time + 45;

												if (!isNull _pilot && {alive _pilot}) then {
													(group _pilot) setSpeedMode "LIMITED";
													_pilot doMove _hoverAGL;

													while {
														alive _veh &&
														{!isNull _veh} &&
														{time < _timeout} &&
														{_veh distance2D _targetASL > 18}
													} do {
														private _pilotNow = driver _veh;

														if (!isNull _pilotNow && {alive _pilotNow}) then {
															_pilotNow doMove _hoverAGL;
															(group _pilotNow) setSpeedMode "LIMITED";
														};

														sleep 1;
													};

													if (
														alive _veh &&
														{!isNull _veh} &&
														{_veh distance2D _targetASL <= 18}
													) then {
														private _height = (getPosASL _veh select 2) - (_targetASL select 2);

														if (_height > 5) then {
															if (_height > 80) then {
																_height = 80;
															};

															_veh flyInHeight PROTOCOL_AI_RAPPELING_HEIGHT;

															sleep 2;

															if (alive _veh) then {
																[
																	_veh,
																	PROTOCOL_AI_RAPPELING_HEIGHT,
																	_targetASL
																] call AR_Rappel_All_Cargo;

																_veh setVariable ["buildingRappelDone", true, true];
															};
														};
													};
												};

												_veh setVariable ["buildingRappelActive", false, true];
											};
										};
									};
								};
							};
						};
					};
				};
			} forEach vehicles;
		};

		sleep 3;
	};
};