
addMissionEventHandler ["EntityCreated", {
        params ["_entity"];
        if (isNull _entity || {!(_entity isKindOf "CAManBase")}) exitWith {};

        [_entity] spawn {
            params ["_unit"];
			
			if (isNil "PROTOCOL_AI_SKILL") then {PROTOCOL_AI_SKILL = 0};
            if (isNil "PROTOCOL_AI_AGRESSIVE") then {PROTOCOL_AI_AGRESSIVE = false};
			
		  
			sleep 0.1;
			if (!alive _unit) exitWith {};
            
			if(PROTOCOL_AI_SKILL == 0) then {
			_unit setSkill 0.5;
            _unit setSkill ["aimingAccuracy", 0.3];
            _unit setSkill ["aimingShake", 0.4];
            _unit setSkill ["aimingSpeed", 0.45];
            _unit setSkill ["spotDistance", 0.55];
            _unit setSkill ["spotTime", 0.5];
            _unit setSkill ["courage", 0.65];
            _unit setSkill ["reloadSpeed", 0.5];
            _unit setSkill ["commanding", 1];
			};


			if(PROTOCOL_AI_SKILL == 1) then {
			_unit setSkill 1;
			_unit setSkill ["aimingAccuracy", 1];
			_unit setSkill ["aimingShake", 0.1];
			_unit setSkill ["aimingSpeed", 1];
			_unit setSkill ["spotDistance", 1];
			_unit setSkill ["spotTime", 1];
			_unit setSkill ["courage", 1];
			_unit setSkill ["reloadSpeed", 1];
			_unit setSkill ["commanding", 1];
			};
			
			if(PROTOCOL_AI_AGRESSIVE) then {
			(group _unit) setCombatMode "RED";
			};
			
		};
		

		
	}];


