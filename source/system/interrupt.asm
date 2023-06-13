MACRO Interrupt_Disable
    xor a
    ld [rIF], a
    ld [rIE], a
ENDM


SECTION "HRAM VBLANK", HRAM

DEF VBLANK_PALETTE_UPDATE_MASK EQU %00000001
DEF VBLANK_PALETTE_UPDATE_KEY EQU 0
DEF VBLANK_AWAIT_MASK EQU %10000000
DEF VBLANK_AWAIT_KEY EQU 7
hVBlank_Requests::
    ds 1

SECTION "InterruptX", ROMX
Interrupt_Init::
    di
    xor a
    ld [hVBlank_Requests], a
    ld [rIF], a
    ld [rIE], a
    ret

Interrupt_SetTimer::
    ; Activate the timer at the rate of 59.8 interrupts per second
    ; This approximately is the same as the refresh rate, reducing the sound glitches when the screen is temporarily disabled, as
    ; the real VBlank is disabled while the screen is off
    Set8 rTMA, $89
    Set8 rTAC, $04

    xor a
    ld [rIF], a
    Set8 rIE, IEF_TIMER
    ei
    ret

Interrupt_SetVBlank::
    xor a
    ld [rIF], a
    Set8 rIE, IEF_VBLANK
    ei
    ret

SECTION "Interrupt", ROM0

VBlank_Await::
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

VBlank_Interrupt::
    SaveRegisters
    PushRAMBank
    PushROMBank
    
    ld a, [hVBlank_Requests]
    bit VBLANK_PALETTE_UPDATE_KEY, a
    call nz, Palette_VBlank_Both

    XCall Joypad_Update

    xor a
    ld [hVBlank_Requests], a

    ei
    PopROMBank
    PopRAMBank
    RestoreRegisters
    reti

Timer_Interrupt::
    ; TODO sound
    reti