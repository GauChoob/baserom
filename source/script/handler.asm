MACRO ScriptObject
    .Bank:
        ds 1
    .Address:
        ds 2
    .SmallCounter:
        ds 1
    .BigCounter:
        ds 1
    .End:
ENDM

SECTION "HRAM SCRIPT", HRAM
hScript_Current::
    ScriptObject

SECTION "WRAM SCRIPT", WRAM0
wScript_Main::
    ScriptObject

wScript_Secondary::
    ScriptObject

SECTION "HandlerX", ROMX

Script_Init::
    ld hl, wScript_Main
    ld c, BANK(SCRIPT_None)
    ld de, SCRIPT_None
    call Script_Set

    ld hl, wScript_Secondary
    ld c, BANK(SCRIPT_None)
    ld de, SCRIPT_None
    call Script_Set

    ret

Script_Set::
    ; Inputs:
    ;   hl = Script
    ;   c = bank
    ;   de = address
    ; Destroys:
    ;   chl
    Set8 hl+, c
    Set8 hl+, e
    Set8 hl+, d
    xor a
    ld [hl+], a
    ld [hl+], a
    ret

Script_Open::
    ; Inputs:
    ;   hl = Script
    ld bc, hScript_Current
    REPT hScript_Current.End - hScript_Current
        LdBCIHLI
    ENDR
    Get16 bc, hScript_Current.Address
    ret

Script_Close::
    ; Inputs:
    ;   hl = Script
    ld bc, hScript_Current
    REPT hScript_Current.End - hScript_Current
        LdHLIBCI
    ENDR
    ret


SECTION "Handler", ROM0[$3800] ; TODO remove this hardcoded - easier for debugging as the breakpoint doesn't move
Script_Do::
    ; Inputs:
    ;   hl = Script
    push hl
    XCall Script_Open

    call Script_Read

    pop hl
    XCall Script_Close

    ret

Script_Read::
    ; Switch to the target bank
    SwitchROMBank [hScript_Current.Bank]

    ; Get the next command
    Script_ReadByte a
    add a
    ld e, a
    ld d, $00
    ld hl, Script_Table
    add hl, de

    ; Jump to the command
    DerefHL
    jp hl