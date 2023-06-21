RENDER_TILEMAP EQU $9900

SECTION "WRAM Tilemap Render", WRAM0
wScreen_X::
    dw
wRender_Buffer::
    ; Tilemap then attrmap
    ds TILEMAP_GAME_HEIGHT*2


SECTION "Tilemap Render", ROMX

Tilemap_Render_Init::
    xor a
    ld [wScreen_X], a
    ret

Tilemap_Render_CalculateScreenPosition::
    ; wScreen_X = wHero.X - (wHero.X*20/wTilemap_Width)

    ; hl = wHero.X*20
    Get16 hl, wHero.X
    push hl
    ld e, l
    ld d, h
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, hl

    ; de = hl/wTilemap_Width = (wHero.X*20/wTilemap_Width)
    Get16 bc, wTilemap_Width
    call Math_Div16

    ; de = -de = -(wHero.X*20/wTilemap_Width)
    TwosComp de

    ; wHero.X - de = wHero.X - (wHero.X*20/wTilemap_Width)
    pop hl
    add hl, de

    Set16 wScreen_X, hl
    ret

Tilemap_Render_CalculateActorPosition::
    ; Calculate wScreen_X first via Tilemap_Render_CalculateScreenPosition
    ; wActor.X - wScreen_X - wHero.Y/16
    Crash
    ret

    ;Offset from wScreen_X (-6 to -1 is left of the screen, 0-19 is visible screen, 20-25 is right of screen)


Tilemap_Render_VBlank_CopyColumn::
    ; Set up with Tilemap_Render_ColumnPrepare
    Get16 hl, hVBlank_Dest
    Get16 bc, wRender_Buffer
    push hl
    ld de, $20

    xor a
    ld [rVBK], a
    FOR loop, 0, TILEMAP_GAME_HEIGHT
        ld a, [bc]
        ld [hl], a
        inc bc
        IF loop != (TILEMAP_GAME_HEIGHT - 1)
            add hl, de
        ENDR
    ENDR

    Set8 rVBK, 1
    pop hl
    FOR loop, 0, TILEMAP_GAME_HEIGHT
        ld a, [bc]
        ld [hl], a
        IF loop != (TILEMAP_GAME_HEIGHT - 1)
            inc bc
            add hl, de
        ENDR
    ENDR
    ret

Tilemap_Render_ColumnPrepare::
    ; Inputs:
    ;   wScreen_X
    ;   de = Column (0-31)

    ; Target = RENDER_TILEMAP/$9900 + Column offset
    ld hl, RENDER_TILEMAP
    add hl, de
    Set16 hVBlank_Dest, hl

    ; Source:
    ; ha = wScreen_X/8 -> Get the tile offset (instead of bit offset)
    Get8 h, wScreen_X + 1
    Get8 a, wScreen_X
    srl h
    rra
    srl h
    rra
    srl h
    rra

    ; a % 32 to Get the tileoffset aligned to the nearest 32
    and %11100000
    ld l, a

    ; hl = (wScreen_X/8) % 32
    ; hl = Source = hl + de = (wScreen_X/8) % 32 + Column offset
    add hl, de

    ld bc, wRender_Buffer
    ld de, wTilemap_Width

    push hl

    SwitchSRAMBank BANK(xTilemap)
    SRAM_On
    FOR loop, 0, TILEMAP_GAME_HEIGHT
        ld a, [hl]
        ld [bc], a
        inc bc
        IF loop != (TILEMAP_GAME_HEIGHT - 1)
            add hl, de
        ENDC
    ENDR

    pop hl

    SwitchSRAMBank BANK(xAttrmap)
    SRAM_On
    FOR loop, 0, TILEMAP_GAME_HEIGHT
        ld a, [hl]
        ld [bc], a
        IF loop != (TILEMAP_GAME_HEIGHT - 1)
            inc bc
            add hl, de
        ENDC
    ENDR

    SRAM_Off

    Set8 hVBlank_Bank, BANK(Tilemap_Render_VBlank_CopyColumn)
    Set16 hVBlank_Func, Tilemap_Render_VBlank_CopyColumn
    ret


Tilemap_Render_Base::
    ; Renders the screen and 6 tiles extra to the left and right
    ; Inputs:
    ;   wScreen_X
    LCD_AssertOff

    xor a
    ld [rSCY], a
    Mov8 rSCX, wScreen_X

    ld de, 31
    .RenderLoop:
        call Tilemap_Render_ColumnPrepare
        call Tilemap_Render_VBlank_CopyColumn
        Dec16Loop de, .RenderLoop
    
    ret