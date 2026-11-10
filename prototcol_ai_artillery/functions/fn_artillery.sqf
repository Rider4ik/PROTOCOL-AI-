
[] spawn
{   
	if (isNil "PROTOCOL_AI_ARTILLERY_ENABLED") then {PROTOCOL_AI_ARTILLERY_ENABLED = true};
	if (isNil "PROTOCOL_AI_ARTILLERY_RELOCATE") then {PROTOCOL_AI_ARTILLERY_RELOCATE = true};
	if (isNil "PROTOCOL_AI_ARTILLERY_COUNTERBATTERY") then {PROTOCOL_AI_ARTILLERY_COUNTERBATTERY = true};
	if (isNil "PROTOCOL_AI_ARTILLERY_RANDOM_ROUNDS") then {PROTOCOL_AI_ARTILLERY_RANDOM_ROUNDS = true};
	if (isNil "PROTOCOL_AI_ARTILLERY_AMOUNT_ROUND") then {PROTOCOL_AI_ARTILLERY_AMOUNT_ROUND = 5};

	 _PROTOCOL_ARTILLERY = {
	params ["_grp"];

	if (
		isNull _grp ||
		{!alive leader _grp}
	) exitWith {};

	private _artyVehicles = (units _grp apply {vehicle _x}) select {
		alive _x &&
		{
			_x isKindOf "StaticMortar" ||
			_x isKindOf "Tank" ||
			_x isKindOf "Wheeled_APC_F"
		}
	};

	_artyVehicles = _artyVehicles arrayIntersect _artyVehicles;

	if ((count _artyVehicles) == 0) exitWith {};

	{

		private _arty = _x;

		if (!alive _arty) then {continue};

		private _ammoTypes = getArtilleryAmmo [_arty];

		if ((count _ammoTypes) == 0) then {continue};

		private _enemyTargets = [];

		{
			private _enemyGrp = _x;

			if (
				side _enemyGrp != side _grp &&
				{alive leader _enemyGrp}
			) then {

				{
					if (
						alive _x &&
						{(leader _grp knowsAbout _x) > 1.5}
					) then {
						_enemyTargets pushBackUnique _x;
					};
				} forEach units _enemyGrp;

			};

		} forEach allGroups;

		{
			private _friendlyGrp = _x;

			if (
				side _friendlyGrp == side _grp &&
				{_friendlyGrp != _grp}
			) then {

				{

					private _knownEnemies = _x nearTargets 2500;

					{

						private _target = _x select 4;

						if (
							!isNull _target &&
							{alive _target}
						) then {
							_enemyTargets pushBackUnique _target;
						};

					} forEach _knownEnemies;

				} forEach units _friendlyGrp;

			};

		} forEach allGroups;

		if ((count _enemyTargets) == 0) then {continue};

		private _target = selectRandom _enemyTargets;
		private _targetPos = getPosATL _target;

		private _maxRange = 0;

		{

			private _r = _arty getArtilleryETA [_targetPos, _x];

			if (_r >= 0) exitWith {
				_maxRange = 1;
			};

		} forEach _ammoTypes;

		if (_maxRange == 0) then {
            
			 if(PROTOCOL_AI_ARTILLERY_RELOCATE) then {
			private _movePos = [
				_targetPos,
				2500 + random 1000,
				random 360
			] call BIS_fnc_relPos;

			{

				if (
					_x == driver _arty ||
					_x == commander _arty
				) then {
					_x doMove _movePos;
				};

			} forEach crew _arty;

			waitUntil {
				sleep 5;
				(_arty distance2D _movePos < 120) ||
				!alive _arty
			};
			};

		};

		private _selectedAmmo = selectRandom _ammoTypes;

		if (_arty getArtilleryETA [_targetPos, _selectedAmmo] >= 0) then {
            
			if(PROTOCOL_AI_ARTILLERY_RANDOM_ROUNDS) then {
			private _rounds = 1 + random 10;
			}
		    else
			{
              private _rounds = PROTOCOL_AI_ARTILLERY_AMOUNT_ROUND;
			};
			_arty doArtilleryFire [
				_targetPos,
				_selectedAmmo,
				_rounds
			];
              
			sleep (20 + random 15);
            if(PROTOCOL_AI_ARTILLERY_RELOCATE) then {
			private _displacePos = [
				getPosATL _arty,
				400 + random 600,
				random 360
			] call BIS_fnc_relPos;

			{

				if (
					_x == driver _arty ||
					_x == commander _arty
				) then {
					_x doMove _displacePos;
				};

			} forEach crew _arty;
		    };

            if(PROTOCOL_AI_ARTILLERY_COUNTERBATTERY) then {
			private _counterBattery = [];

			{

				private _enemyGrp = _x;

				if (side _enemyGrp != side _grp) then {

					{

						private _veh = vehicle _x;

						if (
							alive _veh &&
							{_veh distance2D _arty < 7000}
						) then {

							private _enemyAmmo = getArtilleryAmmo [_veh];

							if ((count _enemyAmmo) > 0) then {
								_counterBattery pushBackUnique _veh;
							};

						};

					} forEach units _enemyGrp;

				};

			} forEach allGroups;

			{

				private _enemyArty = _x;

				private _enemyAmmo = getArtilleryAmmo [_enemyArty];

				if ((count _enemyAmmo) > 0) then {

					private _ammo = selectRandom _enemyAmmo;

					if (
						_enemyArty getArtilleryETA [getPosATL _arty, _ammo] >= 0
					) then {

						_enemyArty doArtilleryFire [
							getPosATL _arty,
							_ammo,
							2 + floor random 3
						];

					};

				};

			} forEach _counterBattery;
		  };
		};

	} forEach _artyVehicles;

};


	while {true} do { 
	{
		private _grp = _x;
	    if (!isNull _grp && {count units _grp > 0} && {PROTOCOL_AI_ARTILLERY_ENABLED}) then {
			[_grp] call _PROTOCOL_ARTILLERY;
	   };
	  } forEach allGroups;
	};
	
};


