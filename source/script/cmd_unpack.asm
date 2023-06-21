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

MACRO GameTilemap
    db Enum_Cmd_GameTilemap
    BankAddress \1 ; GameTileAttrmap
ENDM
Cmd_GameTilemap::
    ; LCD must be off
    ; Arguments:
    ;   BankAddress of GameTileAttrmap
    LCD_AssertOff

    Script_ReadByte d
    Script_ReadWord hl
    Set16 hScript_Current.Address, bc
    ld b, h
    ld c, l
    call Tilemap_Game_UnpackTileAttr

    Get16 bc, hScript_Current.Address
    jp Script_Read

MACRO Tileset
    db Enum_Cmd_Tileset
    BankAddress \1 ; Tileset
    dw \2          ; Destination
    db \3          ; VBK bank
ENDM
Cmd_Tileset::
    LCD_AssertOff

    Script_ReadByte d
    Script_ReadWord hl
    push hl
    Script_ReadWord hl
    Script_ReadByte a
    push af
    Set16 hScript_Current.Address, bc
    pop af
    pop bc
    call Tileset_Unpack

    Get16 bc, hScript_Current.Address
    jp Script_Read