
MACRO Text_Setup
    ; \1 = VBK
    ; \2 = Tileset destination
    Set8 hVBlank_VBK, \1
    Set16 wText_DestinationAddress, \2
    CallForeign Text_ResetBuffer
ENDM

SECTION "WRAM TEXT", WRAM0

wText_FontAddress::
    dw
wText_WidthAddress::
    dw

wText_DestinationAddress::
    dw
wText_DestinationOffset::
    db
wText_TilesetBuffer::
    ds $40
wText_CharWidth::
    db



SECTION "TextX", ROMX, BANK[TEXT_BANK]

Text_Init::
    Set16 wText_FontAddress, BITMAP_Charmap_Tall
    Set16 wText_WidthAddress, Charmap_Tall_Width
    call Text_ResetBuffer
    ret

Text_ResetBuffer::
    xor a
    ld [wText_CharWidth], a
    ld [wText_DestinationOffset], a

    ld b, $00
    ld de, $20
    ld hl, wText_TilesetBuffer
    call Mem_Set
    ret

SECTION "TEXT", ROM0

Text_HandleCharacterRow::
    ; Inputs:
    ;   hl = source
    ;   bc = destination
    ;   wText_DestinationOffset
    Get8 e, hl+
    inc hl ; Assume that only palette ids 0 and 3 are used so we treat as 1bbp instead of 2bbp
    ld d, $00
    push hl

    ; We need to rotate by the offset
    ld a, [wText_DestinationOffset]
    or a
    jr z, .Skip
    .Loop:
        rrc e
        rr d
        rrc c
        rr b
        dec a
        jr nz, .Loop
    .Skip:

    ; Store the first byte twice ("or" with previous data)
    ld a, [bc]
    or e
    ld [bc], a
    inc bc
    ld [bc], a
    inc bc ; +2
    push bc

    ; Store the second byte twice (overwrite old data)
    ld hl, $20 - 2 ; -2
    add hl, bc
    ld a, d
    ld [hl+], a
    ld [hl], a

    pop bc
    pop hl
    ret

Text_PrepareCharacter::
    ; Inputs:
    ;   a = char
    ;   wText_DestinationOffset
    ;   wText_CharWidth from previous frame
    ;   wText_FontAddress, wText_WidthAddress = font
    ;   
    ld b, a
    PushROMBank
    SwitchROMBank TEXT_BANK
    push bc

    ; Update wText_DestinationOffset by adding the width of the previous char
    Get8 c, wText_DestinationOffset
    ld a, [wText_CharWidth]
    add c
    ld [wText_DestinationOffset], a
    JumpSmaller 8, .SkipIncrement
        ; Modulo wText_DestinationOffset
        add -8
        ld [wText_DestinationOffset], a
        ; Update to the next byte horizontally (+$20)
        Get16 hl, wText_DestinationAddress
        ld bc, $20
        add hl, bc
        Set16 wText_DestinationAddress, hl
        ; Shift the bytes in wText_TilesetBuffer
        ld bc, wText_TilesetBuffer + $20
        ld hl, wText_TilesetBuffer
        ld de, $20
        call Mem_Copy
    .SkipIncrement

    ; Get the width of the current char for the next cycle
    pop af
    ld c, a
    ld b, $00
    Get16 hl, wText_WidthAddress
    add hl, bc
    Mov8 wText_CharWidth, hl

    ; Find the char tile data in memory
    ; *$20
    ;ld b, $00
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    Get16 hl, wText_FontAddress
    add hl, bc

    ; Iterate through the height of the tile ($10)
    ld bc, wText_TilesetBuffer
    ld a, $10
    .Loop:
        push af
        call Text_HandleCharacterRow
        pop af
        dec a
        jr nz, .Loop

    ; Set up VBlank
    ld a, [hVBlank_Requests]
    or VBLANK_FUNC_MASK
    ld [hVBlank_Requests], a
    Mov16 hVBlank_Dest, wText_DestinationAddress
    Set16 hVBlank_Source, wText_TilesetBuffer
    Set16 hVBlank_Func, VBlank_Func_CopyTile
    Set8 hVBlank_TileCount, 4

    PopROMBank
    ret