#include "BIS_AddonInfo.hpp"


class CfgPatches
{
    class PROTOCOL_AI_AIRCRAFT
    {
        name = "PROTOCOL_AI_AIRCRAFT";
        author = "Baiden";
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.00;
        requiredAddons[] = {"A3_Data_F", "cba_xeh"};
    };
};
class Extended_PreInit_EventHandlers
{
    class PROTOCOL_AI_AIRCRAFT
    {
        init = "call compile preprocessFileLineNumbers '\protocol_ai_aircraft\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
    class PROTOCOL_AI_AIRCRAFT
    {
       init ="[] execVM 'protocol_ai_aircraft\functions\fn_aircraft.sqf'";
    };
};

