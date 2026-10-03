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
    ["_object", objNull, [objNull]]
];

if (isNull _object) exitWith {};

// Ensure object is initialized server-side or globally
if (isServer) then {
    _object setVariable [QEGVAR(systems,locker_owner), "", true];
    _object setVariable [QEGVAR(systems,locker_ownerUID), "", true];
};

// Disable the default ACEX Field Rations "Get water from source" action on this box
_object setVariable ["ace_field_rations_currentWaterSupply", -1, true];

if (!hasInterface) exitWith {};

// Root Action
private _lockerAction = [
    QEGVAR(systems,lockerAction),
    "Locker", // Placeholder, modified by modifierFunc
    "", // icon
    {}, // statement
    {true}, // condition
    {
        // insertChildren
        params ["_target", "_player", "_params"];
        
        private _ownerUID = _target getVariable [QEGVAR(systems,locker_ownerUID), ""];
        private _actions = [];
        
        if (_ownerUID == "") then {
            // Unclaimed Locker -> Claim Action
            private _claimAction = [
                QEGVAR(systems,claimLocker),
                "Claim Locker",
                "",
                {
                    params ["_target", "_player", "_params"];
                    private _claimedLocker = _player getVariable [QEGVAR(systems,claimed_locker), objNull];
                    if (!isNull _claimedLocker && {alive _claimedLocker}) exitWith {
                        ["You already own a locker! Abandon it first."] call ace_common_fnc_displayTextPicture;
                    };
                    
                    _target setVariable [QEGVAR(systems,locker_owner), name _player, true];
                    _target setVariable [QEGVAR(systems,locker_ownerUID), getPlayerUID _player, true];
                    _player setVariable [QEGVAR(systems,claimed_locker), _target, true];
                    ["Locker Claimed."] call ace_common_fnc_displayTextPicture;
                },
                {true}
            ] call ace_interact_menu_fnc_createAction;
            _actions pushBack [_claimAction, [], _target];
        } else {
            // Claimed Locker, check if it's the owner looking at it
            if (getPlayerUID _player == _ownerUID) then {
                
                // Helper to create Kit actions
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
                
                // TFG Arsenal Action
                private _arsenalAction = [
                    QEGVAR(systems,lockerArsenal),
                    "TFG Arsenal",
                    "cScripts\Data\Icon\icon_arsenal_ca.paa",
                    {
                        call FUNC(clearDefaultArsenalLoadouts);
                        waitUntil { count ace_arsenal_defaultLoadoutsList == 0 };
                        call FUNC(addDefaultArsenalLoadout);
                        waitUntil { count ace_arsenal_defaultLoadoutsList != 0 };

                        // Add everything unconditionally, bypassing the class-based whitelist check
                        [player, true] call ace_arsenal_fnc_addVirtualItems;
                        
                        private _blacklist = ["Aegis_arifle_AK103_F","Aegis_arifle_AK103_plum_F","Aegis_arifle_AK103_GL_F","Aegis_arifle_AK103_GL_plum_F","Kish_Weap_AK12_ARCO_snds_F","arifle_AK12_545_F","arifle_AK12_545_lush_F","arifle_AK12_545_tan_F","Kish_Weap_AK12_Holo_snds_F","arifle_AK12_545_arid_F","arifle_AK12_GL_545_F","arifle_AK12_GL_545_arid_F","arifle_AK12_GL_545_lush_F","arifle_AK12_GL_545_tan_F","Kish_Weap_AK12U_snds_F","Kish_Weap_AK12U_Holo_snds_F","arifle_ak12_f","arifle_AK12_arid_F","arifle_AK12_lush_F","arifle_ak12_gl_f","arifle_AK12_GL_arid_F","arifle_AK12_GL_lush_F","arifle_AK12U_F","arifle_AK12U_arid_F","arifle_AK12U_lush_F","lk_arifle_ak203_gl46_f","lk_arifle_ak203_f","lk_arifle_ak203_grip_f","lk_arifle_ak203_m203_f","lk_arifle_ak203_gl_f","lk_ak308_F","Aegis_arifle_AK74_F","Aegis_arifle_AK74_gold_F","Aegis_arifle_AK74_oak_F","Aegis_arifle_AK74_GL_F","Aegis_arifle_AK74_GL_oak_F","aegis_arifle_akm74_f","Aegis_arifle_AKM74_olive_F","Aegis_arifle_AKM74_plum_F","Aegis_arifle_AKM74_sand_F","AEGIS_arifle_akm74_gl_f","Aegis_arifle_AKM74_olive_GL_F","Aegis_arifle_AKM74_GL_plum_F","Aegis_arifle_AKM74_sand_GL_F","arifle_AKM_F","Aegis_arifle_AKS74_F","Aegis_arifle_AKS74_gold_F","Aegis_arifle_AKS74_oak_F","arifle_AKSM_F","arifle_AKSM_alt_F","arifle_AKS_F","arifle_AKS_alt_F","arifle_AK12U_545_F","arifle_AK12U_545_arid_F","arifle_AK12U_545_lush_F","arifle_AK12U_545_tan_F","Kish_Weap_ASP_ARCO_F","Kish_Weap_ASP_DMS_F","sgun_Mp153_classic_F","arifle_Katiba_GL_F","arifle_Katiba_C_F","arifle_NCAR15_F","arifle_NCAR15_GL_F","arifle_NCAR15_MG_F","arifle_NCAR15B_F","srifle_DMR_07_blk_F","srifle_DMR_07_ghex_F","srifle_DMR_07_hex_F","arifle_CTAR_blk_F","arifle_CTAR_hex_F","arifle_CTAR_ghex_F","Aegis_arifle_CTAR_tan_f","arifle_CTAR_GL_blk_F","arifle_CTAR_GL_ghex_F","arifle_CTAR_GL_hex_F","Aegis_arifle_CTAR_GL_tan_f","arifle_CTARS_blk_F","arifle_CTARS_ghex_F","arifle_CTARS_hex_F","Aegis_arifle_CTARS_tan_f","arifle_RPK12_F","arifle_RPK12_arid_F","arifle_RPK12_lush_F","arifle_RPK_F","Kish_Weap_RPK12_Holo_snds_F","Aegis_arifle_RPK12_545_F","Aegis_arifle_RPK12_545_arid_F","Aegis_arifle_RPK12_545_lush_F","Aegis_arifle_RPK12_545_tan_F","lk_arifle_RPK74_F","Aegis_arifle_RPK74M_F","Opf_arifle_SKS_F","Opf_arifle_SKS_oak_F","Kish_Weap_Sgun","arifle_ARX_blk_F","arifle_ARX_ghex_F","arifle_ARX_hex_F","lk_arifle_type24_f","lk_arifle_type98_f","lk_arifle_type98_helical_f","launch_Titan_blk_F","launch_O_Titan_camo_F","EF_launch_B_Titan_Coy","launch_I_Titan_F","launch_I_Titan_eaf_F","launch_O_Titan_F","launch_B_Titan_F","launch_O_Titan_ghex_F","launch_B_Titan_olive_F","launch_B_Titan_tna_F","launch_Titan_short_blk_F","launch_O_Titan_short_camo_F","launch_O_Titan_short_ghex_F","launch_I_Titan_short_F","launch_B_Titan_short_F","launch_B_Titan_short_tna_F","launch_RPG32_F","launch_RPG32_ghex_F","launch_RPG32_green_F","launch_RPG32_tan_lxWS","launch_RPG32_camo_F","launch_RPG32_black_F","launch_RPG7_F","Aegis_launch_RPG7M_F","ace_csw_spg9CarryTripod","ace_csw_kordCarryTripod","ace_csw_kordCarryTripodLow","sgun_Mp153_black_F","sgun_HunterShotgun_01_F","sgun_HunterShotgun_01_sawedoff_F","EF_smg_Diplomat_Ghex","EF_smg_Diplomat_Hex","AddGis_arifle_KHBAR_F","AddGis_arifle_KHBAR_C_F","AddGis_arifle_KHBAR_GL_F","JAM_AE_ARifle_QBZ95_blk","JAM_AE_ARifle_QBZ95_GL_blk","JAM_AE_ARifle_QBZ95_RIS_blk","JAM_AE_ARifle_QBZ95_RIS_FG_blk","JAM_AE_ARifle_QBZ95_1_AFG_blk","JAM_AE_ARifle_QBZ95_1_FG_blk","JAM_AE_ARifle_QBZ97_blk","JAM_AE_ARifle_QBZ97_GL_blk","JAM_AE_ARifle_QJB95_blk","JAM_AE_LMG_QJY88_blk","lk_g3m_f","lk_g3_f","lk_g3s_f","lk_g3m_gl_f","lk_g3m_lmg_f","lk_g3m_dmr_f","JAM_AE_ARifle_Type56","JAM_AE_ARifle_Type56_dark","JAM_AE_ARifle_Type56_2","JAM_AE_ARifle_Type56_2_plum","JAM_AE_ARifle_Type58_AK","JAM_AE_ARifle_Type58_AK_wat","JAM_AE_ARifle_Type81_1","JAM_AE_ARifle_Type81_1_blk","JAM_AE_ARifle_Type81_1_plum","JAM_AE_ARifle_Type81_LMG","JAM_AE_ARifle_Type81_LMG_blk","JAM_AE_ARifle_Type81_LMG_plum","JAM_AE_ARifle_Type88_2","JAM_AE_ARifle_Type88_2_helical","JAM_AE_Launch_DZAII_grn_F","JAM_AE_Launch_DZJ08_grn_F","launch_O_Vorona_brown_F","launch_O_Vorona_green_F","Atlas_Launch_Pzf3_F","kfc_ps_bw_Atlas_Launch_Pzf3_F","JAM_AE_Launch_PF98_oli","AX_launch_RPG32_drkgrn_F","AX_launch_RPG32_tan_F","AX_launch_Titan_grn_F","AX_launch_Titan_short_grn_F","DSA_MachinePistol45","DSA_MachinePistol9mm","hgun_G17_black_F","hgun_G17_khaki_F","hgun_G17_F","AX_hgun_P320_coy_F","Aegis_8Rnd_12Gauge_HE","Aegis_8Rnd_12Gauge_AA40_HE_khk_lxWS","8Rnd_12Gauge_AA40_HE_lxWS","8Rnd_12Gauge_AA40_HE_Snake_lxWS","8Rnd_12Gauge_AA40_HE_Tan_lxWS","6rnd_HE_Mag_lxWS","Aegis_4Rnd_12Gauge_HE","2rnd_HE_Mag_lxWS","20Rnd_12Gauge_AA40_HE_Tan_lxWS","20Rnd_12Gauge_AA40_HE_Snake_lxWS","20Rnd_12Gauge_AA40_HE_lxWS","Aegis_20Rnd_12Gauge_AA40_HE_khk_lxWS","TFAR_anprc148jem","TFAR_anprc154","TFAR_fadak","TFAR_pnr1000a","ItemRadio","TFAR_rf7800str","B_Tura_UavTerminal_lxWS","O_UavTerminal","I_UavTerminal","B_G_FIA_UavTerminal_lxWS","C_UavTerminal","tsp_flashbang_cts99","dmpCanteenDirty","dmpCanteenEmpty","dmpCanteenClean","dmpBottleFullDirty","dmpBottleFull","dmpEnergyDrink","dmpFranta","dmpHeatpack","dmpMRE","dmpWaterPurification","dmpWallet","dmpPainkillers","GX_DEPLOYABLE_B_G_UAV_02_IED_lxWS","FirstAidKit","Medikit","dmpBandage","Tiger_Attack_weapon","ibr_crossbow_black","ibr_crossbow_wood","arifle_AK12_F","arifle_AK12_GL_F","Aegis_arifle_AKM74_F","Aegis_arifle_AKM74_GL_F","ibr_akm","arifle_AKM_FL_F","ibr_akm_gl","ibr_akm_carbine","ibr_akm_carbine_gl","pjc_core_wep_tavor_blk","pjc_core_wep_tavor_gl_blk","pjc_core_wep_tavor_short_blk","nsw_er7s","nsw_er7a","pjc_core_wep_f16","pjc_core_wep_f16_grip","pjc_core_wep_f16_gl","pjc_core_wep_f16_short","pjc_core_wep_f21","pjc_core_wep_f21_c","pjc_core_wep_f21_gl","pjc_core_wep_f36","pjc_core_wep_f36_gl","pjc_core_wep_f36c","PJC_core_wep_fm50","PJC_core_wep_fm50_GL","pjc_core_wep_kh16B3","pjc_core_wep_kh16B3_FG","pjc_core_wep_kh16B3_GL","pjc_core_wep_kh41a1_NoGrp_blk","pjc_core_wep_kh41a1_NoGrp","pjc_core_wep_kh41a1_blk","pjc_core_wep_kh41a1_gl_blk","pjc_core_wep_kh41a1_gl","pjc_core_wep_kh41a1","pjc_core_wep_kh41a1c_blk","pjc_core_wep_kh41a1c","arifle_Katiba_F","pjc_core_wep_KR15_blk","pjc_core_wep_kr15_oak","pjc_core_wep_kr15_wood","pjc_core_wep_KR15_GL_blk","pjc_core_wep_kr15_GL_oak","pjc_core_wep_kr15_GL_wood","pjc_core_wep_kr15S_wood","pjc_core_wep_KR15MU_blk","pjc_core_wep_KR15S_blk","pjc_core_wep_KR24M","pjc_core_wep_KR24M_GL","pjc_core_wep_KR24MU","pjc_core_wep_MKR39LR","ibr_rpk","Aegis_srifle_SVD_f","Aegis_srifle_SVD_blk_f","Aegis_srifle_SVD_plum_f","ibr_svd","zetaborn_carbine","zetaborn_z12","zetaborn_rifle","zetaborn_z16a","zetaborn_z22","zetaborn_z93","zetaborn_z93x","DSF_launch_RPG7","ibr_rpg7v","launch_RPG32A1_hex","zetaborn_krak","zetaborn_at","GX_ACE_CSW_HUNTER_SP_LAUNCHER","ibr_igla","zetaborn_z6","Aegis_hgun_P320_black_F","Aegis_hgun_P320_khaki_F","Aegis_hgun_P320_olive_F","Aegis_hgun_P320_sand_F","MPP_P320_BLK_BLK_9","MPP_P320_BLK_FDE_9","MPP_P320_FDE_FDE_9","MPP_P320_FDE_BLK_9","SPP_1_base_F","JCA_hgun_M9A1_sand_F","JCA_hgun_M9A1_olive_F","JCA_hgun_M9A1_black_F","JCA_hgun_G17_black_F","JCA_hgun_G17_olive_F","JCA_hgun_G17_sand_F","hgun_Pistol_01_F","hgun_Pistol_Signal_F","ibr_alien_uniform","ibr_alien_uniform2","ibr_alien_uniform3","U_ibr_robo_01_base","ibr_reptile_uniform","zetapack","USP_ADVANCER_BC","ibr_gasmask_SF10","ibr_zetaTVG","ibr_NVG_chip","zetaborn_grenade_mag","ibr_throw_spear","ibr_throwable_stone","tsp_sling_1point","tsp_sling","tsp_sling_3point","dmpAntibiotics","dmpAntidote","dmpAntiparasitic","dmpAntirads","J3FF_FoxholeTool","dmpSmartphone2","dmpSmartphone","dmpSleepingBag","dmpStims","dmpTent","dmpTacticalBacon","ballistic_mask_dow","lar_headp","lar_headw","ibr_Skull_Black","ibr_Skull_Bone","ibr_Skull_Brown","ibr_Skull_Grey","ibr_Zombie","ibr_Zombie_Grey","JCA_launch_M72_black_F","JCA_launch_M72_olive_F","JCA_launch_M72_sand_F"];
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
                
                // Utility Category
                private _utilityCategory = [
                    QEGVAR(systems,lockerUtility),
                    "Utility",
                    "",
                    {},
                    {true},
                    {
                        params ["_target", "_player", "_params"];
                        private _utilActions = [];
                        
                        // Heal
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

                        // Eat Food and Drink Water
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
                        
                        // Retrieve Permissions (Role Menu)
                        private _roleCategory = [
                            QEGVAR(systems,lockerRoles),
                            "Retrieve Permissions",
                            "",
                            {},
                            {true},
                            {
                                params ["_target", "_player", "_params"];
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

                        // Abandon Locker
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
            };
        };
        
        _actions
    }, // insertChildren
    [],
    [0,0,1],
    100,
    [false, false, false, true, false],
    {
        // modifierFunc
        params ["_target", "_player", "_params", "_actionData"];
        private _owner = _target getVariable [QEGVAR(systems,locker_owner), ""];
        if (_owner == "") then {
            _actionData set [1, "Unclaimed Locker"];
        } else {
            _actionData set [1, format ["%1's Locker", _owner]];
        };
    }
] call ace_interact_menu_fnc_createAction;

[_object, 0, [], _lockerAction] call ace_interact_menu_fnc_addActionToObject;
