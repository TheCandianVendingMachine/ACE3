#include "script_component.hpp"
/*
 * Author: Brandon (TCVM)
 * Decreases zoom of current camera
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
params ["_increase"];
 
private _zoomIndex = GVAR(activeCamera) getVariable [QGVAR(currentZoomIndex), 0];
private _zoomArray = GVAR(activeCamera) getVariable [QGVAR(fovLevels), []];
private _camera = GVAR(activeCamera) getVariable [QGVAR(camera), objNull];

if ((count _zoomArray) == 0) exitWith {};
if (_increase) then {
    if ((_zoomIndex + 1) < count _zoomArray) then {
        _zoomIndex = _zoomIndex + 1;
    };
} else {
    if (_zoomIndex != 0) then {
        _zoomIndex = _zoomIndex - 1;
    };
};

GVAR(activeCamera) setVariable [QGVAR(currentZoomIndex), _zoomIndex];
GVAR(activeCamera) setVariable [QGVAR(targetFOV), _zoomArray select _zoomIndex];
GVAR(activeCamera) setVariable [QGVAR(fovChanged), true];
GVAR(activeCamera) setVariable [QGVAR(fovChangedTime), CBA_missionTime];
GVAR(activeCamera) setVariable [QGVAR(startingFov), GVAR(activeCamera) getVariable QGVAR(currentFOV)];
