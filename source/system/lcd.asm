SECTION "WRAM LCD", WRAM0
wLCD_IsOn::
    ds 1

SECTION "LCD", ROM0

LCD_Off::
    ; Abort if LCD already off
    ld a, [rLCDC]
    bit 7, a
    ret z

    ; Disable all interrupts
    xor a
    ld [rIF], a
    ld [rIE], a

    ; Mark LCD as Off
    xor a
    ld [wLCD_IsOn], a
    Crash

LCD_On::
    Set8 wLCD_IsOn, 1
    Crash