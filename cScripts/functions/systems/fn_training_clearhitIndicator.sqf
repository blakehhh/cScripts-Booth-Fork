#include "..\script_component.hpp"
/*
 * Author: CPL.Brostrom.A, Ocean.M
 * This function clears a hitIndicator object's markers.
 *
 * Arguments:
 * 0: Object <OBJECT>
 *
 * Example:
 * [cursorTarget] call cScripts_fnc_training_clearhitIndicator;
 */

params [["_object", objNull, [objNull]]];

private _hitmarkers = _object getVariable [QEGVAR(training,hitIndikatorMarkers), _object getVariable [QEGVAR(training,hitMarkers), []]];
if (_hitmarkers isNotEqualTo []) then {
    { deleteVehicle _x } forEach _hitmarkers;
    _object setVariable [QEGVAR(training,hitIndikatorMarkers), []];
    _object setVariable [QEGVAR(training,hitMarkers), []];
};