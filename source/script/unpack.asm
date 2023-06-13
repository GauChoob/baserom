SECTION "Unpack", ROM0

MACRO Palette
    db Enum_Cmd_Palette
    BankAddress \1 ; Palette
    db \2          ; Destination Offset
    db \3          ; Targets PALETTE_UNPACK_SHADOW_MASK, PALETTE_UNPACK_TARGET_MASK
ENDM
Cmd_Palette::
    ; Arguments:
    ;   BankAddress of Palette
    ;   db  Destination offset
    ;   db  Targets
    Script_ReadByte a
    push af
    Script_ReadWord hl
    Script_ReadByte e
    Script_ReadByte d
    Set16 hScript_Current.Address, bc
    ld b, h
    ld c, l
    pop hl
    call Palette_Unpack
    ret