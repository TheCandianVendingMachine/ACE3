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
params ["_extractedInfo", "_projectile", "_seekerTargetPos"];
_extractedInfo params ["", "", "", "", "", "", "", "_miscManeuvering", "", "", "", "", "_cameraArray"];
_cameraArray params ["_hasCamera", "", "", "", "", "", "", "", "_viewData", "_gimbalData", "", "_designating", "_canStopDesignating"];
_viewData params ["_lookDir", "_groundPos", "_pointPos", "_movingCameraX", "_movingCameraY"];
_gimbalData params ["_hasGimbal", "_maxGimbalX", "_maxGimbalY", "_gimbalSpeedX", "_gimbalSpeedY", "", "", "_gimbalZoomSpeedModifiers", "_stabilizeWhenMoving", "_designateWhenStationary", "_trackLockedPosition"];

private _cameraNamespace = [_projectile] call FUNC(camera_getCameraNamespaceFromProjectile);
if (!_hasCamera || { _cameraNamespace isEqualTo objNull }) exitWith {};

if ([_cameraNamespace] call FUNC(camera_userInCamera)) then {
    cameraEffectEnableHUD true;
};

private _camera = _cameraNamespace getVariable [QGVAR(camera), nil];
private _logic = _cameraNamespace getVariable [QGVAR(logic), objNull];

private _fovChanged = _cameraNamespace getVariable [QGVAR(fovChanged), false];
private _missilePos = getPosASL _projectile;
private _missileRelativeOffset = [0, (_cameraNamespace getVariable [QGVAR(projectileSize), 0]), 0];
private _cameraPosASL = (_projectile modelToWorldVisualWorld _missileRelativeOffset);

private _designatedLastFrame = _cameraNamespace getVariable [QGVAR(designatedLastFrame), false];
if (_designatedLastFrame && !_canStopDesignating && { !(_groundPos isEqualTo [0, 0, 0] && _pointPos isEqualTo [0, 0, 0]) }) then {
    _designating = true;
};

if (!_designating && _designatedLastFrame) then {
    _designatedLastFrame = false;
    _cameraNamespace setVariable [QGVAR(designatedLastFrame), _designatedLastFrame];
};

if (_fovChanged) then {
    private _lerpFovEnabled = _cameraNamespace getVariable [QGVAR(lerpFOVChange), false];
    private _targetFOV = _cameraNamespace getVariable [QGVAR(targetFOV), 1];
    private _currentFOV = _cameraNamespace getVariable [QGVAR(currentFOV), 1];
    private _fovChangeStart = _cameraNamespace getVariable [QGVAR(fovChangedTime), 0];
    private _startingFOV = _cameraNamespace getVariable [QGVAR(startingFov), 1];
    private _fovChangeTime = _cameraNamespace getVariable [QGVAR(fovChangeTime), 0];
    
    private _setFOV = _targetFOV;
    if (_lerpFovEnabled) then {
        _setFOV = linearConversion [0, _fovChangeTime, CBA_missionTime - _fovChangeStart, _startingFOV, _targetFOV, true];
    } else {
        _fovChanged = false;
    };
    
    // if the FOV is near enough to the target FOV stop the lerp
    if (abs(_setFOV - _targetFOV) == 0 || ((CBA_missionTime - _fovChangeStart) > _fovChangeTime + 2)) then {
        _setFOV = _targetFOV;
        _fovChanged = false;
    };
    
    _camera camSetFOV _setFOV;
    _cameraNamespace setVariable [QGVAR(fovChanged), _fovChanged];
    _cameraNamespace setVariable [QGVAR(currentFOV), _setFOV];
};

_movingCameraX = false;
_movingCameraY = false;

