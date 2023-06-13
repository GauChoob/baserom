SECTION "SPEED", ROMX

Speed_Double::
    ; Don't switch if we are already in Double
    ld a, [rKEY1]
    bit 7, a
    ret nz

    jr Speed_Switch

Speed_Single::
    ; Don't switch if we are already in Single
    ld a, [rKEY1]
    bit 7, a
    ret z

    jr Speed_Switch

Speed_Switch:
    xor a
    ld [rIE], a
    Set8 rP1, P1F_GET_NONE
    Set8 rKEY1, KEY1F_PREPARE
    stop
    ret
