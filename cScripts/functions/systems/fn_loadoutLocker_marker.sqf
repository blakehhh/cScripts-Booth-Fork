#include "..\script_component.hpp"
/*
 * Author: Antigravity
 * Manages the local 3D visual indicator above a player's claimed loadout locker.
 *
 * Arguments:
 * 0: Mode <STRING> ("create", "delete", "update")
 * 1: Parameters <ARRAY> (Optional)
 *
 * Return Value:
 * None
 *
 * Example:
 * ["create", [_locker]] call cScripts_fnc_loadoutLocker_marker;
 */

params [
    ["_mode", "update", [""]],
    ["_params", [], [[]]]
];

if (!hasInterface) exitWith {};

switch (_mode) do {
    case "create": {
        _params params [["_locker", objNull, [objNull]]];
        if (isNull _locker || {!alive _locker}) exitWith {};

        // Clean up any existing marker first
        ["delete"] call FUNC(loadoutLocker_marker);

        private _markerHeight = _locker getVariable [QEGVAR(systems,markerHeight), 0.95];

        private _marker = "Sign_Sphere25cm_F" createVehicleLocal [0, 0, 0];
        _marker allowDamage false;
        _marker setObjectTexture [0, "#(argb,8,8,3)color(0.408,0.671,0.333,0.15,ca)"];
        _marker attachTo [_locker, [0, 0, _markerHeight]];
        _marker setObjectScale 0.45;
        _marker hideObject ((player distance _locker) > 25);

        missionNamespace setVariable [QGVAR(loadoutLocker_marker), _marker];

        // Hide marker when further than 25m away
        private _pfh = [{
            params ["_args", "_handle"];
            _args params ["_marker", "_locker"];
            if (isNull _marker || {isNull _locker} || {!alive _locker}) exitWith {
                [_handle] call CBA_fnc_removePerFrameHandler;
                if (!isNull _marker) then { deleteVehicle _marker; };
                missionNamespace setVariable [QGVAR(loadoutLocker_marker), objNull];
                missionNamespace setVariable [QGVAR(loadoutLocker_markerPFH), -1];
            };

            private _shouldHide = (player distance _locker) > 25;
            if (isObjectHidden _marker isNotEqualTo _shouldHide) then {
                _marker hideObject _shouldHide;
            };
        }, 0.5, [_marker, _locker]] call CBA_fnc_addPerFrameHandler;

        missionNamespace setVariable [QGVAR(loadoutLocker_markerPFH), _pfh];
    };

    case "delete": {
        private _marker = missionNamespace getVariable [QGVAR(loadoutLocker_marker), objNull];
        if (!isNull _marker) then {
            detach _marker;
            deleteVehicle _marker;
        };
        missionNamespace setVariable [QGVAR(loadoutLocker_marker), objNull];

        private _pfh = missionNamespace getVariable [QGVAR(loadoutLocker_markerPFH), -1];
        if (_pfh != -1) then {
            [_pfh] call CBA_fnc_removePerFrameHandler;
            missionNamespace setVariable [QGVAR(loadoutLocker_markerPFH), -1];
        };
    };

    case "update": {
        private _claimedLocker = player getVariable [QEGVAR(systems,claimed_locker), objNull];
        if (isNull _claimedLocker || {!alive _claimedLocker}) then {
            private _uid = getPlayerUID player;
            private _registeredLockers = missionNamespace getVariable [QEGVAR(systems,allLockers), []];
            private _existingLockers = _registeredLockers select {alive _x && {(_x getVariable [QEGVAR(systems,locker_ownerUID), ""]) == _uid}};
            if (_existingLockers isNotEqualTo []) then {
                _claimedLocker = _existingLockers select 0;
                player setVariable [QEGVAR(systems,claimed_locker), _claimedLocker, true];
            };
        };

        if (!isNull _claimedLocker && {alive _claimedLocker}) then {
            ["create", [_claimedLocker]] call FUNC(loadoutLocker_marker);
        } else {
            ["delete"] call FUNC(loadoutLocker_marker);
        };
    };
};