private _relativePos = _cameraNamespace getVariable [QGVAR(logicPos), [0, 10, 0] vectorAdd _missileRelativeOffset];
if (_hasGimbal) then {
    _miscManeuvering params ["", "", "", "", "_deltaTime"];

    private _lookInput = _cameraNamespace getVariable [QGVAR(lookInput), [0, 0, 0, 0]];
    _lookInput params ["_up", "_down", "_left", "_right"];

    _movingCameraX = (_right - _left) != 0;
    _movingCameraY = (_up - _down) != 0;

    if !(_movingCameraX || _movingCameraY) then {
        private _lastGroundPos = _cameraNamespace getVariable [QGVAR(lastMovedGroundPos), [0, 0, 0]];
        
        // If we designate a target set the current tracking point to the current ground point to avoid unwanted behavior from static cameras
        if (_designating && !_designatedLastFrame) then {
            _designatedLastFrame = true;
            _cameraNamespace setVariable [QGVAR(designatedLastFrame), _designatedLastFrame];
            _lastGroundPos = _groundPos;
            _cameraNamespace setVariable [QGVAR(lastMovedGroundPos), _lastGroundPos];
        };

        if (_trackLockedPosition && { !(_seekerTargetPos isEqualTo [0, 0, 0]) } && _canStopDesignating) then {
            _lastGroundPos = _seekerTargetPos;
        };

        // lock the camera and dont gimbal with missile rotation
        if !(_lastGroundPos isEqualTo [0, 0, 0]) then {
            drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 1, 1, 1], ASLtoATL (_lastGroundPos), 0.75, 0.75, 0, "Last Camera Ground Position", 1, 0.025, "TahomaB"];
            private _relativePosOffset = _relativePos vectorDiff _missileRelativeOffset;

            private _relativeGround = AGLtoASL (_projectile worldToModelVisual ASLtoAGL _lastGroundPos);
            private _distToGround = vectorMagnitude _relativeGround;
            private _relativePosDiff = (vectorNormalized _relativePosOffset) vectorMultiply _distToGround;
            
            private _dx = (_relativeGround#0) - (_relativePosDiff#0); // difference between looking position on ground and last ground position
            private _dy = (_relativeGround#2) - (_relativePosDiff#2);

            private _distToRp0 = sqrt ((_relativePosOffset#1)^2 + (_relativePosOffset#0)^2);
            private _distToRp2 = sqrt ((_relativePosOffset#1)^2 + (_relativePosOffset#2)^2);

            private _drp0 = (_distToRp0 * _dx) / _distToGround;
            private _drp2 = (_distToRp2 * _dy) / _distToGround;

            private _expectedPos = [_relativePosOffset#0 + _drp0, _relativePosOffset#1, _relativePosOffset#2 + _drp2];
            
            private _angleX = atan ((_expectedPos#0) / (_expectedPos#1));
            private _angleY = atan ((_expectedPos#2) / (_expectedPos#1));
            
            if (_maxGimbalX - (abs _angleX) > 0) then {
                _relativePos set [0, _expectedPos#0];
            };
            if (_maxGimbalY - (abs _angleY) > 0) then {
                _relativePos set [2, _expectedPos#2];
            };
        };
    } else {   
        private _speedModifier = 1;
        if !(_gimbalZoomSpeedModifiers isEqualTo []) then {
            _speedModifier = (_gimbalZoomSpeedModifiers select (_cameraNamespace getVariable [QGVAR(currentZoomIndex), 0]));
        };

        private _posX = (_speedModifier * _gimbalSpeedX * _deltaTime * (_right - _left));
        private _posY = (_speedModifier * _gimbalSpeedY * _deltaTime * (_up - _down));

        // carbon copy of the ground stabilization code. DRY and all that but this is a special case
        if (_stabilizeWhenMoving) then {
            private _relativePosOffset = _relativePos vectorDiff _missileRelativeOffset;

            // stabilize camera when moving in an axis (if enabled)
            if ((_right - _left) == 0) then {
                private _lastGroundPosX = _cameraNamespace getVariable [QGVAR(lastMovedGroundPosX), [0, 0, 0]];
                if !(_lastGroundPosX isEqualTo [0, 0, 0]) then {
                    private _relativeGround = AGLtoASL (_projectile worldToModelVisual ASLtoAGL _lastGroundPosX);
                    private _distToGround = vectorMagnitude _relativeGround;
                    private _relativePosDiff = (vectorNormalized _relativePosOffset) vectorMultiply _distToGround;
                
                    private _dx = (_relativeGround#0) - (_relativePosDiff#0); // difference between looking position on ground and last ground position
                    private _distToRp0 = sqrt ((_relativePosOffset#1)^2 + (_relativePosOffset#0)^2);
                    _posX = (_distToRp0 * _dx) / _distToGround;
                };
            };

            if ((_up - _down) == 0) then {
                private _lastGroundPosY = _cameraNamespace getVariable [QGVAR(lastMovedGroundPosY), [0, 0, 0]];
                if !(_lastGroundPosY isEqualTo [0, 0, 0]) then {
                    private _relativeGround = AGLtoASL (_projectile worldToModelVisual ASLtoAGL _lastGroundPosY);
                    private _distToGround = vectorMagnitude _relativeGround;
                    private _relativePosDiff = (vectorNormalized _relativePosOffset) vectorMultiply _distToGround;
                
                    private _dy = (_relativeGround#2) - (_relativePosDiff#2);
                    private _distToRp2 = sqrt ((_relativePosOffset#1)^2 + (_relativePosOffset#2)^2);
                    _posY = (_distToRp2 * _dy) / _distToGround;
                };
            };
        };
               
        private _angleX = atan ((_relativePos#0 + _posX) / (_relativePos#1));
        private _angleY = atan ((_relativePos#2 + _posY) / (_relativePos#1));
        if (_maxGimbalX - (abs _angleX) > 0) then {
            _relativePos set [0, _relativePos#0 + _posX];
        };
        if (_maxGimbalY - (abs _angleY) > 0) then {
            _relativePos set [2, _relativePos#2 + _posY];
        };
    };
};

_designating = (!_canStopDesignating && _designating) || { _cameraNamespace getVariable [QGVAR(alwaysDesignate), false] || { (_cameraNamespace getVariable [QGVAR(designateInput), [0]])#0 == 1 } };
if (_designateWhenStationary && !(_movingCameraX || _movingCameraY)) then {
    _designating = true;
};
_cameraNamespace setVariable [QGVAR(logicPos), _relativePos];

_logic setVectorUp [0, 0, 1];
_logic setDir getDir _projectile;
_logic setPosASL (_projectile modelToWorldVisualWorld _relativePos);

_camera camSetTarget _logic;
_camera setPos (_projectile modelToWorldVisual _missileRelativeOffset);

_lookDir = _cameraPosASL vectorFromTo (getPosASL _logic);

private _projectedPos = _cameraPosASL vectorAdd (_lookDir vectorMultiply 10000);

private _surfaceIntersections = lineIntersectsSurfaces [_cameraPosASL, _projectedPos, _projectile, _logic];

private _pointPos = [0, 0, 0];
private _groundPos = terrainIntersectAtASL [_cameraPosASL, _projectedPos];

if (count _surfaceIntersections > 0) then {
    _pointPos = (_surfaceIntersections select 0) select 0;
};

if (_movingCameraX) then {
    _cameraNamespace setVariable [QGVAR(lastMovedGroundPosX), _groundPos];
};
if (_movingCameraY) then {
    _cameraNamespace setVariable [QGVAR(lastMovedGroundPosY), _groundPos];
};
if (_movingCameraX || _movingCameraY) then {
    _cameraNamespace setVariable [QGVAR(lastMovedGroundPos), _groundPos];
};

_cameraArray set [11, _designating];

drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 0.5, 1, 1], _projectile modelToWorldVisual _missileRelativeOffset, 0.75, 0.75, 0, "Camera Pos", 1, 0.025, "TahomaB"];
drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 0.5, 1, 1], getPosATL _logic, 0.75, 0.75, 0, "Logic Pos", 1, 0.025, "TahomaB"];

drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0, 1, 1, 1], ASLtoAGL (_groundPos), 0.75, 0.75, 0, "Camera Ground Position", 1, 0.025, "TahomaB"];
drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 1, 0, 1], ASLtoAGL (_pointPos), 0.75, 0.75, 0, "Camera Point Position", 1, 0.025, "TahomaB"];

_viewData set [0, _lookDir];
_viewData set [1, _groundPos];
_viewData set [2, _pointPos];
_viewData set [3, _movingCameraX];
_viewData set [4, _movingCameraY];
_cameraArray set [8, _viewData];
_extractedInfo set [12, _cameraArray];

_camera camCommit 0;

[_cameraNamespace, _extractedInfo, _seekerTargetPos] call FUNC(camera_updateTargetingGate);

 