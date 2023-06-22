RENDER_TILEMAP EQU $9900

SECTION "WRAM Tilemap Render", WRAM0
wScreen_X::
    dw
wCamera_Buffer::
    ; Tilemap then attrmap
    ds TILEMAP_GAME_HEIGHT*2
CAMERA_STATUS_OFF EQU 0
CAMERA_STATUS_ON EQU 1
wCamera_Status::
    db


SECTION "Tilemap Render", ROMX

Camera_Init::
    xor a
    ld [wScreen_X], a
    ld [wCamera_Status], a
    ret

Camera_CalculateScreenPosition::
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

Camera_CalculateActorPosition::
    ; Calculate wScreen_X first via Camera_CalculateScreenPosition
    ; wActor.X - wScreen_X - wHero.Y/16
    Crash
    ret

    ;Offset from wScreen_X (-6 to -1 is left of the screen, 0-19 is visible screen, 20-25 is right of screen)


Camera_VBlank_CopyColumn::
    ; Set up with Camera_ColumnPrepare
    Get16 hl, hVBlank_Dest
    ld bc, wCamera_Buffer
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
        ENDC
    ENDR

    Set8 rVBK, 1
    pop hl
    FOR loop, 0, TILEMAP_GAME_HEIGHT
        ld a, [bc]
        ld [hl], a
        IF loop != (TILEMAP_GAME_HEIGHT - 1)
            inc bc
            add hl, de
        ENDC
    ENDR

    Set16 hVBlank_Func, $0000
    ret

Camera_ColumnPrepare::
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
    ld a, [wScreen_X]
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

    ; hl = Source = hl + de = xTilemap + (wScreen_X/8) % 32 + Column offset
    ld de, xTilemap
    add hl, de

    ld bc, wCamera_Buffer
    Get16 de, wTilemap_Width

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
    FOR loop, 0, TILEMAP_GAME_HEIGHT
        ld a, [hl]
        ld [bc], a
        IF loop != (TILEMAP_GAME_HEIGHT - 1)
            inc bc
            add hl, de
        ENDC
    ENDR

    SRAM_Off

    Set8 hVBlank_Bank, BANK(Camera_VBlank_CopyColumn)
    Set16 hVBlank_Func, Camera_VBlank_CopyColumn
    ret


Camera_Setup::
    ; Renders the screen and 6 tiles extra to the left and right
    ; Inputs:
    ;   wScreen_X
    LCD_AssertOff

    ; Update the screen position
    xor a
    ld [rSCY], a
    Mov8 rSCX, wScreen_X

    ; Render all the columns
    ld de, 32 ; Do 0-31sssssssssssssssssssssssssssssssssss
    .RenderLoop:
        push de
        dec de
        call Camera_ColumnPrepare
        call Camera_VBlank_CopyColumn
        pop de
        Dec16Loop de, .RenderLoop
    
    Set8 wCamera_Status, CAMERA_STATUS_ON
    ret

Camera_Do::
    ; Handles the rendering
    ret