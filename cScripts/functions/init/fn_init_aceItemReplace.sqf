#include "..\script_component.hpp";
/*
 * Author: CPL.Brostrom.A
 * This function enables standardization of item use by swaping items to desired item.
 *
 * Example:
 * call cScripts_fnc_init_aceItemReplace
 *
 * Public: No
 */

if (!EGVAR(patches,usesACE)) exitWith {};

INFO("init", "Initializing Item replacement system.");

if (!isNil {ace_medical_treatment_convertItems == 2}) then {
    switch (EGVAR(Settings,replaceMedical)) do {
        case (1): {
            ["FirstAidKit",[
                "ACE_quikclot",
                "ACE_splint",
                "ACE_quikclot", "ACE_quikclot", "ACE_quikclot",
                "ACE_tourniquet"
            ]] call ace_common_fnc_registerItemReplacement;
            ["Medikit",[
                "ACE_splint",
                "ACE_quikclot", "ACE_quikclot", "ACE_quikclot", "ACE_quikclot", "ACE_quikclot", "ACE_quikclot",
                "ACE_morphine", "ACE_morphine",
                "ACE_salineIV_500", "ACE_salineIV_500",
                "ACE_tourniquet","ACE_tourniquet",
                "ACE_adenosine",
                "ACE_epinephrine", "ACE_epinephrine",
                "ACE_surgicalKit",
                "ACE_personalAidKit"
            ]] call ace_common_fnc_registerItemReplacement;
        };
    };
};


INFO("init", "Item replacement initialization completed.");
