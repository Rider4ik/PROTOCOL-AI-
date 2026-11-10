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
    class PROTOCOL_AI_JAMMING
    {
        name = "PROTOCOL_AI_CQB";
        author = "Baiden";
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.00;
        requiredAddons[] = {"A3_Data_F", "cba_xeh"};
    };
};
class Extended_PreInit_EventHandlers
{
    class PROTOCOL_AI_JAMMING
    {
        init = "call compile preprocessFileLineNumbers '\protocol_ai_jamming\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
    class PROTOCOL_AI_JAMMING
    {
       init ="[] execVM 'protocol_ai_jamming\functions\fn_jamming.sqf'";
    };
};

