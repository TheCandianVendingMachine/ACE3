#include "script_component.hpp"
/*
 * Author: LorenLuke
 * Extracts projectile, seeker, and other information to hand off to onFired EH.
 *
 * Arguments (from EH):
 * 0: Shooter <OBJECT>
 * 1: Weapon <STRING>
 * 2: Muzzle <STRING>
 * 3: Mode <STRING>
 * 4: Ammo <class>
 * 5: Magazine <class>
 * 6: Projectile <OBJECT>
 *
 * Return Value:
 *  <ARRAY>
 *
 * Example:
 * _this call ace_missileguidance_fnc_extractInfo;
 *
 * Public: No
 */
params ["_EH", "_legacy"];
_EH params ["_shooter","_weapon","_muzzle","_mode","_ammo","_magazine","_projectile"];

_projPos = getPosASL _projectile;

// Get absolutely EVERYTHING we could possibly have or need from variables
//////
private _config = configFile >> "CfgAmmo" >> _ammo >> QUOTE(ADDON);
// Check for legacy configs
private _configLegacy = configFile >> "CfgAmmo" >> _ammo >> "ace_missileguidance";


// Get values from player variables alone;
private _variableTarget = _shooter getVariable [QGVAR(target), objNull];
private _variableTargetPos = _shooter getVariable [QGVAR(targetPosition), nil];
private _variableTargetVector = _projPos vectorFromTo _variableTargetPos;
private _variableSeekerType = _shooter getVariable [QGVAR(seekerType), nil];
private _variableAttackProfile = _shooter getVariable [QGVAR(attackProfile), nil];
private _variableLockMode = _shooter getVariable [QGVAR(lockMode), nil];

private _variablePLOSValues = _shooter getVariable [QGVAR(PLOSValues), [0,0]];
private _variableMCLOSValues = _shooter getVariable [QGVAR(MCLOSValues), [0,0]];

private _variableGPSPos = _shooter getVariable [QGVAR(GPSPos), nil];

private _variableMCLOSMissile = _shooter getVariable [QGVAR(MCLOSMissile), objNull];
private _variableSACLOSMissile = _shooter getVariable [QGVAR(SACLOSMissile), objNull];

private _variableLaserCode = _shooter getVariable [QEGVAR(laser,code), nil];

if(_legacy) then {
    if(isNull _variableTarget) then {
        _variableTarget = _shooter getVariable ["ace_missileguidance_target", objNull];
    };
    if(isNil "_variableTargetPos") then {
        _variableTargetPos = _shooter getVariable ["ace_missileguidance_targetPosition", nil];
        _variableTargetVector = _projPos vectorFromTo _variableTargetPos;
    };
    if(isNil "_variableSeekerType") then {
        _variableSeekerType = _shooter getVariable ["ace_missileguidance_seekerType", nil];
    };
    if(isNil "_variableAttackProfile") then {
        _variableAttackProfile = _shooter getVariable ["ace_missileguidance_attackProfile", nil];
    };
    if(isNil "_variableLockMode") then {
        _variableLockMode = _shooter getVariable ["ace_missileguidance_lockMode", nil];
    };
};


// Get ingame variables
private _cursorTarget = objNull;
if(_shooter == player) then {_cursorTarget = cursortarget};
_missileTarget = missileTarget _projectile;
_missileTargetPos = missileTargetPos _projectile;
_missileVector = vectorDir _projectile;
_launchPos = getPosASL _projectile;
_launchTime = time;
_hasPilotCamera = hasPilotCamera _shooter;
_pilotCameraTarget = getPilotCameraTarget _shooter;
_pilotCameraPos = getPilotCameraPosition _shooter;
_pilotCameraDir = getPilotCameraDirection _shooter;

