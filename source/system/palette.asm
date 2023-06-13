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
    .End

wPalette_Target::
    ; Used to fade
    .Background:
        ds 8*4*2
    .Sprite:
        ds 8*4*2
    .End

SECTION "PALETTE Interrupt", ROMX

Palette_Init::
    ;   b = byte
    ;   hl = destination
    ;   de = size
    ld b, $24
    ld hl, wPalette_Shadow
    ld de, wPalette_Shadow.End - wPalette_Shadow
    call Mem_Set

    ld b, $24
    ld hl, wPalette_Target
    ld de, wPalette_Target.End - wPalette_Target
    call Mem_Set

    ret

Palette_VBlank_Background::
    ld hl, wPalette_Shadow.Background
    Set8 rBCPS, %10000000
    ld c, LOW(rBCPD)
    REPT 64
        ld a, [hl+]
        ld [$FF00+c], a
    ENDR
    Set16 hVBlank_Func, VBlank_FuncNull
    ret

Palette_VBlank_Sprite::
    ld hl, wPalette_Shadow.Sprite
    Set8 rOCPS, %10000000
    ld c, LOW(rOCPD)
    REPT 64
        ld a, [hl+]
        ld [$FF00+c], a
    ENDR
    Set16 hVBlank_Func, VBlank_FuncNull
    ret

Palette_VBlank_Both::
    call Palette_VBlank_Background
    call Palette_VBlank_Sprite
    ret

SECTION "PALETTE", ROM0

Palette_UnpackToDestination:
    ; Inputs:
    ;   bc = PaletteObject
    ;   hl = wPalette_Shadow or wPalette_Target
    ;   e = Offset
    ; Destroys:
    ;   All

    ; Destination
    ld d, $00
    add hl, de
    
    ; Size
    ld a, [bc]
    ld e, a
    ld d, 0

    ; Source
    inc bc

    call Mem_Copy
    ret

DEF PALETTE_UNPACK_SHADOW_MASK EQU %00000001
DEF PALETTE_UNPACK_SHADOW_KEY EQU 0
DEF PALETTE_UNPACK_TARGET_MASK EQU %00000010
DEF PALETTE_UNPACK_TARGET_KEY EQU 1
Palette_Unpack::
    ; Inputs:
    ;   h = PaletteObject Bank
    ;   bc = PaletteObject Address
    ;   e = Offset
    ;   d = Targets
    ; Destroys:
    ;   All
    PushROMBank
    SwitchROMBank h

    push de
    push bc

    bit PALETTE_UNPACK_SHADOW_KEY, d
    jr z, .SkipShadow
    .CopyShadow:
        ld hl, wPalette_Shadow
        call Palette_UnpackToDestination

        ld a, [hVBlank_Requests]
        or VBLANK_FUNC_MASK
        ld [hVBlank_Requests], a
        Set8 hVBlank_Bank, BANK(Palette_VBlank_Both)
        Set16 hVBlank_Func, Palette_VBlank_Both
    .SkipShadow:

    pop bc
    pop de

    bit PALETTE_UNPACK_SHADOW_KEY, d
    jr z, .SkipTarget
    .CopyTarget:
        ld hl, wPalette_Target
        call Palette_UnpackToDestination
    .SkipTarget:

    PopROMBank
    ret