#include "script_component.hpp"
/*
 * Author: Brandon (TCVM)
 * Initializes camera for player to view missile from its nose
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
params ["_projectile", "_cameraArray"];
_cameraArray params ["_enabled", "_fovLevels", "_initialFOV", "_thermalTypes", "_initialThermalType", "_switchOnFire", "_lerpFOV", "_fovChangeTime"];
 
if !(_enabled) exitWith {};
 
if (isNull GVAR(activeCameraNamespace)) then {
    GVAR(activeCameraNamespace) = [] call CBA_fnc_createNamespace;
};

private _pos = getPosASL _projectile;

private _camera = "camera" camCreate _pos;
private _logic = "Logic" createVehicleLocal _pos;

_logic setPosASL (_projectile modelToWorldVisualWorld [0, 10, 0]);
_logic setDir getDir _projectile;
_logic setVectorUp vectorUpVisual _projectile;

_camera camSetTarget _logic;
_camera camSetRelPos [0, -10, 0];
_camera camSetFOV _initialFOV;

_camera camCommit 0;
showCinemaBorder false;
camUseNVG false;

GVAR(activeCameraNamespace) setVariable [QGVAR(camera), _camera];
GVAR(activeCameraNamespace) setVariable [QGVAR(logic), _logic];
GVAR(activeCameraNamespace) setVariable [QGVAR(missile), _projectile];
GVAR(activeCameraNamespace) setVariable [QGVAR(fovLevels), _fovLevels];
GVAR(activeCameraNamespace) setVariable [QGVAR(thermalTypes), _thermalTypes];

GVAR(activeCameraNamespace) setVariable [QGVAR(lerpFOVChange), _lerpFOV == 1];
GVAR(activeCameraNamespace) setVariable [QGVAR(targetFOV), _initialFOV];
GVAR(activeCameraNamespace) setVariable [QGVAR(currentFOV), _initialFOV];
GVAR(activeCameraNamespace) setVariable [QGVAR(fovChanged), false];
GVAR(activeCameraNamespace) setVariable [QGVAR(fovChangeTime), _fovChangeTime];
GVAR(activeCameraNamespace) setVariable [QGVAR(logicPos), [0, 50, 0]];

GVAR(activeCameraNamespace) setVariable [QGVAR(lastMovedGroundPos), [0, 0, 0]];

private _currentZoomIndex = _fovLevels findIf { _x isEqualTo _initialFOV };
if (_currentZoomIndex < 0) then { _currentZoomIndex = 0 };

private _currentTIIndex = _thermalTypes findIf { _x isEqualTo _initialThermalType };
if (_currentTIIndex < 0) then { _currentTIIndex = 0 };

GVAR(activeCameraNamespace) setVariable [QGVAR(currentZoomIndex), _currentZoomIndex];
GVAR(activeCameraNamespace) setVariable [QGVAR(currentTIModeIndex), _currentTIIndex];

GVAR(activeCamera) = GVAR(activeCameraNamespace);

[_initialThermalType] call FUNC(camera_setViewMode);


if (_switchOnFire) then {
    [] call FUNC(camera_switchTo);
};
