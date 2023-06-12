SECTION "Math", ROM0

Math_Div8::
    ; a/b
    ; Outputs:
    ;   c = Quotient
    ;   a = Remainder
    ld c, 0
    .Loop:
        sub b
        jr c, .Done
        inc c
        jr .Loop
    .Done:
    add b
    ret

Math_Div16::
    ; hl/bc
    ; Outputs:
    ;   de = Quotient
    ;   hl = Remainder
    push bc
    TwosComp bc
    ld de, 0
    .Loop:
        add hl, bc
        jr c, .Done
        inc de
    .Done:
    pop bc
    add hl, bc
    ret

Math_Mult::
    ; e*c
    ; Outputs:
    ;   hl
    ld hl, $0000
    ld d, $00
    FOR current_bit, 0, 8
        IF current_bit != 0
            sla e
            rl d
        ENDC
        bit current_bit, c
        IF current_bit != 7
            jr z, .Skip\@
                add hl, de
            .Skip\@:
        ELSE
            ret z
            add hl, de
            ret
        ENDC
    ENDR

Math_Random::
    ; TODO
    ld a, [rDIV]
    ret