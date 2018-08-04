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
_args params ["_firedEH", "", "", "_seekerParams"];
_firedEH params ["","","","","","","_projectile"];

_seekerStateParams params["_launchType", "_targetPos", ["_targetObject", objNull], ["_lastKnownTargetVelocity", [0, 0, 0]], ["_lastKnownTargetPos", [0, 0, 0]], ["_etaWhenLost", 0], ["_radarLockedObject", objNull]];
_seekerParams params ["_seekerAngle", "", "_seekerMaxRange"];

private _projPos = getPosASL _projectile;
private _distanceToTarget = _projPos distance _targetPos;

// Active homing enabled when close to target
if (_distanceToTarget <= 2000) then {
    // Radar has locked onto something
    if !(_radarLockedObject isEqualTo objNull) then {
        if !([_projectile, _radarLockedObject] call ace_missileguidance_fnc_checkLOS) then {
            // There is something between the missile and target, assume last known moving position. Lost lock on radar with this
            _targetPos = _lastKnownTargetPos vectorAdd (_lastKnownTargetVelocity vectorMultiply _etaWhenLost);
            _radarLockedObject = objNull;
        } else {
            private _centerOfObject = getCenterOfMass _radarLockedObject;
            private _targetAdjustedPos = _radarLockedObject modelToWorldWorld _centerOfObject;
            _targetPos = _targetAdjustedPos;
        
            // update known data about target (velocity prediction, etc)
            _seekerStateParams set[3, velocity _radarLockedObject];
            _seekerStateParams set[4, _targetPos];
            
            private _projSpeed = vectorMagnitude velocity _projectile;
            private _eta = _distanceToTarget / _projSpeed;
            _seekerStateParams set[5, _eta];
        };
        
        if !([_projectile, _targetPos, _seekerAngle] call ace_missileguidance_fnc_checkSeekerAngle) then {
            // target is not within FOV, revert back to last known pos
            _targetPos = [0, 0, 0];
            _radarLockedObject = objNull;
        };
    } else {
        private _projDir = vectorDir _projectile;
        private _projYaw = getDir _projectile;
        private _rotatedYaw = (+(_projDir select 0) * sin _projYaw) + (+(_projDir select 1) * cos _projYaw);
        if (_rotatedYaw isEqualTo 0) then { _rotatedYaw = 0.001 };
        private _projPitch = atan ((_projDir select 2) / _rotatedYaw);
        private _a1 = abs _projPitch;
        private _a2 = 180 - ((_seekerAngle / 2) + _a1);
        private _seekerBaseRadiusAtGround = _distanceToTarget / sin(_a2) * sin(_seekerAngle / 2);
    
        private _targetsNearPosition = nearestObjects[_targetPos, ["AllVehicles"], _seekerBaseRadiusAtGround, true];
        if (count _targetsNearPosition > 0) then {
            // See if the "radar signature" of the target is within range
            if (!(_targetObject isEqualTo objNull) &&
                { _targetObject in _targetsNearPosition } &&
                { [_projectile, _targetObject] call ace_missileguidance_fnc_checkLOS }) then {
                _radarLockedObject = _targetObject;
            } else {
                // couldnt find the "marked" target
                _radarLockedObject = {
                    if ([_projectile, _x] call ace_missileguidance_fnc_checkLOS) exitWith {
                        _x
                    };
                    objNull
                } forEach _targetsNearPosition;
            };
        };
    };
    
    _seekerStateParams set[6, _radarLockedObject];
    _seekerStateParams set[1, _targetPos];
};

targetHelper setPosASL _targetPos;
_targetPos

