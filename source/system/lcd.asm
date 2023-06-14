SECTION "WRAM LCD", WRAM0
wLCD_LCDC::
    ds 1

SECTION "LCDX", ROMX

LCD_Init::
    call LCD_Off
    call LCD_On
    ret

SECTION "LCD", ROM0

LCD_Off::
    ; Abort if LCD already off
    ld a, [rLCDC]
    bit 7, a
    ret z

    ; Disable all interrupts
    Interrupt_Disable

    ; Await VBlank manually since no interrupts
    .WaitLoop:
        ld a, [rLY]
        cp 144
        jr nz, .WaitLoop

    ; Turn off and mark LCD as off
    xor a
    ld [rLCDC], a
    ld [wLCD_LCDC], a

    XCall Interrupt_SetTimer

    ret

LCD_On::
    ; Abort if LCD already on
    ld a, [rLCDC]
    bit 7, a
    ret nz


    ; Disable pending VBlank requests
    xor a
    ld [hVBlank_Requests], a

    XCall Interrupt_SetVBlank

    ; Turn on LCDC
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
    ld [rLCDC], a
    ld [wLCD_LCDC], a

    ret