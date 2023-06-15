MACRO Script_ReadByte
    ld a, [bc]
    inc bc
    IF STRCMP("\1", "a") != 0
        ld \1, a
    ENDC
ENDM

MACRO Script_ReadWord
    ; Reads 2 byte from the reading frame and increments
    ; Stores the byte into the target 16-bit register
    Script_ReadByte LOW(\1)
    Script_ReadByte HIGH(\1)
ENDM

MACRO Script_MovWord
    ; Stores a word into a variable
    Script_ReadByte [\1]
    Script_ReadByte [\1 + 1]
ENDM

MACRO Script_AwaitAvailableVBlankFunc
    ; If VBlank already has a planned graphics function, Wait 1 frame and try again next frame
    ; Destroys hl
    Get16 hl, hVBlank_Func
    or h
    jr z, .Available\@
    .NotAvailable\@:
        dec bc
        Set16 hScript_Current.Address, bc
        ret
    .Available\@:
ENDM