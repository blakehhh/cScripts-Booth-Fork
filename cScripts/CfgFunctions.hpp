class cScripts {
    class init {
        file = "cScripts\functions\init";
        class init_aceArsenal {};
        class init_aceItemReplace {};




        class init_logistics {};


        class init_diary {};
        class init_message {};
        class init_chatCommands {};

        class init_eventHandlers {};

        class init_zenModuels {};
    };
    class documents {
        file = "cScripts\functions\documents";

        class DocRadio_LACEACE {};
        class DocRadio_MEDEVAC {};
        class DocRadio_ROTARYPICKUP {};
        class DocRadio_SPOTREP {};

        class DocChklist_CFF {};
        class DocChklist_JMTASKS {};
        class DocChklist_LZSPECS {};
        class DocChklist_LZINSERT {};
        class DocChklist_LZEXTRACT {};
    };
    class logistics {
        file = "cScripts\functions\logistics";
        class addCargo {};
        class setCargo {};
        class setCargoAttributes {};
        class checkItemValidity {};
        class createCargoCrate {};

        class doStarterCrateSupplies {};
        class doFieldHospital {};
        class doSupplyCrate {};

        class doEmptyCrate {};

        class logistics_getContainer {};
        class logistics_getAllContainerItems {};
    };

    class mission {
        file = "cScripts\functions\mission";
        class gate {};
        class teleport {};
        class addLoadoutAction {};

        class addGetOutHelo {};
        class addEscapeWreck {};

        class addLineJump {};
        class addHaloJump {};

        class setVehicleLable {};
        
        class addBaseCrate {};


        class doStarterCrate {};

        class makeAgent {};
    };
    class systems {
        file = "cScripts\functions\systems";
        class addInsigniaSelection {};
        class addInsigniaSelectionList {};

        class allowLoadout {};
        class setupLoadoutSelection {};
        class setupLoadoutCategories {};
        class addLoadoutSelection {};

        // Arsenal releated
        class getArsenalWhitelist {};
        class addDefaultArsenalLoadout {};
        class addDefaultArsenalLoadouts {};
        class clearDefaultArsenalLoadouts {};



        class deleteDroppedObjects {};

        // Training scripts
        class training_addHitIndicator {};
        class training_clearhitIndicator {};

        class training_addTargetComputer {};

       // Plane jump
        class para_lineJump {};
        class para_haloJump {};
        class para_equipment {};
        class para_backpack {};

        // Buttons and options
        class addReGear {};
        class addHeal {};
        class addArsenal {};
        class addEatMeal {};
        class addRolePermissions {};
        
        class createActionCategory {};

        class doGetOutHeloSide {};

        class addObjectToCurator {};



        class filterUnitLoadout {};


        class isValidFaction {};
        
        class createVehicleLable {};
        class getVehicleLable {};

        class renameObject {};
        class getIcon {};
        
        class getAttendance {};
        class getServerMetrics {};
    };

    class modules {
        file = "cScripts\functions\modules";
        class zenModule_EnableUnitSimulation {};

        class zenModule_CreateStarterCrate {};
        class zenModule_CreateSupplyCrate {};

        class zenModule_applyLoadout {};
        class zenModule_RegearTrooper {};



        class zenModule_CallEndex {};
    };
    class gear {
        file = "cScripts\functions\gear";
        class gear_preInit { preInit = 1; };
        class gear_postInitProxy { postInit = 1; };
        class gear_postInit {};

        class gear_applyLoadout {};
        class gear_applyCosmetics {};
        class gear_applyAbilities {};
        class gear_applyFunctions {};
        class gear_selectLoadout {};
        class gear_getSideConfig {};



        // Save and Load
        class gear_saveLoadout {};
        class gear_loadLoadout {};
        class gear_removeLoadout {};
        class gear_hasSavedLoadout {};

        // other
        class gear_getLoadoutRole {};
        class gear_getLoadoutName {};
        class gear_getLoadoutDisplayName {};
    };
    class diag {
        file = "cScripts\functions\diag";
        class error {};
        class info {};
        class log {};
        class warning {};
    };
    class testing {
        file = "cScripts\functions\testing";
        class testing_loadoutArrays {};
        class testing_equipmentUsed {};
    };
};