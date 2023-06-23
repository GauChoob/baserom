TILEMAP_GAME EQU $9900
CAMERA_LEFT_LIMIT EQU 4
CAMERA_RIGHT_LIMIT EQU 8
ASSERT CAMERA_LEFT_LIMIT + 20 + CAMERA_RIGHT_LIMIT == 32

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
wCamera_PendingRenders_Left::
    db
wCamera_PendingRenders_Right::
    db


SECTION "Tilemap Render", ROMX

Camera_Init::
    xor a
    ld [wScreen_X], a
    ld [wScreen_X + 1], a
    ld [wCamera_Status], a
    ret

Camera_CalculateScreenPosition::
    ; wScreen_X = wActor_Hero.X - (wActor_Hero.X*20/wTilemap_Width)

    ; hl = wActor_Hero.X*20
    Get16 hl, wActor_Hero.X
    push hl
    ld e, l
    ld d, h
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, hl

    ; de = hl/wTilemap_Width = (wActor_Hero.X*20/wTilemap_Width)
    Get16 bc, wTilemap_Width
    call Math_Div16

    ; de = -de = -(wActor_Hero.X*20/wTilemap_Width)
    TwosComp de

    ; wActor_Hero.X - de = wActor_Hero.X - (wActor_Hero.X*20/wTilemap_Width)
    pop hl
    add hl, de

    Set16 wScreen_X, hl
    ret

Camera_CalculateActorPosition::
    ; Calculate wScreen_X first via Camera_CalculateScreenPosition
    ; wActor.X - wScreen_X - wActor_Hero.Y/16
    ; 64 + wActor_Hero.Y/4
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
    ;   de = Column (-6 to 57)

    ; Target = TILEMAP_GAME/$9900 + (Column offset % 32)
    push de
    ; de = de % 32 = de and %0000000000011111 = (Column offset % 32)
    ld d, 0
    ld a, e
    and %00011111
    ld e, a
    ; Target = TILEMAP_GAME/$9900 + (Column offset % 32)
    ld hl, TILEMAP_GAME
    add hl, de
    Set16 hVBlank_Dest, hl
    pop de

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
    ld a, [wScreen_X]
    ld [rSCX], a

    ; Get the first Column of the viewport
    srl a
    srl a
    srl a
    ; de = wScreen_X/8 which is the Column of the viewport
    ld d, 0
    ld e, a
    ; Render from the left limit to the right limit
    REPT CAMERA_LEFT_LIMIT
        dec de
    ENDR

    ld bc, 32 ; Render a total of 32 columns
    .RenderLoop:
        push de
        push bc
        call Camera_ColumnPrepare
        call Camera_VBlank_CopyColumn
        pop bc
        pop de
        inc de
        Dec16Loop bc, .RenderLoop
    
    Set8 wCamera_Status, CAMERA_STATUS_ON
    xor a
    ld [wCamera_PendingRenders_Left], a
    ld [wCamera_PendingRenders_Right], a
    ret

Camera_Do::
    ; Handles the rendering
    ret