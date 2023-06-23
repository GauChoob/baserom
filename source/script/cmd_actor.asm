SECTION "CmdActor", ROM0

MACRO ActorEnable
    db Enum_Cmd_ActorEnable
    db \1
ENDM
Cmd_ActorEnable::
    ; Arguments:
    ;   db 0 = Hero, 1-4 -> Actor to enable
    ;   dw X
    ;   db Y
    ;   db Z
    ;   dw ACTOR_Handler
    ;   dw ACTOR_RenderTable
    Script_ReadByte e
    PushROMBank
    push bc
    SwitchROMBank ACTOR_BANK

    call Actor_Select
    call Actor_NewActor

    pop hl
    ld a, [hl+]
    ld c, ACTOR_X
    ld [bc], a
    inc c
    ld a, [hl+]
    ld [bc], a
    
    ld a, [hl+]
    ld c, ACTOR_Y
    ld [bc], a

    ld a, [hl+]
    ld c, ACTOR_Z
    ld [bc], a

    ld a, [hl+]
    ld c, ACTOR_Handler
    ld [bc], a
    inc c
    ld a, [hl+]
    ld [bc], a

    ld a, [hl+]
    ld c, ACTOR_RenderTable
    ld [bc], a
    inc c
    ld a, [hl+]
    ld [bc], a

    PopROMBank
    jp Script_Read


MACRO ActorDisable
    db Enum_Cmd_ActorDisable
    db \1
ENDM
Cmd_ActorDisable::
    ; Arguments:
    ;   db 0 = Hero, 1-4 -> Actor to disable
    Script_ReadByte e
    PushROMBank
    push bc
    SwitchROMBank ACTOR_BANK

    call Actor_Select
    call Actor_Disable

    pop bc
    PopROMBank
    jp Script_Read


MACRO ActorDisableAll
    db Enum_Cmd_ActorDisableAll
ENDM
Cmd_ActorDisableAll::
    ; Arguments:
    ;   db 0 = Hero, 1-4 -> Actor to disable
    PushROMBank
    push bc
    SwitchROMBank ACTOR_BANK

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

    pop bc
    PopROMBank
    jp Script_Read