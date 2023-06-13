MACRO Stack_Init
    ld sp, wStack.End
ENDM

SECTION "WRAM Stack", WRAM0

wStack:
    ds $100
    .End