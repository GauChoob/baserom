SECTION "Actor Handler", ROMX, BANK[ACTOR_BANK]

Actor_Do::
    ld b, HIGH(wActor_Hero)
    ld c, ACTOR_Handler + 1
    ld a, [bc]
    or a
    jr z, .Skip0
        ld h, a
        dec c
        Get8 l, bc
        call CallHL
    .Skip0:

    ret