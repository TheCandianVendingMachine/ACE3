#include "script_component.hpp"
/*
 * Author: Brandon (TCVM)
 * SACLOS seeker
 *
 * Arguments:
 * 1: Guidance Arg Array <ARRAY>
 * 2: Seeker State <ARRAY>
 *
 * Return Value:
 * Position of wanted missile pos relative to the camera direction <ARRAY>
 *
 * Example:
 * [] call ace_hot_fnc_seekerType_SACLOS
 *
 * Public: No
 */
params ["", "_args"];
_args params ["_firedEH", "", "", "_seekerParams", "_stateParams"];
_firedEH params ["_shooter","_weapon","","","","","_projectile"];
_seekerParams params ["_seekerAngle"];
_stateParams params ["", "_seekerStateParams"];
_seekerStateParams params ["_turretPath", "_memoryPointGunnerOptics"];

private _shooterPos = AGLToASL (_shooter modelToWorld(_shooter selectionPosition _memoryPointGunnerOptics));
private _projPos = getPosASL _projectile;

private _lookDirection = if !(_shooter isKindOf "CAManBase") then {
    _shooter weaponDirection ((_shooter weaponsTurret _turretPath) select 0);
} else {
    _shooter weaponDirection _weapon;
};

private _distanceToProj = _shooterPos vectorDistance _projPos;
private _testPointVector = vectorNormalized (_projPos vectorDiff _shooterPos);
private _testDotProduct = (_lookDirection vectorDotProduct _testPointVector);

private _testIntersections = lineIntersectsSurfaces [_shooterPos, _projPos, _shooter];

if ((_testDotProduct < (cos _seekerAngle)) || { !(_testIntersections isEqualTo []) }) exitWith {
    // out of LOS of seeker
    [0, 0, 0]
};

_shooterPos vectorAdd (_lookDirection vectorMultiply (_distanceToProj + 50));
