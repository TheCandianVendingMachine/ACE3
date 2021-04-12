#include "script_component.hpp"
/*
 * Author: jaynus / nou
 * Seeker Type: SALH (Laser)
 * Wrapper for ace_laser_fnc_seekerFindLaserSpot
 *
 * Arguments:
 * 1: Guidance Arg Array <ARRAY>
 * 2: Seeker State <ARRAY>
 *
 * Return Value:
 * Missile Aim PosASL <ARRAY>
 *
 * Example:
 * [[], [], []] call ace_missileguidance_fnc_seekerType_SALH;
 *
 * Public: No
 */
#define MAX_AVERAGES 15

params ["", "_args"];
_args params ["_firedEH", "_launchParams", "", "_seekerParams"];
_firedEH params ["","","","","","","_projectile"];
_launchParams params ["","","","","","_laserParams"];
_seekerParams params ["_seekerAngle", "", "_seekerMaxRange", "", ["_lastPositions", []], ["_lastPositionIndex", 0]];
_laserParams params ["_code", "_wavelengthMin", "_wavelengthMax"];

private _laserResult = [(getPosASL _projectile), (velocity _projectile), _seekerAngle, _seekerMaxRange, [_wavelengthMin, _wavelengthMax], _code, _projectile] call EFUNC(laser,seekerFindLaserSpot);
private _foundTargetPos = _laserResult select 0;
TRACE_1("Search", _laserResult);

if (isNil "_foundTargetPos") exitWith {
	[0, 0, 0]
};

// average out any error from laser jump
private _positionSum = [0, 0, 0];
{
	_positionSum = _positionSum vectorAdd _x;
} forEach _lastPositions;

if (_foundTargetPos isNotEqualTo [0, 0, 0]) then {
	_lastPositions set [_lastPositionIndex % MAX_AVERAGES, _foundTargetPos];
	_seekerParams set [4, _lastPositions];
	_seekerParams set [5, _lastPositionIndex + 1];
};

_positionSum = _positionSum vectorAdd _foundTargetPos;
if (MAX_AVERAGES == count _lastPositions) then {
	_positionSum = _positionSum vectorMultiply (1 / (1 + count _lastPositions));
} else {
	_positionSum = _positionSum vectorMultiply (1 / count _lastPositions);
};

TRACE_3("laser target found",_foundTargetPos,_positionSum,count _lastPositions);

_positionSum
