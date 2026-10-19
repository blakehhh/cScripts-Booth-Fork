#include "..\script_component.hpp"
/*
 * Author: CPL.Brostrom.A, CPL.Dunn.W (Optimized)
 * This module sets player weapons to safe, pacifies AI, heals players, broadcasts ENDEX, and records attendance.
 *
 * Arguments:
 * 0: modulePos <POSITION>
 * 1: objectPos <OBJECT>
 *
 * Example:
 * [getPos logic, this] call cScripts_fnc_zenModule_callEndex;
 *
 * Public: No
 */

params ["_modulePos", "_objectPos"];

[
    "Call Endex", 
    [
        ["CHECKBOX", ["Set Player Weapons To Safe", ""], true, false],
        ["CHECKBOX", ["Pacify AI", ""], true, false],
        ["CHECKBOX", ["Heal all players", ""], true, false]
    ], 
    {
        params ["_arg", "_pos"];
        _arg params [
            "_weaponsSafe",
            "_aiPacified",
            "_healAllPlayers"
        ];
        _pos params ["_modulePos"];

        // SystemChat Endex message
        "ENDEX ENDEX ENDEX" remoteExecCall ["systemChat", 0];
        "DEBRIEF" remoteExecCall ["systemChat", 0];
        "LEADERS DEBRIEF IN CHANNEL BELOW" remoteExecCall ["systemChat", 0];

        // Hint Endex message
        private _title = "<t color='#ffc61a' size='1.2' shadow='1' shadowColor='#000000' align='center'>ENDEX ENDEX ENDEX!</t><br />";
        private _image = "<img size='5' image='cScripts\Data\Images\7CAV_LOGO_01.paa' align='center'/><br /><br />";
        private _text0 = "<t font='PuristaMedium' size='1.1'>Mission complete</t><br /><br />";
        private _text1 = "Hold your fire and report to your Squad Leaders for debriefing.<br />";
        private _text3 = "<t font='PuristaMedium' size='1.1'>Please safe your weapons if you haven't already!</t>";

        parseText(_title + _text0 + _image + _text1 + _text3) remoteExecCall ["hint", 0];

        // Set Safety to all Players
        if (_weaponsSafe) then {
            {
                private _weapon = currentWeapon player; 
                private _safedWeapons = player getVariable ['ace_safemode_safedWeapons', []]; 
                if !(_weapon in _safedWeapons) then {  
                    [player, currentWeapon player, currentMuzzle player] call ace_safemode_fnc_lockSafety;
                };
            } remoteExecCall ["bis_fnc_call", 0]; 
        };

        if (_healAllPlayers) then {
            {
                [player, player] call ace_medical_treatment_fnc_fullHeal;
            } remoteExecCall ["bis_fnc_call", 0]; 
        };

        // Pacify AI (Run on group owners / local machines)
        if (_aiPacified) then {
            {
                {
                    if (local _x && {side _x != sideLogic} && {!isPlayer (leader _x)}) then {
                        _x setBehaviourStrong "CARELESS";
                        _x setCombatMode "BLUE";
                    };
                } forEach allGroups;
            } remoteExecCall ["bis_fnc_call", 0];
            INFO("ZEN", "AI groups have been set to careless and blue.");
        };

        missionNamespace setVariable [QEGVAR(Mission,Endex), true, true];
        INFO_2("", "Mission var %1 is set %2", QEGVAR(Mission,Endex), missionNamespace getVariable [QEGVAR(Mission,Endex), false]);
        
        [QGVAR(getAttendance)] call CBA_fnc_localEvent;

        ["Endex called (All attended players have been saved to your RPT log)"] call zen_common_fnc_showMessage;
    },
    {},
    [_modulePos]
] call zen_dialog_fnc_create;
