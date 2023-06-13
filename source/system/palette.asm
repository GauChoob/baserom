MACRO RGBA
    ; RGBA hues to Color (2 bytes)
    ; \1 = R (0-1F)
    ; \2 = G (0-1F)
    ; \3 = B (0-1F)
    ; \4 = A (0-1) - unused
    ASSERT \1 >= 0,"Red less than 0"
    ASSERT \1 <= $1F,"Red more than $1F"
    ASSERT \2 >= 0,"Green less than 0"
    ASSERT \2 <= $1F,"Green more than $1F"
    ASSERT \3 >= 0,"Blue less than 0"
    ASSERT \3 <= $1F,"Blue more than $1F"
    ASSERT \4 >= 0,"Alpha less than 0"
    ASSERT \4 <= 1,"Alpha more than 1"
    dw (\1) + (\2)*%100000 + (\3)*%10000000000 + (\4)*%1000000000000000
ENDM


SECTION "WRAM PALETTE", WRAM0

wPalette_Shadow::
    .Background:
        ds 8*4*2
    .Sprite:
        ds 8*4*2

wPalette_Target::
    ; Used to fade
    .Background:
        ds 8*4*2
    .Sprite:
        ds 8*4*2

SECTION "PALETTEX", ROMX

Palette_VBlank_Background::
    ld hl, wPalette_Shadow.Background
    Set8 rBCPS, %10000000
    ld c, LOW(rBCPD)
    REPT 64
        ld a, [hl+]
        ld [$FF00+c], a
    ENDR
    ret

Palette_VBlank_Sprite::
    ld hl, wPalette_Shadow.Sprite
    Set8 rBCPS, %10000000
    ld c, LOW(rBCPD)
    REPT 64
        ld a, [hl+]
        ld [$FF00+c], a
    ENDR
    ret

Palette_VBlank_Both::
    call Palette_VBlank_Background
    call Palette_VBlank_Sprite
    ret