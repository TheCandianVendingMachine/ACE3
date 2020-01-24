#include "script_component.hpp"
/*
  * Author: Brandon (TCVM)
 * Switches to the currently controlled camera
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
params ["_cameraNamespace"];

if ([] call FUNC(camera_userInCamera)) exitWith {};
private _camera = _cameraNamespace getVariable QGVAR(camera);
private _projectile = _cameraNamespace getVariable QGVAR(missile);
_camera cameraEffect ["internal", "BACK"];
GVAR(activeCamera) = _cameraNamespace;
[_cameraNamespace, _cameraNamespace getVariable [QGVAR(tiModeString), "normal"]] call FUNC(camera_setViewMode);
[_cameraNamespace, _cameraNamespace getVariable [QGVAR(currentZoomIndex), 0]] call FUNC(camera_setZoom);

