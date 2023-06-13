SECTION "WRAM Math", WRAM0
wMath_RandSeed:
    ds 1

SECTION "MathX", ROMX
Math_Init::
    xor a
    ld [wMath_RandSeed], a
    ret

SECTION "Math", ROM0

Math_Div8::
    ; a/b
    ; Outputs:
    ;   c = Quotient
    ;   a = Remainder
    ; Destroys:
    ;   abc
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
    ; Destroys:
    ;   All
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
    ; Destroys:
    ;   cdehl
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
    ; Quick dirty random function that could be improved eventually
    ; Outputs:
    ;   c
    ; Destroys:
    ;   cdehl
    ld a, [rDIV]
    swap a
    ld l, a

    ld a, [wMath_RandSeed]
    xor l

    ld l, a
    ld h, HIGH(Math_Random_Table)

    PushROMBank
    SwitchROMBank BANK(Math_Random_Table)
    ld a, [hl]
    ld c, a
    ld [wMath_RandSeed], a
    PopROMBank
    ret

SECTION "Rand", ROMX, ALIGN[8]

Math_Random_Table::
    db $59, $B6, $A7, $70, $63, $EB, $60, $3D, $95, $B4, $16, $74, $D9, $F5, $3C, $49
    db $04, $FC, $8C, $C6, $A3, $FF, $09, $C7, $17, $E8, $64, $9D, $42, $89, $D8, $56
    db $AA, $D2, $32, $46, $92, $9A, $CF, $EA, $2F, $DA, $86, $E1, $79, $37, $E3, $40
    db $5D, $F1, $19, $DF, $72, $D0, $BB, $C9, $48, $C2, $97, $7B, $8A, $F3, $96, $68
    db $E5, $8B, $A8, $83, $3E, $1F, $9F, $C5, $24, $8F, $DD, $91, $38, $11, $4B, $85
    db $33, $B9, $7D, $9C, $F4, $AC, $BC, $2E, $39, $0F, $EC, $E2, $47, $82, $BD, $A2
    db $14, $90, $77, $07, $C8, $25, $28, $50, $05, $69, $CE, $94, $58, $67, $99, $6C
    db $4E, $52, $0D, $51, $87, $ED, $5B, $DC, $CA, $81, $F0, $AB, $F9, $1A, $D6, $65
    db $71, $41, $F8, $7C, $D7, $B5, $B1, $2C, $62, $5C, $26, $AE, $4F, $06, $8D, $B2
    db $A4, $36, $1E, $31, $B8, $CD, $00, $80, $BA, $8E, $23, $3B, $7F, $FA, $CB, $D5
    db $76, $4A, $43, $D4, $12, $34, $A9, $5A, $57, $54, $B7, $A0, $5E, $20, $3F, $F7
    db $88, $53, $6A, $21, $22, $C0, $0E, $FE, $BF, $1D, $B0, $66, $98, $27, $E9, $DB
    db $03, $E6, $73, $44, $EE, $29, $C4, $55, $DE, $15, $6B, $7E, $02, $4C, $3A, $13
    db $E4, $FB, $18, $10, $2D, $E7, $45, $1B, $AD, $93, $C1, $9E, $0C, $D1, $BE, $6D
    db $5F, $0A, $75, $A1, $4D, $EF, $C3, $6F, $AF, $2A, $A6, $E0, $F6, $2B, $CC, $D3
    db $61, $6E, $9B, $1C, $30, $0B, $35, $78, $7A, $B3, $08, $F2, $84, $A5, $FD, $01