[] spawn {
    if (isNil "PROTOCOL_AI_CQB_ENABLED") then {PROTOCOL_AI_CQB_ENABLED = true};
    if (isNil "PROTOCOL_AI_CQB_RADIUS") then {PROTOCOL_AI_CQB_RADIUS = 5};
    if (isNil "PROTOCOL_AI_CQB_STANCE") then {PROTOCOL_AI_CQB_STANCE = 0};
    if (isNil "PROTOCOL_AI_CQB_GRENADE_IN_DOOR") then {PROTOCOL_AI_CQB_GRENADE_IN_DOOR = true};
    if (isNil "PROTOCOL_AI_CQB_SPEED") then {PROTOCOL_AI_CQB_SPEED = 0};
    if (isNil "PROTOCOL_AI_CQB_NoVoice") then {PROTOCOL_AI_CQB_NoVoice = true};
    if (isNil "PROTOCOL_AI_CITY_TACTICS_ENABLED") then {PROTOCOL_AI_CITY_TACTICS_ENABLED = true};
    if (isNil "PROTOCOL_AI_CITY_TACTICS_SMOKE_ENABLED") then {PROTOCOL_AI_CITY_TACTICS_SMOKE_ENABLED = true};
    if (isNil "PROTOCOL_AI_TACTICS") then {PROTOCOL_AI_TACTICS = 0};
    if (isNil "PROTOCOL_AI_ENABLED") then {PROTOCOL_AI_ENABLED = true};
    if (isNil "PROTOCOL_AI_DEBUG") then {PROTOCOL_AI_DEBUG = false};
	if (isNil "PROTOCOL_AI_SUPRESS") then {PROTOCOL_AI_SUPRESS = true};
	if (isNil "PROTOCOL_AI_BLINDFIRE") then {PROTOCOL_AI_BLINDFIRE = true};

    //if (isNil "PROTOCOL_AI_NAVY_SEAL") then {PROTOCOL_AI_NAVY_SEAL = true};
    
     _PROTOCOL_CITY_TACTICS = {
	params ["_grp"];

	if (
		local (leader _grp) &&
		{(units _grp) findIf {alive _x} > -1}
	) then {

		private _units = (units _grp) select {alive _x};

		if ((count _units) > 2) then {

			private _enemy = objNull;
			private _dist = 9999;

			{
				private _near = _x findNearestEnemy _x;

				if (!isNull _near) then {
					private _d = _x distance _near;

					if (_d < _dist) then {
						_dist = _d;
						_enemy = _near;
					};
				};

			} forEach _units;

			
			if (isNull _enemy || {_dist > 300}) exitWith {
				_grp setVariable ["CoverSmoke", false];
			};

			_grp setCombatMode "RED";
			_grp setBehaviourStrong "COMBAT";
			_grp enableAttack true;

			private _leader = leader _grp;
			private _coverMan = _units select 0;
			private _stack = _units - [_coverMan];

			private _enemyPos = getPosATL _enemy;
			private _dir = [_leader,_enemy] call BIS_fnc_dirTo;

			private _coverPos = _enemyPos getPos [25 + random 15,_dir + 180];

			private _nearBuildings = nearestObjects [_coverPos,["House","Building"],40];

			if ((count _nearBuildings) > 0) then {

				private _building = _nearBuildings select 0;
				private _bPos = getPosATL _building;

				private _wallPos = _bPos getPos [2.5,_dir];
				private _safeSide = _bPos getPos [4,_dir + 180];

				_coverMan doMove _wallPos;
				_coverMan setUnitPos "MIDDLE";
				_coverMan doWatch _enemy;
				_coverMan suppressFor 8;

				if(PROTOCOL_AI_CITY_TACTICS_SMOKE_ENABLED ) then {
				if (
					!("CoverSmoke" in allVariables _grp) ||
					{!(_grp getVariable ["CoverSmoke",false])}
				) then {

					if ("SmokeShell" in magazines _coverMan && {!isRemoteControlling _coverMan}  &&  {!isPlayer _coverMan}  ) then {

						_coverMan playActionNow "ThrowGrenade";
						_coverMan forceWeaponFire ["SmokeShellMuzzle","SmokeShellMuzzle"];
						/*
						private _smoke =
							"SmokeShell" createVehicle
							(_enemyPos getPos [10 + random 15,_dir + 180]);

						_smoke setVelocity [0,0,0];

							_grp setVariable ["CoverSmoke",true];
		*/			};
				};
			    };
				sleep 2;

				{
					private _movePos = _safeSide getPos [random 3,random 360];

					_x doMove _movePos;
					_x setUnitPos "AUTO";
					_x doWatch _enemy;

				} forEach _stack;

				sleep 1;

				private _nextPos = _enemyPos getPos [40 + random 30,_dir + 180];
				private _nextBuildings = nearestObjects [_nextPos,["House","Building"],50];

				if ((count _nextBuildings) > 0) then {

					private _nextBuilding = _nextBuildings select 0;
					private _nextBPos = getPosATL _nextBuilding;

					{
						private _advance =
							_nextBPos getPos
							[
								2 + random 3,
								(_dir + 180) + random 40 - random 40
							];

						_x doMove _advance;
						_x setUnitPos "AUTO";
						_x doWatch _enemy;

					} forEach _units;
				};
			};
		};
	};
}; 

	 _PROTOCOL_CQB = {
	params ["_grp"];
	if (isNull _grp) exitWith {};

	_grp setVariable ["Location","Building"];

	private _units = units _grp;
	if ((count _units) == 0) exitWith {};

	private _leader = leader _grp;
	if (!alive _leader) exitWith {};

	private _buildings = nearestObjects [
		position _leader,
		["House","Building","Strategic","Church","FuelStation","ViewTower","Lighthouse","Fortress","Bunker","Ruins"],
		30
	];

	{
		private _bld = _x;
		private _doorPos = _bld buildingExit 0;
		private _positions = [_bld] call BIS_fnc_buildingPositions;

		if ((count _positions) > 0 && {_leader distance _bld < 30}) then {

			private _enemyInside = false;

			{
				if (
					side _x != side _leader &&
					alive _x &&
					(_x distance2D _bld < 25)
				) exitWith {
					_enemyInside = true;
				};
			} forEach allUnits;

			if (_enemyInside) then {
				  if !(_grp getVariable ["CQBClearing",false]) then {

			_grp setVariable ["CQBClearing",true]; 
				if(_grp getVariable ["DefendCQB", false]) then {
				if (
					alive _leader &&
					{vehicle _leader == _leader} &&
					{!(_leader getVariable ["doorTask",false])}
				) then {
                     if(PROTOCOL_AI_CQB_GRENADE_IN_DOOR) then {
					_leader setVariable ["doorTask",false];
					   if (!isNull _bld) then {

			  private _exitPos = [];
			  private _bestDist = 1e10;

			  for "_i" from 0 to 50 do {

				private _p = _bld buildingExit _i;

				 if ((_p select 0) != 0 || (_p select 1) != 0 || (_p select 2) != 0) then {
				  private _d = _leader distance _p;

				  if (_d < _bestDist) then {
					_bestDist = _d;
					_exitPos = _p;
				  };

				};

			  };

			  if ((count _exitPos) > 0) then {

				_leader doMove _exitPos;
				/*
				waitUntil {
				  sleep 0.2;
				  !alive _leader ||
				  (_leader distance _exitPos < 2)
				};
			   */
				if (alive _leader) then {

				  private _door = 0;
				  private _best = 1e10;

				  for "_i" from 1 to 20 do {

					private _sel = format ["Door_%1_trigger", _i];

					if ((_bld selectionPosition _sel) isNotEqualTo [0,0,0]) then {

					  private _worldPos = _bld modelToWorld (_bld selectionPosition _sel);

					  private _d = _worldPos distance _exitPos;

					  if (_d < _best) then {
						_best = _d;
						_door = _i;
					  };

					};

				  };

				  if (_door > 0) then {

					
					_bld animateSource [format ["Door_%1_sound_source", _door],1];

					sleep 1;
					 _leader doWatch _bld	;
					
					if !("HandGrenade" in magazines _leader) then {
					_leader addMagazine "HandGrenade";
				  };
                  if(!isRemoteControlling _coverMan && {!isPlayer _coverMan}) then {
				  _leader selectWeapon "HandGrenadeMuzzle"; 
				  _leader forceWeaponFire ["HandGrenadeMuzzle","HandGrenadeMuzzle"];
				
					sleep 2;
				  };
					
					_bld animateSource [format ["Door_%1_sound_source", _door],0];
					
					//_leader setSpeedMode "FULL";
					private _dir = _bld getDir _leader;
					private _retreatPos = [getPosATL _leader, 10, _dir] call BIS_fnc_relPos;
					_leader doMove _retreatPos;
					};

				};

			  };

			};
				_leader setVariable ["doorTask",true];
				};
				};
				};
				private _targetBuilding = objNull;
	private _positions = [];
	{
		private _posList = [_x] call BIS_fnc_buildingPositions;
		if ((count _posList) > 0) exitWith {
			_targetBuilding = _x;
			_positions = _posList;
		};
	} forEach _buildings;

	if (isNull _targetBuilding || (count _positions) == 0) exitWith {};

	
	[_grp, _positions, _targetBuilding] spawn {

	params ["_grp","_positions","_building"];

	{
		
		private _room = _x;

		private _aliveUnits = units _grp select {alive _x};

		if ((count _aliveUnits) == 0) exitWith {};

		{
				if (PROTOCOL_AI_CQB_SPEED == 0) then {_x forceSpeed 2;};
				if (PROTOCOL_AI_CQB_SPEED == 1) then {_x forceSpeed 3;};
				if (PROTOCOL_AI_CQB_SPEED == 2) then {_x forceSpeed 5;};
			
					if (PROTOCOL_AI_CQB_STANCE == 0) then {
						_x setUnitPos "UP";
						if ((_forEachIndex mod 2) == 0) then {
							_x setUnitPos "MIDDLE";
						};
					};
					if (PROTOCOL_AI_CQB_STANCE == 1) then {
						_x setUnitPos "UP";
					};
					if (PROTOCOL_AI_CQB_STANCE == 2) then {
						_x setUnitPos "MIDDLE";
					};
				
			
				

			_x doMove _room;
			_x doWatch (_room vectorAdd [random 4 - 2,random 4 - 2,1]);

		} forEach _aliveUnits;

		private _timeout = time + 15;

		waitUntil {

			sleep 0.3;

			private _arrived = true;

			{
				if (alive _x && {_x distance _room > 2.5}) exitWith {
					_arrived = false;
				};
			} forEach _aliveUnits;

			_arrived || {time > _timeout}
		};
		 sleep 2.5;		

		{
			if (alive _x) then {

				_x doWatch (_room vectorAdd [random 6-3,random 6-3,1]);

				if !(currentWeapon _x isEqualTo handgunWeapon _x) then {
					_x doSuppressiveFire (_room vectorAdd [random 3-1.5,random 3-1.5,1]);
				};

			};
		} forEach _aliveUnits;

		sleep 3;

	} forEach _positions;

	{
		if (alive _x) then {
			_x forceSpeed -1;
			_x setUnitPos "AUTO";
		};
	} forEach units _grp;

	_grp setVariable ["CQBClearing", false];

};
	};
	
			} else {
				
				
				{
				private _unit = _x;

				if (alive _unit && {unitReady _unit}) then {

					private _pos = _positions select (_forEachIndex mod (count _positions));
                    
				   if (PROTOCOL_AI_CQB_SPEED == 0) then {_unit forceSpeed 1.5;};
				   if (PROTOCOL_AI_CQB_SPEED == 1) then {_unit forceSpeed 3;};
				   if (PROTOCOL_AI_CQB_SPEED == 2) then {_unit forceSpeed 5;};
					
					if (PROTOCOL_AI_CQB_STANCE == 0) then {
						_unit setUnitPos "UP";
						if ((_forEachIndex mod 2) == 0) then {
							_unit setUnitPos "MIDDLE";
						};
					};
					if (PROTOCOL_AI_CQB_STANCE == 1) then {
						_unit setUnitPos "UP";
					};
					if (PROTOCOL_AI_CQB_STANCE == 2) then {
						_unit setUnitPos "MIDDLE";
					};
				

					_unit doMove _pos;

					_unit doWatch (
						_pos vectorAdd [
							random 5,
							random 5,
							0
						]
					);

					_unit doMove (
						_pos vectorAdd [
							random 2,
							random 2,
							0
						]
					);
					_grp setVariable ["DefendCQB", true];

                    if (PROTOCOL_AI_CQB_NoVoice) then {
					_unit setSpeaker "NoVoice";
					};
				};

			} forEach _units; /* [_grp, _bld, _positions] spawn {
		params ["_grp", "_bld", "_positions"];
		waitUntil {sleep 5; {alive _x && _x distance _bld < 30} count units _grp == 0 || isNull _grp};
		if (isNull _grp) exitWith {};
		while {count units _grp > 0 && !isNull _grp} do {
			{
				private _unit = _x;
				if (alive _unit && _unit distance _bld > 10) then {
					private _closestPos = _positions select 0;
					{ if (_x distance _unit < _closestPos distance _unit) then { _closestPos = _x; } } forEach _positions;
					_unit doMove _closestPos;
				} else {
					if (alive _unit) then {
						private _newPos = _positions select floor random count _positions;
						_unit doMove _newPos;
					};
				};
				sleep 1;
			} forEach units _grp;
			sleep 10;
		};
	};*/
			};

			
		};

	} forEach _buildings;
};
_PROTOCOL_ENVIROMENT_TACTICS = {
    params ["_grp"];
    if (isNull _grp || {count units _grp == 0}) exitWith {};
    private _leader = leader _grp;
    if (isNull _leader || {!alive _leader}) exitWith {};
    private _pos = getPosATL _leader;
    private _LocationGrp = _grp getVariable ["Location", "Open"];
    private _nearestBuilding = nearestObject [_pos, "Building"];
    private _distanceToBuilding = if (!isNull _nearestBuilding) then {_leader distance _nearestBuilding} else {1e10};
	if (!isNull _nearestBuilding) then {
					if (_distanceToBuilding < PROTOCOL_AI_CQB_RADIUS + 10  && _distanceToBuilding > PROTOCOL_AI_CQB_RADIUS && _LocationGrp != "Building") then { 
						  if(PROTOCOL_AI_DEBUG) then {
						  systemChat format [ "%1 | City tactic ", _grp];
						  };
						  _grp setVariable ["Location", "City"];
						  [_grp] call  _PROTOCOL_CITY_TACTICS;
							  
					};
					if (_distanceToBuilding < PROTOCOL_AI_CQB_RADIUS) then {
						if(PROTOCOL_AI_DEBUG) then {
						 systemChat format [ "%1 | CQB ", _grp];
						};
					   [_grp] call _PROTOCOL_CQB; 
					};
					} else { 
					private _pos = getPosATL _leader;
			    	private _trees = nearestTerrainObjects [_pos, ["TREE","SMALL TREE","BUSH"], 30];
				    if (count _trees > 15) then {
					_grp setVariable ["Location", "Forest"];
					if( _LocationGrp == "Forest") then {
						if(PROTOCOL_AI_DEBUG) then {
                        systemChat format [ "%1 | Woodland tactic ", _grp];
						};
					[_grp] call _PROTOCOL_WOODLAND;
			       };
		};
	};
	
	
};
_PROTOCOL_DOCTRINE_TACTICS = {
	params ["_grp"];
	        if (
			!isNull _grp &&
			{local _grp} &&
			{count units _grp > 1} &&
			{alive leader _grp} &&
			{side _grp != civilian} &&
			{side _grp != sideLogic} &&
			{!isPlayer leader _grp}
		) then
		{
			private _leader = leader _grp;
			private _aliveUnits = (units _grp) select {alive _x};

			if (count _aliveUnits > 1) then
			{
				private _posture = [_grp] call _PROTOCOL_GET_POSTURE;

				private _enemy = _leader findNearestEnemy _leader;
				private _enemyValid = !isNull _enemy && {alive _enemy};

				private _ownCount = count _aliveUnits;
				private _enemyCount = 0;
				private _enemyGroup = grpNull;
				private _enemyTactic = "";
				private _enemyDistance = 99999;

				if (_enemyValid) then
				{
					_enemyGroup = group _enemy;
					_enemyCount = count ((units _enemyGroup) select {alive _x});
					_enemyTactic = _enemyGroup getVariable ["PROTOCOL_TACTIC", ""];
					_enemyDistance = _leader distance2D _enemy;
				};

				private _ratio = if (_enemyCount > 0) then
				{
					_ownCount / _enemyCount
				}
				else
				{
					99
				};

				private _dominant = _enemyValid && {_ratio >= 1.35};
				private _outnumbered = _enemyValid && {_ratio <= 0.75};
				private _nearParity = _enemyValid && {!_dominant} && {!_outnumbered};

				private _mountedCount =
				{
					vehicle _x != _x &&
					{vehicle _x isKindOf "LandVehicle"}
				} count _aliveUnits;

				private _mostlyMounted = _mountedCount >= ceil (_ownCount * 0.5);

				private _movingVehicle =
				{
					vehicle _x != _x &&
					{vehicle _x isKindOf "LandVehicle"} &&
					{speed (vehicle _x) > 5}
				} count _aliveUnits > 0;

				private _averageDamage = 0;

				{
					_averageDamage = _averageDamage + damage _x;
				} forEach _aliveUnits;

				_averageDamage = _averageDamage / (_ownCount max 1);

				private _combat = behaviour _leader == "COMBAT";

				private _ambushReady =
					_enemyValid &&
					{_ownCount >= 3} &&
					{_mountedCount > 0} &&
					{_enemyDistance > 150} &&
					{_enemyDistance < 800} &&
					{!_combat} &&
					{_posture in ["ATTACK","TRANSITION"]};

				private _lastTactic = _grp getVariable ["PROTOCOL_TACTIC", ""];
				private _lastPosture = _grp getVariable ["PROTOCOL_TACTIC_POSTURE", ""];
				private _nextSwitch = _grp getVariable ["PROTOCOL_TACTIC_NEXT_SWITCH", 0];

				private _postureChanged = _lastPosture != "" && {_lastPosture != _posture};
				private _canSwitch = _lastTactic isEqualTo "" || {time >= _nextSwitch} || {_postureChanged};

				if (!_enemyValid) then
				{
					if (_posture == "DEFEND") then
					{
						if (_lastTactic != "ALL_ROUND_DEFENSE" || {_canSwitch}) then
						{
							_grp setVariable ["PROTOCOL_TACTIC", "ALL_ROUND_DEFENSE"];
							_grp setVariable ["PROTOCOL_TACTIC_POSTURE", _posture];
							_grp setVariable ["PROTOCOL_TACTIC_NEXT_SWITCH", time + 40 + random 25];

							private _groupName = groupId _grp;

							if (_groupName isEqualTo "") then
							{
								_groupName = format ["%1", _grp];
							};
                            if(PROTOCOL_AI_DEBUG) then {
							systemChat format ["%1 | ALL_ROUND_DEFENSE", _groupName];
							};
						};

						[_grp, "ALL_ROUND_DEFENSE"] call _PROTOCOL_APPLY_TACTIC;
					}
					else
					{
						if (behaviour _leader == "COMBAT") then
						{
							_grp setBehaviour "AWARE";
							_grp setSpeedMode "NORMAL";

							{
								_x setUnitPos "AUTO";
								_x setVariable ["PROTOCOL_SUPPRESSING", false];
							} forEach _aliveUnits;
						};
					};
				}
				else
				{
					if (_canSwitch) then
					{
						private _choices =
						[
							["BOUNDING_OVERWATCH",0],
							["PAIRS",0],
							["TRIPLET",0],
							["FIRE_AND_MANEUVER",0],
							["FLANKING",0],
							["ENCIRCLEMENT",0],
							["RECONNAISSANCE_BY_FIRE",0],
							["CENTRAL_PEEL",0],
							["ALL_ROUND_DEFENSE",0],
							["AMBUSH",0]
						];

						for "_i" from 0 to (count _choices - 1) do
						{
							private _tactic = (_choices select _i) select 0;
							private _w = 0.2;
							private _counterBonus = 0;

							switch (_tactic) do
							{
								case "BOUNDING_OVERWATCH":
								{
									if (_ownCount < 4) then
									{
										_w = 0;
									}
									else
									{
										_w = 1.5;

										if (_posture == "ATTACK") then
										{
											_w = _w + 4;
										};

										if (_posture == "DEFEND") then
										{
											_w = _w + 3;
										};

										if (_outnumbered) then
										{
											_w = _w + 4;
										};

										if (_nearParity) then
										{
											_w = _w + 2;
										};

										if (_mostlyMounted) then
										{
											_w = _w * 0.35;
										};
									};
								};

								case "PAIRS":
								{
									if (_ownCount < 2) then
									{
										_w = 0;
									}
									else
									{
										_w = 1.5;

										if (_nearParity) then
										{
											_w = _w + 4;
										};

										if (_posture == "DEFEND") then
										{
											_w = _w + 2;
										};

										if (_outnumbered) then
										{
											_w = _w + 3;
										};

										if (_mostlyMounted) then
										{
											_w = _w * 0.4;
										};
									};
								};

								case "TRIPLET":
								{
									if (_ownCount < 3) then
									{
										_w = 0;
									}
									else
									{
										_w = 1;

										if (_nearParity) then
										{
											_w = _w + 3;
										};

										if (_posture == "DEFEND") then
										{
											_w = _w + 3;
										};

										if (_posture == "TRANSITION") then
										{
											_w = _w + 2;
										};

										if (_outnumbered) then
										{
											_w = _w + 2;
										};

										if (_mostlyMounted) then
										{
											_w = _w * 0.3;
										};
									};
								};

								case "FIRE_AND_MANEUVER":
								{
									if (_ownCount < 3) then
									{
										_w = 0;
									}
									else
									{
										_w = 1.5;

										if (_posture == "ATTACK") then
										{
											_w = _w + 5;
										};

										if (_dominant) then
										{
											_w = _w + 4;
										};

										if (_nearParity) then
										{
											_w = _w + 3;
										};

										if (_averageDamage > 0.35) then
										{
											_w = _w * 0.65;
										};

										if (_mostlyMounted) then
										{
											_w = _w * 0.3;
										};
									};
								};

								case "FLANKING":
								{
									if (_ownCount < 4) then
									{
										_w = 0;
									}
									else
									{
										_w = 1;

										if (_posture == "ATTACK") then
										{
											_w = _w + 6;
										};

										if (_dominant) then
										{
											_w = _w + 5;
										};

										if (_nearParity) then
										{
											_w = _w + 3;
										};

										if (_outnumbered) then
										{
											_w = _w * 0.35;
										};

										if (_mostlyMounted) then
										{
											_w = _w * 0.35;
										};
									};
								};

								case "ENCIRCLEMENT":
								{
									if (_ownCount < 5 || {!_dominant}) then
									{
										_w = 0;
									}
									else
									{
										_w = 1 + (_ratio min 3) * 3;

										if (_posture == "ATTACK") then
										{
											_w = _w + 7;
										};

										if (_enemyDistance < 700) then
										{
											_w = _w + 2;
										};

										if (_mostlyMounted) then
										{
											_w = _w * 0.45;
										};
									};
								};

								case "RECONNAISSANCE_BY_FIRE":
								{
									_w = 1.5;

									if (_enemyDistance > 250) then
									{
										_w = _w + 4;
									};

									if (_enemyDistance < 900) then
									{
										_w = _w + 2;
									};

									if (_posture == "DEFEND") then
									{
										_w = _w + 3;
									};

									if (_posture == "TRANSITION") then
									{
										_w = _w + 3;
									};

									if (_outnumbered) then
									{
										_w = _w + 2;
									};

									if (_mostlyMounted) then
									{
										_w = _w * 0.5;
									};
								};

								case "CENTRAL_PEEL":
								{
									if (_ownCount < 3) then
									{
										_w = 0;
									}
									else
									{
										_w = 1;

										if (_outnumbered) then
										{
											_w = _w + 8;
										};

										if (_posture == "DEFEND") then
										{
											_w = _w + 5;
										};

										if (_averageDamage > 0.25) then
										{
											_w = _w + 4;
										};

										if (_enemyDistance < 400) then
										{
											_w = _w + 3;
										};

										if (_dominant) then
										{
											_w = _w * 0.35;
										};
									};
								};

								case "ALL_ROUND_DEFENSE":
								{
									if (_ownCount < 2) then
									{
										_w = 0;
									}
									else
									{
										_w = 1;

										if (_posture == "DEFEND") then
										{
											_w = _w + 8;
										};

										if (_outnumbered) then
										{
											_w = _w + 7;
										};

										if (_enemyDistance < 350) then
										{
											_w = _w + 3;
										};

										if (_averageDamage > 0.35) then
										{
											_w = _w + 4;
										};

										if (_posture == "ATTACK") then
										{
											_w = _w * 0.25;
										};
									};
								};

								case "AMBUSH":
								{
									if (!_ambushReady) then
									{
										_w = 0;
									}
									else
									{
										_w = 2;

										if (_movingVehicle) then
										{
											_w = _w + 8;
										};

										if (_mostlyMounted) then
										{
											_w = _w + 5;
										};

										if (_enemyDistance < 500) then
										{
											_w = _w + 4;
										};

										if (_posture == "TRANSITION") then
										{
											_w = _w + 4;
										};
									};
								};
							};

							switch (_enemyTactic) do
							{
								case "AMBUSH":
								{
									if (_tactic == "RECONNAISSANCE_BY_FIRE") then
									{
										_counterBonus = 8;
									};

									if (_tactic == "ALL_ROUND_DEFENSE") then
									{
										_counterBonus = 4;
									};
								};

								case "BOUNDING_OVERWATCH":
								{
									if (_tactic == "FLANKING") then
									{
										_counterBonus = 6;
									};

									if (_tactic == "FIRE_AND_MANEUVER") then
									{
										_counterBonus = 6;
									};
								};

								case "PAIRS":
								{
									if (_tactic == "RECONNAISSANCE_BY_FIRE") then
									{
										_counterBonus = 5;
									};

									if (_tactic == "FLANKING") then
									{
										_counterBonus = 4;
									};
								};

								case "TRIPLET":
								{
									if (_tactic == "FIRE_AND_MANEUVER") then
									{
										_counterBonus = 5;
									};

									if (_tactic == "CENTRAL_PEEL") then
									{
										_counterBonus = 5;
									};
								};

								case "FIRE_AND_MANEUVER":
								{
									if (_tactic == "ALL_ROUND_DEFENSE") then
									{
										_counterBonus = 7;
									};

									if (_tactic == "FLANKING") then
									{
										_counterBonus = 4;
									};
								};

								case "FLANKING":
								{
									if (_tactic == "ALL_ROUND_DEFENSE") then
									{
										_counterBonus = 8;
									};

									if (_tactic == "CENTRAL_PEEL") then
									{
										_counterBonus = 6;
									};
								};

								case "ENCIRCLEMENT":
								{
									if (_tactic == "ALL_ROUND_DEFENSE") then
									{
										_counterBonus = 9;
									};

									if (_tactic == "CENTRAL_PEEL") then
									{
										_counterBonus = 7;
									};

									if (_tactic == "FIRE_AND_MANEUVER") then
									{
										_counterBonus = 4;
									};
								};

								case "RECONNAISSANCE_BY_FIRE":
								{
									if (_tactic == "BOUNDING_OVERWATCH") then
									{
										_counterBonus = 6;
									};

									if (_tactic == "FLANKING") then
									{
										_counterBonus = 4;
									};

									if (_tactic == "AMBUSH") then
									{
										_counterBonus = 3;
									};
								};

								case "CENTRAL_PEEL":
								{
									if (_tactic == "FLANKING") then
									{
										_counterBonus = 6;
									};

									if (_tactic == "ENCIRCLEMENT") then
									{
										_counterBonus = 5;
									};
								};

								case "ALL_ROUND_DEFENSE":
								{
									if (_tactic == "RECONNAISSANCE_BY_FIRE") then
									{
										_counterBonus = 6;
									};

									if (_tactic == "FLANKING") then
									{
										_counterBonus = 4;
									};

									if (_tactic == "BOUNDING_OVERWATCH") then
									{
										_counterBonus = 4;
									};
								};
							};

							_w = _w + _counterBonus;

							if (_tactic == _lastTactic) then
							{
								_w = _w * 0.2;
							};

							if (_tactic == _enemyTactic) then
							{
								_w = _w * 0.15;
							};

							if (_w > 0) then
							{
								_w = _w * (0.75 + random 0.5);
							};

							(_choices select _i) set [1, (_w max 0)];
						};

						private _selectedTactic = [_choices] call _PROTOCOL_SELECT_WEIGHTED;

						if (_selectedTactic isEqualTo "") then
						{
							_selectedTactic =
								switch (true) do
								{
									case _outnumbered: {"CENTRAL_PEEL"};
									case _dominant: {"FLANKING"};
									//case {_posture == "DEFEND"}: {"ALL_ROUND_DEFENSE"};
									default {"BOUNDING_OVERWATCH"};
								};
						};

						private _switchDuration =
							switch (true) do
							{
								case _outnumbered: {45 + random 25};
								case _dominant: {40 + random 25};
								//case {_posture == "DEFEND"}: {55 + random 30};
								default {35 + random 25};
							};

						_grp setVariable ["PROTOCOL_TACTIC", _selectedTactic];
						_grp setVariable ["PROTOCOL_TACTIC_POSTURE", _posture];
						_grp setVariable ["PROTOCOL_TACTIC_NEXT_SWITCH", time + _switchDuration];

						private _groupName = groupId _grp;

						if (_groupName isEqualTo "") then
						{
							_groupName = format ["%1", _grp];
						};
                        if(PROTOCOL_AI_DEBUG) then {
						systemChat format ["%1 | %2", _groupName, _selectedTactic];
						};

						[_grp, _selectedTactic] call _PROTOCOL_APPLY_TACTIC;
					}
					else
					{
						private _currentTactic = _grp getVariable ["PROTOCOL_TACTIC", ""];

						if (_currentTactic != "") then
						{
							[_grp, _currentTactic] call _PROTOCOL_APPLY_TACTIC;
						};
					};
				};
			};
		};

};
    
    _PROTOCOL_BOUNDING_OVERWATCH = {
    params ["_grp"];

    private _leader = leader _grp;
    private _enemy = _leader findNearestEnemy _leader;

    if (
        !isNull _enemy &&
        {(_leader distance _enemy) < 600}
    ) then {
        _grp setBehaviour "COMBAT";

        private _units = (units _grp) select {alive _x};
        private _mid = floor (count _units / 2);
        private _alpha = _units select [0, _mid];
        private _bravo = _units select [_mid];
        private _enemyPos = getPosATL _enemy;
        private _isAlphaMoving = _grp getVariable ["TAG_boundStep", true];
        private _movingPart = if (_isAlphaMoving) then { _alpha } else { _bravo };
        private _firingPart = if (_isAlphaMoving) then { _bravo } else { _alpha };

        {
            if (unitReady _x) then {
                private _dirToEnemy = [_x, _enemyPos] call BIS_fnc_dirTo;
                private _movePos = [
                    _enemyPos,
                    40 + random 20,
                    _dirToEnemy + (random 40 - 20)
                ] call BIS_fnc_relPos;

                _x doMove _movePos;
                _x setUnitPos "AUTO";
                _x setSpeedMode "FULL";
                _x setCombatMode "RED";
            };
        } forEach _movingPart;

        {
            _x setUnitPos "AUTO";

            if (currentCommand _x != "Suppress") then {
                _x doSuppressiveFire _enemyPos;
            };

            if (random 1 > 0.7) then {
            };
        } forEach _firingPart;

        private _lastSwitch = _grp getVariable ["TAG_lastSwitch", 0];

        if (
            time - _lastSwitch > 12 ||
            {(_movingPart findIf {unitReady _x}) != -1}
        ) then {
            _grp setVariable ["TAG_boundStep", !_isAlphaMoving];
            _grp setVariable ["TAG_lastSwitch", time];
        };
    } else {
        if (behaviour _leader == "COMBAT") then {
            _grp setBehaviour "AWARE";
            _grp setSpeedMode "LIMITED";

            {
                _x setUnitPos "AUTO";
            } forEach (units _grp);
        };
    };
};

_PROTOCOL_PAIRS = {
    params ["_grp"];

    private _units = (units _grp) select {alive _x};

    if (count _units >= 2) then {
        _grp setBehaviour "COMBAT";

        private _leader = leader _grp;
        private _enemy = _leader findNearestEnemy _leader;

        if (!isNull _enemy) then {
            private _enemyPos = getPosATL _enemy;

            for "_i" from 0 to (count _units - 1) step 2 do {
                private _unitA = _units select _i;
                private _unitB =
                    if ((_i + 1) < count _units) then {
                        _units select (_i + 1)
                    } else {
                        objNull
                    };

                if (!isNull _unitB) then {
                    private _isATurn = _unitA getVariable ["_leapFrog", true];

                    if (_isATurn) then {
                        private _dirToEnemy = _unitA getDir _enemy;
                        private _zigzagPos = _unitA getPos [
                            15 + random 10,
                            _dirToEnemy + (selectRandom [-35, 35])
                        ];

                        _unitA doMove _zigzagPos;
                        _unitA setUnitPos "UP";
                        _unitA setSpeedMode "FULL";

                        _unitB doSuppressiveFire _enemyPos;
                        _unitB setUnitPos "MIDDLE";
                    } else {
                        private _dirToEnemy = _unitB getDir _enemy;
                        private _zigzagPos = _unitB getPos [
                            15 + random 10,
                            _dirToEnemy + (selectRandom [-35, 35])
                        ];

                        _unitB doMove _zigzagPos;
                        _unitB setUnitPos "UP";
                        _unitB setSpeedMode "FULL";

                        _unitA doSuppressiveFire _enemyPos;
                        _unitA setUnitPos "MIDDLE";
                    };

                    _unitA setVariable ["_leapFrog", !_isATurn];
                };
            };
        };
    };
};

_PROTOCOL_TRIPLET = {
    params ["_grp"];

    private _units = (units _grp) select {alive _x};

    if (count _units >= 3) then {
        for "_i" from 0 to (count _units - 3) step 3 do {
            private _trio = _units select [_i, 3];

            if (count _trio == 3) then {
                private _leader = _trio select 0;
                private _enemy = _leader findNearestEnemy _leader;

                if (!isNull _enemy) then {
                    private _enemyPos = getPosATL _enemy;
                    private _trioID = format ["trio_cycle_%1_%2", _grp, _i];
                    private _cycle = _grp getVariable [_trioID, 0];

                    _grp setBehaviour "COMBAT";

                    if (_cycle == 0) then {
                        private _cover = _trio select 0;
                        private _movers = [_trio select 1, _trio select 2];

                        _cover setUnitPos "MIDDLE";
                        _cover doSuppressiveFire _enemyPos;

                        {
                            private _dir = _x getDir _enemy;
                            private _side = if (_forEachIndex == 0) then {35} else {-35};
                            private _dest = [_x, 12, _dir + _side] call BIS_fnc_relPos;

                            _x doMove _dest;
                            _x setSpeedMode "FULL";
                            _x setUnitPos "UP";
                        } forEach _movers;

                        _grp setVariable [_trioID, 1];
                    } else {
                        private _cover1 = _trio select 1;
                        private _cover2 = _trio select 2;
                        private _mover = _trio select 0;

                        {
                            _x setUnitPos "DOWN";
                            _x doSuppressiveFire _enemyPos;
                        } forEach [_cover1, _cover2];

                        private _dir = _mover getDir _enemy;
                        private _dest = [_mover, 15, _dir] call BIS_fnc_relPos;

                        _mover doMove _dest;
                        _mover setSpeedMode "FULL";
                        _mover setUnitPos "UP";

                        _grp setVariable [_trioID, 0];
                    };
                };
            };
        };
    };

    if (count _units > 3) then {
        for "_j" from 0 to (count _units - 1) step 3 do {
            private _trio = _units select [_j, 3];

            if (count _trio == 3) then {
                private _center = getPosATL (_trio select 0);

                {
                    private _otherTrio = _units select [_x, 1];

                    if (count _otherTrio > 0) then {
                        private _dist = _center distance (getPosATL (_otherTrio select 0));

                        if (_dist < 15) then {
                            private _awayDir = (_otherTrio select 0) getDir (_trio select 0);
                            private _escapePos = [getPosATL (_trio select 0), 10, _awayDir] call BIS_fnc_relPos;

                            (_trio select 0) doMove _escapePos;
                        };
                    };
                } forEach [(_j + 3), (_j - 3)];
            };
        };
    };
};

_PROTOCOL_FIRE_AND_MANEUVER =
{
	params ["_grp"];

	if (isNull _grp) exitWith {};

	private _aliveUnits = (units _grp) select {alive _x};

	if (count _aliveUnits < 2) exitWith {};

	private _leader = leader _grp;
	private _enemy = _leader findNearestEnemy _leader;

	if (isNull _enemy || {!alive _enemy}) exitWith {};

	_grp setBehaviour "COMBAT";
	_grp setCombatMode "RED";
	_grp enableAttack true;

	private _enemyPos = getPosATL _enemy;
	private _half = floor (count _aliveUnits / 2);

	private _baseTeam = _aliveUnits select [0, _half];
	private _maneuverTeam = _aliveUnits select [_half];

	if (count _baseTeam == 0 || {count _maneuverTeam == 0}) exitWith {};

	{
		_x setUnitPos "MIDDLE";
		_x setSpeedMode "NORMAL";
		_x doSuppressiveFire _enemyPos;
		_x setVariable ["PROTOCOL_SUPPRESSING", true];
	} forEach _baseTeam;

	private _dirToEnemy = [_leader, _enemy] call BIS_fnc_dirTo;

	{
		private _flankSide = if (_forEachIndex mod 2 == 0) then {75} else {-75};
		private _flankPos =
		[
			_enemyPos,
			50 + random 35,
			_dirToEnemy + _flankSide + (random 20 - 10)
		] call BIS_fnc_relPos;

		_x doMove _flankPos;
		_x setSpeedMode "FULL";
		_x setUnitPos "UP";
		_x setVariable ["PROTOCOL_SUPPRESSING", false];
	} forEach _maneuverTeam;
};

_PROTOCOL_FLANKING = {
    params ["_grp"];

    private _units = units _grp select {alive _x};

    if (count _units > 1 && !isPlayer (leader _grp)) then {
        private _leader = leader _grp;
        private _enemy = _leader findNearestEnemy _leader;

        if (!isNull _enemy) then {
            private _enemyPos = getPosATL _enemy;
            private _leaderPos = getPosATL _leader;
            private _dist = _leaderPos distance _enemyPos;

            private _mid = floor (count _units / 2);
            private _fireTeam = _units select [0, _mid];
            private _flankTeam = _units select [_mid];

            _grp setBehaviour "COMBAT";
            _grp setCombatMode "RED";

            {
                _x setUnitPos "MIDDLE";
                _x doSuppressiveFire _enemyPos;
            } forEach _fireTeam;

            private _dirToEnemy = _leaderPos getDir _enemyPos;
            private _modifier = if (groupOwner _grp % 2 == 0) then {90} else {-90};
            private _flankPos = [
                _enemyPos,
                _dist * 0.8,
                _dirToEnemy + _modifier
            ] call BIS_fnc_relPos;

            {
                _x setSpeedMode "FULL";
                _x setUnitPos "MIDDLE";
                _x doMove _flankPos;

                if (_x distance _flankPos < 10) then {
                    _x doSuppressiveFire _enemyPos;
                    _x setUnitPos "AUTO";
                };
            } forEach _flankTeam;
        } else {
            _grp setBehaviour "AWARE";
            _grp setSpeedMode "LIMITED";

            {
                _x setUnitPos "AUTO";
            } forEach _units;
        };
    };
};

_PROTOCOL_ENCIRCLEMENT = {
    params ["_grp"];

    if (isNull _grp) exitWith {};

    private _units = units _grp;
    if (count _units <= 0) exitWith {};

    private _leader = leader _grp;
    private _enemy = _leader findNearestEnemy _leader;

    if (!isNull _enemy) then {
        _grp setBehaviour "COMBAT";
        _grp setCombatMode "RED";
        _grp enableAttack true;

        private _enemyPos = getPosATL _enemy;
        private _unitCount = count _units;
        private _angleStep = 360 / _unitCount;
        private _currentDist = _leader distance2D _enemyPos;
        private _radius = (_currentDist * 0.75) max 35;
        private _baseDir = _enemyPos getDir _leader;

        {
            if (alive _x) then {
                private _targetAngle = _baseDir + (_forEachIndex * _angleStep);
                private _randRadius = _radius + (random 20 - 10);
                private _randAngle = _targetAngle + (random 16 - 8);

                private _targetPos = _enemyPos getPos [_randRadius, _randAngle];
                _targetPos set [2, 0];

                if (_x distance2D _targetPos > 12) then {
                    _x doMove _targetPos;
                    _x setSpeedMode (selectRandom ["NORMAL", "FULL"]);
                    _x setUnitPos (selectRandom ["UP", "MIDDLE"]);

                    if (random 1 > 0.7) then {
                        _x doSuppressiveFire _enemy;
                      //  _x playActionNow (selectRandom ["GestureGo", "GestureAdvance"]);
                    };
                } else {
                    _x setUnitPos (selectRandom ["DOWN", "MIDDLE"]);
                    _x doSuppressiveFire _enemyPos;
                };

                if (damage _x > 0.25) then {
                    _x setUnitPos "DOWN";
                    _x setSpeedMode "FULL";
                    //_x playActionNow "GestureCover";
                };
            };
        } forEach _units;
    } else {
        _grp setBehaviour "AWARE";
        _grp setSpeedMode "LIMITED";

        {
            _x setUnitPos "AUTO";
        } forEach _units;
    };
};

_PROTOCOL_RECONNAISSANCE_BY_FIRE = {
    params ["_grp"];

    private _units = units _grp;

    if (count _units > 0) then {
        private _leader = leader _grp;
        private _enemy = _leader findNearestEnemy _leader;

        if (!isNull _enemy) then {
            _grp setBehaviour "COMBAT";
            _grp setCombatMode "RED";
            _grp enableAttack true;

            private _enemyPos = getPosATL _enemy;
            private _unitCount = count _units;
            private _angleStep = 360 / _unitCount;

            private _currentDist = _leader distance2D _enemyPos;
            private _radius = (_currentDist * 0.75) max 35;

            private _baseDir = _enemyPos getDir _leader;

            {
                if (alive _x) then {
                    private _targetAngle = _baseDir + (_forEachIndex * _angleStep);
                    private _randRadius = _radius + (random 20 - 10);
                    private _randAngle = _targetAngle + (random 16 - 8);
                    private _targetPos = _enemyPos getPos [_randRadius, _randAngle];

                    _targetPos set [2, 0];

                    if (_x distance2D _targetPos > 12) then {
                        _x doMove _targetPos;
                        _x setSpeedMode (selectRandom ["NORMAL", "FULL"]);
                        _x setUnitPos (selectRandom ["UP", "MIDDLE"]);

                        if (random 1 > 0.7) then {
                            _x doSuppressiveFire _enemy;
                           // _x playActionNow (selectRandom ["GestureGo", "GestureAdvance"]);
                        };
                    } else {
                        _x setUnitPos (selectRandom ["DOWN", "MIDDLE"]);
                        _x doSuppressiveFire _enemyPos;
                    };

                    if (damage _x > 0.25) then {
                        _x setUnitPos "DOWN";
                        _x setSpeedMode "FULL";
                      //  _x playActionNow "GestureCover";
                    };
                };
            } forEach _units;
        } else {
            _grp setBehaviour "AWARE";
            _grp setSpeedMode "LIMITED";

            {
                _x setUnitPos "AUTO";
            } forEach _units;
        };
    };
};


_PROTOCOL_CENTRAL_PEEL = {
    params ["_grp"];

    if (local _grp && {count units _grp > 1}) then {
        private _leader = leader _grp;
        private _enemy = _leader findNearestEnemy _leader;

        if (!isNull _enemy) then {
            private _units = units _grp;
            private _enemyPos = getPosATL _enemy;

            private _peeler = _units select 0;
            private _anchor = _units select 0;

            {
                if ((_x distance _enemyPos) < (_peeler distance _enemyPos)) then {
                    _peeler = _x;
                };

                if ((_x distance _enemyPos) > (_anchor distance _enemyPos)) then {
                    _anchor = _x;
                };
            } forEach _units;

            private _supporters = _units - [_peeler];

            _grp setBehaviour "COMBAT";
            _grp setCombatMode "RED";

            {
                _x setUnitPos (selectRandom ["MIDDLE", "DOWN"]);
                _x doSuppressiveFire _enemyPos;
                _x suppressFor 6;
            } forEach _supporters;

            private _dirFromEnemy = [_enemyPos, getPosATL _anchor] call BIS_fnc_dirTo;
            private _retreatPos = [
                getPosATL _anchor,
                20,
                _dirFromEnemy + (random 20 - 10)
            ] call BIS_fnc_relPos;

            _peeler setUnitPos "UP";
            _peeler setSpeedMode "FULL";
            _peeler stop false;
            _peeler doMove _retreatPos;

            if (damage _peeler > 0.2) then {
                _peeler setUnitPos "DOWN";
            };

            {
                if (unitReady _x) then {
                    _x doSuppressiveFire _enemyPos;
                };
            } forEach _units;
        } else {
            if (behaviour _leader == "COMBAT") then {
                _grp setBehaviour "AWARE";
                _grp setSpeedMode "LIMITED";

                {
                    _x setUnitPos "AUTO";
                } forEach units _grp;
            };
        };
    };
};

_PROTOCOL_ALL_ROUND_DEFENSE = {
    params ["_grp"];

    if (
        !isNull _grp &&
        {count units _grp > 1} &&
        {alive leader _grp}
    ) then {
        {
            if (
                alive _x &&
                {vehicle _x == _x} &&
                {_x != leader group _x}
            ) then {
                _x doMove [
                    (getPosATL leader group _x select 0) +
                    (sin ((_forEachIndex / ((count units group _x) - 1)) * 360) * 15),

                    (getPosATL leader group _x select 1) +
                    (cos ((_forEachIndex / ((count units group _x) - 1)) * 360) * 15),

                    0
                ];

                _x doWatch [
                    (getPosATL leader group _x select 0) +
                    (sin ((_forEachIndex / ((count units group _x) - 1)) * 360) * 100),

                    (getPosATL leader group _x select 1) +
                    (cos ((_forEachIndex / ((count units group _x) - 1)) * 360) * 100),

                    0
                ];
            };
        } forEach units _grp;
    };
};





_PROTOCOL_AMBUSH = {
    params ["_grp"];

    if (
        count units _grp > 2 &&
        alive leader _grp &&
        !isPlayer leader _grp &&
        leader _grp isKindOf "Man" &&
        !isNull (leader _grp findNearestEnemy position leader _grp) &&
        leader _grp distance (leader _grp findNearestEnemy position leader _grp) < 700
    ) then {
        _grp setFormation "LINE";
        _grp setSpeedMode "LIMITED";
        _grp setFormDir (leader _grp getDir (leader _grp findNearestEnemy position leader _grp));

        if (leader _grp distance (leader _grp findNearestEnemy position leader _grp) > 350) then {
            _grp move (((selectBestPlaces [
                position leader _grp,
                180,
                "forest + 2*trees - houses - meadow",
                10,
                1
            ]) select 0) select 0);
        };

        if (leader _grp distance (leader _grp findNearestEnemy position leader _grp) < 300) then {
            {
                if (alive _x && !isPlayer _x) then {
                    _x reveal [_x findNearestEnemy position _x, 4];
                    _x doWatch (_x findNearestEnemy position _x);

                    if (_x distance (_x findNearestEnemy position _x) < 280) then {
                        _x doFire (_x findNearestEnemy position _x);
                    };
                };
            } forEach units _grp;
        };

        if (leader _grp distance (leader _grp findNearestEnemy position leader _grp) < 150) then {
            _grp move (
                position leader _grp getPos [
                    140,
                    (leader _grp findNearestEnemy position leader _grp) getDir leader _grp
                ]
            );
        };
    };
};
 _PROTOCOL_WOODLAND = {
		params ["_grp"];

		if (isNull _grp) exitWith {};

		_grp setBehaviour "AWARE";
		_grp setCombatMode "RED";
		_grp setSpeedMode "LIMITED";
		_grp setFormation "WEDGE";

		private _units = units _grp;
		private _leader = leader _grp;

		if ((count _units) > 1) then {
			private _half = floor (count _units / 2);
			private _team1 = _units select [0, _half];
			private _team2 = _units select [_half];

			private _pos = getPosATL _leader;
			private _dir = random 360;

			private _offset1 = [_pos, 10 + random 10, _dir] call BIS_fnc_relPos;
			private _offset2 = [_pos, 10 + random 10, _dir + 180] call BIS_fnc_relPos;

			{
				_x doMove _offset1;
				_x setUnitPos "MIDDLE";
				_x suppressFor 2 + random 3;
			} forEach _team1;

			{
				_x doMove _offset2;
				_x setUnitPos "DOWN";
				_x suppressFor 2 + random 3;
			} forEach _team2;

			{
				private _enemy = _x findNearestEnemy _x;
				if (!isNull _enemy) then {
					_x doSuppressiveFire _enemy;
				};
			} forEach _units;
		} else {
			private _u = _units select 0;
			private _enemy = _u findNearestEnemy _u;
			if (!isNull _enemy) then {
				_u doSuppressiveFire _enemy;
			};
		};
	};

_PROTOCOL_GET_POSTURE =
{
	params ["_grp"];

	private _wps = waypoints _grp;

	if (count _wps == 0) exitWith {"DEFEND"};

	private _wp = currentWaypoint _grp;

	if (_wp >= count _wps) exitWith {"DEFEND"};

	private _type = waypointType [_grp, _wp];

	switch (_type) do
	{
		case "HOLD": {"DEFEND"};
		case "SENTRY": {"DEFEND"};
		case "GUARD": {"DEFEND"};
		case "DEFEND": {"DEFEND"};
		case "DISMISS": {"DEFEND"};

		case "MOVE": {"ATTACK"};
		case "SAD": {"ATTACK"};
		case "DESTROY": {"ATTACK"};
		case "JOIN": {"ATTACK"};
		case "JOIN AND LEAD": {"ATTACK"};
		case "CYCLE": {"ATTACK"};

		case "GETIN": {"TRANSITION"};
		case "GETOUT": {"TRANSITION"};
		case "LOAD": {"TRANSITION"};
		case "UNLOAD": {"TRANSITION"};
		case "TR UNLOAD": {"TRANSITION"};
		case "SCRIPTED": {"TRANSITION"};
		case "SUPPORT": {"TRANSITION"};
		case "FOLLOW": {"TRANSITION"};

		default {"ATTACK"};
	};
};

_PROTOCOL_SELECT_WEIGHTED =
{
	params ["_choices"];

	private _total = 0;

	{
		_total = _total + (_x select 1);
	} forEach _choices;

	if (_total <= 0) exitWith {""};

	private _roll = random _total;
	private _acc = 0;
	private _result = "";

	{
		_acc = _acc + (_x select 1);

		if (_result isEqualTo "" && {_roll <= _acc}) then
		{
			_result = _x select 0;
		};
	} forEach _choices;

	_result
};

_PROTOCOL_APPLY_TACTIC =
{
	params ["_grp", "_tactic"];

	switch (_tactic) do
	{
		case "BOUNDING_OVERWATCH":
		{
			[_grp] call _PROTOCOL_BOUNDING_OVERWATCH;
		};

		case "PAIRS":
		{
			[_grp] call _PROTOCOL_PAIRS;
		};

		case "TRIPLET":
		{
			[_grp] call _PROTOCOL_TRIPLET;
		};

		case "FIRE_AND_MANEUVER":
		{
			[_grp] call _PROTOCOL_FIRE_AND_MANEUVER;
		};

		case "FLANKING":
		{
			[_grp] call _PROTOCOL_FLANKING;
		};

		case "ENCIRCLEMENT":
		{
			[_grp] call _PROTOCOL_ENCIRCLEMENT;
		};

		case "RECONNAISSANCE_BY_FIRE":
		{
			[_grp] call _PROTOCOL_RECONNAISSANCE_BY_FIRE;
		};

		case "CENTRAL_PEEL":
		{
			[_grp] call _PROTOCOL_CENTRAL_PEEL;
		};

		case "ALL_ROUND_DEFENSE":
		{
			[_grp] call _PROTOCOL_ALL_ROUND_DEFENSE;
		};

		case "AMBUSH":
		{
			[_grp] call _PROTOCOL_AMBUSH;
		};
	};
};
_PROTOCOL_FIRE_AND_SUPRESS = {
	params ["_grp"];
	  if (!isNull _grp && {alive leader _grp}) then {

		{
		  private _unit = _x;

		  if (
			alive _unit &&
			{vehicle _unit == _unit}
		  ) then {

			private _enemy = _unit findNearestEnemy _unit;

			if (
			  !isNull _enemy &&
			  {_unit knowsAbout _enemy > 1.5}
			) then {

			  private _dist = _unit distance _enemy;

			  _unit setCombatMode "RED";
			  _unit setBehaviourStrong "COMBAT";
			  _unit allowFleeing 0;

			  
			  if (_dist < 120) then {

			   // _unit setUnitPos "UP";

				if (random 1 < 0.35) then {
				  _unit suppressFor 7;
				};

			  } else {

				//_unit setUnitPos "MIDDLE";

			  };

			  

			  if (time > (_unit getVariable ["lastCoverMove",0])) then {

				private _covers =
				  nearestTerrainObjects
				  [
					_unit,
					[
					  "TREE",
					  "SMALL TREE",
					  "BUSH",
					  "ROCK",
					  "ROCKS",
					  "WALL",
					  "FENCE"
					],
					25,
					false,
					true
				  ];

				private _best = objNull;
				private _bestScore = 1e10;

				{
				  private _score = _x distance _enemy;

				  if (_score < _bestScore) then {

					_bestScore = _score;
					_best = _x;

				  };

				} forEach _covers;

				if (!isNull _best) then {

				  private _pos =
					_best getPos
					[2 + random 2,
					 _enemy getDir _best];

				  //_unit doMove _pos;

				} else {

				  private _pos =
					_unit getPos
					[8 + random 8,
					 random 360];

  //			_unit doMove _pos;

				};

				_unit setVariable
				[
				  "lastCoverMove",
				  time + 6 + random 4
				];

			  };


			  if (random 1 < 0.6) then {

				_unit doTarget _enemy;
				_unit doSuppressiveFire position _enemy;

			  };

			};

		  };

		} forEach units _grp;
	  };
	};
	_PROTOCOL_BLIND_FIRE = {
	params ["_grp"];
	{
	 private _unit = _x;
				if (
					alive _unit &&
					{vehicle _unit == _unit} &&
					{!(_unit getVariable ["BlindFire", false])}
				) then {

					[_unit] spawn {

						params ["_unit"];

						_unit setVariable ["BlindFire", true];

						while {alive _unit} do {

							private _enemy = _unit findNearestEnemy _unit;

							if (
								!isNull _enemy &&
								{_unit knowsAbout _enemy > 1.5} &&
								{_unit distance _enemy < 250}
							) then {

								private _cover = nearestObject [
									_unit,
									"House"
								];

								if (!isNull _cover) then {

									private _dir = _cover getDir _enemy;

									private _corner =
										_cover getPos [2.2, _dir + 90];

									//_unit doMove _corner;

									waitUntil {
										sleep 0.2;
										!alive _unit ||
										{_unit distance _corner < 1.2}
									};

									if (alive _unit) then {

										//_unit setUnitPos "MIDDLE";

										sleep (1 + random 1);

										private _target =
											eyePos _enemy;

										for "_i" from 1 to (2 + floor random 3) do {

											_unit doWatch _enemy;

											_unit reveal _enemy;

											_unit forceWeaponFire [
												currentWeapon _unit,
												currentMuzzle _unit
											];

											sleep (0.25 + random 0.2);

										};

										sleep (2 + random 2);

										//_unit doMove position _cover;
									};
								};
							};

							sleep 1;
						};

						_unit setVariable ["BlindFire", false];

					};

				};

			} forEach units _grp;
	};


    while {true} do {

        {
            private _grp = _x;

            if (!isNull _grp && {count units _grp > 0}) then {

                private _leader = leader _grp;
                private _pos = getPosATL _leader;

                private _nearestBuilding = nearestObject [_pos, "Building"];
                private _distanceToBuilding = _leader distance _nearestBuilding;

                _grp setVariable ["Location", "Open"];
                private _LocationGrp = _grp getVariable ["Location", "None"];
                //[_grp] call _PROTOCOL_DISTANCE;
                private _hasTech = false;

                {
                    private _vehicle = vehicle _x;

                    if (
                        _vehicle != _x &&
                        {
                            _vehicle isKindOf "LandVehicle" ||
                            _vehicle isKindOf "Air" ||
                            _vehicle isKindOf "Ship"
                        }
                    ) exitWith {
                        _hasTech = true;
                    };

                } forEach units _grp;

                if (!_hasTech) then {
					   if(_LocationGrp != "Building") then {
					  if(PROTOCOL_AI_SUPRESS) then {	
				     [_grp] call _PROTOCOL_FIRE_AND_SUPRESS;
					  };
					  if(PROTOCOL_AI_BLINDFIRE) then {
				     [_grp] call _PROTOCOL_BLIND_FIRE;
					  };
				     };

					if(PROTOCOL_AI_TACTICS == 0) then {
						//[_grp] call _PROTOCOL_ENVIROMENT_TACTICS;
						[_grp] call _PROTOCOL_DOCTRINE_TACTICS;
					};	
                    if(PROTOCOL_AI_TACTICS == 1) then {[_grp] call _PROTOCOL_DOCTRINE_TACTICS;};
					if(PROTOCOL_AI_TACTICS == 2) then {[_grp] call _PROTOCOL_ENVIROMENT_TACTICS;};
					if(PROTOCOL_AI_TACTICS == 3) then {
					   if (_distanceToBuilding < 60) then {
			          [_grp] call _PROTOCOL_CITY_TACTICS;
			          };
					 };
					if(PROTOCOL_AI_TACTICS == 4) then {
						private _trees = nearestTerrainObjects [_pos, ["TREE","SMALL TREE","BUSH"], 30];
				    if (count _trees > 15) then {
					_grp setVariable ["Location", "Forest"];
					if( _LocationGrp == "Forest") then {
						if(PROTOCOL_AI_DEBUG) then {
                        systemChat format [ "%1 | Woodland tactic ", _grp];
						};
					[_grp] call _PROTOCOL_WOODLAND;
			       };
		};
					};
					if(PROTOCOL_AI_TACTICS == 5) then {
						if (_distanceToBuilding < PROTOCOL_AI_CQB_RADIUS) then {
			             [_grp] call _PROTOCOL_CQB; 
		                 };
					};
					if(PROTOCOL_AI_TACTICS == 6) then { [_grp] call  _PROTOCOL_BOUNDING_OVERWATCH; };
					if(PROTOCOL_AI_TACTICS == 7) then {[_grp] call  _PROTOCOL_PAIRS;}; 
					if(PROTOCOL_AI_TACTICS == 8) then {[_grp] call _PROTOCOL_TRIPLET;};
					if(PROTOCOL_AI_TACTICS == 9) then {[_grp] call  _PROTOCOL_FIRE_AND_MANEUVER;};
					if(PROTOCOL_AI_TACTICS == 10) then {[_grp] call  _PROTOCOL_FLANKING;};
					if(PROTOCOL_AI_TACTICS == 11) then {[_grp] call  _PROTOCOL_ENCIRCLEMENT;};
					if(PROTOCOL_AI_TACTICS == 12) then {[_grp] call  _PROTOCOL_RECONNAISSANCE_BY_FIRE;};
					if(PROTOCOL_AI_TACTICS == 13) then {[_grp] call  _PROTOCOL_CENTRAL_PEEL;};
                    if(PROTOCOL_AI_TACTICS == 14) then {[_grp] call  _PROTOCOL_ALL_ROUND_DEFENSE;};
					if(PROTOCOL_AI_TACTICS == 15) then {[_grp] call  _PROTOCOL_AMBUSH;};	
               
                };
            };

        } forEach allGroups;

        sleep 5;
    };
};


