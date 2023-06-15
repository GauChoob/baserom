SECTION "Text", ROM0


MACRO TextboxClose
    db Enum_Cmd_TextboxClose
    Wait (Textbox_Data_Closing.End - Textbox_Data_Closing)
ENDM
Cmd_TextboxClose::
    ; Close the textbox
    ; Arguments:
    ;   None
    Textbox_Close
    jp Script_Read


MACRO TextboxOpen
    db Enum_Cmd_TextboxOpen
    Wait (Textbox_Data_Opening.End - Textbox_Data_Opening)
ENDM
Cmd_TextboxOpen::
    ; Open the textbox
    ; Arguments:
    ;   None
    Textbox_Open
    jp Script_Read


MACRO Write
    db Enum_Cmd_Write
    db \1          ; Text
    db "🛑"
ENDM
Cmd_Write::
    ; Write the text
    ; Arguments:
    ;   ds - Text to write
    Script_ReserveGraphics

    dec bc
    Set16 hScript_Current.Address, bc

    ld a, [hScript_Current.SmallCounter]
    inc a
    ld [hScript_Current.SmallCounter], a

    cp 1
    ld l, a
    jr nz, .MainLoop
    .Init:
        push hl
        push bc
        Text_Setup 1, $9300
        pop bc
        pop hl
    .MainLoop
        ld h, $00
        add hl, bc

        ld a, [hl]
        cp "🛑"
        jr z, .EOF
        cp "⭍"
        jr z, .Newline
        cp "🅐"
        jr z, .Wait
        .Normal:
            call Text_PrepareCharacter
            ret
        .EOF:
            xor a
            ld [hScript_Current.SmallCounter], a
            inc hl
            Set16 hScript_Current.Address, hl
            ld b, h
            ld c, l
            jp Script_Read
        .Newline:
            Crash
        .Wait:
            ld a, [wJoypad_Held]
            and Joypad_MASK_A
            jr nz, .Continue
            .Awaiting:
                ld a, [hScript_Current.SmallCounter]
                dec a
                ld [hScript_Current.SmallCounter], a
                ret
            .Continue:
                jp Script_Read