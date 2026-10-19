#include "..\script_component.hpp"
/*
 * Author: CPL.Brostrom.A (Optimized)
 * This function returns a list of items used for arsenal whitelist.
 *
 * Arguments:
 * None
 *
 * Return:
 * ARRAY of items
 *
 * Example:
 * call cScripts_fnc_getArsenalWhitelist;
 */

private _classname = [player] call EFUNC(gear,getLoadoutName);
private _loadoutConfig = missionConfigFile >> "CfgLoadouts" >> _classname;

// Direct traversal of the standardized 10-element loadout array
private _loadout = if (isClass _loadoutConfig) then {
    parseSimpleArray getText (_loadoutConfig >> "loadout");
} else {
    INFO_1("ArsenalWhitelist", "Loadout '%1' not in CfgLoadouts; generating whitelist from current gear.", _classname);
    getUnitLoadout player;
};
private _unitItems = [];

// Primary (0), Secondary (1), Handgun (2)
{
    if (_x isNotEqualTo []) then {
        _unitItems pushBack (_x select 0);
        { if (_x isEqualType "" && {_x != ""}) then { _unitItems pushBack _x; }; } forEach (_x select [1, 3]);
        if (count _x > 4 && {(_x select 4) isNotEqualTo []}) then { _unitItems pushBack ((_x select 4) select 0); };
        if (count _x > 5 && {(_x select 5) isNotEqualTo []}) then { _unitItems pushBack ((_x select 5) select 0); };
        if (count _x > 6 && {(_x select 6) isEqualType ""} && {(_x select 6) != ""}) then { _unitItems pushBack (_x select 6); };
    };
} forEach [_loadout param [0, []], _loadout param [1, []], _loadout param [2, []]];

// Container items: Uniform (3), Vest (4), Backpack (5)
{
    if (_x isNotEqualTo []) then {
        _unitItems pushBack (_x select 0);
        if (count _x > 1 && {(_x select 1) isEqualType []}) then {
            {
                if (_x isEqualType [] && {count _x > 0} && {(_x select 0) isEqualType ""}) then {
                    _unitItems pushBack (_x select 0);
                };
            } forEach (_x select 1);
        };
    };
} forEach [_loadout param [3, []], _loadout param [4, []], _loadout param [5, []]];

// Headgear (6), Glasses (7), Binoculars (8), Assigned items (9)
if ((_loadout param [6, ""]) != "") then { _unitItems pushBack (_loadout select 6); };
if ((_loadout param [7, ""]) != "") then { _unitItems pushBack (_loadout select 7); };
if ((_loadout param [8, []]) isNotEqualTo []) then { _unitItems pushBack ((_loadout select 8) select 0); };
{ if (_x != "") then { _unitItems pushBack _x; }; } forEach (_loadout param [9, []]);

_unitItems = _unitItems arrayIntersect _unitItems;

private _commonGear = GET_CONTAINER_KEYS("arsenal_common");

// Read organization directly from loadout config or unit class
private _company = if (isClass _loadoutConfig) then {
    toLower (getText (_loadoutConfig >> "company"));
} else {
    if (_classname find "Atlas" != -1) then { "bravo" } else { "" };
};
private _platoon = if (isClass _loadoutConfig) then {
    getNumber (_loadoutConfig >> "platoon");
} else {
    if (_classname find "Atlas" != -1) then { 1 } else { 0 };
};
private _orgItems = switch (_company) do {
    case "alpha": {
        GET_CONTAINER_KEYS("alpha_company");
    };
    case "bravo": {
        private _companyItems = GET_CONTAINER_KEYS("bravo_company");
        private _platoonItems = switch (_platoon) do {
            case 1: { GET_CONTAINER_KEYS("bravo_company_atlas"); };
            case 2: { GET_CONTAINER_KEYS("bravo_company_viking"); };
            default { [] };
        };
        _companyItems + _platoonItems;
    };
    case "charlie": {
        GET_CONTAINER_KEYS("charlie_company");
    };
    default { GET_CONTAINER_KEYS("arsenal_company_fallback"); };
};

