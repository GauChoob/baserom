SECTION "Actor Handler", ROMX, BANK[ACTOR_BANK]

Actor_Do::
    ; Loop through the Hero and the 4 Actors, and run their handlers
    ld e, 0
    ld d, 5
    .Loop
        push de
        call Actor_Select
        ld c, ACTOR_Handler + 1
        ld a, [bc]
        or a
        jr z, .Skip
            ld h, a
            dec c
            Get8 l, bc
            call CallHL
        .Skip:
        pop de
        inc e
        dec d
        jr nz, .Loop

    ret