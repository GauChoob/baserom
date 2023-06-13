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