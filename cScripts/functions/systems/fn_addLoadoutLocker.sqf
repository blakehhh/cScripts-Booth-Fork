#include "..\script_component.hpp"
/*
 * Author: Antigravity
 * Adds the Personal Loadout Locker interactions to an object.
 *
 * Arguments:
 * 0: Object <OBJECT>
 *
 * Example:
 * [this] call cScripts_fnc_addLoadoutLocker
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

// Ensure object is initialized server-side or globally
if (isServer) then {
    _object setVariable [QEGVAR(systems,locker_owner), "", true];
    _object setVariable [QEGVAR(systems,locker_ownerUID), "", true];
};

// Disable the default ACEX Field Rations "Get water from source" action on this box
_object setVariable ["ace_field_rations_currentWaterSupply", -1, true];

if (!hasInterface) exitWith {};

// 1. Claim Locker Action (Visible only when unclaimed)
private _claimAction = [
    QEGVAR(systems,lockerClaim),
    "Claim Locker",
    "",
    {
        params ["_target", "_player"];
        private _claimedLocker = _player getVariable [QEGVAR(systems,claimed_locker), objNull];
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

// 2. Owner Locker Action (Visible only to the owner, contains all menus)
private _ownerAction = [
    QEGVAR(systems,lockerOwner),
    "Locker", // Modified by modifierFunc
    "",
    {},
    { (_target getVariable [QEGVAR(systems,locker_ownerUID), ""]) == getPlayerUID _player },
    {
        params ["_target", "_player"];
        private _actions = [];
        
        private _fnc_createKitAction = {
            params ["_actionName", "_displayName", "_targetPreset"];
            [
                _actionName,
                _displayName,
                "",
                {
                    params ["_target", "_player", "_params"];
                    _params params ["_targetPreset"];
                    private _savedLoadouts = profileNamespace getVariable ["ace_arsenal_saved_loadouts", []];
                    private _loadoutIndex = _savedLoadouts findIf {(_x select 0) == _targetPreset};
                    
                    if (_loadoutIndex != -1) then {
                        private _loadoutData = (_savedLoadouts select _loadoutIndex) select 1;
                        private _vanillaLoadout = _loadoutData;
                        if (_loadoutData isEqualType [] && {count _loadoutData > 0} && {(_loadoutData select 0) isEqualType []}) then {
                            _vanillaLoadout = _loadoutData select 0;
                        };
                        [_player, _vanillaLoadout] call CBA_fnc_setLoadout;
                        [_player] call EFUNC(gear,saveLoadout);
                        [format ["Equipped %1.", _targetPreset]] call ace_common_fnc_displayTextPicture;
                    } else {
                        [format ["Missing '%1' preset in your ACE Arsenal!", _targetPreset]] call ace_common_fnc_displayTextPicture;
                    };
                },
                {true},
                {},
                [_targetPreset]
            ] call ace_interact_menu_fnc_createAction;
        };

        _actions pushBack [[QEGVAR(systems,equipCombat), "Equip Combat Kit", "Combat Kit"] call _fnc_createKitAction, [], _target];
        _actions pushBack [[QEGVAR(systems,equipRecon), "Equip Recon Kit", "Recon Kit"] call _fnc_createKitAction, [], _target];
        _actions pushBack [[QEGVAR(systems,equipCasual), "Equip Casual Kit", "Casual Kit"] call _fnc_createKitAction, [], _target];
        
        private _arsenalAction = [
            QEGVAR(systems,lockerArsenal),
            "TFG Arsenal",
            "cScripts\Data\Icon\icon_arsenal_ca.paa",
            {
                call FUNC(clearDefaultArsenalLoadouts);
                waitUntil { count ace_arsenal_defaultLoadoutsList == 0 };
                call FUNC(addDefaultArsenalLoadout);
                waitUntil { count ace_arsenal_defaultLoadoutsList != 0 };

                [player, true] call ace_arsenal_fnc_addVirtualItems;
                
                private _blacklist = GVAR(BLACKLIST);
                [player, _blacklist, false] call ace_arsenal_fnc_removeVirtualItems;

                [{
                    [player, player, false] call ace_arsenal_fnc_openBox;
                    [QEGVAR(StagingArsenal,displayOpen)] call CBA_fnc_localEvent;
                    [{
                        private _loadout = [player] call EFUNC(gear,getLoadoutName);
                        private _name = getText (missionConfigFile >> "CfgLoadouts" >> _loadout >> "displayName");
                        private _company = getText (missionConfigFile >> "CfgLoadouts" >> _loadout >> "company");
                        [(findDisplay 1127001), format["Arsenal for %1 Co. %2 loaded", [_company] call CBA_fnc_capitalize, _name]] call ace_arsenal_fnc_message;
                    }, [], 0.35] call CBA_fnc_waitAndExecute;
                }] call CBA_fnc_execNextFrame;
            },
            {true}
        ] call ace_interact_menu_fnc_createAction;
        _actions pushBack [_arsenalAction, [], _target];
        
        private _utilityCategory = [
            QEGVAR(systems,lockerUtility),
            "Utility",
            "",
            {},
            {true},
            {
                params ["_target", "_player"];
                private _utilActions = [];
                
                private _healAction = [
                    QEGVAR(systems,lockerHeal),
                    "Heal",
                    "\z\ACE\addons\medical_gui\ui\cross.paa",
                    {
                        [_this select 0, player] call ace_medical_treatment_fnc_fullHeal;
                        [[],["You have been healed"], [""], [""]] call CBA_fnc_notify;
                    },
                    {!GVAR(OneLife)}
                ] call ace_interact_menu_fnc_createAction;
                _utilActions pushBack [_healAction, [], _target];

                private _eatAction = [
                    QEGVAR(systems,lockerEat),
                    "Eat Food and Drink Water",
                    "\z\ace\addons\field_rations\ui\icon_survival.paa",
                    {
                        params ["_target", "_player"];
                        private _anim = [_player, _target] call ace_field_rations_fnc_getDrinkAnimation;
                        _player setVariable ["ace_field_rations_previousAnim", animationState _player];
                        [_player, _anim, 1] call ace_common_fnc_doAnimation;

                        [10, [_player], {
                            params ["_args"];
                            _args params ["_player"];
                            _player setVariable ["acex_field_rations_hunger", 0, true];
                            _player setVariable ["acex_field_rations_thirst", 0, true];
                            systemChat "You have eaten a meal and drank water.";
                            _player setVariable ["ace_field_rations_previousAnim", nil];
                        }, {
                            params ["_args"];
                            _args params ["_player"];
                            systemChat "You stopped eating and drinking.";
                            if (isNull objectParent _player && {!(_player call ace_common_fnc_isSwimming)}) then {
                                private _prevAnim = _player getVariable ["ace_field_rations_previousAnim", ""];
                                if (_prevAnim != "") then {
                                    [_player, _prevAnim, 2] call ace_common_fnc_doAnimation;
                                };
                            };
                            _player setVariable ["ace_field_rations_previousAnim", nil];
                        }, "Eating and Drinking...", {true}, ["isNotInside"]] call ace_common_fnc_progressBar;
                    },
                    {true}
                ] call ace_interact_menu_fnc_createAction;
                _utilActions pushBack [_eatAction, [], _target];
                
                private _roleCategory = [
                    QEGVAR(systems,lockerRoles),
                    "Retrieve Permissions",
                    "",
                    {},
                    {true},
                    {
                        params ["_target", "_player"];
                        private _roleActions = [];
                        
                        _roleActions pushBack [[QEGVAR(systems,roleCLS), "Combat Lifesaver (CLS)", "\z\ace\addons\medical_gui\ui\cross.paa", {
                            player setVariable ["ace_medical_medicClass", 1, true]; systemChat "You are now a Combat Lifesaver (CLS).";
                        }, {true}] call ace_interact_menu_fnc_createAction, [], _target];
                        
                        _roleActions pushBack [[QEGVAR(systems,roleMedic), "Medic", "\z\ace\addons\medical_gui\ui\cross.paa", {
                            player setVariable ["ace_medical_medicClass", 2, true]; systemChat "You are now a Medic (Doctor).";
                        }, {true}] call ace_interact_menu_fnc_createAction, [], _target];
                        
                        _roleActions pushBack [[QEGVAR(systems,roleEOD), "Explosive/Demo Specialist", "\z\ace\addons\explosives\UI\Defuse_ca.paa", {
                            player setVariable ["ACE_isEOD", true, true]; systemChat "You are now an Explosive/Demo Specialist.";
                        }, {true}] call ace_interact_menu_fnc_createAction, [], _target];
                        
                        _roleActions pushBack [[QEGVAR(systems,roleEngineer), "Engineer", "\a3\ui_f\data\IGUI\Cfg\Actions\repair_ca.paa", {
                            player setVariable ["ace_isEngineer", 2, true]; systemChat "You are now an Advanced Engineer.";
                        }, {true}] call ace_interact_menu_fnc_createAction, [], _target];
                        
                        _roleActions pushBack [[QEGVAR(systems,roleRemoveAll), "Remove All Roles", "", {
                            player setVariable ["ace_medical_medicClass", 0, true];
                            player setVariable ["ACE_isEOD", false, true];
                            player setVariable ["ace_isEngineer", 0, true];
                            systemChat "All role permissions have been removed.";
                        }, {true}] call ace_interact_menu_fnc_createAction, [], _target];

                        _roleActions
                    }
                ] call ace_interact_menu_fnc_createAction;
                _utilActions pushBack [_roleCategory, [], _target];

                private _abandonAction = [
                    QEGVAR(systems,abandonLocker),
                    "Abandon Locker",
                    "",
                    {
                        params ["_target", "_player"];
                        _target setVariable [QEGVAR(systems,locker_owner), "", true];
                        _target setVariable [QEGVAR(systems,locker_ownerUID), "", true];
                        _player setVariable [QEGVAR(systems,claimed_locker), objNull, true];
                        ["Locker Abandoned."] call ace_common_fnc_displayTextPicture;
                    },
                    {true}
                ] call ace_interact_menu_fnc_createAction;
                _utilActions pushBack [_abandonAction, [], _target];

                _utilActions
            }
        ] call ace_interact_menu_fnc_createAction;
        _actions pushBack [_utilityCategory, [], _target];
        
        _actions
    }, // insertChildren
    [],
    _heightOffset,
    100,
    [false, false, false, true, false],
    {
        params ["_target", "_player", "_params", "_actionData"];
        _actionData set [1, format ["%1's Locker", _target getVariable [QEGVAR(systems,locker_owner), ""]]];
    }
] call ace_interact_menu_fnc_createAction;
[_object, 0, [], _ownerAction] call ace_interact_menu_fnc_addActionToObject;

// 3. Non-Owner Locker Action (Visible to others who aren't admin, NO children)
private _nonOwnerAction = [
    QEGVAR(systems,lockerNonOwner),
    "Locker",
    "",
    {},
    {
        private _uid = _target getVariable [QEGVAR(systems,locker_ownerUID), ""];
        private _isAdmin = serverCommandAvailable "#kick" || {!isNull (getAssignedCuratorLogic _player)};
        _uid != "" && _uid != getPlayerUID _player && !_isAdmin
    },
    {}, // NO insertChildren
    [],
    _heightOffset,
    100,
    [false, false, false, true, false],
    {
        params ["_target", "_player", "_params", "_actionData"];
        _actionData set [1, format ["%1's Locker", _target getVariable [QEGVAR(systems,locker_owner), ""]]];
    }
] call ace_interact_menu_fnc_createAction;
[_object, 0, [], _nonOwnerAction] call ace_interact_menu_fnc_addActionToObject;

// 4. Admin Locker Action (Visible to admins on someone else's locker)
private _adminAction = [
    QEGVAR(systems,lockerAdmin),
    "Locker",
    "",
    {},
    {
        private _uid = _target getVariable [QEGVAR(systems,locker_ownerUID), ""];
        private _isAdmin = serverCommandAvailable "#kick" || {!isNull (getAssignedCuratorLogic _player)};
        _uid != "" && _uid != getPlayerUID _player && _isAdmin
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
                    (allPlayers select _ownerIndex) setVariable [QEGVAR(systems,claimed_locker), objNull, true];
                };
                
                [format ["Force abandoned %1's locker.", _ownerName]] call ace_common_fnc_displayTextPicture;
            },
            {true}
        ] call ace_interact_menu_fnc_createAction;
        _actions pushBack [_forceAbandonAction, [], _target];
        _actions
    },
    [],
    _heightOffset,
    100,
    [false, false, false, true, false],
    {
        params ["_target", "_player", "_params", "_actionData"];
        _actionData set [1, format ["%1's Locker", _target getVariable [QEGVAR(systems,locker_owner), ""]]];
    }
] call ace_interact_menu_fnc_createAction;
[_object, 0, [], _adminAction] call ace_interact_menu_fnc_addActionToObject;