_target = _variableTarget;
_targetPos = getPosASL _variableTarget;
_targetVector = vectorDir _projectile;
// Pick our target and set direction/pos; override using variables first;
if(isNull _variableTarget) then {
    if(isNull _missileTarget) then {
        if(!(isNull _cursorTarget)) then {
            if(missileTarget _projectile == _cursorTarget) then {
                _target = _cursorTarget;
                _targetPos = getPosASL _cursorTarget;
                _targetVector = _projPos vectorFromTo _targetPos;
            };
        } else {
            if(_pilotCameraTarget select 0) then {
                _target = _pilotCameraTarget select 2;
                _targetPos = _pilotCameraTarget select 1;
                _targetVector = _projPos vectorFromTo _targetPos;
            } else {
                if(_hasPilotCamera) then {
                    private _pilotCameraPosOffset = (getPos _shooter) vectorDiff (_shooter modelToWorld _pilotCameraPos);
                    private _pilotCameraPosASL = (getPosASL _shooter) vectorAdd (_pilotCameraPosOffset);
                    private _pilotCameraVector = (getPos _shooter) vectorFromTo (_shooter modelToWorld _pilotCameraDir);
                    private _intersectArray = lineIntersectsSurfaces[_pilotCameraPosASL,_pilotCameraPosASL vectorAdd (_pilotCameraVector vectorMultiply 5000)];
                    if(count _intersectArray < 1) then {
                        _targetPos = _pilotCameraPosASL vectorAdd (_pilotCameraVector vectorMultiply 10000);
                    } else {
                        _targetPos = (_intersectArray select 0) select 0;
                    };
                } else {
                    if(_shooter == vehicle _shooter) then {
                        _targetVector = eyeDirection _shooter;
                        private _intersectArray = lineIntersectsSurfaces[eyepos _shooter,(eyePos _shooter) vectorAdd (_targetVector vectorMultiply 10000)];
                        if(!(count _intersectArray < 1)) then {
                            _targetPos = (_intersectArray select 0) select 0;
                        } else {
                            _targetPos = (AGLToASL (_shooter modelToWorld _pilotCameraPos)) vectorAdd (_targetVector vectorMultiply 10000);
                        };
                    } else {
                        _targetVector = _shooter weaponDirection _weapon;
                        private _intersectArray = lineIntersectsSurfaces[eyepos _shooter,(eyePos _shooter) vectorAdd (_targetVector vectorMultiply 10000)];
                        if(!(count _intersectArray < 1)) then {
                            _targetPos = (_intersectArray select 0) select 0;
                        } else {
                            _targetPos = (AGLToASL (_shooter modelToWorld _pilotCameraPos)) vectorAdd (_targetVector vectorMultiply 10000);
                        };
                    };
                };
            };
        };
    } else {
        _target = _missileTarget;
        _targetPos = getPosASL _missileTarget;
    };
};

_missileTarget = _target;
_missileTargetPos = _targetPos;
_targetVector = _projPos vectorFromTo _targetPos;
_missileVector = _targetVector;

_projectile setMissileTarget _missileTarget;
_projectile setMissileTargetPos _missileTargetPos;

// Maneuvering variables
//need to convert legacy to deg/second
private _minDeflectionLegacy = 0.00005;
private _maxDeflectionLegacy = 0.025;
private _incDeflectionLegacy = 0.00005;
//

/*
if(isNil _seekerAngle) then {_seekerAngle = getNumber ( _configLegacy >> "minDeflection")};
if(isNil _minRange) then {_minRange = getNumber ( _configLegacy >> "maxDeflection")};
if(isNil _maxRange) then {_maxRange = getNumber (_configLegacy >> "incDeflection")};
*/

/*
private _degreesPerSecondYaw = nil;
private _degreesPerSecondPitch = nil;
private _degreesPerSecondRoll = nil;
*/
_degreesPerSecond = 5;
_glideAngle = 90; //90 is straight down, 0 flies forever


//SensorVariables
_sensorAngle = getNumber ( _config >> "seekerAngle");
_sensorMinRange = getNumber ( _config >> "seekerMinRange");
_sensorMaxRange = getNumber ( _config >> "seekerMaxRange");

if(isNil "_seekerAngle") then {_seekerAngle = getNumber ( _configLegacy >> "seekerAngle")};
if(isNil "_minRange") then {_minRange = getNumber ( _configLegacy >> "seekerMinRange")};
if(isNil "_maxRange") then {_maxRange = getNumber (_configLegacy >> "seekerMaxRange")};

//DEBUG!!!
//////
_minRange = 0;
_maxRange = 5000;
//////

private _seekerFunction = getText (configFile >> QGVAR(SeekerTypes) >> _seekerType >> "functionName");
private _attackProfileFunction = getText (configFile >> QGVAR(AttackProfiles) >> _attackProfile >> "functionName");


