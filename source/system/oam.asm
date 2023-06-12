SECTION "WRAM OAM", WRAM0, ALIGN[8]
wOAM_Shadow::
    ds 40*4
    .End

wOAM_Cursor::
    ; Next available spot in OAM
    ds 1

wOAM_PreviousCursor:
    ; Previous spot in OAM
    ds 1

SECTION "OAM", ROM0
OAM_Init::
    call OAM_ResetShadow
    ret

OAM_ResetShadow::
    Set8 wOAM_Cursor, LOW(wOAM_Shadow)
    Set8 wOAM_PreviousCursor, LOW(wOAM_Shadow)

    ld hl, wOAM_Shadow
    ld de, 4
    ld b, wOAM_Shadow.End - wOAM_Shadow
    ld a, $FF
    .Loop:
        ld [hl], a
        add hl, de
        dec b
        jr nz, .Loop
    ret

OAM_PrepareNewFrame::
    Crash
    ; Frame_Ready

OAM_DrawEntity::
    Crash
    ; Todo