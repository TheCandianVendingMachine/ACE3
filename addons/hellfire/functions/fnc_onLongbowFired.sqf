#include "script_component.hpp"
/*
 * Author: Brandon (TCVM)
 * Sets up missile guidance state arrays (called from missileGuidance's onFired).
 *
 * Arguments:
 * Guidance Arg Array <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_hellfire_fnc_onFired
 *
 * Public: No
 */
params ["_firedEH", "_launchParams", "", "", "_stateParams"];
_firedEH params ["_shooter","","","","","","_projectile"];
_launchParams params ["","_targetLaunchParams"];
_targetLaunchParams params ["_target", "_targetPos", "_launchPos"];
_stateParams params ["", "_seekerStateParams"];


private _targetObject = cursorTarget;
private _potentialTargetPos = getPosASL _targetObject;
private _potentialTargetVel = velocity _targetObject;

// set launch pos to the warhead pos
_targetLaunchParams set [2, getPosASL _projectile];

_seekerStateParams set[1, _potentialTargetPos];

if (!isVehicleRadarOn vehicle _shooter || { _targetObject isEqualTo objNull }) then {
    _seekerStateParams set[0, "GPS"];
} else {
    private _missileAccel = getNumber(configFile >> "CfgAmmo" >> typeOf(_projectile) >> "thrust");
    private _missileAccelTime = getNumber(configFile >> "CfgAmmo" >> typeOf(_projectile) >> "thrustTime");
    
    private _distanceToTarget = _potentialTargetPos distance _launchPos;
    
    // Aproximation of the position the unit will be at when the missile becomes active.
    private _aproxETA = (1 * _distanceToTarget) / (_missileAccel * _missileAccelTime);
    
    _seekerStateParams set[0, "RADAR"];
    _seekerStateParams set[1, _potentialTargetPos vectorAdd (_potentialTargetVel vectorMultiply _aproxETA)];
    _seekerStateParams set[2, _targetObject]; // storing the "radar signature" of the wanted target
};