// Bake in variables we may not otherwise have;
switch (true) do {
    case (_ammo isKindOf "MissileBase"): {
        _degreesPerSecond = 60;
        _degreesPerSecondYaw = 30;
        _degreesPerSecondPitch = 60;
        _degreesPerSecondRoll = 150;
        if(isNil "_sensorAngle") then {
            _sensorAngle = 35;
        };
    };
    case (_ammo isKindOf "BombCore"): {
        _degreesPerSecond = 10;
        _glideAngle = 0;
        _degreesPerSecondYaw = 30;
        _degreesPerSecondPitch = 60;
        _degreesPerSecondRoll = 150;
        if(isNil "_sensorAngle") then {
            _sensorAngle = 65;
        };
    };
    case (_ammo isKindOf "RocketCore"): {
        _degreesPerSecond = 35;
        _degreesPerSecondYaw = 20;
        _degreesPerSecondPitch = 40;
        _degreesPerSecondRoll = 100;
        if(isNil "_sensorAngle") then {
            _sensorAngle = 25;
        };
    };
    case (_ammo isKindOf "ShellBase"): {
        _degreesPerSecond = 7.5;
        _degreesPerSecondYaw = 5;
        _degreesPerSecondPitch = 5;
        _degreesPerSecondRoll = 0;    
        if(isNil "_sensorAngle") then {
            _sensorAngle = 25;
        };
    };
    case (_ammo isKindOf "BulletBase"): {
        _degreesPerSecond = 3;
        _degreesPerSecondYaw = 3;
        _degreesPerSecondPitch = 3;
        _degreesPerSecondRoll = 0;    
        if(isNil "_sensorAngle") then {
            _sensorAngle = 15;
        };
    };
    case (_ammo isKindOf "GrenadeBase"): {
        _degreesPerSecond = 12.5;
        _degreesPerSecondYaw = 12.5;
        _degreesPerSecondPitch = 12.5;
        _degreesPerSecondRoll = 0;
        if(isNil "_sensorAngle") then {
            _sensorAngle = 20;
        };
    };
};


//determine our seekers and attack profiles
_seekerType = _variableSeekerType;
_attackProfile = _variableAttackProfile;

if (isNil "_seekerType" || {!(_seekerType in (getArray (_config >> "seekerTypes")))}) then {
    _seekerType = getText (_config >> "defaultSeekerType");
};

if ((getNumber (configFile >> "CfgAmmo" >> _ammo >> QUOTE(ADDON) >> "useModeForAttackProfile")) == 1) then {
    _attackProfile = getText (configFile >> "CfgWeapons" >> _weapon >> _mode >> QGVAR(attackProfile))
};
if (isNil "_attackProfile" || {!(_attackProfile in (getArray (_config >> "attackProfiles")))}) then {
    _attackProfile = getText (_config >> "defaultAttackProfile");
};
if ((getNumber (configFile >> "CfgAmmo" >> _ammo >> QUOTE(ADDON) >> "useModeForAttackProfile")) == 1) then {
    _attackProfile = getText (configFile >> "CfgWeapons" >> _weapon >> _mode >> QGVAR(attackProfile))
};

//prep and reserve seeker and attack profile arrays;
private _miscSeeker = [true]; //sets seeker to 'active'
private _miscProfile = [];
private _fuzeVehicle = [0, false, 0];
private _fuzeAlt = [0, false];
private _fuzeRange = [0, false, 0];
private _fuzeTime = [0, false, 0];
private _fuzeLoc = [0, false, [0,0,0]];

//Configure our seeker settings based on the type
switch (_seekerType) do {
    case "GPS": {
        _target = objNull;
        if(isNil "_variableGPSPos") then {
        _variableGPSPos = _missileTargetPos;
        } else {
        _missileTargetPos = _variableGPSPos;
        };
        _miscSeeker set [1, false]; //sets if GPS position can be updated midflight
        _miscSeeker set [2, _variableGPSPos]; //GPS target position
    };
    case "EO": {
        _miscSeeker set [1, _targetPos];
    };
    case "SALH": {
        private _laserCode = _variableLaserCode;
        if(isNil "_variableLaserCode") then {_laserCode = ACE_DEFAULT_LASER_CODE};
        private _laserInfo = [_laserCode, ACE_DEFAULT_LASER_WAVELENGTH, ACE_DEFAULT_LASER_WAVELENGTH];
        _miscSeeker set [1, _laserInfo]; //Laser information
    };
    case "SACLOS": {
        _shooter setVariable [QGVAR(SACLOSMissile), _projectile];
    };
    case "MCLOS": {
        _shooter setVariable [QGVAR(MCLOSMissile), _projectile];
        _degreesPerSecond = 20;
        _miscSeeker set [3, true];
    };
    case "PLOS": {
        _miscSeeker set [1,[0,0,0]]; //Proportional Attack Intercept Vector; VALUE STAND-IN
    };
    case "IR": {
        _miscSeeker set [1,time]; // Give about a half second if contact is lost to reacquire
    };
    case "ARH": {
    
    };
    case "PRH": {};
    default {
        _miscSeeker set [0, false];
    };
};

