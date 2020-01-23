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

params ["_extractedInfo"];
_extractedInfo params ["", "", "", "", "", "", "", "_miscManeuvering", "", "", "", "", "_cameraArray"];
_cameraArray params ["", "", "", "", "", "", "", "", "_viewData", "_gimbalData"];
_viewData params ["_lookDir", "_groundPos", "_pointPos", "_movingCamera"];
_gimbalData params ["_hasGimbal", "_maxGimbalX", "_maxGimbalY", "_gimbalSpeedX", "_gimbalSpeedY"];

cameraEffectEnableHUD true;

_cameraArray set [10, (GVAR(activeCamera) getVariable [QGVAR(designateInput), [0]])#0 == 1];
 
private _camera = GVAR(activeCamera) getVariable [QGVAR(camera), nil];
private _projectile = GVAR(activeCamera) getVariable [QGVAR(missile), objNull];
private _logic = GVAR(activeCamera) getVariable [QGVAR(logic), objNull];

private _fovChanged = GVAR(activeCamera) getVariable [QGVAR(fovChanged), false];
private _cameraPos = getPosASL _projectile;

if (_fovChanged) then {
    private _lerpFovEnabled = GVAR(activeCamera) getVariable [QGVAR(lerpFOVChange), false];
    private _targetFOV = GVAR(activeCamera) getVariable [QGVAR(targetFOV), 1];
    private _currentFOV = GVAR(activeCamera) getVariable [QGVAR(currentFOV), 1];
    private _fovChangeStart = GVAR(activeCamera) getVariable [QGVAR(fovChangedTime), 0];
    private _startingFOV = GVAR(activeCamera) getVariable [QGVAR(startingFov), 1];
    private _fovChangeTime = GVAR(activeCamera) getVariable [QGVAR(fovChangeTime), 0];
    
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
    GVAR(activeCamera) setVariable [QGVAR(fovChanged), _fovChanged];
    GVAR(activeCamera) setVariable [QGVAR(currentFOV), _setFOV];
};

private _lastGroundPos = GVAR(activeCamera) getVariable [QGVAR(lastMovedGroundPos), [0, 0, 0]];
private _relativePos = GVAR(activeCamera) getVariable [QGVAR(logicPos), _relativePos];
if (_hasGimbal) then {
    _miscManeuvering params ["", "", "", "", "_deltaTime"];

    private _lookInput = GVAR(activeCamera) getVariable [QGVAR(lookInput), [0, 0, 0, 0]];
    _lookInput params ["_up", "_down", "_left", "_right"];
       
    if ((_lookInput find 1) < 0) then {
        _movingCamera = false;
        // lock the camera and dont gimbal with missile rotation
        if !(_lastGroundPos isEqualTo [0, 0, 0]) then {
            drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 1, 1, 1], ASLtoAGL (_lastGroundPos), 0.75, 0.75, 0, "Last Camera Ground Position", 1, 0.025, "TahomaB"];
            _camera camSetTarget _lastGroundPos;
        };
        
    } else {
        _movingCamera = true;
    
        private _angleX = atan ((_relativePos#0) / (_relativePos#1));
        private _angleY = atan ((_relativePos#2) / (_relativePos#1));
        
        if (_maxGimbalX - (abs _angleX) <= 0) then {
            if (_angleX > 0) then {
                _right = 0;
            } else {
                _left = 0;
            };
        };
        
        if (_maxGimbalY - (abs _angleY) <= 0) then { 
            if (_angleY > 0) then {
                _up = 0;
            } else {
                _down = 0;
            };
        };
        
        private _posX = _relativePos#0 + ((_gimbalSpeedX * _deltaTime) * (_right - _left));
        private _posY = _relativePos#2 + ((_gimbalSpeedY * _deltaTime) * (_up - _down));
            
        _relativePos set [0, _posX];
        _relativePos set [2, _posY];
    };
};

GVAR(activeCamera) setVariable [QGVAR(logicPos), _relativePos];

_logic setVectorUp [0, 0, 1];
_logic setDir getDir _projectile;
_logic setPosASL (_projectile modelToWorldVisualWorld _relativePos);

if (_movingCamera || _lastGroundPos isEqualTo [0, 0, 0]) then {
    _camera camSetTarget _logic;
};
_camera camSetPos getPos _projectile;

_lookDir = vectorNormalized (getPosASL _logic vectorDiff getPosASL _camera);

private _projectedPos = _cameraPos vectorAdd (_lookDir vectorMultiply 10000);

private _surfaceIntersections = lineIntersectsSurfaces [_cameraPos, _projectedPos, _projectile, _logic];

private _pointPos = [0, 0, 0];
private _groundPos = terrainIntersectAtASL [_cameraPos, _projectedPos];

if (count _surfaceIntersections > 0) then {
    _pointPos = (_surfaceIntersections select 0) select 0;
};

if (_movingCamera) then {
    GVAR(activeCamera) setVariable [QGVAR(lastMovedGroundPos), _groundPos];
};

drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0, 1, 1, 1], ASLtoAGL (_groundPos), 0.75, 0.75, 0, "Camera Ground Position", 1, 0.025, "TahomaB"];
drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 1, 0, 1], ASLtoAGL (_pointPos), 0.75, 0.75, 0, "Camera Point Position", 1, 0.025, "TahomaB"];

_viewData set [0, _lookDir];
_viewData set [1, _groundPos];
_viewData set [2, _pointPos];
_viewData set [3, _movingCamera];
_cameraArray set [8, _viewData];
_extractedInfo set [12, _cameraArray];

_camera camCommit 0;
 
 