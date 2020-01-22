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
_cameraArray params ["_enabled", "_fovLevels", "_initialFOV", "_thermalTypes", "_initialThermalType", "_switchOnFire"];
 
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

GVAR(activeCameraNamespace) setVariable [QGVAR(currentZoomIndex), 0];
GVAR(activeCameraNamespace) setVariable [QGVAR(currentTIModeIndex), 0];

GVAR(activeCamera) = GVAR(activeCameraNamespace);

[_initialThermalType] call FUNC(camera_setViewMode);


if (_switchOnFire == 1) then {
    [] call FUNC(camera_switchTo);
};