[] spawn
{
	if (isNil "PROTOCOL_AI_ENABLED") then {PROTOCOL_AI_ENABLED = true}; 
	if (isNil "PROTOCOL_AI_DYNAMIC_COVER_USAGE") then {PROTOCOL_AI_DYNAMIC_COVER_USAGE = true}; 
	
    private _isEnemy =
    {
        params ["_unit", "_target"];

        !isNull _target &&
        {alive _target} &&
        {_target != _unit} &&
        {((side _unit) getFriend (side _target)) < 0.6}
    };

    private _hasCover =
    {
        params ["_unit", ["_threat", objNull]];

        if (isNull _unit || {!alive _unit}) exitWith {false};

        private _targetASL = eyePos _unit;

        if (!isNull _threat && {alive _threat}) then
        {
            private _sourceASL = if (_threat isKindOf "CAManBase") then
            {
                eyePos _threat
            }
            else
            {
                (getPosASL _threat) vectorAdd [0, 0, 1.5]
            };

            private _hits = lineIntersectsSurfaces
            [
                _sourceASL,
                _targetASL,
                _threat,
                _unit,
                true,
                6,
                "FIRE",
                "FIRE"
            ];

            private _blocked = _hits findIf
            {
                private _hit = _x;
                private _hitPos = _hit select 0;
                private _coverObject = _hit select 2;

                if (isNull _coverObject) then
                {
                    _coverObject = _hit select 3;
                };

                !isNull _coverObject &&
                {!(_coverObject isKindOf "CAManBase")} &&
                {(_hitPos distance _targetASL) > 0.7} &&
                {(_hitPos distance _targetASL) < 8}
            };

            _blocked >= 0
        }
        else
        {
            private _origin = getPosATL _unit;
            private _covered = false;

            {
                if (!_covered) then
                {
                    private _angle = _x;

                    private _startATL =
                    [
                        (_origin select 0) + (sin _angle) * 40,
                        (_origin select 1) + (cos _angle) * 40,
                        1.6
                    ];

                    private _hits = lineIntersectsSurfaces
                    [
                        ATLToASL _startATL,
                        _targetASL,
                        objNull,
                        _unit,
                        true,
                        5,
                        "FIRE",
                        "FIRE"
                    ];

                    private _blocked = _hits findIf
                    {
                        private _hit = _x;
                        private _hitPos = _hit select 0;
                        private _coverObject = _hit select 2;

                        if (isNull _coverObject) then
                        {
                            _coverObject = _hit select 3;
                        };

                        !isNull _coverObject &&
                        {!(_coverObject isKindOf "CAManBase")} &&
                        {(_hitPos distance _targetASL) > 0.7} &&
                        {(_hitPos distance _targetASL) < 8}
                    };

                    if (_blocked >= 0) then
                    {
                        _covered = true;
                    };
                };
            } forEach [0, 60, 120, 180, 240, 300];

            _covered
        }
    };

    private _findRandomCover =
    {
        params
        [
            "_unit",
            ["_threat", objNull],
            ["_doctrine", "BOUNDING_OVERWATCH"]
        ];

        if (isNull _unit || {!alive _unit}) exitWith {[]};

        private _origin = getPosATL _unit;
        private _bestPos = [];
        private _bestScore = 1e10;

        private _threatValid =
            !isNull _threat &&
            {alive _threat} &&
            {[_unit, _threat] call _isEnemy};

        private _currentThreatDistance = -1;
        private _towardThreat = 0;
        private _threatASL = [];

        if (_threatValid) then
        {
            _currentThreatDistance = _unit distance2D _threat;
            _towardThreat = _origin getDir _threat;

            if (_threat isKindOf "CAManBase") then
            {
                _threatASL = eyePos _threat;
            }
            else
            {
                _threatASL = (getPosASL _threat) vectorAdd [0, 0, 1.5];
            };
        };

        for "_i" from 1 to 72 do
        {
            private _angle = random 360;
            private _distance = 4 + random 16;

            private _pos =
            [
                (_origin select 0) + (sin _angle) * _distance,
                (_origin select 1) + (cos _angle) * _distance,
                0
            ];

            if (
                !(surfaceIsWater _pos) &&
                {(_unit distance2D _pos) > 3}
            ) then
            {
                private _occupied =
                (
                    nearestObjects
                    [
                        _pos,
                        ["CAManBase"],
                        2
                    ]
                ) findIf
                {
                    alive _x &&
                    {_x != _unit} &&
                    {(_x distance2D _pos) < 1.7}
                };

                if (_occupied < 0) then
                {
                    private _validCandidate = true;
                    private _angleDiff = 90;
                    private _candidateThreatDistance = -1;

                    if (_threatValid) then
                    {
                        private _moveDir = _origin getDir _pos;

                        _angleDiff = abs
                        (
                            (
                                (_moveDir - _towardThreat + 180) mod 360
                            ) - 180
                        );

                        _candidateThreatDistance = _pos distance2D _threat;

                        if (
                            _angleDiff > 130 ||
                            {_candidateThreatDistance > _currentThreatDistance + 3.5} ||
                            {_candidateThreatDistance < 7}
                        ) then
                        {
                            _validCandidate = false;
                        };
                    };

                    if (_validCandidate) then
                    {
                        private _candidateASL = ATLToASL
                        [
                            _pos select 0,
                            _pos select 1,
                            1.2
                        ];

                        private _sourceASL = [];

                        if (_threatValid) then
                        {
                            _sourceASL = _threatASL;
                        }
                        else
                        {
                            private _testAngle = random 360;
                            private _testDistance = 35 + random 30;

                            _sourceASL = ATLToASL
                            [
                                (_pos select 0) + (sin _testAngle) * _testDistance,
                                (_pos select 1) + (cos _testAngle) * _testDistance,
                                1.6
                            ];
                        };

                        private _hits = lineIntersectsSurfaces
                        [
                            _sourceASL,
                            _candidateASL,
                            _threat,
                            _unit,
                            true,
                            6,
                            "FIRE",
                            "FIRE"
                        ];

                        private _hasBlocker = _hits findIf
                        {
                            private _hit = _x;
                            private _hitPos = _hit select 0;
                            private _coverObject = _hit select 2;

                            if (isNull _coverObject) then
                            {
                                _coverObject = _hit select 3;
                            };

                            !isNull _coverObject &&
                            {!(_coverObject isKindOf "CAManBase")} &&
                            {(_hitPos distance _candidateASL) > 0.7} &&
                            {(_hitPos distance _candidateASL) < 8}
                        };

                        if (_hasBlocker >= 0) then
                        {
                            private _score =
                                (_origin distance2D _pos) + random 6;

                            if (_threatValid) then
                            {
                                if (_candidateThreatDistance > _currentThreatDistance) then
                                {
                                    _score = _score +
                                        6 +
                                        ((_candidateThreatDistance - _currentThreatDistance) * 2);
                                };

                                if (_candidateThreatDistance < _currentThreatDistance - 2) then
                                {
                                    _score = _score - 2;
                                };

                                if (_doctrine == "FLANKING") then
                                {
                                    _score = _score +
                                        (abs (_angleDiff - 75) * 0.09);
                                };

                                if (_doctrine == "FIRE_AND_MANEUVER") then
                                {
                                    if (_angleDiff < 70) then
                                    {
                                        _score = _score - 4;
                                    };
                                };
                            };

                            if (_score < _bestScore) then
                            {
                                _bestScore = _score;
                                _bestPos = _pos;
                            };
                        };
                    };
                };
            };
        };

        _bestPos
    };

    while {true} do
    {   if(PROTOCOL_AI_ENABLED && PROTOCOL_AI_DYNAMIC_COVER_USAGE )  then {
        {
            private _grp = _x;

            if (
                !isNull _grp &&
                {local _grp} &&
                {count units _grp > 0}
            ) then
            {
                private _now = diag_tickTime;

                if (
                    (_grp getVariable ["PROTOCOL_COVER_GROUP_EH", -1]) < 0
                ) then
                {
                    private _groupEH = _grp addEventHandler
                    [
                        "EnemyDetected",
                        {
                            params ["_grp", "_newTarget"];

                            if (
                                !isNull _newTarget &&
                                {alive _newTarget}
                            ) then
                            {
                                _grp setVariable
                                [
                                    "PROTOCOL_COVER_GROUP_ENEMY",
                                    _newTarget
                                ];

                                _grp setVariable
                                [
                                    "PROTOCOL_COVER_GROUP_ENEMY_TIME",
                                    diag_tickTime
                                ];
                            };
                        }
                    ];

                    _grp setVariable
                    [
                        "PROTOCOL_COVER_GROUP_EH",
                        _groupEH
                    ];
                };

                private _doctrine = _grp getVariable
                [
                    "PROTOCOL_COVER_DOCTRINE",
                    ""
                ];

                if (_doctrine == "") then
                {
                    _doctrine = selectRandom
                    [
                        "BOUNDING_OVERWATCH",
                        "BOUNDING_OVERWATCH",
                        "FIRE_AND_MANEUVER",
                        "FLANKING"
                    ];

                    _grp setVariable
                    [
                        "PROTOCOL_COVER_DOCTRINE",
                        _doctrine
                    ];

                    _grp setVariable
                    [
                        "PROTOCOL_COVER_BOUND_PHASE",
                        0
                    ];

                    _grp setVariable
                    [
                        "PROTOCOL_COVER_BOUND_NEXT",
                        _now + 2 + random 2
                    ];
                };

                private _livingInfantry = units _grp select
                {
                    alive _x &&
                    {_x isKindOf "CAManBase"} &&
                    {vehicle _x == _x}
                };

                private _phaseCount = 2;

                if (
                    _doctrine == "FIRE_AND_MANEUVER" &&
                    {count _livingInfantry >= 3}
                ) then
                {
                    _phaseCount = 3;
                };

                private _phase = _grp getVariable
                [
                    "PROTOCOL_COVER_BOUND_PHASE",
                    0
                ];

                _phase = _phase mod _phaseCount;

                private _nextPhase = _grp getVariable
                [
                    "PROTOCOL_COVER_BOUND_NEXT",
                    _now + 3
                ];

                if (_now >= _nextPhase) then
                {
                    _phase = (_phase + 1) mod _phaseCount;

                    _grp setVariable
                    [
                        "PROTOCOL_COVER_BOUND_PHASE",
                        _phase
                    ];

                    _grp setVariable
                    [
                        "PROTOCOL_COVER_BOUND_NEXT",
                        _now + 7 + random 5
                    ];
                };

                {
                    private _unit = _x;

                    if (
                        local _unit &&
                        {alive _unit} &&
                        {!isPlayer _unit} &&
                        {canMove _unit} &&
                        {vehicle _unit == _unit}
                    ) then
                    {
                        if (
                            (_unit getVariable ["PROTOCOL_COVER_EH", -1]) < 0
                        ) then
                        {
                            private _eh = _unit addEventHandler
                            [
                                "Suppressed",
                                {
                                    params
                                    [
                                        "_unit",
                                        "_distance",
                                        "_shooter",
                                        "_instigator",
                                        "_ammoObject",
                                        "_ammoClassName",
                                        "_ammoConfig"
                                    ];

                                    _unit setVariable
                                    [
                                        "PROTOCOL_COVER_LAST_FIRE",
                                        diag_tickTime
                                    ];

                                    if (!isNull _shooter) then
                                    {
                                        _unit setVariable
                                        [
                                            "PROTOCOL_COVER_SHOOTER",
                                            _shooter
                                        ];
                                    }
                                    else
                                    {
                                        if (!isNull _instigator) then
                                        {
                                            _unit setVariable
                                            [
                                                "PROTOCOL_COVER_SHOOTER",
                                                _instigator
                                            ];
                                        };
                                    };
                                }
                            ];

                            _unit setVariable
                            [
                                "PROTOCOL_COVER_EH",
                                _eh
                            ];
                        };

                        private _lastFire = _unit getVariable
                        [
                            "PROTOCOL_COVER_LAST_FIRE",
                            -100
                        ];

                        private _groupEnemyTime = _grp getVariable
                        [
                            "PROTOCOL_COVER_GROUP_ENEMY_TIME",
                            -100
                        ];

                        private _threat = objNull;

                        private _savedShooter = _unit getVariable
                        [
                            "PROTOCOL_COVER_SHOOTER",
                            objNull
                        ];

                        if (
                            (_now - _lastFire) < 35 &&
                            {[_unit, _savedShooter] call _isEnemy}
                        ) then
                        {
                            _threat = _savedShooter;
                        };

                        private _groupThreat = _grp getVariable
                        [
                            "PROTOCOL_COVER_GROUP_ENEMY",
                            objNull
                        ];

                        if (
                            isNull _threat &&
                            {(_now - _groupEnemyTime) < 75} &&
                            {[_unit, _groupThreat] call _isEnemy}
                        ) then
                        {
                            _threat = _groupThreat;
                        };

                        if (isNull _threat) then
                        {
                            private _nearbyTargets = nearestObjects
                            [
                                getPosATL _unit,
                                ["CAManBase", "LandVehicle", "Air", "Ship"],
                                600
                            ];

                            {
                                if (
                                    isNull _threat &&
                                    {[_unit, _x] call _isEnemy} &&
                                    {(_unit knowsAbout _x) > 0.5}
                                ) then
                                {
                                    _threat = _x;
                                };
                            } forEach _nearbyTargets;
                        };

                        private _inCombat =
                            (behaviour _unit == "COMBAT") ||
                            {(_now - _lastFire) < 30} ||
                            {
                                (_now - _groupEnemyTime) < 60 &&
                                {!isNull _threat}
                            } ||
                            {
                                !isNull _threat &&
                                {(_unit knowsAbout _threat) > 0.5}
                            };

                        if (_inCombat) then
                        {
                            if !(_unit getVariable ["PROTOCOL_COVER_STANCE_SET", false]) then
                            {
                                //_unit setUnitPos "MIDDLE";

                                _unit setVariable
                                [
                                    "PROTOCOL_COVER_STANCE_SET",
                                    true
                                ];
                            };

                            if (!isNull _threat) then
                            {
                                _unit doWatch _threat;
                            };

                            private _unitIndex = (units _grp) find _unit;

                            if (_unitIndex < 0) then
                            {
                                _unitIndex = 0;
                            };

                            private _canBound =
                                count _livingInfantry <= 1 ||
                                {(_unitIndex mod _phaseCount) == _phase};

                            private _covered =
                            [
                                _unit,
                                _threat
                            ] call _hasCover;

                            if (!_covered) then
                            {
                                _canBound = true;
                            };

                            private _nextMove = _unit getVariable
                            [
                                "PROTOCOL_COVER_NEXT_MOVE",
                                0
                            ];

                            if (
                                _canBound &&
                                {
                                    _now >= _nextMove ||
                                    {!_covered}
                                }
                            ) then
                            {
                                private _coverPos =
                                [
                                    _unit,
                                    _threat,
                                    _doctrine
                                ] call _findRandomCover;

                                if !(_coverPos isEqualTo []) then
                                {
                                    _unit doMove _coverPos;

                                    _unit setVariable
                                    [
                                        "PROTOCOL_COVER_POSITION",
                                        _coverPos
                                    ];

                                    _unit setVariable
                                    [
                                        "PROTOCOL_COVER_NEXT_MOVE",
                                        _now + 5 + random 5
                                    ];
                                }
                                else
                                {
                                    _unit setVariable
                                    [
                                        "PROTOCOL_COVER_NEXT_MOVE",
                                        _now + 2.5
                                    ];
                                };
                            };
                        }
                        else
                        {
                            if (_unit getVariable ["PROTOCOL_COVER_STANCE_SET", false]) then
                            {
                                _unit setUnitPos "AUTO";

                                _unit setVariable
                                [
                                    "PROTOCOL_COVER_STANCE_SET",
                                    false
                                ];
                            };

                            private _nextScan = _unit getVariable
                            [
                                "PROTOCOL_COVER_NEXT_SCAN",
                                0
                            ];

                            if (
                                _now >= _nextScan &&
                                {(speed _unit) < 1.2}
                            ) then
                            {
                                private _covered =
                                [
                                    _unit,
                                    objNull
                                ] call _hasCover;

                                if (!_covered) then
                                {
                                    private _coverPos =
                                    [
                                        _unit,
                                        objNull,
                                        _doctrine
                                    ] call _findRandomCover;

                                    if !(_coverPos isEqualTo []) then
                                    {
                                        _unit doMove _coverPos;

                                        _unit setVariable
                                        [
                                            "PROTOCOL_COVER_POSITION",
                                            _coverPos
                                        ];
                                    };
                                };

                                _unit setVariable
                                [
                                    "PROTOCOL_COVER_NEXT_SCAN",
                                    _now + 5 + random 3
                                ];
                            };
                        };
                    };
                } forEach units _grp;
            };
        } forEach allGroups;

        sleep 2;
	};
    };
};

