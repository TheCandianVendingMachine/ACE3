#include "script_component.hpp"
/*
  * Author: Brandon (TCVM)
 * Switches away from the currently controlled camera
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
params ["_cameraNamespace", "_extractedInfo", "_seekerTargetPos"];
_extractedInfo params ["", "", "", "", "", "", "", "_miscManeuvering", "", "", "", "", "_cameraArray"];
_cameraArray params ["", "", "", "", "", "", "", "", "_viewData", "_gimbalData", "_reticleData", "_designating"];
_viewData params ["_lookDir", "_groundPos", "_pointPos", "_movingCameraX", "_movingCameraY", "_stabilizeWhenMoving"];
_gimbalData params ["_hasGimbal", "_maxGimbalX", "_maxGimbalY", "_gimbalSpeedX", "_gimbalSpeedY", "", "", "_gimbalZoomSpeedModifiers"];
_reticleData params ["", "", "", "", "", "", "", "", "", "_reticleMovesWithTrack"];

if !(([_cameraNamespace] call FUNC(camera_userInCamera))) exitWith {};

private _seekerPositionScreen = [0, 0];

if (_seekerTargetPos isEqualTo [0, 0, 0]) then {
    {
        _x ctrlShow false;
    } forEach (_cameraNamespace getVariable QGVAR(appearOnLock));
    {
        _x ctrlShow true;
    } forEach (_cameraNamespace getVariable QGVAR(disappearOnLock));
} else {
    // seeker has target - enable relevant data
    {
        _x ctrlShow true;
    } forEach (_cameraNamespace getVariable QGVAR(appearOnLock));
    {
        _x ctrlShow false;
    } forEach (_cameraNamespace getVariable QGVAR(disappearOnLock));
    
    if (_reticleMovesWithTrack) then {
        _seekerPositionScreen = worldToScreen ASLtoAGL _seekerTargetPos;
        _seekerPositionScreen set [0, _seekerPositionScreen#0 - 0.5];
        _seekerPositionScreen set [1, _seekerPositionScreen#1 - 0.5];
    };
};

if (_seekerPositionScreen isEqualTo []) then {
    _seekerPositionScreen = [0, 0];
};

(_cameraNamespace getVariable QGVAR(reticleCenter)) ctrlSetPosition _seekerPositionScreen;
(_cameraNamespace getVariable QGVAR(reticleCenter)) ctrlCommit 0;