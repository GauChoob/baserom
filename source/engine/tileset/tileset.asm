SECTION "Tileset", ROM0

Tileset_Unpack::
    ; Unpacks a tileset to the destination
    ; Inputs:
    ;   d = TilemapStaticObject Bank
    ;   bc = TilemapStaticObject Address
    ;   hl = Destination
    ;   a = VBK
    ; Destroys:
    ;   All
    ld [rVBK], a

    PushROMBank
    SwitchROMBank d

    Get8 e, bc
    inc bc
    Get8 d, bc
    inc bc
    call Mem_Copy

    PopROMBank
    ret