[]spawn 
{
   if (isNil "PROTOCOL_AI_ENABLED") then {PROTOCOL_AI_ENABLED = true};
   if (isNil "PROTOCOL_AI_DISTANCE") then {PROTOCOL_AI_DISTANCE = 1200};
 _PROTOCOL_DISTANCE = {
	params ["_grp"];
	  if (!isNull _grp && {alive leader _grp}) then
			{
				{
					private _unit = _x;

					if (!alive _unit) then {continue};

					if !(vehicle _unit == _unit) then {continue};

					private _targets = _unit nearEntities [["Man","Car","Tank","Motorcycle","Air","Ship"],1200];

					{
						private _enemy = _x;

						if (
							alive _enemy &&
							{side group _enemy getFriend side _grp < 0.6} &&
							{_unit distance _enemy < PROTOCOL_AI_DISTANCE} &&
							{[_unit,"VIEW"] checkVisibility [eyePos _unit, eyePos _enemy] > 0.25}
						) then
						{
							if ((_grp knowsAbout _enemy) < 2.5) then
							{
								_grp reveal [_enemy,4];
							};

							_unit doTarget _enemy;

							//_grp setBehaviourStrong "COMBAT";
							//_grp setCombatMode "RED";
							//_grp enableAttack true;

							{
								_x doWatch _enemy;
							} forEach units _grp;
						};

					} forEach _targets;

				} forEach units _grp;
			};
	};
  while {true} do { 
  if(PROTOCOL_AI_ENABLED) then {
  {
	 private _grp = _x;

            if (!isNull _grp && {count units _grp > 0}) then {
                [_grp] call _PROTOCOL_DISTANCE;
                
			};

  } forEach allGroups; 
  };
  
        sleep 2;
    };
};

