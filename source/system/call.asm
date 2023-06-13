SECTION "Call", ROM0

CallHL::
    jp hl


MACRO CallForeign
    ; From ROM0, switches the ROM bank, calls a function in a ROMX,
    ;   and then restores the ROM bank
    ; When used from a ROMX targetting a different ROMX, it also works as intended
    ; When used from a ROMX targetting a function in bank 0, you should not use
    ;   the macro a manually specify e and hl. This allows you to use a function in
    ;   ROM0 targetting a different ROMX bank (e.g. to copy assets)
    ; When used from ROM0, using CallForeign restores the ROMX bank back to previous
    ;   If you don't need to restore the ROMX bank, XCall suffices instead
    ; 1 = Target function
    ld hl, \1
    ld e, BANK(\1)
    call Call_Foreign
ENDM
Call_Foreign::
    ; Used with Macro Call_Foreign
    ; Switches to Bank e temporarily, then calls hl
    ; After that, restores initial bank
    ; Inputs:
    ;   e = Desired bank
    ;   hl = Desired function to call
    PushROMBank
    SwitchROMBank e
    call CallHL
    PopROMBank
    ret


MACRO XCall
    ; Calls a function in a different bank
    ; \1 = Target
    SwitchROMBank BANK(\1)
    call \1
ENDM


MACRO XJump
    ; Jumps to a function in a different bank
    ; \1 = Target
    SwitchROMBank BANK(\1)
    jp \1
ENDM