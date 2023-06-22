Ram_Set8:
    ; Inputs:
    ;   de = address
    ; Arguments:
    ;   Value
    LdDEIBCI
    ret

Ram_Set16:
    ; Inputs:
    ;   de = address
    ; Arguments:
    ;   Value
    LdDEIBCI
    LdDEIBCI
    ret

Ram_Add16:
    ; Inputs:
    ;   de = address
    ; Arguments:
    ;   Value
    Script_ReadWord hl
    push bc
    Get8 c, de
    inc de
    Get8 b, de

    add hl, bc

    Set8 de, h
    dec de
    Set8 de, l

    pop bc
    ret

Ram_Add8:
    ; Inputs:
    ;   de = address
    ; Arguments:
    ;   Value
    Script_ReadByte l
    ld a, [de]
    add l
    ld [de], a
    ret

Ram_Parse:
    ; Inputs:
    ;   hl = function
    ; Arguments:
    ;   AddressBank
    Script_ReadWord de
    cp $FF
    jr z, .HighRam
    JumpBiggerEq $D0, .WRAMX
    JumpBiggerEq $C0, .WRAM0
    JumpBiggerEq $A0, .SRAM
    Crash

    .HighRam:
    .WRAM0:
        ; No need to switch banks
        inc bc
        call CallHL
        ret
    .WRAMX:
        Script_ReadByte a
        SwitchRAMBank a
        call CallHL
        ret
    .SRAM:
        Script_ReadByte a
        SwitchSRAMBank a
        SRAM_On
        call CallHL
        SRAM_Off
        ret

MACRO RamSet8
    db Enum_Cmd_RamSet8
    dw \1
    db BANK(\1)
    db \2
ENDM
Cmd_RamSet8::
    ; Arguments:
    ;   AddressBank
    ;   Value
    ld hl, Ram_Set8
    call Ram_Parse
    jp Script_Read


MACRO RamSet16
    db Enum_Cmd_RamSet16
    dw \1
    db BANK(\1)
    dw \2
ENDM
Cmd_RamSet16::
    ; Arguments:
    ;   AddressBank
    ;   Value
    ld hl, Ram_Set16
    call Ram_Parse
    jp Script_Read


MACRO RamAdd8
    db Enum_Cmd_RamAdd8
    dw \1
    db BANK(\1)
    db \2
ENDM
Cmd_RamAdd8::
    ; Arguments:
    ;   AddressBank
    ;   Value
    ld hl, Ram_Add8
    call Ram_Parse
    jp Script_Read


MACRO RamAdd16
    db Enum_Cmd_RamAdd16
    dw \1
    db BANK(\1)
    dw \2
ENDM
Cmd_RamAdd16::
    ; Arguments:
    ;   Address
    ;   Bank
    ;   Value
    ld hl, Ram_Add16
    call Ram_Parse
    jp Script_Read