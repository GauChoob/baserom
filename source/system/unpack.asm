SECTION "UNPACK", ROM0

Unpack_Palette_ToDestination:
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

DEF PALETTE_UNPACK_SHADOW_MASK EQU %00000001
DEF PALETTE_UNPACK_SHADOW_KEY EQU 0
DEF PALETTE_UNPACK_TARGET_MASK EQU %00000010
DEF PALETTE_UNPACK_TARGET_KEY EQU 1
Unpack_Palette::
    ; Inputs:
    ;   bc = PaletteObject
    ;   e = Offset
    ;   d = Targets
    ; Destroys:
    ;   All

    push de
    push bc

    bit PALETTE_UNPACK_SHADOW_KEY, d
    jr z, .SkipShadow
    .CopyShadow:
        ld hl, wPalette_Shadow
        call Unpack_Palette_ToDestination
    .SkipShadow:

    pop bc
    pop de

    bit PALETTE_UNPACK_SHADOW_KEY, d
    jr z, .SkipTarget
    .CopyTarget:
        ld hl, wPalette_Target
        call Unpack_Palette_ToDestination
    .SkipTarget:

    ld a, [hVBlank_Requests]
    or VBLANK_PALETTE_UPDATE_MASK
    ld [hVBlank_Requests], a
    ret