SECTION "WRAM JOYPAD", WRAM0
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