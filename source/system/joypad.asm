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
    Crash
    ; todo