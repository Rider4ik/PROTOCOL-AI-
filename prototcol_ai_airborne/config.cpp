#include "BIS_AddonInfo.hpp"
/*
class CfgPatches {
    class PROTOCOL_AI_CQB {
        name = "PROTOCOL AI CQB";
        author = "Baiden";
        requiredVersion = 1.00;
        requiredAddons[] = { "A3_Functions_F" };
        units[] = {};
        weapons[] = {};
    };
};

class CfgFunctions {
    class Baiden {
        class PROTOCOL_AI_CQB {
            file = "\prototcol_ai_cqb\functions";
            class CQB {postInit = 1;};
        };
    };
};
*/

class CfgPatches
{
    class PROTOCOL_AI_AIRBORNE
    {
        name = "PROTOCOL_AI_AIRBORNE";
        author = "Baiden";
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.00;
        requiredAddons[] = {"A3_Data_F", "cba_xeh"};
    };
};
class Extended_PreInit_EventHandlers
{
    class PROTOCOL_AI_AIRBORNE
    {
        init = "call compile preprocessFileLineNumbers '\prototcol_ai_airborne\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
    class PROTOCOL_AI_AIRBORNE
    {
       init ="[] execVM 'prototcol_ai_airborne\functions\fn_airborne.sqf'";
    };
};