/*
[]spawn 
{   if (isNil "PROTOCOL_AI_ENABLED") then {PROTOCOL_AI_ENABLED = true};
	if (isNil "PROTOCOL_AI_SUPRESS") then {PROTOCOL_AI_SUPRESS = true};
	_PROTOCOL_FIRE_AND_SUPRESS = {
	params ["_grp"];
	  if (!isNull _grp && {alive leader _grp}) then {

		{
		  private _unit = _x;

		  if (
			alive _unit &&
			{vehicle _unit == _unit}
		  ) then {

			private _enemy = _unit findNearestEnemy _unit;

			if (
			  !isNull _enemy &&
			  {_unit knowsAbout _enemy > 1.5}
			) then {

			  private _dist = _unit distance _enemy;

			  _unit setCombatMode "RED";
			  _unit setBehaviourStrong "COMBAT";
			  _unit allowFleeing 0;

			  
			  if (_dist < 120) then {

			   // _unit setUnitPos "UP";

				if (random 1 < 0.35) then {
				  _unit suppressFor 7;
				};

			  } else {

				//_unit setUnitPos "MIDDLE";

			  };

			  

			  if (time > (_unit getVariable ["lastCoverMove",0])) then {

				private _covers =
				  nearestTerrainObjects
				  [
					_unit,
					[
					  "TREE",
					  "SMALL TREE",
					  "BUSH",
					  "ROCK",
					  "ROCKS",
					  "WALL",
					  "FENCE"
					],
					25,
					false,
					true
				  ];

				private _best = objNull;
				private _bestScore = 1e10;

				{
				  private _score = _x distance _enemy;

				  if (_score < _bestScore) then {

					_bestScore = _score;
					_best = _x;

				  };

				} forEach _covers;

				if (!isNull _best) then {

				  private _pos =
					_best getPos
					[2 + random 2,
					 _enemy getDir _best];

				  //_unit doMove _pos;

				} else {

				  private _pos =
					_unit getPos
					[8 + random 8,
					 random 360];

  //			_unit doMove _pos;

				};

				_unit setVariable
				[
				  "lastCoverMove",
				  time + 6 + random 4
				];

			  };


			  if (random 1 < 0.6) then {

				_unit doTarget _enemy;
				_unit doSuppressiveFire position _enemy;

			  };

			};

		  };

		} forEach units _grp;
	  };
	};

  while {true} do {
	if(PROTOCOL_AI_ENABLED) then {
    {
	 private _grp = _x;

            if (!isNull _grp && {count units _grp > 0}) then {

                private _leader = leader _grp;
                private _pos = getPosATL _leader;

                private _nearestBuilding = nearestObject [_pos, "Building"];
                private _distanceToBuilding = _leader distance _nearestBuilding;

                _grp setVariable ["Location", "Open"];
                private _LocationGrp = _grp getVariable ["Location", "None"];
                private _hasTech = false;

                {
                    private _vehicle = vehicle _x;

                    if (
                        _vehicle != _x &&
                        {
                            _vehicle isKindOf "LandVehicle" ||
                            _vehicle isKindOf "Air" ||
                            _vehicle isKindOf "Ship"
                        }
                    ) exitWith {
                        _hasTech = true;
                    };

                } forEach units _grp;
				if(!_hasTech ) then 
				{
                 if(_LocationGrp != "Building") then {
					  if(PROTOCOL_AI_SUPRESS) then {	
				     [_grp] call _PROTOCOL_FIRE_AND_SUPRESS;
					  };
				 };
				};
			};

  } forEach allGroups; 
  };
  };
};
*/
/*
[]spawn 
{   if (isNil "PROTOCOL_AI_ENABLED") then {PROTOCOL_AI_ENABLED = true};
	if (isNil "PROTOCOL_AI_BLINDFIRE") then {PROTOCOL_AI_BLINDFIRE = true};
	_PROTOCOL_BLIND_FIRE = {
	params ["_grp"];
	{
	 private _unit = _x;
				if (
					alive _unit &&
					{vehicle _unit == _unit} &&
					{!(_unit getVariable ["BlindFire", false])}
				) then {

					[_unit] spawn {

						params ["_unit"];

						_unit setVariable ["BlindFire", true];

						while {alive _unit} do {

							private _enemy = _unit findNearestEnemy _unit;

							if (
								!isNull _enemy &&
								{_unit knowsAbout _enemy > 1.5} &&
								{_unit distance _enemy < 250}
							) then {

								private _cover = nearestObject [
									_unit,
									"House"
								];

								if (!isNull _cover) then {

									private _dir = _cover getDir _enemy;

									private _corner =
										_cover getPos [2.2, _dir + 90];

									//_unit doMove _corner;

									waitUntil {
										sleep 0.2;
										!alive _unit ||
										{_unit distance _corner < 1.2}
									};

									if (alive _unit) then {

										//_unit setUnitPos "MIDDLE";

										sleep (1 + random 1);

										private _target =
											eyePos _enemy;

										for "_i" from 1 to (2 + floor random 3) do {

											_unit doWatch _enemy;

											_unit reveal _enemy;

											_unit forceWeaponFire [
												currentWeapon _unit,
												currentMuzzle _unit
											];

											sleep (0.25 + random 0.2);

										};

										sleep (2 + random 2);

										//_unit doMove position _cover;
									};
								};
							};

							sleep 1;
						};

						_unit setVariable ["BlindFire", false];

					};

				};

			} forEach units _grp;
	};
  while {true} do {
	if(PROTOCOL_AI_ENABLED) then {
  {
	 private _grp = _x;

            if (!isNull _grp && {count units _grp > 0}) then {

                private _leader = leader _grp;
                private _pos = getPosATL _leader;

                private _nearestBuilding = nearestObject [_pos, "Building"];
                private _distanceToBuilding = _leader distance _nearestBuilding;

                _grp setVariable ["Location", "Open"];
                private _LocationGrp = _grp getVariable ["Location", "None"];
                private _hasTech = false;

                {
                    private _vehicle = vehicle _x;

                    if (
                        _vehicle != _x &&
                        {
                            _vehicle isKindOf "LandVehicle" ||
                            _vehicle isKindOf "Air" ||
                            _vehicle isKindOf "Ship"
                        }
                    ) exitWith {
                        _hasTech = true;
                    };

                } forEach units _grp;
				if(!_hasTech ) then
				{
                   if(_LocationGrp != "Building") then {
					  if(PROTOCOL_AI_BLINDFIRE) then {
				     [_grp] call _PROTOCOL_BLIND_FIRE;
					  };
			        };
				};
			};

  } forEach allGroups; 
  };
  };
};
*/

