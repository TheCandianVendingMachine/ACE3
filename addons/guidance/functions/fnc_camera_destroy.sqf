#include "script_component.hpp"
/*
 * Author: Brandon (TCVM)
 * Destroys camera attaches to projectile
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

[] call FUNC(camera_switchAway);

private _key = _cameraNamespace getVariable [QGVAR(missile), objNull];
[GVAR(projectileCameraHash), objNull] call CBA_fnc_hashRem;

private _logic = _cameraNamespace getVariable [QGVAR(logic), objNull];
deleteVehicle _logic;

private _camera = _cameraNamespace getVariable QGVAR(camera);
camDestroy _camera;

private _shooter = _cameraNamespace getVariable [QGVAR(shooter), objNull];
_shooter setVariable [QGVAR(missileCamera), objNull];

GVAR(activeCamera) = objNull;
_cameraNamespace call CBA_fnc_deleteNamespace;
