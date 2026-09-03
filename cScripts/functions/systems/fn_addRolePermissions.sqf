#include "..\script_component.hpp";
/*
 * Author: 7th Cavalry
 * This function adds role permissions selection (Medic, CLS, EOD, Engineer) to a given object.
 *
 * Arguments:
 * 0: Object <OBJECT>
 * 1: Action Type <NUMBER> (Default: 0) [0: Interaction menu, 1: Self-interaction menu]
 * 2: category <ARRAY> (Default: ["ACE_MainActions"])
 *
 * Example:
 * [this] call cScripts_fnc_addRolePermissions;
 */

params [
    ["_object", objNull, [objNull]],
    ["_actionType", 0, [0]],
    ["_category", ["ACE_MainActions"], [[]]]
];

if (isNull _object) exitWith {};

private _mainCategoryName = QEGVAR(Actions,RolePermissions);
private _mainCategory = [_mainCategoryName, "Retrieve Permissions", "", {}, {true}] call ace_interact_menu_fnc_createAction;
[_object, _actionType, _category, _mainCategory] call ace_interact_menu_fnc_addActionToObject;

private _newCategory = _category + [_mainCategoryName];

private _clsStatement = {
    player setVariable ["ace_medical_medicClass", 1, true];
    systemChat "You are now a Combat Lifesaver (CLS).";
};
private _clsAction = [QEGVAR(Actions,RoleCLS), "Combat Lifesaver (CLS)", "\z\ace\addons\medical_gui\ui\cross.paa", _clsStatement, {true}] call ace_interact_menu_fnc_createAction;
[_object, _actionType, _newCategory, _clsAction] call ace_interact_menu_fnc_addActionToObject;

private _medicStatement = {
    player setVariable ["ace_medical_medicClass", 2, true];
    systemChat "You are now a Medic.";
};
private _medicAction = [QEGVAR(Actions,RoleMedic), "Medic", "\z\ace\addons\medical_gui\ui\cross.paa", _medicStatement, {true}] call ace_interact_menu_fnc_createAction;
[_object, _actionType, _newCategory, _medicAction] call ace_interact_menu_fnc_addActionToObject;

private _eodStatement = {
    player setVariable ["ACE_isEOD", true, true];
    systemChat "You are now an Explosive/Demo Specialist.";
};
private _eodAction = [QEGVAR(Actions,RoleEOD), "Explosive/Demo Specialist", "\z\ace\addons\explosives\UI\Defuse_ca.paa", _eodStatement, {true}] call ace_interact_menu_fnc_createAction;
[_object, _actionType, _newCategory, _eodAction] call ace_interact_menu_fnc_addActionToObject;

private _engineerStatement = {
    player setVariable ["ace_isEngineer", 2, true];
    systemChat "You are now an Engineer.";
};
private _engineerAction = [QEGVAR(Actions,RoleEngineer), "Advanced Engineer", "\a3\ui_f\data\IGUI\Cfg\Actions\repair_ca.paa", _engineerStatement, {true}] call ace_interact_menu_fnc_createAction;
[_object, _actionType, _newCategory, _engineerAction] call ace_interact_menu_fnc_addActionToObject;

private _removeAllStatement = {
    player setVariable ["ace_medical_medicClass", 0, true];
    player setVariable ["ACE_isEOD", false, true];
    player setVariable ["ace_isEngineer", 0, true];
    systemChat "All role permissions have been removed.";
};
private _removeAllAction = [QEGVAR(Actions,RoleRemoveAll), "Remove All Roles", "", _removeAllStatement, {true}] call ace_interact_menu_fnc_createAction;
[_object, _actionType, _newCategory, _removeAllAction] call ace_interact_menu_fnc_addActionToObject;
