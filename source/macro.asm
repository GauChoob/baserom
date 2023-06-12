MACRO Crash
    db $D3 ; Invalid opcode
ENDM


MACRO NegativeA
    cpl
    inc a
ENDM

MACRO TwosComp
    ; r16 <- (-r16)
    ; Gets the negative value of a 16-bit register
    ; \1 = Target r16
    ld a, LOW(\1)
    cpl
    ld LOW(\1), a
    ld a, HIGH(\1)
    cpl
    ld HIGH(\1), a
    inc \1
ENDM

MACRO Dec16Loop
    ; Decrease a 16-bit register, and jumps to label if non-zero
    ; \1 = Target r16
    ; \2 = jump label
    dec \1
    ld a, LOW(\1)
    or HIGH(\1)
    jr nz, \2
ENDM

MACRO DecHL16
    ; Decreases the (16-bit) value of [hl]
    ; de is modified
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    dec de
    ld a, d
    ld [hl-], a
    ld [hl], e
ENDM

MACRO IncHL16
    ; Increases the (16-bit) value of [hl]
    ; de is modified
    ; UNUSED
    ld a, [hl+]
    ld d, [hl]

    ld e, a
    inc de
    ld a, d

    ld [hl-], a
    ld [hl], e
ENDM


MACRO Get8
    ; Retrieves an 8-bit value into a register from a source
    ; \1 = destination register
    ; \2 = source address
    ld a, [\2]
    ld \1, a
ENDM

MACRO Get16
    ; Retrieves an 16-bit value into a register from a source
    ; \1 = destination register
    ; \2 = source address
    ld a, [\2+1]
    ld HIGH(\1), a
    ld a, [\2]
    ld LOW(\1), a
ENDM

MACRO Mov8
    ; ld [dest], [source] (8-bit)
    ; \1 = destination
    ; \2 = source
    ld a, [\2]
    ld [\1], a
ENDM

MACRO Mov16
    ; ld [dest], [source] (16-bit)
    ; \1 = destination
    ; \2 = source
    Mov8 \1, \2
    Mov8 \1+1, \2+1
ENDM

MACRO Set8
    ; ld [dest], param
    ; \1 = destination
    ; \2 = 8-bit register or address
    ld a, \2
    ld [\1], a
ENDM

MACRO Set16
    ; Stores 16 bits to an address. Similar to Mov16
    ; \1 = destination
    ; \2 = 16-bit register or address
    ld a, HIGH(\2)
    ld [\1+1], a
    ld a, LOW(\2)
    ld [\1], a
ENDM

MACRO Sla16
    ; Shifts a 16-bit register left X times
    ; \1 = register
    ; \2 = number of rotations
    ld a, \2
    .Loop\@:
        sla LOW(\1)
        rl HIGH(\1)
        dec a
        jr nz, .Loop\@
ENDM

MACRO Srl16
    ; Shifts a 16-bit register right X times
    ; \1 = register
    ; \2 = number of rotations
    ld a, \2
    .Loop\@:
        srl HIGH(\1)
        rr LOW(\1)
        dec a
        jr nz, .Loop\@
ENDM

MACRO DerefHL
    ; Dereferences hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
ENDM

MACRO LdBCDHLD
    ; ld [bc-], [hl-]
    ld a, [hl-]
    ld [bc], a
    dec bc
ENDM

MACRO LdBCIHLI
    ; ld [bc+], [hl+]
    ld a, [hl+]
    ld [bc], a
    inc bc
ENDM

MACRO LdHLIBCI
    ; ld [hl+], [bc+]
    ld a, [bc]
    ld [hl+], a
    inc bc
ENDM

MACRO RestoreRegisters
    pop hl
    pop de
    pop bc
    pop af
ENDM

MACRO SaveRegisters
    push af
    push bc
    push de
    push hl
ENDM


