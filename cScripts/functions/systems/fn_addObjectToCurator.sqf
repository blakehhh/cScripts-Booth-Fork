#include "..\script_component.hpp"
/*
 * Author: CPL.Brostrom.A (Optimized)
 * Adds object(s) to all curators on next frame. Must execute on server.
 *
 * Arguments:
 * 0: Object or Array of Objects <OBJECT | ARRAY>
 *
 * Example:
 * [this] call cScripts_fnc_addObjectToCurator;
 * [[crate1, crate2]] call cScripts_fnc_addObjectToCurator;
 *
 * Public: No
 */

if (!isServer) exitWith {
    if (time > 0) then {
        _this remoteExecCall [QFUNC(addObjectToCurator), 2];
    };
};

private _objects = [];
if (_this isEqualType objNull) then {
    _objects = [_this];
} else {
    if (_this isEqualType []) then {
        if (count _this > 0 && {_this select 0 isEqualType objNull}) then {
            _objects = _this;
        } else {
            if (count _this > 0 && {_this select 0 isEqualType []}) then {
                _objects = _this select 0;
            };
        };
    };
};

_objects = _objects select {!isNull _x};
if (_objects isEqualTo []) exitWith {};

[{
    params ["_objects"];
    {
        _x addCuratorEditableObjects [_objects, false];
    } forEach allCurators;
    INFO_1("addObjectToCurator", "%1 objects have been added to all curators.", count _objects);
}, [_objects]] call CBA_fnc_execNextFrame;