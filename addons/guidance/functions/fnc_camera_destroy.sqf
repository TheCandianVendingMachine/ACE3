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
 
[] call FUNC(camera_switchAway);
private _camera = GVAR(activeCamera) getVariable QGVAR(camera);
camDestroy _camera;