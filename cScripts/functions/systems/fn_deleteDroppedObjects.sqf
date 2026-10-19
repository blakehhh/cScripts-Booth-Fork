#include "..\script_component.hpp"
/*
 * This function deletes objects and junk on the ground in a given radius.
 *
 * Arguments:
 * 0: Object
 * 1: Radius
 *
 * Example:
 * [this, 15] call cScripts_fnc_deleteDroppedObjects
 * [_object, 15] call cScripts_fnc_deleteDroppedObjects
 */

params [
    ["_object", objNull, [objNull]],
    ["_radius", 15, [0]]
];

if (isNull _object) exitWith {};
if (_object getVariable [QGVAR(hasDeleteDroppedEH), false]) exitWith {};
_object setVariable [QGVAR(hasDeleteDroppedEH), true];

[_object, "ContainerClosed", {
    params ["_object"];
    [{
        params ["_object", "_radius"];
        if (isNull _object) exitWith {};
        if ((_object nearEntities ["Man", _radius]) isEqualTo []) then {
            private _holders = nearestObjects [_object, ["WeaponHolder", "GroundWeaponHolder", "GroundWeaponHolder_Scripted"], _radius];
            {
                if (!local _x) then {
                    [_x] remoteExecCall ["deleteVehicle", 2];
                } else {
                    deleteVehicle _x;
                };
            } forEach _holders;
        };
    }, [_object, _thisArgs], 120] call CBA_fnc_waitAndExecute;
}, _radius] call CBA_fnc_addBISEventHandler;