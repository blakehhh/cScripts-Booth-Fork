# cScripts Architectural Reference Guide

> **Quick Reference Document** for understanding, maintaining, and assessing the **cScripts** Arma 3 mission framework.

---

## Table of Contents
1. [Architectural Overview & Lifecycle](#1-architectural-overview--lifecycle)
   - [Boot & Execution Timeline](#boot--execution-timeline)
   - [Subsystem Relationships](#subsystem-relationships)
2. [Root Files & Engine Entry Points](#2-root-files--engine-entry-points)
3. [cScripts Core Headers & Life-Cycle Scripts](#3-cscripts-core-headers--life-cycle-scripts)
4. [Initialization Subsystem (`cScripts/functions/init/`)](#4-initialization-subsystem-cscriptsfunctionsinit)
5. [Gear & Loadout Subsystem](#5-gear--loadout-subsystem)
   - [Loadout Resolution Cascade](#loadout-resolution-cascade)
   - [Configuration Files (`cScripts/Loadouts/`)](#configuration-files-cscriptsloadouts)
   - [Gear Functions (`cScripts/functions/gear/`)](#gear-functions-cscriptsfunctionsgear)
6. [Logistics & Cargo Subsystem (`cScripts/functions/logistics/`)](#6-logistics--cargo-subsystem-cscriptsfunctionslogistics)
7. [Mission Helpers (`cScripts/functions/mission/`)](#7-mission-helpers-cscriptsfunctionsmission)
8. [Systems Engine (`cScripts/functions/systems/`)](#8-systems-engine-cscriptsfunctionssystems)
9. [ZEN Zeus Modules (`cScripts/functions/modules/`)](#9-zen-zeus-modules-cscriptsfunctionsmodules)
10. [Documents & Briefing Checklists (`cScripts/functions/documents/`)](#10-documents--briefing-checklists-cscriptsfunctionsdocuments)
11. [Diagnostics & Automated Testing (`diag/` & `testing/`)](#11-diagnostics--automated-testing-diag--testing)
12. [Data Assets Summary (`Data/` & `cScripts/Data/`)](#12-data-assets-summary-data--cscriptsdata)
13. [Common Maintenance Tasks ("Where do I change X?")](#13-common-maintenance-tasks-where-do-i-change-x)

---

## 1. Architectural Overview & Lifecycle

cScripts is structured around **CBA Extended Event Handlers (XEH)**, **ACE3 interaction systems**, and engine config hooks. Instead of running monolithic loops, it is event-driven: systems register callbacks, hooks, and ACE actions that execute only when needed (unit spawn, entering staging, opening crates, jumping from aircraft, or Zeus interaction).

### Boot & Execution Timeline

```
[Engine Mission Load]
  │
  ├──> description.ext
  │       ├── Includes cScripts/CfgFunctions.hpp  (Compiles cScripts_fnc_*)
  │       ├── Includes cScripts/CfgLoadouts.hpp   (Mounts loadout definitions)
  │       └── Declares CBA XEH hooks (Extended_PreInit / Extended_PostInit)
  │
  ├──> CBA parses cba_settings.sqf (forces baseline ACE/cScripts mission settings)
  │
[Phase 1: Engine Function PreInit (preInit = 1)]
  │
  └──> cScripts_fnc_gear_preInit
          └── Registers CBA class event handlers on "CAManBase" (InitPost, Respawn, Local)
  │
[Phase 2: CBA Extended PreInit]
  │
  └──> cScripts/cScripts_preInit.sqf
          ├── Detects active mods (ACE, ACEX, Kat, ACRE2, TFAR, ZEN, etc.)
          ├── Registers CBA Addon Settings (cScripts/initSettings.inc.sqf)
          ├── Sets up staging arsenal defaults (cScripts_fnc_init_aceArsenal)
          ├── Compiles logistics database into memory (cScripts_fnc_init_logistics -> cScripts_DATABASE)
          ├── Loads equipment blacklist (cScripts/cScripts_blacklist.sqf -> cScripts_BLACKLIST)
          ├── Registers player chat commands (cScripts_fnc_init_chatCommands)
          ├── Registers ZEN / Zeus curator modules (cScripts_fnc_init_zenModuels)
          └── Binds server logger and player tracking (cScripts_fnc_init_eventHandlers)
  │
[Phase 3: Unit Creation & Engine InitPost]
  │
  └──> "CAManBase" InitPost executes per unit:
          └── Resolves role gear and applies loadout (cScripts_fnc_gear_selectLoadout & applyLoadout)
  │
[Phase 4: Engine Function PostInit (postInit = 1)]
  │
  └──> cScripts_fnc_gear_postInitProxy -> cScripts_fnc_gear_postInit
          └── Hooks "ace_arsenal_displayClosed" to auto-cache custom loadouts
  │
[Phase 5: CBA Extended PostInit]
  │
  └──> cScripts/cScripts_postInit.sqf
          ├── Replaces vanilla FAKs/Medikits with ACE medical (cScripts_fnc_init_aceItemReplace)
          ├── Displays player welcome & difficulty checks (cScripts_fnc_init_message)
          └── Generates briefing diary topics & checklists (cScripts_fnc_init_diary)
  │
[Phase 6: Engine Mission Init]
  │
  └──> init.sqf
          ├── Verifies MP environment
          ├── Sets ACE carry/drag constraints
          └── Hands off execution to custom mission-maker code
```

### Subsystem Relationships

```
                     ┌──────────────────────────────────────────┐
                     │          cScripts_preInit.sqf            │
                     └────┬─────────────────────────────────┬───┘
                          │                                 │
                          v                                 v
        ┌───────────────────────────────────┐     ┌───────────────────────────────────┐
        │       Logistics & Supply DB       │     │     Loadouts & Gear Management    │
        │      (cScripts_logistics.sqf)     │     │    (CfgLoadouts.hpp / gear_*)     │
        └─────────────────┬─────────────────┘     └─────────────────┬─────────────────┘
                          │                                         │
                          ├────────────────────┬────────────────────┤
                          │                    │                    │
                          v                    v                    v
                 ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
                 │ Staging Crates  │  │ Personal Locker │  │ Filtered Staging│
                 │ & Resupply Carts│  │  (addLoadout-   │  │   ACE Arsenal   │
                 │ (fn_doStarter-  │  │    Locker.sqf)  │  │  (fn_addArsenal │
                 │    Crate.sqf)   │  │                 │  │     .sqf)       │
                 └────────┬────────┘  └────────┬────────┘  └────────┬────────┘
                          │                    │                    │
                          └────────────────────┼────────────────────┘
                                               │
                                               v
                          ┌─────────────────────────────────────────┐
                          │         Mission & Live Operations       │
                          │ - ZEN Zeus Modules (modules/zenModule_*)│
                          │ - Airborne Systems (systems/fn_para_*)  │
                          │ - In-Flight Dismounts (fn_addGetOutHelo)│
                          │ - Training Targets (systems/training_*) │
                          │ - Vehicle Decals (fn_setVehicleLable)   │
                          └─────────────────────────────────────────┘
```

---

## 2. Root Files & Engine Entry Points

| File | Purpose & Architectural Role | When / How It Runs | Key Parameters / Variables |
|---|---|---|---|
| `description.ext` | Mission configuration header. Declares engine metadata, MP rules, respawn templates, remote execution policies, garbage collection, ACEX Fortify presets, and includes `CfgFunctions.hpp` and `CfgLoadouts.hpp`. | Evaluated by Arma engine on mission load. | `cba_settings_hasSettingsFile = 1`, `cba_settings_whitelist[]`, `respawn = BASE`, `ACEX_Fortify_Presets`. |
| `init.sqf` | Standard mission startup script. Runs on all clients, server, and headless clients. Partition between core cScripts framework and mission-maker scripts. | Executes after preInit and concurrent with postInit. | Sets `ACE_maxWeightCarry = 8000`, `ACE_maxWeightDrag = 12000`. User scripts go below line 27. |
| `cba_settings.sqf` | Master CBA settings configuration containing forced mission settings (`force force <setting> = <value>;`). Standardizes ACE medical, fatigue, ballistics, radios, and cScripts behavior across all clients. | Parsed and locked by CBA on mission startup. | Forces `cScripts_Settings_*` flags (mission type, diary records, jump simulation, filtered arsenal). |
| `version.txt` | Single-line release tag file. | Read by automated build and packaging scripts (`tools/build.py`). | Current version tag (e.g., `V1.1.3`). |

---

## 3. cScripts Core Headers & Life-Cycle Scripts

| File | Purpose & Architectural Role | When / How It Runs | Key Contents / Details |
|---|---|---|---|
| `cScripts/script_component.hpp` | Component configuration header. Defines root project constants and global toggles. | Included at the top of every SQF and HPP file. | Defines `PREFIX cScripts`, `VERSION "4.5.21"`, and the commented-out `DEBUG_MODE` toggle. |
| `cScripts/script_macros.hpp` | Master preprocessor macro definitions library. Provides namespacing, formatting, safe variable setters, and multi-tier logging macros. | Preprocessed across the framework. | `FUNC()`, `GVAR()`, `SETVAR()`, `GETVAR()`, `SHOW_LOG()`, `SHOW_CHAT_WARNING()`, `SHOW_SERVER_INFO()`. |
| `cScripts/CfgFunctions.hpp` | Registers all framework functions into Arma's `CfgFunctions` under tag `cScripts` (`cScripts_fnc_*`). | Included in `description.ext`. | Organizes functions into categories: `init`, `gear`, `logistics`, `mission`, `systems`, `modules`, `documents`, `diag`, `testing`. |
| `cScripts/cScripts_preInit.sqf` | Master pre-initialization orchestrator. Runs mod detection, sets global state flags, compiles databases, registers chat commands, curator modules, and core event handlers. | Executed via CBA `Extended_PreInit_EventHandlers`. | Initializes `cScripts_Staging_ZoneStatus`, `cScripts_DATABASE`, `cScripts_BLACKLIST`, mod detection flags (`cScripts_patches_uses*`). |
| `cScripts/cScripts_postInit.sqf` | Master post-initialization orchestrator. Runs item replacement, player welcome messages, and briefing generation once entities exist in 3D world. | Executed via CBA `Extended_PostInit_EventHandlers`. | Triggers `fn_init_aceItemReplace`, `fn_init_message`, and `fn_init_diary`. |
| `cScripts/initSettings.inc.sqf` | CBA Addon Settings registration file. Injects cScripts configuration options into the CBA UI and pause menu. | Included inline by `cScripts_preInit.sqf`. | Defines `cScripts_Settings_setMissionType`, `showDiaryRecords`, `useFilteredArsenal`, `replaceMedical`, `jumpSimulation`, etc. |

---

## 4. Initialization Subsystem (`cScripts/functions/init/`)

| File | Function | Purpose & How It Works |
|---|---|---|
| `fn_init_aceArsenal.sqf` | `cScripts_fnc_init_aceArsenal` | Manages staging arsenal lifecycle events and default loadout injection. Sets up `"ace_arsenal_displayClosed"` to cleanup temporary arsenal containers and save the player's selected insignia to `profileNamespace`. |
| `fn_init_aceItemReplace.sqf` | `cScripts_fnc_init_aceItemReplace` | Uses `ace_common_fnc_registerItemReplacement` to automatically convert vanilla `FirstAidKit` and `Medikit` items into standardized ACE Medical supplies (QuickClot, splints, tourniquets, morphine, saline). |
| `fn_init_chatCommands.sqf` | `cScripts_fnc_init_chatCommands` | Registers user chat commands via CBA: `#attendance` (triggers attendance report event), `#cScripts` (displays framework version), and `#loadout` (displays player's current loadout class). |
| `fn_init_diary.sqf` | `cScripts_fnc_init_diary` | Generates briefing records on the map screen. Creates subjects `"TFG"`, `"Chklists"` (Checklists), and `"radioReports"`, calling individual document generator functions. |
| `fn_init_eventHandlers.sqf` | `cScripts_fnc_init_eventHandlers` | Registers framework event handlers: CBA `cScripts_getAttendance`, server log routing (`cScripts_log_text`), and connection tracking (`PlayerConnected` -> `cScripts_log_players` HashMap). |
| `fn_init_logistics.sqf` | `cScripts_fnc_init_logistics` | Parses and compiles `cScripts_logistics.sqf` into an in-memory HashMap stored in the global variable `cScripts_DATABASE`. |
| `fn_init_message.sqf` | `cScripts_fnc_init_message` | Runs on client postInit. Validates server difficulty (warns in chat if not Veteran/Custom) and handles player welcome messages. |
| `fn_init_zenModuels.sqf` | `cScripts_fnc_init_zenModuels` | Registers custom Task Force Grey curator modules into ZEN under categories `"TFG AI"`, `"TFG Logistics"`, `"TFG Utilities"`, and `"TFG Mission"`. |

---

## 5. Gear & Loadout Subsystem

The Gear subsystem automates loadout assignment, saves customized kits, resolves role inheritance, and enforces equipment standards.

### Loadout Resolution Cascade

When a unit spawns, respawns, or changes locality, `cScripts_fnc_gear_selectLoadout` evaluates the unit using a strict 5-tier fallback cascade:

```
1. Saved / Cached Loadout?  ──[Yes]──> Return cached array (cScripts_gear_loadout)
            │ [No]
2. Unit Variable Set?       ──[Yes]──> Return class (cScripts_Gear_LoadoutClass)
            │ [No]
3. 3DEN vehicleVarName?     ──[Yes]──> Return class matching editor name
            │ [No]
4. Unit typeOf (Classname)? ──[Yes]──> Return class matching CfgVehicles class
            │ [No]
5. Side Default Fallback?   ──[Yes]──> Return CommonBlufor / CommonOpfor / etc.
            │ [No]
   Fallback to "" (with chat warning)
```

### Configuration Files (`cScripts/Loadouts/`)

| File | Purpose & Role | Key Classes / Config Entries |
|---|---|---|
| `cScripts/CfgLoadouts.hpp` | Master loadout config root included in `description.ext`. Serves as the mounting point for mission loadout classes. | Defines empty `class CfgLoadouts {};` which is populated and extended by loadout headers. |
| `cScripts/cScripts_blacklist.sqf` | Returns an array of forbidden weapon, launcher, optic, and item classnames stored in `cScripts_BLACKLIST`. | Queried by starter crates and lockers to sanitize arsenals and prevent unapproved equipment from being taken. |
| `cScripts/Loadouts/CfgLoadouts_Bravo_Viking_Weapons.hpp` | Defines platoon-level heavy weapons squad loadouts for Bravo Company (Viking). | Roles: M240B Fireteam Leader, M240B Machinegunner, Ammo Bearer, MAAWS Gunner, MAAWS Assistant, 60mm Mortar Gunner/Assistant. |
| `cScripts/Loadouts/CfgLoadouts_Special.hpp` | Defines specialized headquarters and controller loadouts. | S3 Operations / Mission Controllers (`S3_Base`, `S3`, `S3_1` to `S3_6`). Injects `cScripts_Player_Unit = 'S3'` via `preLoadout`. |
| `cScripts/Loadouts/CfgLoadouts_Training.hpp` | Defines training cadres and recruit gear for qualification ranges. | `Cav_B_Training_Cadre_F` (Instructor), `Cav_B_Training_Cadet_F` (Recruit/Student). |

### Gear Functions (`cScripts/functions/gear/`)

| File | Function | Purpose & How It Works |
|---|---|---|
| `fn_gear_preInit.sqf` | `cScripts_fnc_gear_preInit` | Runs during engine preInit (`preInit = 1`). Hooks CBA event handlers on `CAManBase` (`InitPost`, `Respawn`, `Local`) to automatically assign gear. |
| `fn_gear_postInitProxy.sqf` | `cScripts_fnc_gear_postInitProxy` | Engine postInit bridge (`postInit = 1`). Uses `CBA_fnc_directCall` to execute `fn_gear_postInit.sqf` in an unscheduled environment. |
| `fn_gear_postInit.sqf` | `cScripts_fnc_gear_postInit` | Binds `"ace_arsenal_displayClosed"` event to auto-save custom loadouts and registers the `cScripts_gear_applyLoadout` CBA event. |
| `fn_gear_selectLoadout.sqf` | `cScripts_fnc_gear_selectLoadout` | Core decision engine. Evaluates the unit against the 5-tier resolution cascade and returns the target config class or loadout array. |
| `fn_gear_applyLoadout.sqf` | `cScripts_fnc_gear_applyLoadout` | Applies resolved gear via `CBA_fnc_setLoadout`. Executes `preLoadout` code, filters radio IDs via ACRE2, applies abilities and cosmetics, lowers weapon, and executes `postLoadout` code. |
| `fn_gear_applyAbilities.sqf` | `cScripts_fnc_gear_applyAbilities` | Configures ACE skills on the unit based on config tags: `abilityMedic` (sets `ace_medical_medicClass`), `abilityEngineer` (`ace_isEngineer`), `abilityEOD` (`ACE_isEOD`). |
| `fn_gear_applyCosmetics.sqf` | `cScripts_fnc_gear_applyCosmetics` | Sets player name without rank prefix, assigns in-game rank, applies team color, and applies uniform squad insignia with a 2-second CBA delay. |
| `fn_gear_applyFunctions.sqf` | `cScripts_fnc_gear_applyFunctions` | Automatically inserts ACE earplugs on spawn and grants the "Server Metrics" diagnostic action to logged-in server admins. |
| `fn_gear_getLoadoutDisplayName.sqf` | `cScripts_fnc_gear_getLoadoutDisplayName` | Returns the human-readable `displayName` of a unit's current loadout class for UI menus and attendance logs. |
| `fn_gear_getLoadoutName.sqf` | `cScripts_fnc_gear_getLoadoutName` | Returns the raw internal config classname currently assigned to a unit. |
| `fn_gear_getLoadoutRole.sqf` | `cScripts_fnc_gear_getLoadoutRole` | Returns the role category string (`"officer"`, `"medic"`, `"weapons"`, `"trooper"`) defined in the loadout config. |
| `fn_gear_getSideConfig.sqf` | `cScripts_fnc_gear_getSideConfig` | Maps a side (`west`, `east`, `independent`, `civilian`) to its default fallback base config class (`CommonBlufor`, `CommonOpfor`, etc.). |
| `fn_gear_hasSavedLoadout.sqf` | `cScripts_fnc_gear_hasSavedLoadout` | Returns `true` if the unit has a cached loadout saved from ACE Arsenal (`cScripts_Gear_SavedLoadout`). |
| `fn_gear_loadLoadout.sqf` | `cScripts_fnc_gear_loadLoadout` | Retrieves the saved loadout array from `_unit getVariable "cScripts_gear_loadout"`. |
| `fn_gear_removeLoadout.sqf` | `cScripts_fnc_gear_removeLoadout` | Clears saved loadout cache variables from a unit to reset them to standard default config gear. |
| `fn_gear_saveLoadout.sqf` | `cScripts_fnc_gear_saveLoadout` | Reads unit inventory with `CBA_fnc_getLoadout`, cleans radio IDs, saves the array to `cScripts_Gear_Loadout`, sets saved flag, and persists insignia to `profileNamespace`. |

---

## 6. Logistics & Cargo Subsystem (`cScripts/functions/logistics/`)

| File | Function | Purpose & How It Works |
|---|---|---|
| `cScripts/cScripts_logistics.sqf` | *Data Script* | Master dictionary of crate and vehicle inventories (`GVAR(DATABASE)`). Defines starter crates, resupply crates, infantry medical, Atlas medical, vehicle ammo, and arsenal whitelists. |
| `fn_addCargo.sqf` | `cScripts_fnc_addCargo` | Validates item classnames and counts, then adds them globally to an object using `addItemCargoGlobal`. |
| `fn_checkItemValidity.sqf` | `cScripts_fnc_checkItemValidity` | Verifies an item exists in `CfgMagazines`, `CfgWeapons`, or `CfgVehicles` and respects active ACE/ACEX modules (earplugs, rations, ropes) to prevent missing-mod crashes. |
| `fn_createCargoCrate.sqf` | `cScripts_fnc_createCargoCrate` | Spawns a crate, populates cargo, configures ACE cargo sizes, and can load the crate directly into a vehicle's ACE cargo hold. |
| `fn_doEmptyCrate.sqf` | `cScripts_fnc_doEmptyCrate` | Clears all weapons, ammo, and items from a crate; sets ACE cargo size to 1; makes it draggable/carryable; applies 7th Cavalry custom textures. |
| `fn_doFieldHospital.sqf` | `cScripts_fnc_doFieldHospital` | Designates an object as a Field Hospital facility (`ace_medical_isMedicalFacility = true`) and stocks it with Atlas medical supplies. |
| `fn_doStarterCrateSupplies.sqf` | `cScripts_fnc_doStarterCrateSupplies` | Server-side function that fills a starter crate based on company selection (`"NONE"`, `"FULL"`, `"ALL"`, `"MANUAL"`, `"TFG DEFAULT"`). |
| `fn_doSupplyCrate.sqf` | `cScripts_fnc_doSupplyCrate` | Spawns a resupply crate at a position based on crate type (Infantry Resupply, Atlas Medical, Infantry Medical, Stinger) and registers it with Zeus. |
| `fn_logistics_getAllContainerItems.sqf` | `cScripts_fnc_logistics_getAllContainerItems` | Returns an array of all item classnames registered across all containers in the logistics database (used for whitelisting and testing). |
| `fn_logistics_getContainer.sqf` | `cScripts_fnc_logistics_getContainer` | Retrieves the item array for a specific crate key from `cScripts_DATABASE`. |
| `fn_setCargo.sqf` | `cScripts_fnc_setCargo` | Completely wipes an object's current inventory and populates it with a specified items array via `fn_addCargo`. |
| `fn_setCargoAttributes.sqf` | `cScripts_fnc_setCargoAttributes` | Sets ACE cargo storage space (`ace_cargo_fnc_setSpace`), cargo size (`setSize`), and dragging/carrying properties on an object. |

---

## 7. Mission Helpers (`cScripts/functions/mission/`)

| File | Function | Purpose & How It Works |
|---|---|---|
| `fn_addEscapeWreck.sqf` | `cScripts_fnc_addEscapeWreck` | Adds a hold action ("Escape Wreck") to airframes allowing crew and passengers to safely egress destroyed or burning wrecks via `fn_doGetOutHeloSide`. |
| `fn_addGetOutHelo.sqf` | `cScripts_fnc_addGetOutHelo` | Adds quick dismount scroll-wheel actions to helicopters allowing cargo passengers to rapidly egress on the left or right door. |
| `fn_addHaloJump.sqf` | `cScripts_fnc_addHaloJump` | Attaches a high-altitude HALO jump hold action to transport aircraft. Validates altitude (e.g. >= 5000m) and open ramp before triggering `fn_para_haloJump`. |
| `fn_addLineJump.sqf` | `cScripts_fnc_addLineJump` | Attaches a static line jump hold action to transport aircraft. Checks altitude (180–350m) and airspeed (<= 310 km/h) before triggering `fn_para_lineJump`. |
| `fn_addLoadoutAction.sqf` | `cScripts_fnc_addLoadoutAction` | Adds an addAction on an object to equip a specific loadout: `[this, "Rifleman", "Cav_B_B_Weapons_Rifleman_F"] call cScripts_fnc_addLoadoutAction`. |
| `fn_doStarterCrate.sqf` | `cScripts_fnc_doStarterCrate` | Master staging crate initializer. Attaches Re-Gear, Heal, Insignia selection, ACE Loadout selection, Meal consumption, and debris cleanup. |
| `fn_makeAgent.sqf` | `cScripts_fnc_makeAgent` | Replaces an editor AI unit with a lightweight Arma agent (`createAgent`) to reduce AI processing overhead for base ambient guards/civilians. |
| `fn_setVehicleLable.sqf` | `cScripts_fnc_setVehicleLable` | Attaches tactical callsigns, numerals, and troop decals to air and ground vehicles (UH-60, C-130J, Stryker, Bradley, Abrams) using `UserTexture1m_F`. |

---

## 8. Systems Engine (`cScripts/functions/systems/`)

The Systems engine powers interactive menus, staging mechanics, airborne physics, training range automation, and server diagnostics.

| File | Function | Purpose & How It Works |
|---|---|---|
| `fn_addArsenal.sqf` | `cScripts_fnc_addArsenal` | Spawns an on-demand, filtered ACE Staging Arsenal tailored to the player's assigned role and company. |
| `fn_addDefaultArsenalLoadout.sqf` | `cScripts_fnc_addDefaultArsenalLoadout` | Injects the player's active role loadout into the ACE Arsenal default loadout templates. |
| `fn_addDefaultArsenalLoadouts.sqf` | `cScripts_fnc_addDefaultArsenalLoadouts` | Scans `CfgLoadouts` and loads every valid loadout class into ACE Arsenal's default loadout list. |
| `fn_addEatMeal.sqf` | `cScripts_fnc_addEatMeal` | Adds an ACE interaction to consume a full field meal, resetting ACEX hunger and thirst to zero after a 10-second progress bar. |
| `fn_addHeal.sqf` | `cScripts_fnc_addHeal` | Adds an action to fully heal the player via ACE medical. Automatically disabled if `OneLife` mode is active. |
| `fn_addInsigniaSelection.sqf` | `cScripts_fnc_addInsigniaSelection` | Helper function that creates individual insignia selection actions on an object. |
| `fn_addInsigniaSelectionList.sqf` | `cScripts_fnc_addInsigniaSelectionList` | Builds the hierarchical ACE interaction tree for 7th Cavalry uniform patches (Regimental, Alpha, Bravo, Charlie, Specialized). |
| `fn_addLoadoutLocker.sqf` | `cScripts_fnc_addLoadoutLocker` | Manages Personal Loadout Lockers. Supports claiming/abandoning lockers, owner-only gear management, saving/loading custom kits, and admin overrides. |
| `fn_addLoadoutSelection.sqf` | `cScripts_fnc_addLoadoutSelection` | Adds an individual ACE interaction action for a specific loadout class to a crate or locker. |
| `fn_addObjectToCurator.sqf` | `cScripts_fnc_addObjectToCurator` | Adds a dynamically spawned object or crate to all active Zeus curator interfaces on the next frame. |
| `fn_addReGear.sqf` | `cScripts_fnc_addReGear` | Adds an action to reset the player's ammo, explosives, and role gear back to their starting loadout. |
| `fn_addRolePermissions.sqf` | `cScripts_fnc_addRolePermissions` | ACE interaction menu allowing players to toggle specialist qualifications: Combat Lifesaver, Doctor/Medic, EOD Specialist, or Advanced Engineer. |
| `fn_allowLoadout.sqf` | `cScripts_fnc_allowLoadout` | Permission gatekeeper. Checks whether a player's assigned company permits them to equip a specific loadout (bypassed by Zeus and Admins). |
| `fn_clearDefaultArsenalLoadouts.sqf` | `cScripts_fnc_clearDefaultArsenalLoadouts` | Empties the `ace_arsenal_defaultLoadoutsList` array before building custom whitelists. |
| `fn_createActionCategory.sqf` | `cScripts_fnc_createActionCategory` | Helper function to build nested ACE interaction categories on objects. |
| `fn_createVehicleLable.sqf` | `cScripts_fnc_createVehicleLable` | Creates a `UserTexture1m_F` decal object and attaches it to a vehicle at a specified offset and vector rotation. |
| `fn_deleteDroppedObjects.sqf` | `cScripts_fnc_deleteDroppedObjects` | Garbage collection monitor that deletes weapon and backpack ground holders dropped around staging crates once players move away. |
| `fn_doGetOutHeloSide.sqf` | `cScripts_fnc_doGetOutHeloSide` | Safely ejects a passenger 2.5m out the left or right door of a helicopter while triggering door animations. |
| `fn_filterUnitLoadout.sqf` | `cScripts_fnc_filterUnitLoadout` | Strips runtime instance radio IDs (ACRE2/TFAR) from a loadout array, replacing them with base classnames to prevent radio duplication bugs. |
| `fn_getArsenalWhitelist.sqf` | `cScripts_fnc_getArsenalWhitelist` | Compiles an item whitelist for ACE Arsenal based on player role: includes base loadout items, common equipment, company kit, and matching weapon family accessories. |
| `fn_getAttendance.sqf` | `cScripts_fnc_getAttendance` | Compiles connected player attendance logs (name, role loadout, UTC join time, reconnection counts) and outputs formatted summaries to RPT and chat. |
| `fn_getIcon.sqf` | `cScripts_fnc_getIcon` | Resolves icon strings into absolute texture paths across Arma configs and local mission directories. |
| `fn_getServerMetrics.sqf` | `cScripts_fnc_getServerMetrics` | Diagnostic tool that displays current server FPS, minimum FPS, entity counts, tick uptime, and running SQF script counts to admins. |
| `fn_getVehicleLable.sqf` | `cScripts_fnc_getVehicleLable` | Translates shorthand callsigns and numbers (`"A"`, `"B"`, `"1"`-`"0"`, `"LINE"`, `"STRYKER"`) into texture PAA paths. |
| `fn_para_backpack.sqf` | `cScripts_fnc_para_backpack` | Front-mounts a player's backpack during airborne operations: saves backpack and contents, equips parachute, and adds a ground-only action to restore gear. |
| `fn_para_equipment.sqf` | `cScripts_fnc_para_equipment` | Simulates aerodynamic equipment loss during parachute jumps (drops unstrapped soft caps, NVGs, or sport glasses based on jump simulation difficulty). |
| `fn_para_haloJump.sqf` | `cScripts_fnc_para_haloJump` | Executes high-altitude freefall jump sequence: safely ejects player from aircraft ramp, runs equipment check, and front-mounts backpack. |
| `fn_para_lineJump.sqf` | `cScripts_fnc_para_lineJump` | Executes static line jump sequence: ejects player into airflow, spawns parachute vehicle, moves player directly into canopy, and runs equipment check. |
| `fn_renameObject.sqf` | `cScripts_fnc_renameObject` | Sets `ace_cargo_customName` globally on an object for clear display inside ACE Cargo menus. |
| `fn_setupLoadoutCategories.sqf` | `cScripts_fnc_setupLoadoutCategories` | Builds the hierarchical ACE interaction menu structure for organization loadouts (Alpha Co., Bravo Co., Charlie Co., Training, OPFOR). |
| `fn_setupLoadoutSelection.sqf` | `cScripts_fnc_setupLoadoutSelection` | Scans `CfgLoadouts` and dynamically generates selectable ACE loadout actions on a crate or locker. |
| `fn_training_addHitIndicator.sqf` | `cScripts_fnc_training_addHitIndicator` | Adds a `HitPart` event handler to target silhouettes, spawning small 3D spheres at bullet impact points or mirroring them onto a shooter feedback board. |
| `fn_training_addTargetComputer.sqf` | `cScripts_fnc_training_addTargetComputer` | Disables Arma target auto-reset and links targets to a range control console that can raise and reset all targets on command. |
| `fn_training_clearhitIndicator.sqf` | `cScripts_fnc_training_clearhitIndicator` | Deletes all 3D bullet impact marker spheres from target silhouettes and feedback boards. |

---

## 9. ZEN Zeus Modules (`cScripts/functions/modules/`)

Modules registered into the ZEN (Zeus Enhanced) interface for Game Masters during operations.

| File | Function | Purpose & How It Works |
|---|---|---|
| `fn_zenModule_applyLoadout.sqf` | `cScripts_fnc_zenModule_applyLoadout` | ZEN dialog allowing Zeus to select any loadout from `CfgLoadouts` and force-apply it to a clicked player or AI unit. |
| `fn_zenModule_callEndex.sqf` | `cScripts_fnc_zenModule_callEndex` | Declares ENDEX (End of Exercise). Locks player weapon safeties, pacifies AI groups (Careless/Blue), heals all players, and triggers attendance logging. |
| `fn_zenModule_createStarterCrate.sqf` | `cScripts_fnc_zenModule_createStarterCrate` | Spawns a full 7th Cavalry staging crate in the field with configurable company filters, heal actions, and arsenal toggles. |
| `fn_zenModule_createSupplyCrate.sqf` | `cScripts_fnc_zenModule_createSupplyCrate` | Spawns resupply crates (Infantry Resupply, Atlas Medical, Infantry Medical, Stinger MANPAD). |
| `fn_zenModule_enableUnitSimulation.sqf` | `cScripts_fnc_zenModule_enableUnitSimulation` | Wakes up frozen or cached AI groups by enabling simulation and un-hiding objects globally. |
| `fn_zenModule_regearTrooper.sqf` | `cScripts_fnc_zenModule_regearTrooper` | Re-applies the assigned starting loadout to a clicked unit to quickly re-arm them in the field. |

---

## 10. Documents & Briefing Checklists (`cScripts/functions/documents/`)

Post-initialization functions that build tactical references in the player's in-game briefing screen under `"Chklists"` and `"radioReports"`.

| File | Function | Topic / Title | Content Summary |
|---|---|---|---|
| `fn_DocChklist_CFF.sqf` | `cScripts_fnc_DocChklist_CFF` | `Chklists` > CALL FOR FIRE | Displays Call-For-Fire transmission card graphic (`CFF.jpg`). |
| `fn_DocChklist_JMTASKS.sqf` | `cScripts_fnc_DocChklist_JMTASKS` | `Chklists` > JUMPMASTER CHECKLISTS | Airborne jumpmaster procedures, stick briefing guide, and drop checklists (`AB_Admin_Checklist.paa`, `AB_Drop_Checklist.paa`). |
| `fn_DocChklist_LZEXTRACT.sqf` | `cScripts_fnc_DocChklist_LZEXTRACT` | `Chklists` > HELO EXTRACTION | Helicopter extraction SOPs and checklists (`extract-admin-checklist.paa`, `extract-extract-checklist.paa`). |
| `fn_DocChklist_LZINSERT.sqf` | `cScripts_fnc_DocChklist_LZINSERT` | `Chklists` > HELO INSERTION | Helicopter insertion SOPs and checklists (`insertion-admin-checklist.paa`, `insertion-insert-checklist.paa`). |
| `fn_DocChklist_LZSPECS.sqf` | `cScripts_fnc_DocChklist_LZSPECS` | `Chklists` > LZ/PZ SPECIFICATIONS | Landing point diameter sizes by airframe (`LPSIZES.paa`), terrain types (`LZTYPES.paa`), and map markings (`LZ-MAP-MARKINGS.paa`). |
| `fn_DocRadio_LACEACE.sqf` | `cScripts_fnc_DocRadio_LACEACE` | `radioReports` > LACE/ACE REPORT | Scripted format for reporting Liquids, Ammunition, Casualties, and Equipment. |
| `fn_DocRadio_MEDEVAC.sqf` | `cScripts_fnc_DocRadio_MEDEVAC` | `radioReports` > MEDEVAC REQUEST | Standard 6-line aeromedical evacuation request script with line-by-line guidelines. |
| `fn_DocRadio_ROTARYPICKUP.sqf` | `cScripts_fnc_DocRadio_ROTARYPICKUP` | `radioReports` > ROTARY PICKUP | Tactical extraction request script for helicopter passenger transport. |
| `fn_DocRadio_SPOTREP.sqf` | `cScripts_fnc_DocRadio_SPOTREP` | `radioReports` > SPOTREP | SALUTE-derived Spot Report format (Size, Activity, Location, Uniform, Time, Equipment, Actions). |

---

## 11. Diagnostics & Automated Testing (`diag/` & `testing/`)

| File | Function | Purpose & How It Works |
|---|---|---|
| `cScripts/functions/diag/fn_log.sqf` | `cScripts_fnc_log` | Core logging engine. Formats log lines (`[cScripts] (component) TYPE: message`), writes to local RPT, can forward logs to dedicated server RPT via CBA event `cScripts_log_text`, and optionally echoes to chat. |
| `cScripts/functions/diag/fn_error.sqf` | `cScripts_fnc_error` | Diagnostic wrapper for errors. Defaults: shows in chat, type `"ERROR"`. |
| `cScripts/functions/diag/fn_info.sqf` | `cScripts_fnc_info` | Diagnostic wrapper for info logs. Defaults: RPT only, type `"INFO"`. |
| `cScripts/functions/diag/fn_warning.sqf` | `cScripts_fnc_warning` | Diagnostic wrapper for warnings. Defaults: RPT only, type `"WARNING"`. |
| `cScripts/functions/testing/fn_testing_equipmentUsed.sqf` | `cScripts_fnc_testing_equipmentUsed` | Automated QA test. Iterates over all item classnames in `cScripts_DATABASE` and asserts that every item exists in `CfgMagazines`, `CfgWeapons`, or `CfgVehicles`. |
| `cScripts/functions/testing/fn_testing_loadoutArrays.sqf` | `cScripts_fnc_testing_loadoutArrays` | Automated QA test. Parses all `CfgLoadouts` classes and validates that their `loadout` strings conform to standard Arma 3 10-element `getUnitLoadout` array syntax. |

---

## 12. Data Assets Summary (`Data/` & `cScripts/Data/`)

- `Data/MissionLogo.paa` & `Data/MissionLogo.psd`: Loading screen and overview graphic displayed during mission load.
- `cScripts/Data/Icon/`: Custom UI icons for ACE interactions and loadout locker menus (`icon_arsenal_ca.paa`, `icon_00.paa`, `icon_x.paa`, etc.).
- `cScripts/Data/Images/`: Graphical checklists and references embedded into player map diaries (CFF card, airborne drop checklists, rotary LZ/PZ specification charts).

---

## 13. Common Maintenance Tasks ("Where do I change X?")

| Desired Change | Primary Files to Modify | Notes |
|---|---|---|
| **Add or edit crate supplies / vehicle cargo** | `cScripts/cScripts_logistics.sqf` | Add or update container arrays in `GVAR(DATABASE)`. Run `call cScripts_fnc_testing_equipmentUsed` to verify classnames. |
| **Add or edit player role loadouts** | `cScripts/Loadouts/` (e.g., `CfgLoadouts_Bravo_Viking_Weapons.hpp`) | Inherit from company base class, set `scope = 2`, `displayName`, `role`, and `loadout` array. Run `call cScripts_fnc_testing_loadoutArrays`. |
| **Change forced ACE / mission settings** | `cba_settings.sqf` | Look for `force force <settingName> = <value>;`. |
| **Add or adjust framework CBA settings** | `cScripts/initSettings.inc.sqf` | Uses `CBA_fnc_addSetting`. |
| **Add a new Zeus curator module** | `cScripts/functions/init/fn_init_zenModuels.sqf` & `cScripts/functions/modules/` | Register the module with `zen_custom_modules_fnc_register` and create the module handler. |
| **Add a briefing checklist or SOP card** | `cScripts/functions/documents/` & `fn_init_diary.sqf` | Create a new `fn_DocChklist_*.sqf` and call it inside `fn_init_diary.sqf`. |
| **Ban or permit an equipment classname** | `cScripts/cScripts_blacklist.sqf` | Add or remove classnames from the returned blacklist array. |
| **Add a tactical vehicle decal / number** | `cScripts/functions/systems/fn_getVehicleLable.sqf` & `fn_setVehicleLable.sqf` | Add decal mapping in `fn_getVehicleLable.sqf` and model offset coordinates in `fn_setVehicleLable.sqf`. |
