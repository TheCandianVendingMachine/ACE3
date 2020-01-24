#include "script_component.hpp"
/*
 * Author: Brandon (TCVM)
 * Updates camera with inputs
 *
 * Arguments:
 * 0: Guidance Arg Array <ARRAY>
 * 1: PFID <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [[], 0] call ace_missileguidance_fnc_guidancePFH;
 *
 * Public: No
 */
params ["_key", "_down"];

if !([objNull] call FUNC(camera_userInCamera)) exitWith {};

private _return = false;
private _lookInput = GVAR(activeCamera) getVariable [QGVAR(lookInput), [0, 0, 0, 0]];
private _designateInput = GVAR(activeCamera) getVariable [QGVAR(designateInput), [0]];
switch (_key) do {
    case 1: {
        // designate whatever. depends on seeker to implement
        if (_down) then {
            _designateInput set [0, 1];
        } else {
            _designateInput set [0, 0];
        };
        _return = true;
    }; //MF key 1
    case 2: {
        [] call FUNC(camera_switchAway);
    }; // MF Key 2
    case 3: {
        if (_down) then {
            _lookInput set [0, 1];
        } else {
            _lookInput set [0, 0];
        };
        _return = true;
    }; //Up
    
    case 4: {
        if (_down) then {
            _lookInput set [2, 1];
        } else {
            _lookInput set [2, 0];
        };
        _return = true;
    }; //Left
    
    case 5: {
        if (_down) then {
            _lookInput set [3, 1];
        } else {
            _lookInput set [3, 0];
        };
        _return = true;
    }; //Right
    
    case 6: {
        if (_down) then {
            _lookInput set [1, 1];
        } else {
            _lookInput set [1, 0];
        };
        _return = true;
    }; //Down
    case 7: {
        if(_down) then {
            [GVAR(activeCamera)] call FUNC(camera_cycleViewMode);
        };
        _return = true;
    }; //N
    case 8: {
        if(_down) then {
            [GVAR(activeCamera), true] call FUNC(camera_changeZoom);
        };
        _return = true;
    }; // Num+
    case 9: {
        if(_down) then {
            [GVAR(activeCamera), false] call FUNC(camera_changeZoom);
        };
        _return = true;
    }; // Num-
};
GVAR(activeCamera) setVariable [QGVAR(designateInput), _designateInput];
GVAR(activeCamera) setVariable [QGVAR(lookInput), _lookInput];

_return
