#include "BIS_AddonInfo.hpp"


class CfgPatches
{
    class PROTOCOL_AI_ANTI_AIR
    {
        name = "PROTOCOL_AI_ANTI_AIR";
        author = "Baiden";
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.00;
        requiredAddons[] = {"A3_Data_F", "cba_xeh"};
    };
};
class Extended_PreInit_EventHandlers
{
    class PROTOCOL_AI_ANTI_AIR
    {
        init = "call compile preprocessFileLineNumbers '\protocol_ai_anti_air\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
    class PROTOCOL_AI_ANTI_AIR
    {
       init ="[] execVM 'protocol_ai_anti_air\functions\fn_AA.sqf'";
    };
};

