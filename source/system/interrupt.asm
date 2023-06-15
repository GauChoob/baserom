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

SECTION "InterruptX", ROMX
Interrupt_Init::
    di
    xor a
    ld [hVBlank_Bank], a
    ld [hVBlank_Requests], a
    ld [rIF], a
    ld [rIE], a

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
    Set8 rIE, IEF_VBLANK
    ei
    ret


SECTION "Interrupt_VBlank", ROM0[$0040]
Interrupt_VBlank::
    jp VBlank_Interrupt

SECTION "Interrupt_HBlank", ROM0[$0048]
Interrupt_HBlank::
    Crash
    reti

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

        halt
        nop
        .Wait:
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