SECTION "CmdTilemap", ROM0

MACRO CameraOn
    db Enum_Cmd_CameraOn
ENDM
Cmd_CameraOn::
    ; LCD must be off
    ; Enable screen drawing
    ; Arguments:
    ;   None
    LCD_AssertOff
    push bc
    CallForeign Camera_Setup
    pop bc
    jp Script_Read