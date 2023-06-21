MACRO Script_AddCommand
    .\1:
        dw \1
    DEF Enum_\1 RB 1
ENDM


SECTION "ScriptTable", ROM0

RSRESET
Script_Table::
    ; control.asm
    Script_AddCommand Cmd_Wait
    Script_AddCommand Cmd_End
    Script_AddCommand Cmd_Jump
    Script_AddCommand Cmd_JumpTable
    ; system.asm
    Script_AddCommand Cmd_LCDOff
    Script_AddCommand Cmd_LCDOn
    ; text.asm
    Script_AddCommand Cmd_TextboxClose
    Script_AddCommand Cmd_TextboxOpen
    Script_AddCommand Cmd_TextboxPortrait
    Script_AddCommand Cmd_Write
    ; unpack.asm
    Script_AddCommand Cmd_GameTilemap
    Script_AddCommand Cmd_Palette
    Script_AddCommand Cmd_StaticTilemap
    Script_AddCommand Cmd_Tileset