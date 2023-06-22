MACRO SwitchRAMBank
    ; \1 = bank
    IF STRCMP("\1", "a") != 0
        ld a, \1
    ENDC
    ld [wBanks_SVBK], a
    ld [rSVBK], a
ENDM

MACRO SwitchROMBank
    ; \1 = bank
    IF STRCMP("\1", "a") != 0
        ld a, \1
    ENDC
    ld [wBanks_ROMB0], a
    ld [rROMB0], a
ENDM

MACRO PushRAMBank
    ; Pushes RAM bank onto stack
    ld a, [wBanks_SVBK]
    push af
ENDM

MACRO PushROMBank
    ; Pushes ROM bank onto stack
    ld a, [wBanks_ROMB0]
    push af
ENDM

MACRO PopRAMBank
    ; Pops RAM bank from stack and loads said RAM bank
    pop af
    ld [wBanks_SVBK], a
    ld [rSVBK], a
ENDM

MACRO PopROMBank
    ; Pops ROM bank from stack and loads said ROM bank
    pop af
    ld [wBanks_ROMB0], a
    ld [rROMB0], a
ENDM

MACRO SRAM_On
    ; Enables read/write to external ram
    ld a, $0A
    ld [rRAMG], a
ENDM

MACRO SRAM_Off
    ; Disables read/write to external ram
    xor a
    ld [rRAMG], a
ENDM

MACRO SwitchSRAMBank
    IF STRCMP("\1", "a") != 0
        ld a, \1
    ENDC
    ld [rRAMB], a
ENDM

SECTION "WRAM Banks", WRAM0

wBanks_SVBK::
    ds 1
wBanks_ROMB0::
    ds 1


SECTION "Banks", ROM0
Banks_Init::
    SwitchROMBank 1
    SwitchRAMBank 0
    ret