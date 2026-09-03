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
    params ["_target", "_player", "_params"];
    private _anim = [_player, _target] call ace_field_rations_fnc_getDrinkAnimation;
    _player setVariable ["ace_field_rations_previousAnim", animationState _player];
    [_player, _anim, 1] call ace_common_fnc_doAnimation;

    [5, [_player], {
        params ["_args"];
        _args params ["_player"];
        _player setVariable ["acex_field_rations_hunger", 0, true];
        _player setVariable ["acex_field_rations_thirst", 0, true];
        systemChat "You have eaten a meal and drank water.";
        _player setVariable ["ace_field_rations_previousAnim", nil];
    }, {
        params ["_args"];
        _args params ["_player"];
        systemChat "You stopped eating.";
        
        if (isNull objectParent _player && {!(_player call ace_common_fnc_isSwimming)}) then {
            private _prevAnim = _player getVariable ["ace_field_rations_previousAnim", ""];
            if (_prevAnim != "") then {
                [_player, _prevAnim, 2] call ace_common_fnc_doAnimation;
            };
        };
        _player setVariable ["ace_field_rations_previousAnim", nil];
    }, "Consuming Meal...", {true}, ["isNotInside"]] call ace_common_fnc_progressBar;
};

private _eatAction = [QEGVAR(Actions,EatFood), "Eat Food", "cScripts\Data\Icon\icon_00.paa", _eatStatement, {true}] call ace_interact_menu_fnc_createAction;
[_object, _actionType, _category, _eatAction] call ace_interact_menu_fnc_addActionToObject;