private _roleSpecific = switch ([player] call EFUNC(gear,getLoadoutRole)) do {
    case "officer": { GET_CONTAINER_KEYS("arsenal_role_officer"); };
    case "squadleader": { GET_CONTAINER_KEYS("arsenal_role_squadleader"); };
    case "fireteamleader": { GET_CONTAINER_KEYS("arsenal_role_fireteamleader"); };
    case "weapons": { GET_CONTAINER_KEYS("arsenal_role_weapons"); };
    case "strykercrew": { GET_CONTAINER_KEYS("arsenal_role_strykercrew"); };
    case "pilot";
    case "rotarypilot": { GET_CONTAINER_KEYS("arsenal_role_rotarypilot"); };
    case "rotarycrew": { GET_CONTAINER_KEYS("arsenal_role_pilotcrew"); };
    case "rotarycls": {
        private _rotaryRole = GET_CONTAINER_KEYS("arsenal_role_pilotcrew");
        private _clsRole = GET_CONTAINER_KEYS("arsenal_role_cls");
        _rotaryRole + _clsRole;
    };
    case "pilotfighter": { GET_CONTAINER_KEYS("arsenal_role_pilotfighter"); };
    case "pilottransport": { GET_CONTAINER_KEYS("arsenal_role_pilottransport"); };
    case "cls": { GET_CONTAINER_KEYS("arsenal_role_cls"); };
    case "medic": { GET_CONTAINER_KEYS("arsenal_role_medic"); };
    case "doctor": { GET_CONTAINER_KEYS("arsenal_role_doctor"); };
    default { [] };
};

private _cfgWeapons = configFile >> "CfgWeapons";

private _primaryWeapon = (_loadout param [0, []]) param [0, ""];
private _primarySpecific = switch (true) do {
    case (_primaryWeapon isKindOf ['rhs_weap_mk18_m320', _cfgWeapons]
            || _primaryWeapon isKindOf ['rhs_weap_m16a4_carryhandle_M203', _cfgWeapons]
            || _primaryWeapon isKindOf ['rhs_weap_m4a1_m320', _cfgWeapons]): { GET_CONTAINER_KEYS("arsenal_weap_ugl"); };

    case (_primaryWeapon isKindOf ['rhs_weap_m4a1', _cfgWeapons]
            || _primaryWeapon isKindOf ['rhs_weap_m16a4', _cfgWeapons]): { GET_CONTAINER_KEYS("arsenal_weap_m4"); };

    case (_primaryWeapon isKindOf ['rhs_weap_sr25_ec', _cfgWeapons]): { GET_CONTAINER_KEYS("arsenal_weap_sr25"); };

    case (_primaryWeapon isKindOf ['rhs_weap_m240_base', _cfgWeapons]): { GET_CONTAINER_KEYS("arsenal_weap_m240"); };

    case (_primaryWeapon isKindOf ['rhs_weap_m249_pip', _cfgWeapons]
            || _primaryWeapon isKindOf ['rhs_weap_m249_pip_L', _cfgWeapons]
            || _primaryWeapon isKindOf ['rhs_weap_m249_pip_S', _cfgWeapons]): { GET_CONTAINER_KEYS("arsenal_weap_m249"); };
    default { [] };
};

private _handgunWeapon = (_loadout param [2, []]) param [0, ""];
private _handgunSpecific = switch (true) do {
    case (_handgunWeapon isKindOf ['rhs_weap_M320', _cfgWeapons]): { GET_CONTAINER_KEYS("arsenal_weap_ugl"); };
    case (_handgunWeapon isKindOf ['rhsusf_weap_glock17g4', _cfgWeapons]
            || _handgunWeapon isKindOf ['UK3CB_P320_BLK', _cfgWeapons]
            || _handgunWeapon isKindOf ['UK3CB_P320_DES', _cfgWeapons]
            || _handgunWeapon isKindOf ['rhsusf_weap_m1911a1', _cfgWeapons]): { GET_CONTAINER_KEYS("arsenal_weap_sidearm"); };
    default { [] };
};

private _launcherWeapon = (_loadout param [1, []]) param [0, ""];
private _launcherSpecific = switch (true) do {
    case (_launcherWeapon isKindOf ['rhs_weap_fgm148', _cfgWeapons]
            || _launcherWeapon isKindOf ['rhs_weap_fim92', _cfgWeapons]
            || _launcherWeapon isKindOf ['rhs_weap_maaws', _cfgWeapons]
            || _launcherWeapon isKindOf ['launch_MRAWS_green_F', _cfgWeapons]
            || _launcherWeapon isKindOf ['launch_MRAWS_sand_F', _cfgWeapons]
            || _launcherWeapon isKindOf ['launch_MRAWS_olive_F', _cfgWeapons]): { GET_CONTAINER_KEYS("arsenal_weap_launchers"); };
    default { [] };
};

private _whitelist = +_commonGear;
_whitelist append _unitItems;
_whitelist append _orgItems;
_whitelist append _roleSpecific;
_whitelist append _primarySpecific;
_whitelist append _handgunSpecific;
_whitelist append _launcherSpecific;
_whitelist = _whitelist arrayIntersect _whitelist;

INFO_2("Arsenal", "Whitelist created for %1 [%2].", player, typeOf player);

_whitelist
