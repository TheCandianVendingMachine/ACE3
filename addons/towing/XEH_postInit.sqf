#include "script_component.hpp"
["MouseButtonDown", LINKFUNC(onMouseButtonDown)] call CBA_fnc_addDisplayHandler;
["MouseButtonUp", LINKFUNC(onMouseButtonUp)] call CBA_fnc_addDisplayHandler;
GVAR(mouseLeft) = false;
GVAR(mouseRight) = false;

GVAR(cancel) = false;
GVAR(canAttach) = false;

[QGVAR(lockVehicle), {
    params ["_vehicle", "_lock"];
    if (_lock) then {
        _vehicle lock 2;
    } else {
        _vehicle lock 0;
    };
}] call CBA_fnc_addEventHandler;

[QGVAR(setTowParent), {
    params ["_parent", "_child"];
    _child setTowParent _parent;
}] call CBA_fnc_addEventHandler;

if (!isServer) exitWith {};

["Tank", "initPost", {(_this select 0) addItemCargoGlobal ["ACE_rope12", 1]}, true, [], true] call CBA_fnc_addClassEventHandler;
["Car", "initPost", {
    params ["_car"];
    private _rope = ["ACE_rope6", "ACE_rope12"] select (_car isKindOf "Truck_F" || {_car isKindOf "Wheeled_APC_F"});
    _car addItemCargoGlobal [_rope, 1]
}, true, [], true] call CBA_fnc_addClassEventHandler;