[]spawn 
{
   if (isNil "PROTOCOL_AI_ENABLED") then {PROTOCOL_AI_ENABLED = true};
   if (isNil "PROTOCOL_AI_AUTOFORMATIONS") then {PROTOCOL_AI_AUTOFORMATIONS = true};
   _PROTOCOL_FORMATIONS = {

	params ["_grp"];

	if (isNull _grp) exitWith {};
	if (count units _grp <= 1) exitWith {};

	private _ldr = leader _grp;
	if (!alive _ldr) exitWith {};

	private _pos = getPosATL _ldr;

	private _nearForest = terrainIntersectASL [
		ATLToASL _pos,
		ATLToASL (_pos vectorAdd [25,0,8])
	];

	private _houses = nearestObjects [_pos, ["House"], 80];
	private _trees = nearestTerrainObjects [_pos, ["TREE","SMALL TREE","BUSH"], 60];
	private _roads = _pos nearRoads 40;
	private _enemies = _ldr nearEntities [["Man","Car","Tank"], 300];

	private _formation = "WEDGE";

	if (count _houses > 15) then {
		_formation = "COLUMN";
	};

	if ((count _roads > 0) && {count _houses < 5}) then {
		_formation = "FILE";
	};

	if ((count _trees > 30) && {count _houses < 5}) then {
		_formation = "STAG COLUMN";
	};

	if ((count _enemies > 0) && {count _trees > 15}) then {
		_formation = "ECH LEFT";
	};

	if ((count _enemies > 0) && {count _houses > 10}) then {
		_formation = "ECH RIGHT";
	};

	if (
		(count _enemies > 0) &&
		(count _trees < 10) &&
		(count _houses < 5)
	) then {
		_formation = "LINE";
	};

	if (
		(count _trees < 10) &&
		(count _houses < 5) &&
		(count _roads == 0) &&
		(count _enemies == 0)
	) then {
		_formation = "WEDGE";
	};

	if (_nearForest) then {
		_formation = "DIAMOND";
	};

	_grp setFormation _formation;
	 /*
	switch (_formation) do {

		case "WEDGE": {
			_grp setSpeedMode "NORMAL";
			_grp setBehaviour "AWARE";
		};

		case "LINE": {
			_grp setSpeedMode "LIMITED";
			_grp setBehaviour "COMBAT";
		};

		case "COLUMN": {
			_grp setSpeedMode "FULL";
			_grp setBehaviour "SAFE";
		};

		case "FILE": {
			_grp setSpeedMode "FULL";
			_grp setBehaviour "SAFE";
		};

		case "STAG COLUMN": {
			_grp setSpeedMode "NORMAL";
			_grp setBehaviour "AWARE";
		};

		case "ECH LEFT": {
			_grp setSpeedMode "LIMITED";
			_grp setBehaviour "COMBAT";
		};

		case "ECH RIGHT": {
			_grp setSpeedMode "LIMITED";
			_grp setBehaviour "COMBAT";
		};

		case "DIAMOND": {
			_grp setSpeedMode "NORMAL";
			_grp setBehaviour "AWARE";
		};
  
	}; */

};

  while {true} do {
	if(PROTOCOL_AI_ENABLED) then {
  {
	 private _grp = _x;

            if (!isNull _grp && {count units _grp > 0}) then {

                private _leader = leader _grp;
                private _pos = getPosATL _leader;

                private _nearestBuilding = nearestObject [_pos, "Building"];
                private _distanceToBuilding = _leader distance _nearestBuilding;

                _grp setVariable ["Location", "Open"];
                private _LocationGrp = _grp getVariable ["Location", "None"];
                
                private _hasTech = false;

                {
                    private _vehicle = vehicle _x;

                    if (
                        _vehicle != _x &&
                        {
                            _vehicle isKindOf "LandVehicle" ||
                            _vehicle isKindOf "Air" ||
                            _vehicle isKindOf "Ship"
                        }
                    ) exitWith {
                        _hasTech = true;
                    };

                } forEach units _grp;
				if(!_hasTech ) then
				{
                  if(PROTOCOL_AI_AUTOFORMATIONS) then { 
                    [_grp] call _PROTOCOL_FORMATIONS;
				     };
				};
			};

  } forEach allGroups; 
  };
  
        sleep 8;
    };
};



[]spawn 
{   if (isNil "PROTOCOL_AI_ENABLED") then {PROTOCOL_AI_ENABLED = true};
	if (isNil "PROTOCOL_AI_TACTICS") then {PROTOCOL_AI_TACTICS = 0};
	if (isNil "PROTOCOL_AI_CQB_ENABLED") then {PROTOCOL_AI_CQB_ENABLED = true};
    if (isNil "PROTOCOL_AI_CQB_RADIUS") then {PROTOCOL_AI_CQB_RADIUS = 5};
    if (isNil "PROTOCOL_AI_CQB_STANCE") then {PROTOCOL_AI_CQB_STANCE = 0};
    if (isNil "PROTOCOL_AI_CQB_GRENADE_IN_DOOR") then {PROTOCOL_AI_CQB_GRENADE_IN_DOOR = true};
    if (isNil "PROTOCOL_AI_CQB_SPEED") then {PROTOCOL_AI_CQB_SPEED = 0};
    if (isNil "PROTOCOL_AI_CQB_NoVoice") then {PROTOCOL_AI_CQB_NoVoice = true};
    if (isNil "PROTOCOL_AI_CITY_TACTICS_ENABLED") then {PROTOCOL_AI_CITY_TACTICS_ENABLED = true};
    if (isNil "PROTOCOL_AI_CITY_TACTICS_SMOKE_ENABLED") then {PROTOCOL_AI_CITY_TACTICS_SMOKE_ENABLED = true};
	if (isNil "PROTOCOL_AI_DEBUG") then {PROTOCOL_AI_DEBUG = false};     
	_PROTOCOL_CITY_TACTICS = {
	params ["_grp"];

	if (
		local (leader _grp) &&
		{(units _grp) findIf {alive _x} > -1}
	) then {

		private _units = (units _grp) select {alive _x};

		if ((count _units) > 2) then {

			private _enemy = objNull;
			private _dist = 9999;

			{
				private _near = _x findNearestEnemy _x;

				if (!isNull _near) then {
					private _d = _x distance _near;

					if (_d < _dist) then {
						_dist = _d;
						_enemy = _near;
					};
				};

			} forEach _units;

			
			if (isNull _enemy || {_dist > 300}) exitWith {
				_grp setVariable ["CoverSmoke", false];
			};

			_grp setCombatMode "RED";
			_grp setBehaviourStrong "COMBAT";
			_grp enableAttack true;

			private _leader = leader _grp;
			private _coverMan = _units select 0;
			private _stack = _units - [_coverMan];

			private _enemyPos = getPosATL _enemy;
			private _dir = [_leader,_enemy] call BIS_fnc_dirTo;

			private _coverPos = _enemyPos getPos [25 + random 15,_dir + 180];

			private _nearBuildings = nearestObjects [_coverPos,["House","Building"],40];

			if ((count _nearBuildings) > 0) then {

				private _building = _nearBuildings select 0;
				private _bPos = getPosATL _building;

				private _wallPos = _bPos getPos [2.5,_dir];
				private _safeSide = _bPos getPos [4,_dir + 180];

				_coverMan doMove _wallPos;
				_coverMan setUnitPos "MIDDLE";
				_coverMan doWatch _enemy;
				_coverMan suppressFor 8;

				if(PROTOCOL_AI_CITY_TACTICS_SMOKE_ENABLED) then {
				if (
					!("CoverSmoke" in allVariables _grp) ||
					{!(_grp getVariable ["CoverSmoke",false])}
				) then {

					if ("SmokeShell" in magazines _coverMan && {!isRemoteControlling _coverMan}  && {!isPlayer _coverMan} ) then {

						_coverMan playActionNow "ThrowGrenade";
						_coverMan forceWeaponFire ["SmokeShellMuzzle","SmokeShellMuzzle"];
						/*
						private _smoke =
							"SmokeShell" createVehicle
							(_enemyPos getPos [10 + random 15,_dir + 180]);

						_smoke setVelocity [0,0,0];

							_grp setVariable ["CoverSmoke",true];
		*/			};
				};
			    };
				sleep 2;

				{
					private _movePos = _safeSide getPos [random 3,random 360];

					_x doMove _movePos;
					_x setUnitPos "AUTO";
					_x doWatch _enemy;

				} forEach _stack;

				sleep 1;

				private _nextPos = _enemyPos getPos [40 + random 30,_dir + 180];
				private _nextBuildings = nearestObjects [_nextPos,["House","Building"],50];

				if ((count _nextBuildings) > 0) then {

					private _nextBuilding = _nextBuildings select 0;
					private _nextBPos = getPosATL _nextBuilding;

					{
						private _advance =
							_nextBPos getPos
							[
								2 + random 3,
								(_dir + 180) + random 40 - random 40
							];

						_x doMove _advance;
						_x setUnitPos "AUTO";
						_x doWatch _enemy;

					} forEach _units;
				};
			};
		};
	};
}; 

	 _PROTOCOL_CQB = {
	params ["_grp"];
	if (isNull _grp) exitWith {};

	_grp setVariable ["Location","Building"];

	private _units = units _grp;
	if ((count _units) == 0) exitWith {};

	private _leader = leader _grp;
	if (!alive _leader) exitWith {};

	private _buildings = nearestObjects [
		position _leader,
		["House","Building","Strategic","Church","FuelStation","ViewTower","Lighthouse","Fortress","Bunker","Ruins"],
		30
	];

	{
		private _bld = _x;
		private _doorPos = _bld buildingExit 0;
		private _positions = [_bld] call BIS_fnc_buildingPositions;

		if ((count _positions) > 0 && {_leader distance _bld < 30}) then {

			private _enemyInside = false;

			{
				if (
					side _x != side _leader &&
					alive _x &&
					(_x distance2D _bld < 25)
				) exitWith {
					_enemyInside = true;
				};
			} forEach allUnits;

			if (_enemyInside) then {
				  if !(_grp getVariable ["CQBClearing",false]) then {

			_grp setVariable ["CQBClearing",true]; 
				if(_grp getVariable ["DefendCQB", false]) then {
				if (
					alive _leader &&
					{vehicle _leader == _leader} &&
					{!(_leader getVariable ["doorTask",false])}
				) then {
                     if(PROTOCOL_AI_CQB_GRENADE_IN_DOOR) then {
					_leader setVariable ["doorTask",false];
					   if (!isNull _bld) then {

			  private _exitPos = [];
			  private _bestDist = 1e10;

			  for "_i" from 0 to 50 do {

				private _p = _bld buildingExit _i;

				 if ((_p select 0) != 0 || (_p select 1) != 0 || (_p select 2) != 0) then {
				  private _d = _leader distance _p;

				  if (_d < _bestDist) then {
					_bestDist = _d;
					_exitPos = _p;
				  };

				};

			  };

			  if ((count _exitPos) > 0) then {

				_leader doMove _exitPos;
				/*
				waitUntil {
				  sleep 0.2;
				  !alive _leader ||
				  (_leader distance _exitPos < 2)
				};
			   */
				if (alive _leader) then {

				  private _door = 0;
				  private _best = 1e10;

				  for "_i" from 1 to 20 do {

					private _sel = format ["Door_%1_trigger", _i];

					if ((_bld selectionPosition _sel) isNotEqualTo [0,0,0]) then {

					  private _worldPos = _bld modelToWorld (_bld selectionPosition _sel);

					  private _d = _worldPos distance _exitPos;

					  if (_d < _best) then {
						_best = _d;
						_door = _i;
					  };

					};

				  };

				  if (_door > 0) then {

					
					_bld animateSource [format ["Door_%1_sound_source", _door],1];

					sleep 1;
					 _leader doWatch _bld	;
					
					if !("HandGrenade" in magazines _leader) then {
					_leader addMagazine "HandGrenade";
				  };
                  if(!isRemoteControlling _coverMan  &&  {!isPlayer _coverMan}) then { 
				  _leader selectWeapon "HandGrenadeMuzzle"; 
				  _leader forceWeaponFire ["HandGrenadeMuzzle","HandGrenadeMuzzle"];
				
					sleep 2;
				  };
					
					_bld animateSource [format ["Door_%1_sound_source", _door],0];
					
					//_leader setSpeedMode "FULL";
					private _dir = _bld getDir _leader;
					private _retreatPos = [getPosATL _leader, 10, _dir] call BIS_fnc_relPos;
					_leader doMove _retreatPos;
					};

				};

			  };

			};
				_leader setVariable ["doorTask",true];
				};
				};
				};
				private _targetBuilding = objNull;
	private _positions = [];
	{
		private _posList = [_x] call BIS_fnc_buildingPositions;
		if ((count _posList) > 0) exitWith {
			_targetBuilding = _x;
			_positions = _posList;
		};
	} forEach _buildings;

	if (isNull _targetBuilding || (count _positions) == 0) exitWith {};

	
	[_grp, _positions, _targetBuilding] spawn {

	params ["_grp","_positions","_building"];

	{
		
		private _room = _x;

		private _aliveUnits = units _grp select {alive _x};

		if ((count _aliveUnits) == 0) exitWith {};

		{
				if (PROTOCOL_AI_CQB_SPEED == 0) then {_x forceSpeed 2;};
				if (PROTOCOL_AI_CQB_SPEED == 1) then {_x forceSpeed 3;};
				if (PROTOCOL_AI_CQB_SPEED == 2) then {_x forceSpeed 5;};
			
					if (PROTOCOL_AI_CQB_STANCE == 0) then {
						_x setUnitPos "UP";
						if ((_forEachIndex mod 2) == 0) then {
							_x setUnitPos "MIDDLE";
						};
					};
					if (PROTOCOL_AI_CQB_STANCE == 1) then {
						_x setUnitPos "UP";
					};
					if (PROTOCOL_AI_CQB_STANCE == 2) then {
						_x setUnitPos "MIDDLE";
					};
				
			
				

			_x doMove _room;
			_x doWatch (_room vectorAdd [random 4 - 2,random 4 - 2,1]);

		} forEach _aliveUnits;

		private _timeout = time + 15;

		waitUntil {

			sleep 0.3;

			private _arrived = true;

			{
				if (alive _x && {_x distance _room > 2.5}) exitWith {
					_arrived = false;
				};
			} forEach _aliveUnits;

			_arrived || {time > _timeout}
		};
		 sleep 2.5;		

		{
			if (alive _x) then {

				_x doWatch (_room vectorAdd [random 6-3,random 6-3,1]);

				if !(currentWeapon _x isEqualTo handgunWeapon _x) then {
					_x doSuppressiveFire (_room vectorAdd [random 3-1.5,random 3-1.5,1]);
				};

			};
		} forEach _aliveUnits;

		sleep 3;

	} forEach _positions;

	{
		if (alive _x) then {
			_x forceSpeed -1;
			_x setUnitPos "AUTO";
		};
	} forEach units _grp;

	_grp setVariable ["CQBClearing", false];

};
	};
	
			} else {
				
				
				{
				private _unit = _x;

				if (alive _unit && {unitReady _unit}) then {

					private _pos = _positions select (_forEachIndex mod (count _positions));
                    
				   if (PROTOCOL_AI_CQB_SPEED == 0) then {_unit forceSpeed 1.5;};
				   if (PROTOCOL_AI_CQB_SPEED == 1) then {_unit forceSpeed 3;};
				   if (PROTOCOL_AI_CQB_SPEED == 2) then {_unit forceSpeed 5;};
					
					if (PROTOCOL_AI_CQB_STANCE == 0) then {
						_unit setUnitPos "UP";
						if ((_forEachIndex mod 2) == 0) then {
							_unit setUnitPos "MIDDLE";
						};
					};
					if (PROTOCOL_AI_CQB_STANCE == 1) then {
						_unit setUnitPos "UP";
					};
					if (PROTOCOL_AI_CQB_STANCE == 2) then {
						_unit setUnitPos "MIDDLE";
					};
				

					_unit doMove _pos;

					_unit doWatch (
						_pos vectorAdd [
							random 5,
							random 5,
							0
						]
					);

					_unit doMove (
						_pos vectorAdd [
							random 2,
							random 2,
							0
						]
					);
					_grp setVariable ["DefendCQB", true];

                    if (PROTOCOL_AI_CQB_NoVoice) then {
					_unit setSpeaker "NoVoice";
					};
				};

			} forEach _units; /* [_grp, _bld, _positions] spawn {
		params ["_grp", "_bld", "_positions"];
		waitUntil {sleep 5; {alive _x && _x distance _bld < 30} count units _grp == 0 || isNull _grp};
		if (isNull _grp) exitWith {};
		while {count units _grp > 0 && !isNull _grp} do {
			{
				private _unit = _x;
				if (alive _unit && _unit distance _bld > 10) then {
					private _closestPos = _positions select 0;
					{ if (_x distance _unit < _closestPos distance _unit) then { _closestPos = _x; } } forEach _positions;
					_unit doMove _closestPos;
				} else {
					if (alive _unit) then {
						private _newPos = _positions select floor random count _positions;
						_unit doMove _newPos;
					};
				};
				sleep 1;
			} forEach units _grp;
			sleep 10;
		};
	};*/
			};

			
		};

	} forEach _buildings;
};
 _PROTOCOL_WOODLAND = {
		params ["_grp"];

		if (isNull _grp) exitWith {};

		_grp setBehaviour "AWARE";
		_grp setCombatMode "RED";
		_grp setSpeedMode "LIMITED";
		_grp setFormation "WEDGE";

		private _units = units _grp;
		private _leader = leader _grp;

		if ((count _units) > 1) then {
			private _half = floor (count _units / 2);
			private _team1 = _units select [0, _half];
			private _team2 = _units select [_half];

			private _pos = getPosATL _leader;
			private _dir = random 360;

			private _offset1 = [_pos, 10 + random 10, _dir] call BIS_fnc_relPos;
			private _offset2 = [_pos, 10 + random 10, _dir + 180] call BIS_fnc_relPos;

			{
				_x doMove _offset1;
				_x setUnitPos "MIDDLE";
				_x suppressFor 2 + random 3;
			} forEach _team1;

			{
				_x doMove _offset2;
				_x setUnitPos "DOWN";
				_x suppressFor 2 + random 3;
			} forEach _team2;

			{
				private _enemy = _x findNearestEnemy _x;
				if (!isNull _enemy) then {
					_x doSuppressiveFire _enemy;
				};
			} forEach _units;
		} else {
			private _u = _units select 0;
			private _enemy = _u findNearestEnemy _u;
			if (!isNull _enemy) then {
				_u doSuppressiveFire _enemy;
			};
		};
	};
	_PROTOCOL_ENVIROMENT_TACTICS = { 
	params ["_grp"];
	 private _nearestBuilding = nearestObject [_pos, "Building"];
    private _distanceToBuilding = _leader distance _nearestBuilding;
	if (!isNull _nearestBuilding) then {
					if (_distanceToBuilding < PROTOCOL_AI_CQB_RADIUS + 10  && _distanceToBuilding > PROTOCOL_AI_CQB_RADIUS && _LocationGrp != "Building") then { 
						  if(PROTOCOL_AI_DEBUG) then {
						  systemChat format [ "%1 | City tactic ", _grp];
						  };
						  _grp setVariable ["Location", "City"];
						  [_grp] call  _PROTOCOL_CITY_TACTICS;
							  
					};
					if (_distanceToBuilding < PROTOCOL_AI_CQB_RADIUS) then {
						if(PROTOCOL_AI_DEBUG) then {
						 systemChat format [ "%1 | CQB ", _grp];
						};
					   [_grp] call _PROTOCOL_CQB; 
					};
					} else { 
					private _pos = getPosATL _leader;
			    	private _trees = nearestTerrainObjects [_pos, ["TREE","SMALL TREE","BUSH"], 30];
				    if (count _trees > 15) then {
					_grp setVariable ["Location", "Forest"];
					if( _LocationGrp == "Forest") then {
						if(PROTOCOL_AI_DEBUG) then {
                        systemChat format [ "%1 | Woodland tactic ", _grp];
						};
					[_grp] call _PROTOCOL_WOODLAND;
			       };
		};
	};
	
	
};

  while {true} do {
  if(PROTOCOL_AI_ENABLED) then {
  {
	 private _grp = _x;

            if (!isNull _grp && {count units _grp > 0}) then {

                private _leader = leader _grp;
                private _pos = getPosATL _leader;

                private _nearestBuilding = nearestObject [_pos, "Building"];
                private _distanceToBuilding = _leader distance _nearestBuilding;

                _grp setVariable ["Location", "Open"];
                private _LocationGrp = _grp getVariable ["Location", "None"];
                private _hasTech = false;

                {
                    private _vehicle = vehicle _x;

                    if (
                        _vehicle != _x &&
                        {
                            _vehicle isKindOf "LandVehicle" ||
                            _vehicle isKindOf "Air" ||
                            _vehicle isKindOf "Ship"
                        }
                    ) exitWith {
                        _hasTech = true;
                    };

                } forEach units _grp;
				if(!_hasTech ) then 
				{
                 if(PROTOCOL_AI_TACTICS == 0) then {
					 [_grp] call _PROTOCOL_ENVIROMENT_TACTICS;
					};	
				};
			};

  } forEach allGroups; 
  };
  
        sleep 5;
    };
};


