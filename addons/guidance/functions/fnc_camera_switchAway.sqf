#include "script_component.hpp"
/*
  * Author: Brandon (TCVM)
 * Switches away from the currently controlled camera
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
_camera cameraEffect ["terminate", "back"];
_projectile hideObject false;
