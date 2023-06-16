SECTION "CmdText", ROM0

MACRO TextboxPortrait
    db Enum_Cmd_TextboxPortrait
    BankAddress \1
ENDM
Cmd_TextboxPortrait::
    ; Initializes the textbox and loads a portrait
    ; Arguments:
    ;   BankAddress portrait

    ld a, [hScript_Current.SmallCounter]
    or a
    jr nz, .Waiting
    .Init:
        inc a
        ld [hScript_Current.SmallCounter], a

        dec bc
        Set16 hScript_Current.Address, bc
        inc bc

        Script_ReadByte [wTextbox_PortraitBank]
        Script_MovWord wTextbox_PortraitAddress

        Set8 wTextbox_VBlank_DoPortrait, 1
        Set8 hVBlank_VBK, 1
        Set8 hVBlank_Bank, BANK(Textbox_VBlank_LoadTilemap)
        Set16 hVBlank_Func, Textbox_VBlank_LoadTilemap
        ret
    .Waiting:
        ; We wait until VBlank Func is cleared
        Script_AwaitAvailableVBlankFunc

        ; Then we can continue to the next command
        xor a
        ld [hScript_Current.SmallCounter], a

        inc bc
        inc bc
        inc bc
        jp Script_Read


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

    Script_AwaitAvailableVBlankFunc

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
        Text_Setup 1, TEXTBOX_LINE1
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
            ld [hScript_Current.BigCounter], a
            inc hl
            Set16 hScript_Current.Address, hl
            ld b, h
            ld c, l
            jp Script_Read
        .Newline:
            ld a, [hScript_Current.BigCounter]
            or a
            jr nz, .SecondLine
            .FirstLine:
                ; Just go to line 2
                inc a
                ld [hScript_Current.BigCounter], a

                Text_Setup 1, TEXTBOX_LINE2
                ; Then immediately read the next character
                Get16 bc, hScript_Current.Address
                jp Script_Read

            .SecondLine:
                ; We need to erase the previous lines and go back to the top line
                xor a
                ld [hScript_Current.BigCounter], a
                ld [wTextbox_VBlank_DoPortrait], a ;We don't want to update the Portrait during VBlank

                Text_Setup 1, TEXTBOX_LINE1

                ; This will VBlank twice to clear the tileset
                ; There is also a third VBlank to redraw the portrait which we disable above
                ; Since this Cmd cannot run if there is a Vblank function, it will automatically wait
                Set8 hVBlank_VBK, 1
                Set8 hVBlank_Bank, BANK(Textbox_VBlank_ClearText1)
                Set16 hVBlank_Func, Textbox_VBlank_ClearText1
                ret
        .Wait:
            ; Wait until A is pressed
            ld a, [wJoypad_Held]
            and Joypad_MASK_A
            jr nz, .Continue
            .Awaiting:
                ; Don't increment
                ld a, [hScript_Current.SmallCounter]
                dec a
                ld [hScript_Current.SmallCounter], a
                ret
            .Continue:
                jp Script_Read