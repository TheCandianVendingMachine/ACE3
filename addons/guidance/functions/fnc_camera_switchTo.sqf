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

private _camera = GVAR(activeCamera) getVariable QGVAR(camera);
private _projectile = GVAR(activeCamera) getVariable QGVAR(missile);
_camera cameraEffect ["internal", "BACK"];
_projectile hideObject true;
