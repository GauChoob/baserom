MACRO LCDOff
    db Enum_Cmd_LCDOff
ENDM
Cmd_LCDOff::
    ; Arguments:
    ;   None
    call LCD_Off
    jp Script_Read

MACRO LCDOn
    db Enum_Cmd_LCDOn
ENDM
Cmd_LCDOn::
    ; Arguments:
    ;   None
    call LCD_On
    jp Script_Read