[] spawn {
if (isNil "PROTOCOL_AI_TROOPS") then {PROTOCOL_AI_TROOPS = true};
if (isNil "PROTOCOL_AI_ENABLED") then {PROTOCOL_AI_ENABLED = true}; 
_PROTOCOL_TROOPS = {
    {
        private _veh = vehicle _x;

        if (
            _veh isKindOf "LandVehicle" &&
            {alive _veh} &&
            {canMove _veh} &&
            {driver _veh == _x}
        ) then {
            private _driver = _x;
            private _group = group _driver;
            private _gunner = gunner _veh;

            if (isNull _gunner) then {
                continue;
            };

            private _currentWP = currentWaypoint _group;

            if (_currentWP >= 0 && {waypointType [_group, _currentWP] == "MOVE"}) then {
                private _groupUnits = (units _group) select {alive _x};
                private _allLoaded = _groupUnits isNotEqualTo [] && {
                    ({vehicle _x == _veh} count _groupUnits) == count _groupUnits
                };

                if (_allLoaded) then {
                    private _wpPos = waypointPosition [_group, _currentWP];

                    _veh forceSpeed -1;
                    _veh limitSpeed -1;
                    _driver commandMove _wpPos;
                };
            };

            private _targets = _gunner targets [true, 600];

            if (_targets isEqualTo []) then {
                _veh forceSpeed -1;
                continue;
            };

            private _target = _targets select 0;

            if (!alive _target) then {
                continue;
            };

            private _dist = _veh distance _target;
            private _targetPos = getPosATL _target;
            private _commander = commander _veh;
            private _crew = crew _veh;
            private _infantry = _crew select {
                alive _x &&
                vehicle _x == _veh &&
                !(_x in [_driver, _gunner, _commander])
            };
            private _hasInfantry = count _infantry > 0;
            private _deployed = _veh getVariable ["infantryDeployed", false];

            if (_deployed) then {
                if (_dist > 100) then {
                    _veh forceSpeed -1;
                    _driver doMove _targetPos;
                    _veh limitSpeed 12;
                } else {
                    _veh forceSpeed 0;
                };

                if (isNil {_veh getVariable "lastFire"}) then {
                    _veh setVariable ["lastFire", time];

                    private _weapons = _veh weaponsTurret [0];

                    if (_weapons isNotEqualTo []) then {
                        _gunner fireAtTarget [_target, _weapons select 0];
                    };

                    [_veh] spawn {
                        params ["_veh"];
                        sleep 2;
                        _veh setVariable ["lastFire", nil];
                    };
                };
            } else {
                if (_hasInfantry && _dist < 450) then {
                    _veh forceSpeed 0;

                    if (isNil {_veh getVariable "lastFire"}) then {
                        _veh setVariable ["lastFire", time];

                        private _weapons = _veh weaponsTurret [0];

                        if (_weapons isNotEqualTo []) then {
                            _gunner fireAtTarget [_target, _weapons select 0];
                        };

                        [_veh] spawn {
                            params ["_veh"];
                            sleep 2;
                            _veh setVariable ["lastFire", nil];
                        };
                    };

                    {
                        unassignVehicle _x;
                        doGetOut _x;

                        if (random 1 < 0.25) then {
                            _x setUnitPos "DOWN";
                            sleep 0.4;
                            _x setUnitPos "AUTO";
                        };

                        _x playActionNow "EvasiveRight";
                    } forEach _infantry;

                    _veh setVariable ["infantryDeployed", true];

                    sleep 3;

                    private _group = group _driver;

                    _group setFormation "FILE";
                    _group setSpeedMode "LIMITED";

                    _veh forceSpeed -1;
                    _driver doMove _targetPos;
                    _veh limitSpeed 12;
                } else {
                    if (_dist <= 200) then {
                        _veh forceSpeed 0;
                        _gunner doWatch _target;

                        if (isNil {_veh getVariable "lastFire"}) then {
                            _veh setVariable ["lastFire", time];

                            private _weapons = _veh weaponsTurret [0];

                            if (_weapons isNotEqualTo []) then {
                                _gunner fireAtTarget [_target, _weapons select 0];
                            };

                            [_veh] spawn {
                                params ["_veh"];
                                sleep 2;
                                _veh setVariable ["lastFire", nil];
                            };
                        };

                        if (isNil {_veh getVariable "smokeDeployed"}) then {
                            [_veh, "SmokeLauncher"] call BIS_fnc_fire;
                            _veh setVariable ["smokeDeployed", true];

                            [_veh] spawn {
                                params ["_veh"];
                                sleep 60;
                                _veh setVariable ["smokeDeployed", nil];
                            };
                        };

                        if (isNil {_veh getVariable "retreating"}) then {
                            _veh setVariable ["retreating", true];

                            [_veh] spawn {
                                params ["_veh"];
                                sleep 2;

                                private _backPos = _veh getPos [-20, getDir _veh];

                                (driver _veh) doMove _backPos;
                                _veh limitSpeed 10;

                                sleep 5;

                                _veh limitSpeed -1;
                                _veh setVariable ["retreating", nil];
                            };
                        };
                    } else {
                        _veh forceSpeed -1;
                        _driver doMove _targetPos;
                    };
                };
            };
        };
    } forEach allUnits;
};


    while {true} do {
		if(PROTOCOL_AI_TROOPS && PROTOCOL_AI_ENABLED) then {
		call _PROTOCOL_TROOPS;
		};
    
        sleep 1;
    };
};
// corner
if (isNil "PROTOCOL_AI_CORNER_PEEK_ENABLED") then {
	PROTOCOL_AI_CORNER_PEEK_ENABLED = true;
};

if (isNil "PROTOCOL_AI_CORNER_PEEK_DISTANCE") then {
	PROTOCOL_AI_CORNER_PEEK_DISTANCE = 0.55;
};

if (isNil "PROTOCOL_AI_CORNER_PEEK_FORWARD") then {
	PROTOCOL_AI_CORNER_PEEK_FORWARD = 0.12;
};

if (isNil "PROTOCOL_AI_CORNER_PEEK_DURATION") then {
	PROTOCOL_AI_CORNER_PEEK_DURATION = 1.1;
};

[] spawn {
	while {PROTOCOL_AI_CORNER_PEEK_ENABLED} do {
		{
			private _grp = _x;

			{
				private _unit = _x;

				if (
					alive _unit &&
					{!isPlayer _unit} &&
					{vehicle _unit == _unit} &&
					{abs (speed _unit) < 6} &&
					{time > (_unit getVariable ["PROTOCOL_AI_CORNER_PEEK_NEXT", 0])}
				) then {
					private _enemy = _unit findNearestEnemy _unit;

					if (
						!isNull _enemy &&
						{alive _enemy} &&
						{_enemy isKindOf "Man"} &&
						{_unit knowsAbout _enemy >= 0.5} &&
						{_unit distance2D _enemy < 100}
					) then {
						private _blocked = lineIntersectsSurfaces [
							eyePos _unit,
							eyePos _enemy,
							_unit,
							_enemy,
							true,
							1,
							"VIEW",
							"FIRE"
						];

						if (count _blocked > 0) then {
							private _coverPos = getPosATL _unit;
							private _enemyPos = getPosATL _enemy;

							private _dx = (_enemyPos select 0) - (_coverPos select 0);
							private _dy = (_enemyPos select 1) - (_coverPos select 1);

							private _len = sqrt (_dx * _dx + _dy * _dy);

							if (_len > 0.1) then {
								private _side = [
									-(_dy / _len),
									_dx / _len,
									0
								];

								private _toward = [
									_dx / _len,
									_dy / _len,
									0
								];

								private _distance = PROTOCOL_AI_CORNER_PEEK_DISTANCE;
								_distance = (_distance max 0.2) min 1.2;

								private _forward = PROTOCOL_AI_CORNER_PEEK_FORWARD;
								_forward = (_forward max 0) min 0.5;

								private _leftOffset = (_side vectorMultiply _distance) vectorAdd (_toward vectorMultiply _forward);
								private _rightOffset = (_side vectorMultiply (-_distance)) vectorAdd (_toward vectorMultiply _forward);

								private _leftPos = _coverPos vectorAdd _leftOffset;
								private _rightPos = _coverPos vectorAdd _rightOffset;

								private _eyePos = eyePos _unit;

								private _leftASL = _eyePos vectorAdd [_leftOffset select 0, _leftOffset select 1, 0];
								private _rightASL = _eyePos vectorAdd [_rightOffset select 0, _rightOffset select 1, 0];

								private _leftBlocked = lineIntersectsSurfaces [_leftASL, eyePos _enemy, _unit, _enemy, true, 1, "VIEW", "FIRE"];
								private _rightBlocked = lineIntersectsSurfaces [_rightASL, eyePos _enemy, _unit, _enemy, true, 1, "VIEW", "FIRE"];

								private _candidates = [];

								if (count _leftBlocked == 0 && {!surfaceIsWater _leftPos}) then {
									_candidates pushBack [_leftPos, "LeanLeft"];
								};

								if (count _rightBlocked == 0 && {!surfaceIsWater _rightPos}) then {
									_candidates pushBack [_rightPos, "LeanRight"];
								};

								if (count _candidates > 0) then {
									private _choice = selectRandom _candidates;
									private _peekPos = _choice select 0;
									private _leanAction = _choice select 1;

									_unit setVariable ["PROTOCOL_AI_CORNER_PEEK_NEXT", time + 4 + random 3];

									[
										_unit,
										_enemy,
										_peekPos,
										_coverPos,
										_leanAction
									] spawn {
										params ["_unit", "_enemy", "_peekPos", "_coverPos", "_leanAction"];

										private _oldUnitPos = unitPos _unit;

										_unit doMove _peekPos;

										private _deadline = time + 3.0;


										if (alive _unit && {!isNull _enemy} && {alive _enemy}) then {
																						_unit doWatch _enemy;
											_unit playActionNow _leanAction;

											sleep 0.1;

											if (alive _unit && {alive _enemy}) then {
												_unit doTarget _enemy;
												_unit doFire _enemy;
											};

											private _peekDuration = PROTOCOL_AI_CORNER_PEEK_DURATION;
											_peekDuration = (_peekDuration max 0.3) min 3;

											sleep (_peekDuration + random 0.2);
										};

										if (alive _unit) then {
											private _returnDeadline = time + 3.0;
											_unit doMove _coverPos;

										   
																					};
									};
								};
							};
						};
					};
				};
			} forEach units _grp;
		} forEach allGroups;

		sleep 0.5;
	};
};

