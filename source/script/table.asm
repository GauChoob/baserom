MACRO Script_AddCommand
    .\1:
        dw \1
    DEF Enum_\1 RB 1
ENDM

RSRESET
Script_Table::
    Script_AddCommand Cmd_Wait
    Script_AddCommand Cmd_End
    Script_AddCommand Cmd_Jump
    Script_AddCommand Cmd_JumpTable