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
_viewData params ["_lookDir", "_groundPos"];
_gimbalData params ["_hasGimbal", "_maxGimbalX", "_maxGimbalY", "_gimbalSpeedX", "_gimbalSpeedY"];

 
private _camera = GVAR(activeCamera) getVariable [QGVAR(camera), nil];
private _projectile = GVAR(activeCamera) getVariable [QGVAR(missile), objNull];
private _logic = GVAR(activeCamera) getVariable [QGVAR(logic), objNull];

private _fovChanged = GVAR(activeCamera) getVariable [QGVAR(fovChanged), false];

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

private _relativePos = [0, 10, 0];
if (_hasGimbal) then {
    _miscManeuvering params ["", "", "", "", "_deltaTime"];

    private _lookInput = GVAR(activeCamera) getVariable [QGVAR(lookInput), [0, 0, 0, 0]];
    _lookInput params ["_up", "_down", "_left", "_right"];
    
    private _logicPos = _projectile worldToModelVisual getPosATL _logic;
    
    private _angleX = atan ((_logicPos#0) / (_logicPos#1));
    private _angleY = atan ((_logicPos#2) / (_logicPos#1));
    
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
    
    systemChat str [_angleX, _angleY];
    
    private _posX = _logicPos#0 + ((_gimbalSpeedX * _deltaTime) * (_right - _left));
    private _posY = _logicPos#2 + ((_gimbalSpeedY * _deltaTime) * (_up - _down));
    
    _relativePos set [0, _posX];
    _relativePos set [2, _posY];
    
};

_logic setPosASL (_projectile modelToWorldVisualWorld _relativePos);
_logic setDir getDir _projectile;
_logic setVectorUp vectorUpVisual _projectile;

_camera camSetTarget _logic;
_camera camSetRelPos ([0, 0, 0] vectorDiff _relativePos);

_lookDir = vectorNormalized (getPosASL _logic vectorDiff getPosASL _camera);

//_viewData set [0, _lookDir];
//_viewData set [1, [0, 0, 0]];
//_cameraArray set [8, _viewData];
//_extractedInfo set [12, _cameraArray];

_camera camCommit 0;
 
 