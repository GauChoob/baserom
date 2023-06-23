SECTION "Actor", ROMX, BANK[ACTOR_BANK]

Actor_Init::
    ld b, HIGH(wActor_Hero)
    call Actor_Disable
    ld b, HIGH(wActor_1)
    call Actor_Disable
    ld b, HIGH(wActor_2)
    call Actor_Disable
    ld b, HIGH(wActor_3)
    call Actor_Disable
    ld b, HIGH(wActor_4)
    call Actor_Disable
    ret

Actor_Disable::
    ; Inputs:
    ;   b = Actor_Current
    ld c, ACTOR_Handler + 1
    xor a
    ld [bc], a
    ret

Actor_NewActor::
    ; Initialize actor variables
    ; Still need to manually define:
    ;   ACTOR_X, ACTOR_Y, ACTOR_Z
    ;   ACTOR_Handler
    ;   ACTOR_RenderTable
    ; Inputs:
    ;   b = Actor_Current
    ;   e = Actor slot (0 = Hero, 1-4)
    ; Destroys: abcde
    ld c, ACTOR_Z
    Set8 bc, 0
    ld c, ACTOR_Speed
    Set8 bc, 1
    ld c, ACTOR_FacesRight
    xor a
    ld [bc], a
    ld c, ACTOR_Shielding
    ld [bc], a
    ld c, ACTOR_Handler
    ld [bc], a
    inc c
    ld [bc], a

    ld c, ACTOR_RenderAnimID
    dec a
    ld [bc], a

    ; ACTOR_RenderTileID -> 0 for Hero and Actor 1, then $20, $40, $60 for Actors 2, 3, 4
    ld a, e
    ld d, 0
    JumpSmaller 2, .ZeroId
    .NonZeroId:
        ; (d - 1)*$20
        dec e
        xor a
        .Loop:
            add $20
            dec e
            jr nz, .Loop
        ld d, a
    .ZeroId: ; 0
    ld a, d
    ld c, ACTOR_RenderTileID
    ld [bc], a

    Actor_SetAnim ANIM_IDLE

    ret

Actor_Select_Table:
    db HIGH(wActor_Hero)
    db HIGH(wActor_1)
    db HIGH(wActor_2)
    db HIGH(wActor_3)
    db HIGH(wActor_4)

Actor_Select::
    ; Inputs:
    ;   e = Actor slot (0 = Hero, 1-4)
    ; Output:
    ;   b = Actor_Current
    ; Destroys: all
    ld hl, Actor_Select_Table
    ld d, $00
    add hl, de
    ld b, [hl]
    ret


Actor_MoveLeft::
    ; Inputs:
    ;   b = Actor_Current
    ; Destroys all except b

    ; de = -speed
    ld c, ACTOR_Speed
    ld a, [bc]
    NegativeA
    ld e, a
    ld d, $FF

    ; hl = X
    ld c, ACTOR_X
    Get8 l, bc
    inc c
    Get8 h, bc

    ; hl = X - speed
    add hl, de

    ; Store new value
    Set8 bc, h
    dec bc
    Set8 bc, l
    
    ret


Actor_MoveRight::
    ; Inputs:
    ;   b = Actor_Current
    ; Destroys all except b

    ; de = speed
    ld c, ACTOR_Speed
    Get8 e, bc
    ld d, 0

    ; hl = X
    ld c, ACTOR_X
    Get8 l, bc
    inc c
    Get8 h, bc

    ; hl = X - speed
    add hl, de

    ; Store new value
    Set8 bc, h
    dec bc
    Set8 bc, l
    
    ret


Actor_MoveDown::
    ; Inputs:
    ;   b = Actor_Current
    ; Destroys cl

    ; l = speed
    ld c, ACTOR_Speed
    Get8 l, bc

    ; a = Y
    ld c, ACTOR_Y
    ld a, [bc]

    ; speed + Y
    add l

    ; Store the new value
    ld [bc], a

    ret


Actor_MoveUp::
    ; Inputs:
    ;   b = Actor_Current
    ; Destroys cl

    ; l = speed
    ld c, ACTOR_Speed
    Get8 l, bc

    ; a = Y
    ld c, ACTOR_Y
    ld a, [bc]

    ; speed + Y
    sub l

    ; Store the new value
    ld [bc], a

    ret