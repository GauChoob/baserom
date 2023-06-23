DEF ACTOR_BANK EQU 2 ; Todo - arbitrary number

RSRESET
DEF ANIM_IDLE RB 0
DEF ANIM_IDLE_LEFT RB 3
DEF ANIM_IDLE_RIGHT RB 3

DEF ANIM_WALK RB 0
DEF ANIM_WALK_LEFT RB 3
DEF ANIM_WALK_RIGHT RB 3

MACRO Actor_SetAnim
    ; Arguments:
    ;   \1 = e.g. ANIM_IDLE
    ; Inputs:
    ;   b = Actor_Current

    ; [.RenderScript] = [.RenderTable] + AnimID + 3*Rightfacing
    ; Destroys all

    ; Given an anim \1 e.g. ANIM_IDLE, set it to ANIM_IDLE_LEFT or ANIM_IDLE_RIGHT
    ld c, ACTOR_FacesRight
    ld a, [bc]
    add a, \1
    ld e, a

    ; Check to see if the anim has changed. If it is the same, do not update the anim
    ld c, ACTOR_RenderAnimID
    ld a, [bc]
    cp e
    jr z, .End\@
    ; or else save the id of the new anim
    ld a, e
    ld [bc], a

    ; Get the offset to the script
    ld d, 0
    ld c, ACTOR_RenderTable
    Get8 l, bc
    inc c
    Get8 h, bc
    add hl, de

    ; Store the new script location
    ld c, ACTOR_RenderScript
    Set8 bc, l
    inc c
    Set8 bc, h

    .End\@
ENDM

MACRO Actor_FaceRight
    ; Inputs:
    ;   b = Actor_Current
    ; Destroys ac
    ld c, ACTOR_FacesRight
    ld a, 3
    ld [bc], a
ENDM

MACRO Actor_FaceLeft
    ; Inputs:
    ;   b = Actor_Current
    ; Destroys ac
    ld c, ACTOR_FacesRight
    xor a
    ld [bc], a
ENDM

RSSET 0
DEF ACTOR_X RB 1
DEF ACTOR_Y RB 1
DEF ACTOR_Z RB 1
DEF ACTOR_Speed RB 1
DEF ACTOR_FacesRight RB 1
DEF ACTOR_Shielding RB 1
DEF ACTOR_Handler RB 2
DEF ACTOR_OAMX RB 1
DEF ACTOR_OAMY RB 1
DEF ACTOR_RenderAnimID RB 1
DEF ACTOR_RenderTable RB 2
DEF ACTOR_RenderScript RB 3
DEF ACTOR_RenderTileID RB 1

MACRO Actor_Struct
.X:
    dw
.Y:
    db
.Z:
    db
.Speed:
    db
.FacesRight:
    ; 0 = Left, 3 = Right
    db
.Shielding:
    db
.Handler:
    dw
.OAMX:
    db
.OAMY:
    db
.RenderAnimID:
    db
.RenderTable:
    dw
.RenderScript:
    ds 3
.RenderTileID:
    db
ENDM


SECTION "WRAM Actor Hero", WRAM0, ALIGN[8]
wActor_Hero::
    Actor_Struct

SECTION "WRAM Actor 1", WRAM0, ALIGN[8]
wActor_1::
    Actor_Struct

SECTION "WRAM Actor 2", WRAM0, ALIGN[8]
wActor_2::
    Actor_Struct

SECTION "WRAM Actor 3", WRAM0, ALIGN[8]
wActor_3::
    Actor_Struct

SECTION "WRAM Actor 4", WRAM0, ALIGN[8]
wActor_4::
    Actor_Struct