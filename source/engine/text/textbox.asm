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

SECTION "Textbox", ROM0

Textbox_VBlank_LoadTilemap::
    ld d, BANK(STATICTILE_TestText)
    ld bc, STATICTILE_TestText
    ld hl, $9C00
    call Tilemap_Static_UnpackTileAttr
    Set8 hVBlank_VBK, 1
    Set8 hVBlank_Bank, BANK(Textbox_VBlank_ClearText)
    Set16 hVBlank_Func, Textbox_VBlank_ClearText
    ret


SECTION "TextboxX", ROMX

Textbox_VBlank_ClearText::
    ; 125 16*8
    ld hl, $9100
    xor a
    REPT $100*4
        ld [hl+], a
    ENDR
    Set8 hVBlank_VBK, 1
    Set16 hVBlank_Dest, $9000
    Mov16 hVBlank_Source, wTextbox_PortraitAddress
    Mov8 hVBlank_Bank, wTextbox_PortraitBank
    Set16 hVBlank_Func, VBlank_Func_CopyTile
    Set8 hVBlank_TileCount, 16
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
    db 145
    .End:

Textbox_Data_Opening:
    ; WY position
    db 145
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
