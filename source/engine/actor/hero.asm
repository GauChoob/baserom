SECTION "Hero", ROMX, BANK[ACTOR_BANK]

Actor_Hero_RenderTable::


Actor_Hero_Main::
    ; Inputs:
    ;   b = Actor_Current
    ; First, handle the idle case
    ld a, [wJoypad_Held]
    and %11110000
    jr nz, .NotIdle
    .Idle:
        Actor_SetAnim ANIM_IDLE
        ret
    .NotIdle:

    Get8 d, wJoypad_Held
    bit Joypad_BIT_RIGHT, d
    jr nz, .Right
    bit Joypad_BIT_LEFT, d
    jr z, .Pass1
    .Left:
        push de
        call Actor_MoveLeft
        Actor_FaceLeft
        pop de
        jr .Pass1
    .Right:
        push de
        call Actor_MoveRight
        Actor_FaceRight
        pop de
        ;jr .Pass1
    .Pass1:

    bit Joypad_BIT_DOWN, d
    jr nz, .Down
    bit Joypad_BIT_UP, d
    jr z, .Pass2
    .Up:
        call Actor_MoveUp
        jr .Pass2
    .Down:
        call Actor_MoveDown
        ;jr .Pass2
    .Pass2:

    Actor_SetAnim ANIM_WALK
    ret