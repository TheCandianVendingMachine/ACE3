#include "script_component.hpp"

["ACE3 Weapons", QGVAR(MFKey1), localize LSTRING(MFKey1),
{
    [1, true] call FUNC(keyDown);
},
{
    [1, false] call FUNC(keyDown);
},
[15, [false, false, false]], false] call CBA_fnc_addKeybind;  //Tab Key

["ACE3 Weapons", QGVAR(MFKey2), localize LSTRING(MFKey2),
{
    [2, true] call FUNC(keyDown);
},
{
    [2, false] call FUNC(keyDown);
},
[15, [false, true, false]], false] call CBA_fnc_addKeybind;  //Ctrl+Tab Key

["ACE3 Weapons", QGVAR(MFKeyUp), localize LSTRING(MFKeyUp),
{
    [3, true] call FUNC(keyDown);
},
{
    [3, false] call FUNC(keyDown);
},
[200, [false, false, false]], false] call CBA_fnc_addKeybind;  //Up Arrow

["ACE3 Weapons", QGVAR(MFKeyLeft), localize LSTRING(MFKeyLeft),
{
    [4, true] call FUNC(keyDown);
},
{
    [4, false] call FUNC(keyDown);
},
[203, [false, false, false]], false] call CBA_fnc_addKeybind;  //Left

["ACE3 Weapons", QGVAR(MFKeyRight), localize LSTRING(MFKeyRight),
{
    [5, true] call FUNC(keyDown);
},
{
    [5, false] call FUNC(keyDown);
},
[205, [false, false, false]], false] call CBA_fnc_addKeybind;  //Right

["ACE3 Weapons", QGVAR(MFKeyDown), localize LSTRING(MFKeyDown),
{
    [6, true] call FUNC(keyDown);
},
{
    [6, false] call FUNC(keyDown);
},
[208, [false, false, false]], false] call CBA_fnc_addKeybind;  //Down

["ACE3 Weapons", QGVAR(Camera_N), localize LSTRING(Camera_ViewModeCycle),
{
    [7, true] call FUNC(keyDown);
},
{
    [7, false] call FUNC(keyDown);
},
[49, [false, false, false]], false] call CBA_fnc_addKeybind;  //N

["ACE3 Weapons", QGVAR(Camera_NumPlus), localize LSTRING(Camera_ZoomIncrease),
{
    [8, true] call FUNC(keyDown);
},
{
    [8, false] call FUNC(keyDown);
},
[78, [false, false, false]], false] call CBA_fnc_addKeybind;  //Keypad+

["ACE3 Weapons", QGVAR(Camera_NumMinus), localize LSTRING(Camera_ZoomDecrease),
{
    [9, true] call FUNC(keyDown);
},
{
    [9, false] call FUNC(keyDown);
},
[74, [false, false, false]], false] call CBA_fnc_addKeybind;  //Keypad-

GVAR(projectileCameraHash) = [[], objNull] call CBA_fnc_hashCreate;
GVAR(activeCamera) = objNull;

// add camera interactions
private _switchToCameraAction = ["SwitchToCamera", "Switch To Missile Camera", "", {
    // statement
    params ["_target", "_player", "_params"];
    private _camera = _player getVariable [QGVAR(missileCamera), objNull];
    [_camera] call FUNC(camera_switchTo);
}, {
    // condition
    params ["_target", "_player", "_params"];
    private _camera = _player getVariable [QGVAR(missileCamera), objNull];
    private _projectile = _camera getVariable [QGVAR(missile), objNull];
    !([] call FUNC(camera_userInCamera)) && { !(_camera isEqualTo objNull); } && { !(_projectile isEqualTo objNull) }
}/*, {
    params ["_target", "_player", "_params"];
    // insert children
}*/] call EFUNC(interact_menu,createAction);
["CAManBase", 1, ["ACE_SelfActions"], _switchToCameraAction, true] call EFUNC(interact_menu,addActionToClass);

true
