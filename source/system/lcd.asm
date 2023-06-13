SECTION "WRAM LCD", WRAM0
wLCD_IsOn::
    ds 1

SECTION "LCDX", ROMX

LCD_Init:
    Set8 wLCD_IsOn, 1
    ret

SECTION "LCD", ROM0

LCD_Off::
    ; Abort if LCD already off
    ld a, [rLCDC]
    bit 7, a
    ret z

    ; Disable all interrupts
    Interrupt_Disable

    ; Mark LCD as Off
    xor a
    ld [wLCD_IsOn], a
    Crash

    ; Await VBlank manually since no interrupts
    .WaitLoop:
        ld a, [rLY]
        cp 144
        jr nz, .WaitLoop

    xor a
    ld [rLCDC], a

    XCall Interrupt_SetTimer

    ret

LCD_On::
    Set8 wLCD_IsOn, 1
    Crash