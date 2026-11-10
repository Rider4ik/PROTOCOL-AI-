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
    class PROTOCOL_AI_FPV_REACTION
    {
        name = "PROTOCOL_AI_FPV_REACTION";
        author = "Baiden";
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.00;
        requiredAddons[] = {"A3_Data_F", "cba_xeh"};
    };
};
class Extended_PreInit_EventHandlers
{
    class PROTOCOL_AI_FPV_REACTION
    {
        init = "call compile preprocessFileLineNumbers '\protocol_ai_fpv_reaction\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
    class PROTOCOL_AI_FPV_REACTION
    {
       init ="[] execVM 'protocol_ai_fpv_reaction\functions\fn_fpv_reaction.sqf'";
    };
};

