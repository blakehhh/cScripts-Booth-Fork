// Control Types
#define CT_STATIC           0
#define CT_BUTTON           1
#define CT_STRUCTURED_TEXT  13

// Static Styles
#define ST_LEFT             0x00
#define ST_RIGHT            0x01
#define ST_CENTER           0x02
#define ST_VCENTER          0x0c
#define ST_BACKGROUND       80

// Dialog Dimensions (Centered)
#define LOCKER_W 0.54
#define LOCKER_H 0.48
#define LOCKER_X (safezoneX + (safezoneW - LOCKER_W) / 2)
#define LOCKER_Y (safezoneY + (safezoneH - LOCKER_H) / 2)
#define TITLE_H  0.038

// Base Classes
class cScripts_RscText {
    access = 0;
    type = CT_STATIC;
    idc = -1;
    style = ST_LEFT;
    colorBackground[] = {0, 0, 0, 0};
    colorText[] = {1, 1, 1, 1};
    colorShadow[] = {0, 0, 0, 0.5};
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    linespacing = 1;
    shadow = 1;
    text = "";
    fixedWidth = 0;
    x = 0;
    y = 0;
    h = 0.037;
    w = 0.3;
};

class cScripts_RscStructuredText {
    access = 0;
    type = CT_STRUCTURED_TEXT;
    idc = -1;
    style = 0;
    colorText[] = {1, 1, 1, 1};
    class Attributes {
        font = "RobotoCondensed";
        color = "#ffffff";
        colorLink = "#D09B43";
        align = "left";
        shadow = 1;
    };
    x = 0;
    y = 0;
    h = 0.035;
    w = 0.1;
    text = "";
    size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    shadow = 1;
};

class cScripts_RscButton {
    access = 0;
    type = CT_BUTTON;
    text = "";
    colorText[] = {1, 1, 1, 1};
    colorDisabled[] = {0.5, 0.5, 0.5, 0.6};
    colorBackground[] = {0.18, 0.22, 0.28, 1};
    colorBackgroundDisabled[] = {0.12, 0.14, 0.17, 0.8};
    colorBackgroundActive[] = {0.26, 0.32, 0.40, 1};
    colorFocused[] = {0.26, 0.32, 0.40, 1};
    colorShadow[] = {0, 0, 0, 0};
    colorBorder[] = {0, 0, 0, 1};
    soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter", 0.09, 1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush", 0.09, 1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick", 0.09, 1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape", 0.09, 1};
    style = ST_CENTER + ST_VCENTER;
    x = 0;
    y = 0;
    w = 0.095589;
    h = 0.039216;
    shadow = 1;
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.95)";
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0.001;
    offsetPressedY = 0.001;
    borderSize = 0;
};

class cScripts_RscButtonAccent: cScripts_RscButton {
    colorBackground[] = {0.75, 0.55, 0.08, 0.95};
    colorBackgroundActive[] = {0.90, 0.70, 0.15, 1.0};
    colorFocused[] = {0.90, 0.70, 0.15, 1.0};
    font = "RobotoCondensedBold";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.05)";
};

class cScripts_RscButtonDanger: cScripts_RscButton {
    colorBackground[] = {0.55, 0.15, 0.15, 0.9};
    colorBackgroundActive[] = {0.75, 0.20, 0.20, 1.0};
    colorFocused[] = {0.75, 0.20, 0.20, 1.0};
};

class cScripts_RscButtonRole: cScripts_RscButton {
    colorBackground[] = {0, 0, 0, 0};
    colorBackgroundDisabled[] = {0, 0, 0, 0};
    colorBackgroundActive[] = {1, 1, 1, 0.15};
    colorFocused[] = {0, 0, 0, 0};
    colorShadow[] = {0, 0, 0, 0};
    borderSize = 0;
};

class cScripts_RscLoadoutLocker {
    idd = 19100;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "['onLoad', _this] call cScripts_fnc_loadoutLocker_ui;";

    class ControlsBackground {
        class MainBackground: cScripts_RscText {
            style = ST_BACKGROUND;
            colorBackground[] = {0.11, 0.13, 0.16, 0.95};
            x = LOCKER_X;
            y = LOCKER_Y;
            w = LOCKER_W;
            h = LOCKER_H;
        };

        // Left Column (Presets) Backgrounds
        class PresetsHeader: cScripts_RscText {
            style = ST_LEFT + ST_VCENTER;
            colorBackground[] = {0.14, 0.17, 0.22, 1.0};
            colorText[] = {0.95, 0.75, 0.15, 1.0};
            font = "RobotoCondensedBold";
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.95)";
            text = " LOADOUT PRESETS";
            x = LOCKER_X + 0.016;
            y = LOCKER_Y + 0.048;
            w = 0.248;
            h = 0.028;
        };

