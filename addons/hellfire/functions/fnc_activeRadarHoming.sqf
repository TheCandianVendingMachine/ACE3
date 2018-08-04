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
private _projDir = vectorDir _projectile;
private _projYaw = getDir _projectile;
private _distanceToTarget = _projPos distance _targetPos;

private _rotatedYaw = (+(_projDir select 0) * sin _projYaw) + (+(_projDir select 1) * cos _projYaw);
if (_rotatedYaw isEqualTo 0) then { _rotatedYaw = 0.001 };
private _projPitch = atan ((_projDir select 2) / _rotatedYaw);
private _a1 = abs _projPitch;
private _a2 = 180 - ((_seekerAngle / 2) + _a1);
private _seekerBaseRadiusAtGround = _distanceToTarget / sin(_a2) * sin(_seekerAngle / 2);

// Active homing enabled when close to target
if (_distanceToTarget <= 2000) then {
    //systemChat str(_seekerBaseRadiusAtGround);
    // Radar has locked onto something
    if !(_radarLockedObject isEqualTo objNull) then {
        private _centerOfObject = getCenterOfMass _radarLockedObject;
        private _targetAdjustedPos = _radarLockedObject modelToWorldWorld _centerOfObject;
        _targetPos = _targetAdjustedPos;
        
        if !([_projPos, _targetPos] call ace_missileguidance_fnc_checkLOS) then {
            // There is something between the missile and target, assume last known moving position. Lost lock on radar with this
            _targetPos = _lastKnownTargetPos vectorAdd (_lastKnownTargetVelocity vectorMultiply _etaWhenLost);
            //_radarLockedObject = objNull;
        } else {
            // update known data about target (velocity prediction, etc)
            _seekerStateParams set[4, velocity _radarLockedObject];
            _seekerStateParams set[5, _targetPos];
            
            private _projSpeed = vectorMagnitude velocity _projectile;
            private _eta = _distanceToTarget / _projSpeed;
            _seekerStateParams set[6, _eta];
        };
        
        if !([_projPos, _targetPos, _seekerAngle] call ace_missileguidance_fnc_checkSeekerAngle) then {
            // target is not within FOV
            _targetPos = [0, 0, 0];
        };
    } else {
        private _targetsNearPosition = nearestObjects[_targetPos, ["AllVehicles"], _seekerBaseRadiusAtGround, true];
        if (count _targetsNearPosition > 0) then {
            // See if the "radar signature" of the target is within range
            if (!(_targetObject isEqualTo objNull) &&
                { _targetObject in _targetsNearPosition } &&
                { count lineIntersectsObjs[_projPos, getPosASL _targetObject, objNull, _radarLockedObject, false, 16] == 0 }) then {
                _radarLockedObject = _targetObject;
            } else {
                // couldnt find the "marked" target
                _radarLockedObject = {
                    if !([_projPos, getPosASL _x] call ace_missileguidance_fnc_checkLOS) exitWith {
                        _x
                    };
                    objNull
                } forEach _targetsNearPosition;
            };
        };
    };
    
    _seekerStateParams set[7, _radarLockedObject];
};

targetHelper setPosASL _targetPos;
_targetPos

