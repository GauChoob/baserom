SECTION "Evaluation", ROMX

; Evaluation functions used by Cmd_JumpTable
; You should preserve bc
; Returns a val in "d"

Evaluation_RandBool::
    ; Gets 0 or 1
    push bc
    call Math_Random
    ld a, c
    pop bc
    and %00000001
    ld d, a
    ret