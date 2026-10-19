#include "..\script_component.hpp"
/*
 * Author: Antigravity
 * Handles UI interactions and state updates for the Personal Loadout Locker dialog.
 *
 * Arguments:
 * 0: Mode <STRING>
 * 1: Parameters <ARRAY> (Optional)
 *
 * Return Value:
 * None
 *
 * Example:
 * ["onLoad", [_display]] call cScripts_fnc_loadoutLocker_ui;
 */

params [
    ["_mode", "", [""]],
    ["_params", [], [[]]]
];

switch (_mode) do {
    case "onLoad": {
        _params params [["_display", displayNull, [displayNull]]];
        if (isNull _display) exitWith {};

        // Retrieve claimed locker or fall back to current interaction target
        private _locker = player getVariable [QEGVAR(systems,claimed_locker), objNull];
        if (isNull _locker) then {
            _locker = missionNamespace getVariable ["cScripts_ui_currentLocker", objNull];
            if (!isNull _locker && {(_locker getVariable [QEGVAR(systems,locker_ownerUID), ""]) == getPlayerUID player}) then {
                player setVariable [QEGVAR(systems,claimed_locker), _locker, true];
            };
        };

        // Set Title with Locker Owner's Name
        private _ctrlTitle = _display displayCtrl 19101;
        private _ownerName = if (!isNull _locker) then {
            _locker getVariable [QEGVAR(systems,locker_owner), name player]
        } else {
            name player
        };
        _ctrlTitle ctrlSetText format [" PERSONAL LOCKER - %1", toUpper _ownerName];

        // Update all status panels
        ["updateStatus", [_display]] call FUNC(loadoutLocker_ui);
    };

    case "updateStatus": {
        private _display = if (count _params > 0) then {_params select 0} else {findDisplay 19100};
        if (isNull _display) exitWith {};

        // 1. Role Buttons Dynamic State (Green when active, Slate when inactive)
        private _medicClass = player getVariable ["ace_medical_medicClass", 0];
        private _engineerClass = player getVariable ["ace_isEngineer", 0];
        private _isEOD = player getVariable ["ACE_isEOD", false];

        private _colorActive = [0.15, 0.50, 0.20, 1.0];
        private _colorInactive = [0.18, 0.22, 0.28, 1.0];
        private _bgCLS = _display displayCtrl 19125;
        private _bgMedic = _display displayCtrl 19126;
        private _bgEng = _display displayCtrl 19127;
        private _bgEOD = _display displayCtrl 19128;

        _bgCLS ctrlSetBackgroundColor (if (_medicClass == 1) then {_colorActive} else {_colorInactive});
        _bgCLS ctrlCommit 0;

        _bgMedic ctrlSetBackgroundColor (if (_medicClass == 2) then {_colorActive} else {_colorInactive});
        _bgMedic ctrlCommit 0;

        _bgEng ctrlSetBackgroundColor (if (_engineerClass > 0) then {_colorActive} else {_colorInactive});
        _bgEng ctrlCommit 0;

        _bgEOD ctrlSetBackgroundColor (if (_isEOD) then {_colorActive} else {_colorInactive});
        _bgEOD ctrlCommit 0;

        // 2. Preset Buttons Availability Check
        private _savedLoadouts = profileNamespace getVariable ["ace_arsenal_saved_loadouts", []];
        private _hasCombat = (_savedLoadouts findIf {_x isEqualType [] && {count _x > 0} && {(_x select 0) == "Combat Kit"}}) != -1;
        private _hasRecon = (_savedLoadouts findIf {_x isEqualType [] && {count _x > 0} && {(_x select 0) == "Recon Kit"}}) != -1;
        private _hasCasual = (_savedLoadouts findIf {_x isEqualType [] && {count _x > 0} && {(_x select 0) == "Casual Kit"}}) != -1;

        private _btnCombat = _display displayCtrl 19110;
        private _btnRecon = _display displayCtrl 19111;
        private _btnCasual = _display displayCtrl 19112;

        _btnCombat ctrlSetText (if (_hasCombat) then {"Equip Combat Kit"} else {"Combat Kit (Not Found)"});
        _btnCombat ctrlEnable _hasCombat;

        _btnRecon ctrlSetText (if (_hasRecon) then {"Equip Recon Kit"} else {"Recon Kit (Not Found)"});
        _btnRecon ctrlEnable _hasRecon;

        _btnCasual ctrlSetText (if (_hasCasual) then {"Equip Casual Kit"} else {"Casual Kit (Not Found)"});
        _btnCasual ctrlEnable _hasCasual;
    };

    case "equipKit": {
        _params params [["_targetPreset", "", [""]]];
        private _savedLoadouts = profileNamespace getVariable ["ace_arsenal_saved_loadouts", []];
        private _loadoutIndex = _savedLoadouts findIf {(_x select 0) == _targetPreset};

        if (_loadoutIndex != -1) then {
            private _loadoutData = (_savedLoadouts select _loadoutIndex) select 1;
            private _vanillaLoadout = _loadoutData;
            if (_loadoutData isEqualType [] && {count _loadoutData > 0} && {(_loadoutData select 0) isEqualType []}) then {
                _vanillaLoadout = _loadoutData select 0;
            };
            [player, _vanillaLoadout] call CBA_fnc_setLoadout;
            [player] call EFUNC(gear,saveLoadout);
            [format ["Equipped %1.", _targetPreset]] call ace_common_fnc_displayTextPicture;
            ["updateStatus"] call FUNC(loadoutLocker_ui);
        } else {
            [format ["Missing '%1' preset in your ACE Arsenal!", _targetPreset]] call ace_common_fnc_displayTextPicture;
        };
    };

    case "openArsenal": {
        closeDialog 0;
        call FUNC(clearDefaultArsenalLoadouts);
        call FUNC(addDefaultArsenalLoadout);

        [player, true] call ace_arsenal_fnc_addVirtualItems;

        private _blacklist = GVAR(BLACKLIST);
        [player, _blacklist, false] call ace_arsenal_fnc_removeVirtualItems;

        [{
            [player, player, false] call ace_arsenal_fnc_openBox;
            [QEGVAR(StagingArsenal,displayOpen)] call CBA_fnc_localEvent;
            [{
                private _loadout = [player] call EFUNC(gear,getLoadoutName);
                private _loadoutCfg = missionConfigFile >> "CfgLoadouts" >> _loadout;
                private _titleMsg = if (isClass _loadoutCfg) then {
                    private _name = getText (_loadoutCfg >> "displayName");
                    private _company = getText (_loadoutCfg >> "company");
                    format ["Arsenal for %1 Co. %2 loaded", [_company] call CBA_fnc_capitalize, _name]
                } else {
                    format ["Arsenal loaded for %1", _loadout]
                };
                [(findDisplay 1127001), _titleMsg] call ace_arsenal_fnc_message;
            }, [], 0.35] call CBA_fnc_waitAndExecute;
        }] call CBA_fnc_execNextFrame;
    };

    case "setRole": {
        _params params [["_role", "", [""]]];
        switch (_role) do {
            case "CLS": {
                private _current = player getVariable ["ace_medical_medicClass", 0];
                if (_current == 1) then {
                    player setVariable ["ace_medical_medicClass", 0, true];
                    systemChat "Role removed: Combat Lifesaver.";
                } else {
                    player setVariable ["ace_medical_medicClass", 1, true];
                    systemChat "Role updated: Combat Lifesaver (CLS).";
                };
            };
            case "Medic": {
                private _current = player getVariable ["ace_medical_medicClass", 0];
                if (_current == 2) then {
                    player setVariable ["ace_medical_medicClass", 0, true];
                    systemChat "Role removed: Medic.";
                } else {
                    player setVariable ["ace_medical_medicClass", 2, true];
                    systemChat "Role updated: Medic (Doctor).";
                };
            };
            case "Engineer": {
                private _current = player getVariable ["ace_isEngineer", 0];
                if (_current > 0) then {
                    player setVariable ["ace_isEngineer", 0, true];
                    systemChat "Role removed: Advanced Engineer.";
                } else {
                    player setVariable ["ace_isEngineer", 2, true];
                    systemChat "Role updated: Advanced Engineer.";
                };
            };
            case "EOD": {
                private _current = player getVariable ["ACE_isEOD", false];
                player setVariable ["ACE_isEOD", !_current, true];
                if (!_current) then {
                    systemChat "Role updated: Explosive/Demo Specialist (EOD) added.";
                } else {
                    systemChat "Role updated: Explosive/Demo Specialist (EOD) removed.";
                };
            };
            case "clearAll": {
                player setVariable ["ace_medical_medicClass", 0, true];
                player setVariable ["ace_isEngineer", 0, true];
                player setVariable ["ACE_isEOD", false, true];
                systemChat "All role permissions have been removed.";
            };
        };
        ["updateStatus"] call FUNC(loadoutLocker_ui);
    };

    case "heal": {
        if (GVAR(OneLife)) exitWith {
            [[], ["Full heal is disabled during One-Life operations."], [""], [""]] call CBA_fnc_notify;
        };
        [player, player] call ace_medical_treatment_fnc_fullHeal;
        [[], ["You have been fully healed."], [""], [""]] call CBA_fnc_notify;
        ["updateStatus"] call FUNC(loadoutLocker_ui);
    };

    case "eatAndDrink": {
        closeDialog 0;
        private _target = player getVariable [QEGVAR(systems,claimed_locker), objNull];
        if (isNull _target) then {
            _target = missionNamespace getVariable ["cScripts_ui_currentLocker", objNull];
        };

        private _anim = [player, _target] call ace_field_rations_fnc_getDrinkAnimation;
        player setVariable ["ace_field_rations_previousAnim", animationState player];
        [player, _anim, 1] call ace_common_fnc_doAnimation;

        [10, [player, _target], {
            params ["_args"];
            _args params ["_player", "_target"];
            _player setVariable ["acex_field_rations_hunger", 0, true];
            _player setVariable ["acex_field_rations_thirst", 0, true];
            systemChat "You have eaten a meal and drank water.";
            _player setVariable ["ace_field_rations_previousAnim", nil];
            if (alive _player && {!isNull _target && {_player distance _target <= 5}}) then {
                createDialog "cScripts_RscLoadoutLocker";
            };
        }, {
            params ["_args"];
            _args params ["_player", "_target"];
            systemChat "You stopped eating and drinking.";
            
            if (isNull objectParent _player && {!(_player call ace_common_fnc_isSwimming)}) then {
                private _prevAnim = _player getVariable ["ace_field_rations_previousAnim", ""];
                if (_prevAnim != "") then {
                    [_player, _prevAnim, 2] call ace_common_fnc_doAnimation;
                };
            };
            _player setVariable ["ace_field_rations_previousAnim", nil];
            if (alive _player && {!isNull _target && {_player distance _target <= 5}}) then {
                createDialog "cScripts_RscLoadoutLocker";
            };
        }, "Eating and Drinking...", {true}, ["isNotInside"]] call ace_common_fnc_progressBar;
    };

    case "closeDisplay": {
        if (!isNull (findDisplay 19100)) then {
            (findDisplay 19100) closeDisplay 1;
            closeDialog 0;
        };
    };

    case "abandonLocker": {
        (findDisplay 19100) closeDisplay 1;
        closeDialog 0;
        private _target = player getVariable [QEGVAR(systems,claimed_locker), objNull];
        if (isNull _target) then {
            _target = missionNamespace getVariable ["cScripts_ui_currentLocker", objNull];
        };
        if (!isNull _target) then {
            _target setVariable [QEGVAR(systems,locker_owner), "", true];
            _target setVariable [QEGVAR(systems,locker_ownerUID), "", true];
            player setVariable [QEGVAR(systems,claimed_locker), objNull, true];
            missionNamespace setVariable ["cScripts_ui_currentLocker", objNull];
            ["Locker Abandoned."] call ace_common_fnc_displayTextPicture;
        };
    };
};
