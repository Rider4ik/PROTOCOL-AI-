#include "BIS_AddonInfo.hpp"


class CfgPatches
{
    class PROTOCOL_AI_RAPPELING
    {
        name = "PROTOCOL_AI_RAPPELING";
        author = "Baiden";
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.00;
        requiredAddons[] = {"A3_Data_F", "cba_xeh"};
    };
};
class Extended_PreInit_EventHandlers
{
    class PROTOCOL_AI_RAPPELING
    {
        init = "call compile preprocessFileLineNumbers '\protocol_ai_rappeling\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
    class PROTOCOL_AI_RAPPELING
    {
       init ="[] execVM 'protocol_ai_rappeling\functions\fn_rappeling.sqf'";
    };
};

