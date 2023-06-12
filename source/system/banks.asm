SECTION "WRAM Banks", WRAM0

wBanks_rSVBK::
    ds 1
wBanks_ROMB0::
    ds 1

SECTION "Banks", ROMX
Banks_Init::
    SwitchROMBank 1
    SwitchRAMBank 0
    ret

MACRO SwitchRAMBank
    ; \1 = bank
    ld a, \1
    ld [wBanks_rSVBK], a
    ld [rSVBK], a
ENDM

MACRO SwitchROMBank
    ; \1 = bank
    ld a, \1
    ld [wBanks_ROMB0], a
    ld [rROMB0], a
ENDM

MACRO PushRAMBank
    ; Pushes RAM bank onto stack
    ld a, [wBanks_rSVBK]
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
    ld [wBanks_rSVBK], a
    ld [rSVBK], a
ENDM

MACRO PopROMBank
    ; Pops ROM bank from stack and loads said RAM bank
    pop af
    ld [wBanks_ROMB0], a
    ld [rROMB0], a
ENDM
