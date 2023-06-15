SECTION "Tilemap Static", ROM0

Tilemap_Static_Unpack:
    ; Inputs:
    ;   d = TilemapStaticObject Bank
    ;   bc = TilemapStaticObject Address
    ;   hl = Destination
    ; Destroys:
    ;   bc = Points to end of file
    ;   All
    PushROMBank
    SwitchROMBank d

    ; width
    ld a, [bc]
    ld d, a
    inc bc

    ; height
    ld a, [bc]
    ld e, a
    inc bc

    .LoopHeight:
        push de
        push hl
        .LoopWidth:
            LdHLIBCI
            dec d
            jr nz, .LoopWidth
        ; Next row
        pop hl
        ld de, $20
        add hl, de

        pop de
        dec e
        jr nz, .LoopHeight
    PopROMBank
    ret

Tilemap_Static_UnpackTileAttr::
    ; Unpacks a static tilemap and then attrmap to the destination
    ; Inputs:
    ;   d = TilemapStaticObject Bank
    ;   bc = TilemapStaticObject Address
    ;   hl = Destination
    ; Destroys:
    ;   All
    xor a
    ld [rVBK], a
    push de
    push hl
    call Tilemap_Static_Unpack
    pop hl
    pop de
    Mov8 rVBK, 1
    call Tilemap_Static_Unpack
    ret