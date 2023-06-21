TILEMAP_GAME_HEIGHT EQU 10

SECTION "WRAM Tilemap Game", WRAM0
wTilemap_Width::
    ds 2

SECTION "XRAM Tilemap Game", SRAM
xTilemap::
    ds $2000

SECTION "XRAM Attrmap Game", SRAM
xAttrmap::
    ds $2000

SECTION "Tilemap Game", ROM0

Tilemap_Game_Unpack:
    ; Inputs:
    ;   d = TilemapStaticObject Bank
    ;   bc = TilemapStaticObject Address
    ; Destroys:
    ;   bc = Points to end of file
    ;   All
    PushROMBank
    SwitchROMBank d

    ; width
    ld a, [bc]
    ld [wTilemap_Width], a
    ld e, a
    inc bc
    ld a, [bc]
    ld [wTilemap_Width + 1], a
    ld d, a
    inc bc

    ; height
    ld a, [bc]
    inc bc

    ; Assert height is fixed value
    cp TILEMAP_GAME_HEIGHT
    jr z, .Pass
        Crash
    .Pass

    SRAM_On
    .LoopWidth:
        REPT TILEMAP_GAME_HEIGHT
            LdHLIBCI
        ENDR
        Dec16Loop de, .LoopWidth
    SRAM_Off

    PopROMBank
    ret

Tilemap_Game_UnpackTileAttr::
    ; Unpacks a game tilemap and then attrmap to the destination
    ; Inputs:
    ;   d = TilemapGameObject Bank
    ;   bc = TilemapGameObject Address
    ; Destroys:
    ;   All
    SwitchSRAMBank BANK(xTilemap)
    ld hl, xTilemap
    push de
    call Tilemap_Game_Unpack
    pop de
    SwitchSRAMBank BANK(xAttrmap)
    ld hl, xAttrmap
    call Tilemap_Game_Unpack
    ret