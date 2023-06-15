SECTION "WRAM JOYPAD", WRAM0
;Bit positions of the 8 buttons
DEF     Joypad_BIT_A         EQU 0
DEF     Joypad_BIT_B         EQU 1
DEF     Joypad_BIT_SELECT    EQU 2
DEF     Joypad_BIT_START     EQU 3
DEF     Joypad_BIT_RIGHT     EQU 4
DEF     Joypad_BIT_LEFT      EQU 5
DEF     Joypad_BIT_UP        EQU 6
DEF     Joypad_BIT_DOWN      EQU 7
;Masks of the 8 buttons
DEF     Joypad_MASK_A        EQU %00000001
DEF     Joypad_MASK_B        EQU %00000010
DEF     Joypad_MASK_SELECT   EQU %00000100
DEF     Joypad_MASK_START    EQU %00001000
DEF     Joypad_MASK_RIGHT    EQU %00010000
DEF     Joypad_MASK_LEFT     EQU %00100000
DEF     Joypad_MASK_UP       EQU %01000000
DEF     Joypad_MASK_DOWN     EQU %10000000
wJoypad_Held::
    ds 1
wJoypad_PressDown::
    ds 1
wJoypad_PressUp::
    ds 1

SECTION "JOYPAD", ROMX

Joypad_Init::
    xor a
    ld [wJoypad_Held], a
    ld [wJoypad_PressDown], a
    ld [wJoypad_PressUp], a
    ret

Joypad_Update::
    ; Update the pressed buttons
    Get8 d, wJoypad_Held

    Set8 rP1, P1F_GET_BTN
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    cpl
    and %00001111
    ld b, a

    Set8 rP1, P1F_GET_DPAD
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    cpl
    and %00001111
    swap a
    or b

    ld [wJoypad_Held], a

    ld b, a
    xor d
    ld c, a

    and b ; XOR and Held
    ld [wJoypad_PressDown], a

    ld a, b
    cpl
    and c  ; XOR and NotHeld
    ld [wJoypad_PressUp], a

    Set8 rP1, P1F_GET_NONE
    ret