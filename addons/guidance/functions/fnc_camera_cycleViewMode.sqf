#include "script_component.hpp"
/*
 * Author: Brandon (TCVM)
 * Cycles camera thermal mode (if avaliable)
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
 
private _tiIndex = GVAR(activeCamera) getVariable [QGVAR(currentTIModeIndex), 0];
private _tiArray = GVAR(activeCamera) getVariable [QGVAR(thermalTypes), []];

if ((count _tiArray) == 0) exitWith {};
if ((_tiIndex + 1) >= count _tiArray) then {
    _tiIndex = 0;
} else { 
    _tiIndex = _tiIndex + 1;
};

GVAR(activeCamera) setVariable [QGVAR(currentTIModeIndex), _tiIndex];

[_tiArray select _tiIndex] call FUNC(camera_setViewMode);
