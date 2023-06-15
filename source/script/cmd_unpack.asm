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
    Script_AwaitAvailableVBlankFunc

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

MACRO StaticTilemap
    db Enum_Cmd_StaticTilemap
    BankAddress \1 ; StaticTileAttrmap
    dw \2          ; Destination
ENDM
Cmd_StaticTilemap::
    ; LCD must be off
    ; Arguments:
    ;   BankAddress of StaticTileAttrmap
    ;   dw  Destination
    LCD_AssertOff

    Script_ReadByte d
    Script_ReadWord hl
    push hl
    Script_ReadWord hl
    Set16 hScript_Current.Address, bc
    pop bc
    call Tilemap_Static_UnpackTileAttr

    Get16 bc, hScript_Current.Address
    jp Script_Read
