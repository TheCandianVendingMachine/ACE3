#include "script_component.hpp"
/*
 * Author: Brandon (TCVM)
 * Active Radar Homing seeker
 *
 * Arguments:
 * 1: Guidance Arg Array <ARRAY>
 * 2: Seeker State <ARRAY>
 *
 * Return Value:
 * Seeker Pos <ARRAY>
 *
 * Example:
 * [] call ace_hellfire_fnc_activeRadarHoming
 *
 * Public: No
 */
params ["", "_args", "_seekerStateParams"];
_args params ["_firedEH"];
_firedEH params ["","","","","","","_projectile"];

_seekerStateParams params["_launchType", "_launchTime", "_targetPos", ["_targetObject", objNull], ["_lastKnownTargetVelocity", [0, 0, 0]], ["_lastKnownTargetPos", [0, 0, 0]], ["_etaWhenLost", 0]];
_attackProfileStateParams params ["_attackStage"];

private _projPos = getPosASL _projectile;
private _distanceToTarget = _projPos distance _targetPos;

// Active homing enabled when close to target
if (_distanceToTarget <= 1000) then {
    private _targetsNearPosition = nearestObjects[_targetPos, ["AllVehicles"], 100, true];
    private _targetedObject = objNull;
    
    if (count _targetsNearPosition > 0) then {
        // See if the "radar signature" of the target is within range
        if (!(_targetObject isEqualTo objNull) && { _targetObject in _targetsNearPosition }) then {
            _targetedObject = _targetObject;
        } else {
            // couldnt find the "marked" target
            _targetedObject = _targetsNearPosition select 0;
        };
    };
   
    // Radar has locked onto something
    if !(_targetedObject isEqualTo objNull) then {
        _targetPos = getPosASL _targetedObject;

        private _centerOfObject = getCenterOfMass _targetedObject;
        _targetPos = _targetedObject modelToWorldWorld _centerOfObject;
        
        private _intersectingObjects = lineIntersectsObjs [_projPos, _targetPos, objNull, _targetedObject, false, 16];
        if (count _intersectingObjects > 0) then {
            // There is something between the missile and target, assume last known moving position
            _targetPos = _lastKnownTargetPos vectorAdd (_lastKnownTargetVelocity vectorMultiply _etaWhenLost);
            
        } else {
            // update known data about target (velocity prediction, etc)
            _seekerStateParams set[4, velocity _targetedObject];
            _seekerStateParams set[5, _targetPos];
            
            private _projSpeed = vectorMagnitude velocity _projectile;
            private _eta = _distanceToTarget / _projSpeed;
            _seekerStateParams set[6, _eta];
        };
        
        private _projDir = vectorDir _projectile;
        private _isFacingDot = _projDir vectorDotProduct vectorNormalized(_projPos vectorDiff _targetPos);
        if (_isFacingDot > 0) then {
            // facing away from target, moved past target and cant adjust
            _targetPos = [0, 0, 0];
        };
    };
};

targetHelper setPosASL _targetPos;

_targetPos

