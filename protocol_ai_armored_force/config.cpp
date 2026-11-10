#include "BIS_AddonInfo.hpp"


class CfgPatches
{
    class PROTOCOL_AI_ARMORED_FORCE
    {
        name = "PROTOCOL_AI_ARMORED_FORCE";
        author = "Baiden";
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.00;
        requiredAddons[] = {"A3_Data_F", "cba_xeh"};
    };
};

class Extended_PreInit_EventHandlers
{
    class PROTOCOL_AI_ARMORED_FORCE
    {
        init = "call compile preprocessFileLineNumbers'\protocol_ai_armored_force\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
    class PROTOCOL_AI_ARMORED_FORCE
    {
       init ="[] execVM 'protocol_ai_armored_force\functions\fn_armored_force.sqf'";
    };
};


