#include "..\script_component.hpp";
/*
 * Author: SGT.Brostrom.A
 * This function apply functions to a player.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * call cScripts_fnc_gear_applyFunctions
 *
 */




// Earplugs
if (EGVAR(Settings,addEarplugs)) then {
    if !([player] call ace_hearing_fnc_hasEarPlugsIn) then {
        [{
            [_this select 0] call ace_hearing_fnc_putInEarplugs;
        }, [player]] call CBA_fnc_execNextFrame;
    };
};


//Server metrics
if ((call BIS_fnc_admin) >= 2) then {
    player addAction ["Server Metrics", {
        [owner player] call FUNC(getServerMetrics);
    }, [], 0, false, true];
};