// stance 
if (isNil "PROTOCOL_AI_STANCE_ENABLED") then {
    PROTOCOL_AI_STANCE_ENABLED = true;
};

if (isNil "PROTOCOL_AI_STANCE_INTERVAL") then {
    PROTOCOL_AI_STANCE_INTERVAL = 3;
};

if (isNil "PROTOCOL_AI_STANCE_MAX_DISTANCE") then {
    PROTOCOL_AI_STANCE_MAX_DISTANCE = 500;
};

if (isNil "PROTOCOL_AI_STANCE_CQB_DISTANCE") then {
    PROTOCOL_AI_STANCE_CQB_DISTANCE = 12;
};

if (isNil "PROTOCOL_AI_STANCE_SUPPRESSION_HIGH") then {
    PROTOCOL_AI_STANCE_SUPPRESSION_HIGH = 0.55;
};

if (isNil "PROTOCOL_AI_STANCE_LOOP_RUNNING") then {
    PROTOCOL_AI_STANCE_LOOP_RUNNING = false;
};

if (!PROTOCOL_AI_STANCE_LOOP_RUNNING) then {
    PROTOCOL_AI_STANCE_LOOP_RUNNING = true;

    [] spawn {
        while {PROTOCOL_AI_STANCE_ENABLED} do {

            private _aliveUnits = allUnits select {
                alive _x
            };

            {
                private _grp = _x;

                {
                    private _unit = _x;

                    if (
                        alive _unit &&
                        {local _unit} &&
                        {!(isPlayer _unit)} &&
                        {(vehicle _unit) isEqualTo _unit}
                    ) then {

                        private _unitSide = side _unit;

                        private _knownEnemies = _aliveUnits select {
                            !(_x isEqualTo _unit) &&
                            {(_unitSide getFriend (side _x)) < 0.6} &&
                            {(_unit knowsAbout _x) > 0.1} &&
                            {(_unit distance2D _x) <= PROTOCOL_AI_STANCE_MAX_DISTANCE}
                        };

                        private _nearestEnemy = objNull;
                        private _nearestDistance = 1e10;

                        {
                            private _distance = _unit distance2D _x;

                            if (_distance < _nearestDistance) then {
                                _nearestDistance = _distance;
                                _nearestEnemy = _x;
                            };
                        } forEach _knownEnemies;

                        private _desiredPosition = "AUTO";

                        if (!isNull _nearestEnemy) then {

                            private _suppression = getSuppression _unit;

                            if (_suppression < 0) then {
                                _suppression = 0;
                            };

                            private _inBuilding = (insideBuilding _unit) > 0.65;
                            private _moving = abs (speed _unit) > 4;

                            private _inContact =
                                (behaviour _unit) isEqualTo "COMBAT" ||
                                {_nearestDistance <= 30} ||
                                {_suppression >= 0.15};

                            if (_inContact) then {

                                private _visibility = [
                                    _unit,
                                    "VIEW",
                                    _nearestEnemy
                                ] checkVisibility [
                                    eyePos _unit,
                                    eyePos _nearestEnemy
                                ];

                                private _hasCover = _visibility < 0.2;

                                if (_suppression >= PROTOCOL_AI_STANCE_SUPPRESSION_HIGH) then {

                                    if (_hasCover) then {
                                        _desiredPosition = "MIDDLE";
                                    } else {
                                        _desiredPosition = "DOWN";
                                    };

                                } else {

                                    if (
                                        _inBuilding &&
                                        {_nearestDistance <= 35}
                                    ) then {

                                        _desiredPosition = "UP";

                                    } else {

                                        if (_nearestDistance <= PROTOCOL_AI_STANCE_CQB_DISTANCE) then {

                                            if (_moving) then {
                                                _desiredPosition = "UP";
                                            } else {
                                                _desiredPosition = "MIDDLE";
                                            };

                                        } else {

                                            if (_moving) then {

                                                _desiredPosition = "AUTO";

                                            } else {

                                                if (_hasCover) then {

                                                    _desiredPosition = "MIDDLE";

                                                } else {

                                                    if (_nearestDistance >= 45) then {
                                                        _desiredPosition = "DOWN";
                                                    } else {
                                                        _desiredPosition = "MIDDLE";
                                                    };

                                                };

                                            };

                                        };

                                    };

                                };

                            };

                        };

                        if (
                            (toUpper (unitPos _unit)) != _desiredPosition
                        ) then {
                            _unit setUnitPos _desiredPosition;
                        };

                    };

                } forEach units _grp;

            } forEach allGroups;

            sleep PROTOCOL_AI_STANCE_INTERVAL;
        };

        PROTOCOL_AI_STANCE_LOOP_RUNNING = false;
    };
};
// ammo 
[] spawn {
	while {true} do {
		{
			{
				private _unit = _x;

				if (
					local _unit &&
					{alive _unit} &&
					{!isPlayer _unit} &&
					{vehicle _unit == _unit}
				) then {
					private _target = _unit findNearestEnemy _unit;

					if (
						!isNull _target &&
						{alive _target} &&
						{(_unit knowsAbout _target) > 1.2} &&
						{((side _unit) getFriend (side _target)) < 0.6}
					) then {
						private _weapon = currentWeapon _unit;

						if (_weapon != "") then {
							private _modes = getArray (
								configFile >>
								"CfgWeapons" >>
								_weapon >>
								"modes"
							);

							private _fireMode = "";

							{
								if (_x in _modes) exitWith {
									_fireMode = _x;
								};
							} forEacАh [
								"FullAuto",
								"Burst",
								"manual",
								"close",
								"short",
								"medium",
								"far_optic1",
								"far_optic2"
							];

							if (
								_fireMode != "" &&
								{(_unit aimedAtTarget [_target]) > 0.15} &&
								{(_unit ammo _weapon) > 0}
							) then {
								_unit forceWeaponFire [
									_weapon,
									_fireMode
								];
							};
						};
					};
				};
			} forEach units _x;
		} forEach allGroups;

		sleep 1.2;
	};
}; 
//Explosive
if (isNil "PROTOCOL_AI_EXPLOSIVE_SUPPRESSION_ENABLED") then {
	PROTOCOL_AI_EXPLOSIVE_SUPPRESSION_ENABLED = true;
};

if (isNil "PROTOCOL_AI_EXPLOSIVE_SUPPRESSION_CHECK_TIME") then {
	PROTOCOL_AI_EXPLOSIVE_SUPPRESSION_CHECK_TIME = 1.5;
};

if (isNil "PROTOCOL_AI_FNC_IS_EXPLOSIVE_MAG") then {
	PROTOCOL_AI_FNC_IS_EXPLOSIVE_MAG = {
		params ["_mag"];

		private _name = toLower _mag;

		private _excluded = [
			"smoke",
			"chemlight",
			"irgrenade",
			"flare",
			"illum",
			"signal",
			"training",
			"practice",
			"marker"
		];

		if (
			(_excluded findIf {
				(_name find _x) >= 0
			}) >= 0
		) exitWith {
			false
		};

		private _ammo = getText (
			configFile >>
			"CfgMagazines" >>
			_mag >>
			"ammo"
		);

		private _cfg = configFile >> "CfgAmmo" >> _ammo;

		if (
			_ammo isEqualTo "" ||
			{!isClass _cfg}
		) exitWith {
			false
		};

		private _hit = getNumber (_cfg >> "hit");
		private _indirectHit = getNumber (_cfg >> "indirectHit");
		private _indirectRange = getNumber (_cfg >> "indirectHitRange");

		(_hit >= 10) ||
		{
			_indirectHit >= 3 &&
			{_indirectRange >= 3}
		}
	};
};

[] spawn {
	while {PROTOCOL_AI_EXPLOSIVE_SUPPRESSION_ENABLED} do {

		{
			private _grp = _x;
			private _side = side _grp;

			if (
				count units _grp > 0 &&
				{!isNull leader _grp}
			) then {

				{
					private _unit = _x;

					if (
						local _unit &&
						{alive _unit} &&
						{!isPlayer _unit} &&
						{vehicle _unit isEqualTo _unit} &&
						{
							time >= (
								_unit getVariable [
									"PROTOCOL_AI_EXPLOSIVE_NEXT",
									0
								]
							)
						} &&
						{
							time >= (
								_grp getVariable [
									"PROTOCOL_AI_EXPLOSIVE_GROUP_NEXT",
									0
								]
							)
						}
					) then {

						private _target = assignedTarget _unit;

						if (isNull _target) then {
							private _target = _unit findNearestEnemy _unit;						};

						if (
							!isNull _target &&
							{alive _target} &&
							{!(_target isEqualTo _unit)} &&
							{
								(_side getFriend (side _target)) < 0.6
							} &&
							{(_unit knowsAbout _target) >= 1.5}
						) then {

							private _distance =
								_unit distance2D _target;

							private _tactic = toUpper (
								_grp getVariable [
									"PROTOCOL_AI_CURRENT_TACTIC",
									"AUTO"
								]
							);

							private _handChance = 0.65;
							private _uglChance = 0.70;

							switch (_tactic) do {

								case "FIRE_AND_MANEUVER": {
									_handChance = 0.88;
									_uglChance = 0.82;
								};

								case "FLANKING": {
									_handChance = 0.90;
									_uglChance = 0.78;
								};

								case "ENCIRCLEMENT": {
									_handChance = 0.90;
									_uglChance = 0.85;
								};

								case "CENTRAL_PEEL": {
									_handChance = 0.68;
									_uglChance = 0.78;
								};

								case "RECONNAISSANCE_BY_FIRE": {
									_handChance = 0.45;
									_uglChance = 0.90;
								};

								case "AMBUSH": {
									_handChance = 0.72;
									_uglChance = 0.76;
								};

								case "ALL_ROUND_DEFENSE": {
									_handChance = 0.72;
									_uglChance = 0.85;
								};
							};

							if (
								_distance >= 10 &&
								{_distance <= 28}
							) then {

								private _throwables = (
									throwables _unit
								) select {
									private _mag = _x select 0;
									private _count = _x param [3, 1];

									_count > 0 &&
									{
										[_mag] call
										PROTOCOL_AI_FNC_IS_EXPLOSIVE_MAG
									}
								};

								if (
									count _throwables > 0 &&
									{random 1 < _handChance}
								) then {

									private _friendlyNearTarget =
										(allUnits findIf {
											alive _x &&
											{!(_x isEqualTo _unit)} &&
											{
												(
													_side getFriend
													(side _x)
												) >= 0.6
											} &&
											{
												_x distance2D _target < 12
											}
										}) >= 0;

									if (!_friendlyNearTarget) then {

										private _chosen =
											selectRandom _throwables;

										private _mag = _chosen select 0;

										_unit setVariable [
											"PROTOCOL_AI_EXPLOSIVE_NEXT",
											time + 22 + random 12,
											false
										];

										_grp setVariable [
											"PROTOCOL_AI_EXPLOSIVE_GROUP_NEXT",
											time + 3 + random 3,
											false
										];

										[
											_unit,
											_target,
											_mag
										] spawn {

											params [
												"_unit",
												"_target",
												"_mag"
											];

											if (
												!local _unit ||
												{!alive _unit} ||
												{!alive _target}
											) exitWith {};

											_unit doTarget _target;
											_unit doWatch _target;

											uiSleep 0.35;

											if (
												!alive _unit ||
												{!alive _target}
											) exitWith {};

											if (_unit selectThrowable _mag) then {

												uiSleep 0.15;

												private _throwable =
													currentThrowable _unit;

												private _muzzle =
													_throwable param [1, ""];

												if (_muzzle != "") then {
													[
														_unit,
														_muzzle
													] call BIS_fnc_fire;
												};
											};
										};
									};
								};

							} else {

								if (
									_distance >= 35 &&
									{_distance <= 115} &&
									{random 1 < _uglChance}
								) then {

									private _weapon =
										primaryWeapon _unit;

									if (_weapon != "") then {

										private _muzzles = getArray (
											configFile >>
											"CfgWeapons" >>
											_weapon >>
											"muzzles"
										);

										private _launcherOptions = [];

										{
											private _muzzle = _x;

											if (
												!(_muzzle isEqualTo "this")
											) then {

												private _compatible =
													compatibleMagazines [
														_weapon,
														_muzzle
													];

												private _available = (
													magazinesAmmoFull _unit
												) select {

													(_x select 1) > 0 &&
													{
														(_x select 0) in
														_compatible
													} &&
													{
														[
															_x select 0
														] call
														PROTOCOL_AI_FNC_IS_EXPLOSIVE_MAG
													}
												};

												if (
													count _available > 0
												) then {

													_launcherOptions pushBack [
														_muzzle,
														_compatible
													];
												};
											};

										} forEach _muzzles;

										private _friendlyNearTarget =
											(allUnits findIf {
												alive _x &&
												{!(_x isEqualTo _unit)} &&
												{
													(
														_side getFriend
														(side _x)
													) >= 0.6
												} &&
												{
													_x distance2D _target < 16
												}
											}) >= 0;

										if (
											count _launcherOptions > 0 &&
											{!_friendlyNearTarget}
										) then {

											private _chosen =
												selectRandom _launcherOptions;

											private _muzzle =
												_chosen select 0;

											private _compatible =
												_chosen select 1;

											private _modes = getArray (
												configFile >>
												"CfgWeapons" >>
												_weapon >>
												_muzzle >>
												"modes"
											);

											private _mode = if (
												count _modes > 0
											) then {
												_modes select 0
											} else {
												"Single"
											};

											if (_mode isEqualTo "this") then {
												_mode = _muzzle;
											};

											private _rounds =
												2 + floor random 2;

											_unit setVariable [
												"PROTOCOL_AI_EXPLOSIVE_NEXT",
												time + 12 + random 8,
												false
											];

											_grp setVariable [
												"PROTOCOL_AI_EXPLOSIVE_GROUP_NEXT",
												time + 3 + random 3,
												false
											];

											[
												_unit,
												_target,
												_weapon,
												_muzzle,
												_compatible,
												_mode,
												_rounds,
												_side
											] spawn {

												params [
													"_unit",
													"_target",
													"_weapon",
													"_muzzle",
													"_compatible",
													"_mode",
													"_rounds",
													"_side"
												];

												if (
													!local _unit ||
													{!alive _unit} ||
													{!alive _target}
												) exitWith {};

												_unit doTarget _target;
												_unit doWatch _target;

												uiSleep 0.5;

												for "_i" from 1 to _rounds do {

													if (
														!alive _unit ||
														{!alive _target} ||
														{!local _unit}
													) exitWith {};

													private _friendlyNear =
														(allUnits findIf {
															alive _x &&
															{
																!(_x isEqualTo _unit)
															} &&
															{
																(
																	_side getFriend
																	(side _x)
																) >= 0.6
															} &&
															{
																_x distance2D
																_target < 16
															}
														}) >= 0;

													if (_friendlyNear) exitWith {};

													private _available = (
														magazinesAmmoFull _unit
													) select {

														(_x select 1) > 0 &&
														{
															(_x select 0) in
															_compatible
														} &&
														{
															[
																_x select 0
															] call
															PROTOCOL_AI_FNC_IS_EXPLOSIVE_MAG
														}
													};

													if (
														count _available == 0
													) exitWith {};

													private _mag =
														(_available select 0)
														select 0;

													_unit selectWeapon [
														_weapon,
														_muzzle,
														_mode
													];

													uiSleep 0.25;

													if (
														alive _unit &&
														{alive _target} &&
														{local _unit}
													) then {

														_unit fire [
															_muzzle,
															_mode,
															_mag
														];
													};

													uiSleep (
														0.9 + random 0.5
													);
												};

												if (
													alive _unit &&
													{local _unit}
												) then {

													private _primaryMuzzles =
														getArray (
															configFile >>
															"CfgWeapons" >>
															_weapon >>
															"muzzles"
														);

													private _primaryMuzzle =
														if (
															count _primaryMuzzles > 0
														) then {
															_primaryMuzzles select 0
														} else {
															_weapon
														};

													if (
														_primaryMuzzle
														isEqualTo "this"
													) then {
														_primaryMuzzle = _weapon;
													};

													_unit selectWeapon
														_primaryMuzzle;
												};
											};
										};
									};
								};
							};
						};
					};

				} forEach units _grp;
			};

		} forEach allGroups;

		sleep PROTOCOL_AI_EXPLOSIVE_SUPPRESSION_CHECK_TIME;
	};
};