#include "..\script_component.hpp"
/*
 * Author: Antigravity
 * Adds the Personal Loadout Locker interactions to an object.
 *
 * Arguments:
 * 0: Object <OBJECT>
 * 1: Height Offset <NUMBER or ARRAY> (Optional)
 *
 * Example:
 * [this] call cScripts_fnc_addLoadoutLocker;
 */

params [
    ["_object", objNull, [objNull]],
    ["_heightOffset", 0, [0, []]]
];

if (isNull _object) exitWith {};

// Allow passing a single number for height, or a full 3D offset array
if (_heightOffset isEqualType 0) then {
    _heightOffset = [0, 0, _heightOffset];
};

// Register in missionNamespace locker pool for class-independent respawn checks
private _allLockers = missionNamespace getVariable [QEGVAR(systems,allLockers), []];
_allLockers pushBackUnique _object;
missionNamespace setVariable [QEGVAR(systems,allLockers), _allLockers];

// Ensure object is initialized server-side or globally
if (isServer) then {
    _object setVariable [QEGVAR(systems,locker_owner), "", true];
    _object setVariable [QEGVAR(systems,locker_ownerUID), "", true];
    // Disable the default ACEX Field Rations "Get water from source" action on this box
    _object setVariable ["ace_field_rations_currentWaterSupply", -1, true];
};

if (!hasInterface) exitWith {};

// 1. Claim Locker Action (Visible only when unclaimed)
private _claimAction = [
    QEGVAR(systems,lockerClaim),
    "Claim Locker",
    "",
    {
        params ["_target", "_player"];
        private _claimedLocker = _player getVariable [QEGVAR(systems,claimed_locker), objNull];
        if (isNull _claimedLocker) then {
            private _uid = getPlayerUID _player;
            private _registeredLockers = missionNamespace getVariable [QEGVAR(systems,allLockers), []];
            private _existingLockers = _registeredLockers select {alive _x && {(_x getVariable [QEGVAR(systems,locker_ownerUID), ""]) == _uid}};
            if (_existingLockers isNotEqualTo []) then {
                _claimedLocker = _existingLockers select 0;
                _player setVariable [QEGVAR(systems,claimed_locker), _claimedLocker, true];
            };
        };
        if (!isNull _claimedLocker && {alive _claimedLocker}) exitWith {
            ["You already own a locker! Abandon it first."] call ace_common_fnc_displayTextPicture;
        };
        _target setVariable [QEGVAR(systems,locker_owner), name _player, true];
        _target setVariable [QEGVAR(systems,locker_ownerUID), getPlayerUID _player, true];
        _player setVariable [QEGVAR(systems,claimed_locker), _target, true];
        ["Locker Claimed."] call ace_common_fnc_displayTextPicture;
    },
    { (_target getVariable [QEGVAR(systems,locker_ownerUID), ""]) == "" },
    {},
    [],
    _heightOffset
] call ace_interact_menu_fnc_createAction;
[_object, 0, [], _claimAction] call ace_interact_menu_fnc_addActionToObject;

// 2. Owner Locker Action (Visible only to the owner; opens the GUI)
private _ownerAction = [
    QEGVAR(systems,lockerOwner),
    "Open Locker",
    "cScripts\Data\Icon\icon_00.paa",
    {
        params ["_target", "_player"];
        if (isNull (findDisplay 19100)) then {
            cScripts_ui_currentLocker = _target;
            createDialog "cScripts_RscLoadoutLocker";
        };
    },
    { (_target getVariable [QEGVAR(systems,locker_ownerUID), ""]) == getPlayerUID _player },
    {},
    [],
    _heightOffset,
    4,
    [false, false, false, false, false],
    {
        params ["_target", "_player", "_params", "_actionData"];
        _actionData set [1, format ["Open %1's Locker", _target getVariable [QEGVAR(systems,locker_owner), ""]]];
    }
] call ace_interact_menu_fnc_createAction;
[_object, 0, [], _ownerAction] call ace_interact_menu_fnc_addActionToObject;

// 3. Non-Owner Locker Action (Visible to others who aren't admin, inert display)
private _nonOwnerAction = [
    QEGVAR(systems,lockerNonOwner),
    "Locker",
    "",
    {},
    {
        params ["_target", "_player"];
        private _uid = _target getVariable [QEGVAR(systems,locker_ownerUID), ""];
        private _isAdmin = serverCommandAvailable "#kick" || {!isNull (getAssignedCuratorLogic _player)} || {call BIS_fnc_admin > 0} || {!isMultiplayer} || {is3DENMultiplayer};
        _uid != "" && {_uid != getPlayerUID _player} && {!_isAdmin}
    },
    {},
    [],
    _heightOffset,
    4,
    [false, false, false, false, false],
    {
        params ["_target", "_player", "_params", "_actionData"];
        _actionData set [1, format ["%1's Locker", _target getVariable [QEGVAR(systems,locker_owner), ""]]];
    }
] call ace_interact_menu_fnc_createAction;
[_object, 0, [], _nonOwnerAction] call ace_interact_menu_fnc_addActionToObject;

// 4. Admin Locker Action (Visible to admins and curators on someone else's locker)
private _adminAction = [
    QEGVAR(systems,lockerAdmin),
    "Locker",
    "",
    {},
    {
        params ["_target", "_player"];
        private _uid = _target getVariable [QEGVAR(systems,locker_ownerUID), ""];
        private _isAdmin = serverCommandAvailable "#kick" || {!isNull (getAssignedCuratorLogic _player)} || {call BIS_fnc_admin > 0} || {!isMultiplayer} || {is3DENMultiplayer};
        _uid != "" && {_uid != getPlayerUID _player} && {_isAdmin}
    },
    {
        params ["_target", "_player"];
        private _actions = [];
        private _forceAbandonAction = [
            QEGVAR(systems,forceAbandonLocker),
            "<t color='#FF0000'>Force Abandon (Admin)</t>",
            "",
            {
                params ["_target", "_player"];
                private _ownerName = _target getVariable [QEGVAR(systems,locker_owner), "Unknown"];
                private _targetUID = _target getVariable [QEGVAR(systems,locker_ownerUID), ""];

                _target setVariable [QEGVAR(systems,locker_owner), "", true];
                _target setVariable [QEGVAR(systems,locker_ownerUID), "", true];

                private _ownerIndex = allPlayers findIf {getPlayerUID _x == _targetUID};
                if (_ownerIndex != -1) then {
                    private _ownerUnit = allPlayers select _ownerIndex;
                    _ownerUnit setVariable [QEGVAR(systems,claimed_locker), objNull, true];
                    ["closeDisplay", []] remoteExecCall [QFUNC(loadoutLocker_ui), _ownerUnit];
                };

                if (!isNull (findDisplay 19100)) then {
                    (findDisplay 19100) closeDisplay 1;
                    closeDialog 0;
                };
                missionNamespace setVariable ["cScripts_ui_currentLocker", objNull];

                [format ["Force abandoned %1's locker.", _ownerName]] call ace_common_fnc_displayTextPicture;
            },
            {true}
        ] call ace_interact_menu_fnc_createAction;
        _actions pushBack [_forceAbandonAction, [], _target];
        _actions
    },
    [],
    _heightOffset,
    4,
    [false, false, false, true, false],
    {
        params ["_target", "_player", "_params", "_actionData"];
        _actionData set [1, format ["%1's Locker", _target getVariable [QEGVAR(systems,locker_owner), ""]]];
    }
] call ace_interact_menu_fnc_createAction;
[_object, 0, [], _adminAction] call ace_interact_menu_fnc_addActionToObject;
