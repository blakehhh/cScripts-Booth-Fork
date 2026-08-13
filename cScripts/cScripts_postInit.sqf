#include "script_component.hpp";
/*
 * Author: CPL.Brostrom.A
 * This is the rules set for the mission using the cba XEH. Each setting here is alterd via cbaSettings
 */
if (is3DEN) exitWith {};

INFO("postInit", "Initializing...");


// item replacement
if (EGVAR(Settings,allowReplaceItem)) then {
    call EFUNC(init,aceItemReplace);
};


// messages 
call EFUNC(init,message);

// diary records
if (EGVAR(Settings,showDiaryRecords)) then {
    call EFUNC(init,diary);
};



INFO("postInit", "Initialization completed.");
