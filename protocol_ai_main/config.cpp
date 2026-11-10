#include "BIS_AddonInfo.hpp"


class CfgPatches
{
    class PROTOCOL_AI
    {
        name = "PROTOCOL_AI";
        author = "Baiden";
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.00;
        requiredAddons[] = {"A3_Data_F", "cba_xeh"};
    };
};
class Extended_PreInit_EventHandlers
{
    class PROTOCOL_AI
    {
        init = "call compile preprocessFileLineNumbers '\protocol_ai_main\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
    class PROTOCOL_AI
    {
       init ="[] execVM 'protocol_ai_main\functions\protocol.sqf'";
    };
};

