MACRO Interrupt_Disable
    xor a
    ld [rIF], a
    ld [rIE], a
ENDM

MACRO VBlank_Graphics
    SwitchROMBank [hVBlank_Bank]
    Get16 hl, hVBlank_Func
    
    ; Skip if hl == $0000
    or h
    jr z, .SkipFunc\@
        call CallHL
    .SkipFunc\@:
ENDM


SECTION "HRAM VBLANK", HRAM

DEF VBLANK_DMA_MASK EQU %00000001
DEF VBLANK_DMA_KEY EQU 0
DEF VBLANK_AWAIT_MASK EQU %10000000
DEF VBLANK_AWAIT_KEY EQU 7
hVBlank_Requests::
    db
hVBlank_Bank::
    db
hVBlank_Func::
    dw

hVBlank_Source::
    dw
hVBlank_Dest::
    dw
hVBlank_VBK::
    db
hVBlank_TileCount::
    db


hHBlank_Func::
    dw

SECTION "InterruptX", ROMX
Interrupt_Init::
    di
    xor a
    ld [hVBlank_Bank], a
    ld [hVBlank_Requests], a
    ld [rIF], a
    ld [rIE], a
    Set8 rSTAT, STATF_LYC
    Set8 rLYC, -1

    Set16 hVBlank_Func, $0000
    ret

Interrupt_SetTimer::
    ; Activate the timer at the rate of 59.8 interrupts per second
    ; This approximately is the same as the refresh rate, reducing the sound glitches when the screen is temporarily disabled, as
    ; the real VBlank is disabled while the screen is off
    Set8 rTMA, $77
    Set8 rTAC, %100

    xor a
    ld [rIF], a
    Set8 rIE, IEF_TIMER
    ld a, $FF
    ei
    ld [rTIMA], a
    ret

Interrupt_SetVBlank::
    xor a
    ld [rIF], a
    Set8 rIE, IEF_VBLANK | IEF_STAT
    ei
    ret


SECTION "Interrupt_VBlank", ROM0[$0040]
Interrupt_VBlank::
    jp VBlank_Interrupt

SECTION "Interrupt_HBlank", ROM0[$0048]
Interrupt_HBlank::
    jp HBlank_Interrupt

SECTION "Interrupt_Timer", ROM0[$0050]
Interrupt_Timer::
    jp Timer_Interrupt

SECTION "Interrupt_Serial", ROM0[$0058]
Interrupt_Serial::
    Crash
    reti

SECTION "Interrupt_Joypad", ROM0[$0060]
Interrupt_Joypad::
    Crash
    reti

SECTION "Interrupt", ROM0[$3000] ; TODO remove this hardcoded - easier for debugging as the breakpoint doesn't move

HBlank_Interrupt::
    push af
    push hl
    Get16 hl, hHBlank_Func
    jp hl

HBlank_GameSCX::
    ; Set the camera to the game position
    Mov8 rSCX, wScreen_X

    ; If there is a window, run HBlank_Textbox
    ld a, [rWY]
    cp 144
    jr z, .End
    .SetupTextbox
        ld [rLYC], a
        Set16 hHBlank_Func, HBlank_TextboxDisableSprite
        pop hl
        pop af
        reti
    .End:
        Set8 rLYC, -1
        pop hl
        pop af
        reti


HBlank_TextboxDisableSprite::
    ; Disables sprites from appearing above the textbox
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_OBJ8 | LCDCF_OBJOFF | LCDCF_BGON
    ld [rLCDC], a
    ld [wLCD_LCDC], a
    ; Disable HBlank
    Set8 rLYC, -1
    pop hl
    pop af
    reti

VBlank_Await::
    ; Wait until the VBlank handler has run
    ; If the screen is off, this function will run the graphics functions from the VBlank handler and immediately continue
    ld a, [wLCD_LCDC]
    or a
    jr z, .ScreenOff
    .ScreenOn:
        ld a, [hVBlank_Requests]
        or VBLANK_AWAIT_MASK
        ld [hVBlank_Requests], a

        .Wait:
            halt
            ld a, [hVBlank_Requests]
            or a
            jr nz, .Wait
            ret
    .ScreenOff:
        VBlank_Graphics
        ret

VBlank_Func_Null:
    ret

VBlank_Func_CopyTile::
    ; Copy x tiles from hVBlank_Source to hVBlank_Dest
    ; Arguments:
    ;   wVBlank_SourceAddress
    ;   hVBlank_VBK
    ;   hVBlank_Dest
    ;   hVBlank_TileCount
    Get16 hl, hVBlank_Source
    Get16 bc, hVBlank_Dest
    Mov8 rVBK, hVBlank_VBK
    Get8 d, hVBlank_TileCount
    .Loop:
        REPT $10
            LdBCIHLI
        ENDR
        dec d
        jr nz, .Loop
    Set16 hVBlank_Func, $0000
    ret


VBlank_Interrupt::
    SaveRegisters
    PushRAMBank
    PushROMBank

    VBlank_Graphics

    ld a, [hVBlank_Requests]
    bit VBLANK_DMA_KEY, a
    jr z, .SkipDMA
        call hDMA_Transfer
    .SkipDMA:

    XCall Textbox_VBlank_Slide

    XCall Joypad_Update

    xor a
    ld [hVBlank_Requests], a

    ei
    PopROMBank
    PopRAMBank
    RestoreRegisters
    reti

Timer_Await::
    ; Wait until the Timer handler has run

    ; Time handler should not be running if Screen is on, exit immediately
    ld a, [wLCD_LCDC]
    or a
    ret nz

    ld a, [hVBlank_Requests]
    or VBLANK_AWAIT_MASK
    ld [hVBlank_Requests], a

    halt
    nop
    .Wait:
        ld a, [hVBlank_Requests]
        or a
        jr nz, .Wait
        ret

Timer_Interrupt::
    SaveRegisters
    PushRAMBank
    PushROMBank

    ; Sound stuff

    ;XCall Joypad_Update

    xor a
    ld [hVBlank_Requests], a

    ei
    PopROMBank
    PopRAMBank
    RestoreRegisters
    reti