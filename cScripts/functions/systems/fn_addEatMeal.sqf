#include "..\script_component.hpp";
/*
 * Author: 7th Cavalry
 * This function adds an action to eat a meal and drink water to a given object.
 *
 * Arguments:
 * 0: Object <OBJECT>
 * 1: Action Type <NUMBER> (Default: 0) [0: Interaction menu, 1: Self-interaction menu]
 * 2: category <ARRAY> (Default: ["ACE_MainActions"])
 *
 * Example:
 * [this] call cScripts_fnc_addEatMeal;
 */

params [
    ["_object", objNull, [objNull]],
    ["_actionType", 0, [0]],
    ["_category", ["ACE_MainActions"], [[]]]
];

if (isNull _object) exitWith {};

private _eatStatement = {
    player setVariable ["acex_field_rations_hunger", 0, true];
    systemChat "You have eaten some food.";
};

private _eatAction = [QEGVAR(Actions,EatFood), "Eat Food", "cScripts\Data\Icon\icon_00.paa", _eatStatement, {true}] call ace_interact_menu_fnc_createAction;
[_object, _actionType, _category, _eatAction] call ace_interact_menu_fnc_addActionToObject;