_miscProfile set [0, [_mode, _variableLockMode]]; //top-attack/Overfly mode; PLACEHOLDER VALUE
//configure our attack profile settings based on type;
switch (_attackProfile) do {
    case "FGM": {

    };
    case "FIM": {
        _seekerAngle = 65;
        _fuzeVehicle = [20, false, 0];
    };
    case "ATGM": {
        _miscProfile set [0, false, 0]; //top-attack/Overfly mode; PLACEHOLDER VALUE
    };
    case "SSBM": {
        _degreesPerSecond = 12;
    };
    case "SAM": {
        _fuzeVehicle = [25, false, 0];
    };
    case "AGM": {

    };
    case "AAM": {
        _seekerAngle = 25;
        _fuzeVehicle = [15, false, 0];
    };
    case "GBU": {
        if(_seekerType == "GPS") then {
            _miscProfile set [1, 0]; //Custom angle of attack; Always negative; 0 or greater is ignored value.
        } else {

        };
    };
    case "ROCKET": {};
    case "INDIRECT": {
        _miscSeeker set [0, false]; //don't want mortar/artillery shells looking for targets on the upswing
    };
    case "DIRECT": {};
    default {};
};

//Aggregate settings in our array
private _miscManeuvering = [_degreesPerSecond, _glideAngle, diag_tickTime, time, 0]; //diag_tickTime used for '_lastTickTime'; time used for _lastRunTime
private _miscSensor = [_sensorAngle, _sensorMinRange, _sensorMaxRange];
private _miscFuze = [_fuzeVehicle, _fuzeAlt, _fuzeRange, _fuzeTime, _fuzeLoc];

// Setup camera array
private _cameraConfig = _config >> "camera";
private _cameraArray = [false];
if (!(_cameraConfig isEqualTo configNull) && { (getNumber (_cameraConfig >> "enabled")) == 1 }) then {
    _cameraArray set [0, true];
    _cameraArray set [1, getArray (_cameraConfig >> "fovLevels")];
    _cameraArray set [2, getNumber (_cameraConfig >> "initialFOV")];
    
    _cameraArray set [3, getArray (_cameraConfig >> "enabledThermalTypes")];
    _cameraArray set [4, getText (_cameraConfig >> "initialThermalType")];
    
    _cameraArray set [5, (getNumber (_cameraConfig >> "switchOnFire")) == 1];
    
    _cameraArray set [6, getNumber (_cameraConfig >> "lerpFOV")];
    _cameraArray set [7, getNumber (_cameraConfig >> "fovChangeTime")];
    
    _cameraArray set [8, [[0, 0, 0], [0, 0, 0], [0, 0, 0], false, false]]; // camera view data. [look direction, ground pos, point pos, moving camera x, moving camera y]
    
    _cameraArray set [9, [
        (getNumber (_cameraConfig >> "gimbal")) == 1,
        getNumber (_cameraConfig >> "gimbalAngleX"),
        getNumber (_cameraConfig >> "gimbalAngleY"),
        getNumber (_cameraConfig >> "gimbalSpeedX"),
        getNumber (_cameraConfig >> "gimbalSpeedY"),
        getNumber (_cameraConfig >> "gimbalInitOffsetX"),
        getNumber (_cameraConfig >> "gimbalInitOffsetY"),
        getArray (_cameraConfig >> "fovGimbalSpeedModifiers"),
        getNumber (_cameraConfig >> "stabilizeWhenMoving") == 1
    ]];
    
    _cameraArray set [10, (getNumber (_cameraConfig >> "alwaysDesignate")) == 1];
    _cameraArray set [11, (getNumber (_cameraConfig >> "designateWhenStationary")) == 1];
};

[_seekerType, _attackProfile, _target, _targetPos, _targetVector, _launchPos, _launchTime, _miscManeuvering, _miscSensor, _miscSeeker, _miscProfile, _miscFuze, _cameraArray];
