SECTION "Text", ROM0

MACRO Write
    db Enum_Cmd_Write
    db \1          ; Text
    db Charmap_EOL
ENDM
Cmd_Write::
    ; Write the text
    ; Arguments:
    ;   ds - Text to write
    dec bc
    Set16 hScript_Current.Address, bc

    ld a, [hScript_Current.SmallCounter]
    inc a
    ld [hScript_Current.SmallCounter], a

    cp 1
    ld l, a
    jr nz, .MainLoop
    .Init:
        Text_Setup 1, $9600
    .MainLoop
        ld h, $00
        add hl, bc

        ld a, [hl]
        cp Charmap_EOL
        jr z, .EOL
        .Normal:
            call Text_PrepareCharacter
            ret
        .EOL:
            xor a
            ld [hScript_Current.SmallCounter], a
            inc hl
            Set16 hScript_Current.Address, hl
            ld b, h
            ld c, l
            jp Script_Read