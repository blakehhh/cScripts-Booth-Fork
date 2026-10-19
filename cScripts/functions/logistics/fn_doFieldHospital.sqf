#include "..\script_component.hpp"
/*
 * Author: CPL.Brostrom.A, SPC.Turn.J
 * This script creates the 7th Cavalry field hospital.
 * It adds equipment and some optional selections to a given object.
 *
 * Arguments:
 * 0: Crate <OBJECT>
 * 1: Medical Facility <BOOL> (Default: true)
 * 2: Scale cargo ammount <NUMBER> (Default: 1)
 *
 * Example:
 * [this] call cScripts_fnc_doFieldHospital;
 * [this, true, 1] call cScripts_fnc_doFieldHospital;
 */

params [
    ["_crate", objNull, [objNull]],
    ["_isFacility", true]
];

INFO("", "Field Hospital applied to %1.", _crate);

// Make addAction Topic
_crate addAction ["<img image='cScripts\Data\Icon\icon_00.paa' /> Field Hospital", {}, [], 1.5, true, true, "", "true", 5];

if (_isFacility) then {
    _crate setVariable ["ace_medical_isMedicalFacility", true, true];
};

// If isServer add medical equipment and set ACE attributes locally
if (isServer) then {
    private _crateContent = ["crate_medicalAtlas"] call EFUNC(logistics,getContainer);
    [_crate, _crateContent] call FUNC(setCargo);

    [_crate, 1] call ace_cargo_fnc_setSize;
    [_crate, true] call ace_dragging_fnc_setDraggable;
    [_crate, true] call ace_dragging_fnc_setCarryable;
};
