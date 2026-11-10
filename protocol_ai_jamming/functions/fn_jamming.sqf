
[] spawn
{   if (isNil "PROTOCOL_AI_JAMMING_ENABLED") then {PROTOCOL_AI_JAMMING_ENABLED = true};
    if (isNil "PROTOCOL_AI_JAMMING_RADIUS") then {PROTOCOL_AI_JAMMING_RADIUS = 200};
    if (isNil "PROTOCOL_AI_JAMMING_VOICE_CHAT") then {PROTOCOL_AI_JAMMING_VOICE_CHAT = true};
    if (isNil "PROTOCOL_AI_JAMMING_CHANNELS") then {PROTOCOL_AI_JAMMING_CHANNELS = true};
    if (isNil "PROTOCOL_AI_TFAR_JAMMING") then {PROTOCOL_AI_TFAR_JAMMING = true};
    if (isNil "PROTOCOL_AI_JAMMING_DRONES") then {PROTOCOL_AI_JAMMING_DRONES = true};
    if (isNil "PROTOCOL_AI_JAMMING_SOUND_EFFECT") then {PROTOCOL_AI_JAMMING_SOUND_EFFECT = true};
	if (isNil "PROTOCOL_AI_JAMMING_RADIO") then {PROTOCOL_AI_JAMMING_RADIO = true};

	private _isRadar = {
        params ["_obj"];

        if (isNull _obj || {!alive _obj} || {_obj isKindOf "Air"}) exitWith {false};

        private _cfg = configFile >> "CfgVehicles" >> typeOf _obj;
        private _radarType = getNumber (_cfg >> "radarType");
        private _sensors = [];

        if (_obj isKindOf "AllVehicles" && {isClass (_cfg >> "Components" >> "SensorsManagerComponent" >> "Components")}) then {
            _sensors = listVehicleSensors _obj;
        };

        private _hasRadarSensor = _sensors findIf {
            (_x select 1) in ["ActiveRadarSensorComponent","PassiveRadarSensorComponent"]
        } > -1;

        private _className = toLower (typeOf _obj);
        private _displayName = toLower getText (_cfg >> "displayName");
        private _radarName = false;

        {
            if ((_className find _x > -1) || {(_displayName find _x > -1)}) exitWith {
                _radarName = true;
            };
        } forEach [
            "radar",
            "rls",
            "рлс",
            "радар",
            "рэб",
            "reb",
            "ew_",
            "r-14n2",
            "r-14",
            "r-142",
            "r-145",
            "p-18",
            "p-19"
        ];

        _hasRadarSensor || {
            _radarType in [1,2,4,8]
        } || {
            _radarName
        }
    };

    private _disableComms = {
        params ["_unit"];

        if (isNull _unit || {!alive _unit} || {!isPlayer _unit}) exitWith {};

        if (!(_unit getVariable ["ew_comms_blocked", false])) then {

            _unit setVariable ["ew_comms_blocked", true];
            
			if(PROTOCOL_AI_TFAR_JAMMING) then {
            _unit setVariable ["ew_saved_tf_globalVolume", _unit getVariable ["tf_globalVolume", 1]];
            _unit setVariable ["ew_saved_tf_send", _unit getVariable ["tf_sendingDistanceMultiplicator", 1]];
            _unit setVariable ["ew_saved_tf_receive", _unit getVariable ["tf_receivingDistanceMultiplicator", 1]];
			};
			IF(PROTOCOL_AI_ACRE_JAMMING) then {
            _unit setVariable ["ew_saved_acre_send", _unit getVariable ["acre_send_power", 1]];
            _unit setVariable ["ew_saved_acre_receive", _unit getVariable ["acre_receive_power", 1]];
			};
            
			if(PROTOCOL_AI_JAMMING_RADIO) then {
			enableRadio false;
			};
			if(PROTOCOL_AI_JAMMING_CHANNELS) then {
			showChat false;
            {
                _unit enableChannel [_x, false];
            } forEach [0,1,2,3,4,5,6,7,8,9];
			};
			if(PROTOCOL_AI_TFAR_JAMMING) then {
            _unit setVariable ["tf_unable_to_use_radio", true];
            _unit setVariable ["tf_sendingDistanceMultiplicator", 0];
            _unit setVariable ["tf_receivingDistanceMultiplicator", 0];
            _unit setVariable ["tf_globalVolume", 0];
			_unit setVariable ["tf_unable_to_use_radio", true, true];
			};
			if(PROTOCOL_AI_ACRE_JAMMING) then {
            _unit setVariable ["acre_send_power", 0, true];
            _unit setVariable ["acre_receive_power", 0, true];
			};

            if(PROTOCOL_AI_JAMMING_SOUND_EFFECT) then {
            if (!(_unit getVariable ["ew_radioNoiseActive", false])) then {
                _unit setVariable ["ew_radioNoiseActive", true];

                [_unit] spawn {
                    params ["_unit"];

                    private _sounds = [
                        "A3\Sounds_F\sfx\radio\ambient_radio1.wss",
                        "A3\Sounds_F\sfx\radio\ambient_radio2.wss",
                        "A3\Sounds_F\sfx\radio\ambient_radio3.wss",
                        "A3\Sounds_F\sfx\radio\ambient_radio6.wss",
                        "A3\Sounds_F\sfx\radio\ambient_radio8.wss"
                    ];

                    while {
                        alive _unit &&
                        {_unit getVariable ["ew_comms_blocked", false]} &&
                        {isPlayer _unit}
                    } do {
                        playSoundUI [
                            selectRandom _sounds,
                            0.20 + random 0.18,
                            0.90 + random 0.20
                        ];

                        sleep (0.18 + random 0.35);
                    };

                    _unit setVariable ["ew_radioNoiseActive", false];
                };
            };
		};
        };
    };

    private _enableComms = {
        params ["_unit"];

        if (isNull _unit) exitWith {};

        if (_unit getVariable ["ew_comms_blocked", false]) then {

            _unit setVariable ["ew_comms_blocked", false];
             
			 if (PROTOCOL_AI_JAMMING_RADIO) then {
			 enableRadio true;
			};
			if(PROTOCOL_AI_JAMMING_CHANNELS) then {
            showChat true;
            {
                _unit enableChannel [_x, true];
            } forEach [0,1,2,3,4,5,6,7,8,9];
			};
            if(PROTOCOL_AI_TFAR_JAMMING) then {
            _unit setVariable [
                "tf_unable_to_use_radio",
                false
            ];

            _unit setVariable [
                "tf_sendingDistanceMultiplicator",
                _unit getVariable ["ew_saved_tf_send", 1]
            ];

            _unit setVariable [
                "tf_receivingDistanceMultiplicator",
                _unit getVariable ["ew_saved_tf_receive", 1]
            ];

            _unit setVariable [
                "tf_globalVolume",
                _unit getVariable ["ew_saved_tf_globalVolume", 1]
            ];
			_unit setVariable ["tf_unable_to_use_radio", false, true];
			};
             if(PROTOCOL_AI_ACRE_JAMMING) then {
            _unit setVariable [
                "acre_send_power",
                _unit getVariable ["ew_saved_acre_send", 1],
                true
            ];

            _unit setVariable [
                "acre_receive_power",
                _unit getVariable ["ew_saved_acre_receive", 1],
                true
            ];
			_unit setVariable ["ew_saved_tf_globalVolume", nil];
            _unit setVariable ["ew_saved_tf_send", nil];
            _unit setVariable ["ew_saved_tf_receive", nil];
            _unit setVariable ["ew_saved_acre_send", nil];
            _unit setVariable ["ew_saved_acre_receive", nil];
			};
            

            
        };
    };

    while {true} do {
		
		if (PROTOCOL_AI_JAMMING_ENABLED) then {

        private _radars = vehicles select {
            [_x] call _isRadar
        };

        if (PROTOCOL_AI_JAMMING_DRONES) then {
            {
                private _radar = _x;

                if (alive _radar) then {

                    private _radarSide = side _radar;

                    private _uavs = vehicles select {
                        alive _x &&
                        {unitIsUAV _x} &&
                        {_x distance _radar < PROTOCOL_AI_JAMMING_RADIUS} &&
                        {side _x != _radarSide}
                    };

                    {
                        private _uav = _x;

                        if (alive _uav && {!(_uav getVariable ["ew_active", false])}) then {

                            _uav setVariable ["ew_active", true, true];

                            [_uav, _radar] spawn {
                                params ["_uav","_radar"];

                                private _noise = "#particlesource" createVehicleLocal (getPosATL _uav);

                                _noise setParticleParams [
                                    ["\A3\data_f\ParticleEffects\Universal\Universal",16,12,13,0],
                                    "",
                                    "Billboard",
                                    1,
                                    0.3,
                                    [0,0,0],
                                    [0,0,0],
                                    1,
                                    1,
                                    1,
                                    0,
                                    [0.5,1,1.5],
                                    [
                                        [0.7,0.7,0.7,0.15],
                                        [1,1,1,0.05],
                                        [1,1,1,0]
                                    ],
                                    [1],
                                    1,
                                    0,
                                    "",
                                    "",
                                    _uav
                                ];

                                _noise setParticleRandom [
                                    0,
                                    [1,1,1],
                                    [3,3,3],
                                    0,
                                    0.2,
                                    [0,0,0,0],
                                    0,
                                    0
                                ];

                                _noise setDropInterval 0.005;

                                private _crew = crew _uav;

                                {
                                    _x disableAI "MOVE";
                                    _x disableAI "PATH";
                                    _x disableAI "TARGET";
                                    _x disableAI "AUTOTARGET";
                                } forEach _crew;

                                private _isPlane = _uav isKindOf "Plane";

                                while {
                                    alive _uav &&
                                    {alive _radar} &&
                                    {_uav distance _radar < PROTOCOL_AI_JAMMING_RADIUS}
                                } do {

                                    private _pos = getPos _uav;
                                    private _vel = velocity _uav;

                                    if (_isPlane) then {

                                        _uav engineOn false;

                                        _uav setVelocity [
                                            (_vel select 0) * 0.98,
                                            (_vel select 1) * 0.98,
                                            (_vel select 2) - 0.2
                                        ];

                                    } else {

                                        if ((_pos select 2) > 1.5) then {

                                            _uav setVelocity [
                                                (_vel select 0) * 0.8,
                                                (_vel select 1) * 0.8,
                                                -2.5
                                            ];

                                            _uav setVectorUp [0,0,1];
                                            _uav setDir ((getDir _uav) + 1);
                                            _uav engineOn false;

                                        } else {

                                            _uav setVelocity [0,0,-0.1];
                                            _uav setVectorUp surfaceNormal _pos;
                                            _uav engineOn false;
                                        };
                                    };

                                    sleep 0.1;
                                };

                                deleteVehicle _noise;

                                _uav setVariable ["ew_active", false, true];

                                if (alive _uav) then {
                                    {
                                        _x enableAI "MOVE";
                                        _x enableAI "PATH";
                                        _x enableAI "TARGET";
                                        _x enableAI "AUTOTARGET";
                                    } forEach _crew;
                                };
                            };
                        };
                    } forEach _uavs;
                };
            } forEach _radars;
        };

        {
            private _unit = _x;

            if (local _unit && {alive _unit} && {!(_unit isKindOf "UAV")}) then {

                private _isJammed = false;

                {
                    if (
                        alive _x &&
                        {side _x != side group _unit} &&
                        {_unit distance _x < PROTOCOL_AI_JAMMING_RADIUS}
                    ) exitWith {
                        _isJammed = true;
                    };
                } forEach _radars;

                if (_isJammed) then {
                    [_unit] call _disableComms;
                } else {
                    [_unit] call _enableComms;
                };
            };

        } forEach allUnits;

        sleep 1;
    };
  };
	
};