        class PresetsPanel: cScripts_RscText {
            style = ST_BACKGROUND;
            colorBackground[] = {0.14, 0.17, 0.22, 0.5};
            x = LOCKER_X + 0.016;
            y = LOCKER_Y + 0.076;
            w = 0.248;
            h = 0.250;
        };

        // Right Column (Roles) Backgrounds
        class RolesHeader: cScripts_RscText {
            style = ST_LEFT + ST_VCENTER;
            colorBackground[] = {0.14, 0.17, 0.22, 1.0};
            colorText[] = {0.95, 0.75, 0.15, 1.0};
            font = "RobotoCondensedBold";
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.95)";
            text = " SPECIALTY ROLES";
            x = LOCKER_X + 0.276;
            y = LOCKER_Y + 0.048;
            w = 0.248;
            h = 0.028;
        };

        class RolesPanel: cScripts_RscText {
            style = ST_BACKGROUND;
            colorBackground[] = {0.14, 0.17, 0.22, 0.5};
            x = LOCKER_X + 0.276;
            y = LOCKER_Y + 0.076;
            w = 0.248;
            h = 0.250;
        };

        // Bottom Maintenance Backgrounds
        class MaintenanceHeader: cScripts_RscText {
            style = ST_LEFT + ST_VCENTER;
            colorBackground[] = {0.14, 0.17, 0.22, 1.0};
            colorText[] = {0.95, 0.75, 0.15, 1.0};
            font = "RobotoCondensedBold";
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.95)";
            text = " FIELD MAINTENANCE & MANAGEMENT";
            x = LOCKER_X + 0.016;
            y = LOCKER_Y + 0.338;
            w = LOCKER_W - 0.032;
            h = 0.028;
        };

        class MaintenancePanel: cScripts_RscText {
            style = ST_BACKGROUND;
            colorBackground[] = {0.14, 0.17, 0.22, 0.5};
            x = LOCKER_X + 0.016;
            y = LOCKER_Y + 0.366;
            w = LOCKER_W - 0.032;
            h = 0.098;
        };
    };

    class Controls {
        class TitleBar: cScripts_RscText {
            idc = 19101;
            style = ST_LEFT + ST_VCENTER;
            colorBackground[] = {0.08, 0.10, 0.12, 1.0};
            colorText[] = {0.95, 0.75, 0.15, 1.0};
            font = "RobotoCondensedBold";
            sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.05)";
            text = " PERSONAL LOADOUT LOCKER";
            x = LOCKER_X;
            y = LOCKER_Y;
            w = LOCKER_W - TITLE_H;
            h = TITLE_H;
        };

        class CloseBtn: cScripts_RscButton {
            idc = 2;
            shortcuts[] = {0x00050000 + 1};
            text = "X";
            style = ST_CENTER + ST_VCENTER;
            colorBackground[] = {0.55, 0.15, 0.15, 0.9};
            colorBackgroundActive[] = {0.85, 0.20, 0.20, 1.0};
            font = "RobotoCondensedBold";
            x = LOCKER_X + LOCKER_W - TITLE_H;
            y = LOCKER_Y;
            w = TITLE_H;
            h = TITLE_H;
            action = "closeDialog 0;";
        };

        // Left Column (Loadouts) Controls
        class BtnCombatKit: cScripts_RscButton {
            idc = 19110;
            text = "Equip Combat Kit";
            x = LOCKER_X + 0.026;
            y = LOCKER_Y + 0.088;
            w = 0.228;
            h = 0.038;
            action = "['equipKit', ['Combat Kit']] call cScripts_fnc_loadoutLocker_ui;";
        };

        class BtnReconKit: cScripts_RscButton {
            idc = 19111;
            text = "Equip Recon Kit";
            x = LOCKER_X + 0.026;
            y = LOCKER_Y + 0.138;
            w = 0.228;
            h = 0.038;
            action = "['equipKit', ['Recon Kit']] call cScripts_fnc_loadoutLocker_ui;";
        };

        class BtnCasualKit: cScripts_RscButton {
            idc = 19112;
            text = "Equip Casual Kit";
            x = LOCKER_X + 0.026;
            y = LOCKER_Y + 0.188;
            w = 0.228;
            h = 0.038;
            action = "['equipKit', ['Casual Kit']] call cScripts_fnc_loadoutLocker_ui;";
        };

        class BtnArsenal: cScripts_RscButtonAccent {
            idc = 19113;
            text = "OPEN TFG ARSENAL";
            x = LOCKER_X + 0.026;
            y = LOCKER_Y + 0.255;
            w = 0.228;
            h = 0.053;
            action = "['openArsenal'] call cScripts_fnc_loadoutLocker_ui;";
        };

        // Right Column (Roles) Controls
        class BgRoleCLS: cScripts_RscText {
            idc = 19125;
            style = ST_BACKGROUND;
            colorBackground[] = {0.18, 0.22, 0.28, 1};
            x = LOCKER_X + 0.286;
            y = LOCKER_Y + 0.088;
            w = 0.228;
            h = 0.038;
        };
        class BtnRoleCLS: cScripts_RscButtonRole {
            idc = 19120;
            text = "Combat Lifesaver (CLS)";
            x = LOCKER_X + 0.286;
            y = LOCKER_Y + 0.088;
            w = 0.228;
            h = 0.038;
            action = "['setRole', ['CLS']] call cScripts_fnc_loadoutLocker_ui;";
        };

        class BgRoleMedic: cScripts_RscText {
            idc = 19126;
            style = ST_BACKGROUND;
            colorBackground[] = {0.18, 0.22, 0.28, 1};
            x = LOCKER_X + 0.286;
            y = LOCKER_Y + 0.132;
            w = 0.228;
            h = 0.038;
        };
        class BtnRoleMedic: cScripts_RscButtonRole {
            idc = 19121;
            text = "Medic / Doctor";
            x = LOCKER_X + 0.286;
            y = LOCKER_Y + 0.132;
            w = 0.228;
            h = 0.038;
            action = "['setRole', ['Medic']] call cScripts_fnc_loadoutLocker_ui;";
        };

        class BgRoleEngineer: cScripts_RscText {
            idc = 19127;
            style = ST_BACKGROUND;
            colorBackground[] = {0.18, 0.22, 0.28, 1};
            x = LOCKER_X + 0.286;
            y = LOCKER_Y + 0.176;
            w = 0.228;
            h = 0.038;
        };
        class BtnRoleEngineer: cScripts_RscButtonRole {
            idc = 19122;
            text = "Advanced Engineer";
            x = LOCKER_X + 0.286;
            y = LOCKER_Y + 0.176;
            w = 0.228;
            h = 0.038;
            action = "['setRole', ['Engineer']] call cScripts_fnc_loadoutLocker_ui;";
        };

        class BgRoleEOD: cScripts_RscText {
            idc = 19128;
            style = ST_BACKGROUND;
            colorBackground[] = {0.18, 0.22, 0.28, 1};
            x = LOCKER_X + 0.286;
            y = LOCKER_Y + 0.220;
            w = 0.228;
            h = 0.038;
        };
        class BtnRoleEOD: cScripts_RscButtonRole {
            idc = 19123;
            text = "EOD Specialist";
            x = LOCKER_X + 0.286;
            y = LOCKER_Y + 0.220;
            w = 0.228;
            h = 0.038;
            action = "['setRole', ['EOD']] call cScripts_fnc_loadoutLocker_ui;";
        };

        class BtnRoleClear: cScripts_RscButton {
            idc = 19124;
            text = "Remove All Roles";
            x = LOCKER_X + 0.286;
            y = LOCKER_Y + 0.270;
            w = 0.228;
            h = 0.038;
            action = "['setRole', ['clearAll']] call cScripts_fnc_loadoutLocker_ui;";
        };

        // Bottom Maintenance Controls
        class BtnHeal: cScripts_RscButton {
            idc = 19130;
            text = "Full Treatment";
            x = LOCKER_X + 0.026;
            y = LOCKER_Y + 0.386;
            w = 0.155;
            h = 0.058;
            action = "['heal'] call cScripts_fnc_loadoutLocker_ui;";
        };

        class BtnEatDrink: cScripts_RscButton {
            idc = 19131;
            text = "Eat & Drink";
            x = LOCKER_X + 0.192;
            y = LOCKER_Y + 0.386;
            w = 0.155;
            h = 0.058;
            action = "['eatAndDrink'] call cScripts_fnc_loadoutLocker_ui;";
        };

        class BtnAbandon: cScripts_RscButtonDanger {
            idc = 19140;
            text = "Abandon Locker";
            x = LOCKER_X + 0.358;
            y = LOCKER_Y + 0.386;
            w = 0.155;
            h = 0.058;
            action = "['abandonLocker'] call cScripts_fnc_loadoutLocker_ui;";
        };
    };
};
