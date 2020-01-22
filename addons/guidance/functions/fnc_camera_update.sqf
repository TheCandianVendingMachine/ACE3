#include "script_component.hpp"
/*
 * Author: Brandon (TCVM)
 * Updates camera to be on a fixed point
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
params ["_seekerTargetPos", "_attackProfileTargetPos"];
 
private _camera = GVAR(activeCamera) getVariable QGVAR(camera);
private _projectile = GVAR(activeCamera) getVariable QGVAR(missile);
private _logic = GVAR(activeCamera) getVariable QGVAR(logic);
 
_logic setPosASL (_projectile modelToWorldVisualWorld [0, 10, 0]);
_logic setDir getDir _projectile;
_logic setVectorUp vectorUpVisual _projectile;

_camera camSetTarget _logic;
_camera camSetRelPos [0, -10, 0];

_camera camCommit 0;
 
 