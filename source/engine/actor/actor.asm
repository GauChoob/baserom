SECTION "Actor", ROMX, BANK[ACTOR_BANK]

Actor_Init::
    ld b, HIGH(wActor_Hero)
    ld c, ACTOR_Handler + 1
    xor a
    ld [bc], a

    ld b, HIGH(wActor_1)
    ld [bc], a
    ld b, HIGH(wActor_2)
    ld [bc], a
    ld b, HIGH(wActor_3)
    ld [bc], a
    ld b, HIGH(wActor_4)
    ld [bc], a
    ret


Actor_MoveLeft::
    ; Inputs:
    ;   b = wActor_Current
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
    ;   b = wActor_Current
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
    ;   b = wActor_Current
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
    ;   b = wActor_Current
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