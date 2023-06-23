MACRO Textbox_Open
    Set16 wTextbox_SlideFrame, Textbox_Data_Opening
    Set16 wTextbox_SlideEnd, Textbox_Data_Opening.End
ENDM

MACRO Textbox_Close
    Set16 wTextbox_SlideFrame, Textbox_Data_Closing
    Set16 wTextbox_SlideEnd, Textbox_Data_Closing.End
ENDM


SECTION "WRAM Textbox", WRAM0

wTextbox_SlideFrame::
    dw
wTextbox_SlideEnd::
    db
wTextbox_PortraitBank::
    db
wTextbox_PortraitAddress::
    dw
wTextbox_VBlank_DoPortrait::
    db

SECTION "Textbox", ROM0

Textbox_VBlank_LoadTilemap::
    ; VBlank #1/4 - Takes up around 80% of VBlank!
    ld d, BANK(STATICTILE_Textbox)
    ld bc, STATICTILE_Textbox
    ld hl, TEXTBOX_TILEMAP
    call Tilemap_Static_UnpackTileAttr
    Set8 hVBlank_VBK, 1
    Set8 hVBlank_Bank, BANK(Textbox_VBlank_ClearText1)
    Set16 hVBlank_Func, Textbox_VBlank_ClearText1
    ret


SECTION "TextboxX", ROMX

_Textbox_VBlank_ClearText:
    xor a
    REPT $100*2
        ld [hl+], a
    ENDR
    ret


Textbox_VBlank_ClearText1::
    ; VBlank #3/4 - 40% of VBlank
    ; Clear TEXTBOX_LINE1
    ld hl, TEXTBOX_LINE1
    call _Textbox_VBlank_ClearText

    Set8 hVBlank_VBK, 1
    Set8 hVBlank_Bank, BANK(Textbox_VBlank_ClearText2)
    Set16 hVBlank_Func, Textbox_VBlank_ClearText2
    ret

Textbox_VBlank_ClearText2::
    ; VBlank #4/4 - 40% of VBlank
    ; Clear TEXTBOX_LINE2
    ld hl, TEXTBOX_LINE2
    call _Textbox_VBlank_ClearText

    ; VBlank #5 - Copy the portrait - about 70% of VBlank. Skip if disabled
    ld a, [wTextbox_VBlank_DoPortrait]
    or a
    jr z, .SkipPortrait
    .DoPortrait:
        Set8 hVBlank_VBK, 1
        Set16 hVBlank_Dest, TEXTBOX_PORTRAIT
        Mov16 hVBlank_Source, wTextbox_PortraitAddress
        Mov8 hVBlank_Bank, wTextbox_PortraitBank
        Set16 hVBlank_Func, VBlank_Func_CopyTile
        Set8 hVBlank_TileCount, 16
        ret
    .SkipPortrait:
        Set16 hVBlank_Func, $0000
        ret

Textbox_Init::
    Set16 wTextbox_SlideFrame, $0000
    ret

Textbox_Data_Closing:
    ; WY position
    ds 3, 112
    ds 3, 113
    ds 2, 114
    ds 2, 115
    db 116
    db 117
    db 119
    db 121
    db 124
    db 127
    db 131
    db 135
    db 140
    db 144
    .End:

Textbox_Data_Opening:
    ; WY position
    db 144
    db 140
    db 135
    db 131
    db 127
    db 124
    db 121
    db 119
    db 117
    db 116
    ds 2, 115
    ds 2, 114
    ds 3, 113
    ds 3, 112
    .End:

Textbox_VBlank_Slide::
    Get16 hl, wTextbox_SlideFrame

    ; Abort if no Frame
    or h
    ret z

    Mov8 rWY, hl+
    ld a, [wTextbox_SlideEnd]
    cp l
    jr nz, .Skip
    .End:
        ld hl, $0000
    .Skip:
    Set16 wTextbox_SlideFrame, hl
    ret
