
[] spawn
{   
	if (isNil "PROTOCOL_AI_AIRBORNE_ENABLED") then {PROTOCOL_AI_AIRBORNE_ENABLED = true};
	if (isNil "PROTOCOL_AI_AIRBORNE_ENABLED_HELICOPTER") then {PROTOCOL_AI_AIRBORNE_ENABLED_HELICOPTER = true};
	if (isNil "PROTOCOL_AI_AIRBORNE_ENABLED_PLANE") then {PROTOCOL_AI_AIRBORNE_ENABLED_PLANE = true};
    if (isNil "PROTOCOL_AI_AIRBORNE_DISTANCE") then {PROTOCOL_AI_AIRBORNE_DISTANCE = 500};
    if (isNil "PROTOCOL_AI_AIRBORNE_HELICOPTER_HEIGHT") then {PROTOCOL_AI_AIRBORNE_HELICOPTER_HEIGHT = 150};
    if (isNil "PROTOCOL_AI_AIRBORNE_PLANE_HEIGHT") then {PROTOCOL_AI_AIRBORNE_PLANE_HEIGHT = 250};
    if (isNil "PROTOCOL_AI_AIRBORNE_TIME_INTERVAL") then {PROTOCOL_AI_AIRBORNE_TIME_INTERVAL = 2};

_PROTOCOL_AIRBORNE = {
	params ["_grp"];

	if (isNull _grp) exitWith {};

	private _leader = leader _grp;

	if (isNull _leader) exitWith {};

	private _veh = vehicle _leader;

	if (_veh == _leader) exitWith {};
   
    if(PROTOCOL_AI_AIRBORNE_ENABLED_HELICOPTER && PROTOCOL_AI_AIRBORNE_ENABLED_PLANE) then {
	if !(_veh isKindOf "Helicopter" || {_veh isKindOf "Plane"}) exitWith {};
	} 
	else {
		if(PROTOCOL_AI_AIRBORNE_ENABLED_HELICOPTER) then {
			if !(_veh isKindOf "Helicopter") exitWith {};
		};
		if(PROTOCOL_AI_AIRBORNE_ENABLED_PLANE) then {
			if !(_veh isKindOf "Plane") exitWith {};
		};
	};
	
	if (!alive _veh) exitWith {};

	if (_veh getVariable ["dropDone", false]) exitWith {};

	if (_veh isKindOf "Plane") then {
		_veh flyInHeight PROTOCOL_AI_AIRBORNE_PLANE_HEIGHT;
	} else {
		_veh flyInHeight PROTOCOL_AI_AIRBORNE_HELICOPTER_HEIGHT;
	};

	private _enemy = (_veh nearEntities ["Man", PROTOCOL_AI_AIRBORNE_DISTANCE]) select {
		alive _x &&
		{side _x != side _grp}
	};

	if (_enemy isEqualTo []) exitWith {};

	private _cargo = (crew _veh) select {
		alive _x &&
		{vehicle _x == _veh} &&
		{toLower ((assignedVehicleRole _x) param [0, ""]) == "cargo"}
	};

	if (_cargo isEqualTo []) exitWith {};

	private _gunners = (crew _veh) select {
		alive _x &&
		{vehicle _x == _veh} &&
		{toLower ((assignedVehicleRole _x) param [0, ""]) == "turret"}
	};

	{
		_x setCombatMode "RED";
		_x setBehaviour "COMBAT";
		_x setSpeedMode "FULL";
	} forEach _gunners;

	_veh setVariable ["dropDone", true, true];

	[_veh, _gunners, _grp] spawn {
		params ["_veh", "_gunners", "_grp"];

		while {
			alive _veh &&
			{!isNull _veh} &&
			{!(_gunners isEqualTo [])}
		} do {

			private _targets = (_veh nearEntities ["Man", PROTOCOL_AI_AIRBORNE_DISTANCE]) select {
				alive _x &&
				{side _x != side _grp}
			};

			if !(_targets isEqualTo []) then {

				private _target = _targets select 0;

				{
					if (alive _x && {vehicle _x == _veh}) then {
						_x reveal _target;
						_x doTarget _target;
						_x doFire _target;
						_x doWatch _target;
					};
				} forEach _gunners;
			};

			sleep 2;
		};
	};

	{
		if (alive _x && {vehicle _x == _veh}) then {
			_x addBackpack "B_Parachute";
			_x action ["Eject", _veh];
			sleep PROTOCOL_AI_AIRBORNE_TIME_INTERVAL;
		};
	} forEach _cargo;
};



	while {true} do { 
	{
		private _grp = _x;
	   if (!isNull _grp && {count units _grp > 0} && {PROTOCOL_AI_AIRBORNE_ENABLED}) then 
	   {
			[_grp] call _PROTOCOL_AIRBORNE;
	   };
	  } forEach allGroups;
	};
	
};


