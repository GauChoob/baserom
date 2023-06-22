MACRO Script_AddCommand
    .\1:
        dw \1
    DEF Enum_\1 RB 1
ENDM


SECTION "ScriptTable", ROM0

RSRESET
Script_Table::
    ; cmd_camera.asm
    Script_AddCommand Cmd_CameraOn
    ; cmd_control.asm
    Script_AddCommand Cmd_Wait
    Script_AddCommand Cmd_End
    Script_AddCommand Cmd_Jump
    Script_AddCommand Cmd_JumpTable
    ; cmd_ram.asm
    Script_AddCommand Cmd_RamAdd8
    Script_AddCommand Cmd_RamAdd16
    Script_AddCommand Cmd_RamSet8
    Script_AddCommand Cmd_RamSet16
    ; cmd_system.asm
    Script_AddCommand Cmd_LCDOff
    Script_AddCommand Cmd_LCDOn
    ; cmd_text.asm
    Script_AddCommand Cmd_TextboxClose
    Script_AddCommand Cmd_TextboxOpen
    Script_AddCommand Cmd_TextboxPortrait
    Script_AddCommand Cmd_Write
    ; cmd_unpack.asm
    Script_AddCommand Cmd_GameTilemap
    Script_AddCommand Cmd_Palette
    Script_AddCommand Cmd_StaticTilemap
    Script_AddCommand Cmd_Tileset