MACRO Wait
    db Enum_Cmd_Wait
    dw \1
ENDM
Cmd_Wait::
    ; Wait X number of frames
    ; Arguments:
    ;   dw - Number of frames to wait
    dec bc
    Set16 hScript_Current.Address, bc
    inc bc

    Script_ReadWord de
    Get16 hl, hScript_Current.SmallCounter
    or h
    jr nz, .MainLoop
    .Init:
        ld h, d
        ld l, e
        ;jr .MainLoop
    .MainLoop:
        dec hl
        Set16 hScript_Current.SmallCounter, hl
        ld h, a
        or l
        ret nz
    .Finally:
        Set16 hScript_Current.Address, bc
        ret

MACRO End
    db Enum_Cmd_End
ENDM
Cmd_End::
    ret

MACRO Jump
    db Enum_Cmd_Jump
    BankAddress \1
ENDM
Cmd_Jump::
    ; Arguments:
    ;   BankAddress
    Script_ReadByte [hScript_Current.Bank]
    Script_ReadWord hl
    Set16 hScript_Current.Address, hl
    ld b, h
    ld c, l
    jp Script_Read


MACRO JumpTable
    db Enum_Cmd_JumpTable
    BankAddress \1
ENDM
Cmd_JumpTable::
    ; Arguments:
    ;   BankAddress - evaluation function returning a
    ;   N*Address - list of local addresses to jump to

    ; Evaluate with custom function
    Script_ReadByte e
    Script_ReadWord hl
    call Call_Foreign

    add a
    ld l, a
    ld h, $00
    add hl, bc

    Set16 hScript_Current.Address, hl
    ld b, h
    ld c, l
    jp Script_Read