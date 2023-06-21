SECTION "Main", ROM0

Boot::
    ; Verify if running on GBC
    cp a, BOOTUP_A_CGB
    jr z, Reset
    .DMG:
        Crash

Reset::
    Stack_Init
    call System_Init
    XCall Text_Init
    XCall Textbox_Init
    XCall Tilemap_Render_Init
    XCall Script_Init
    jp Game_Init

Game_Init::
    ld hl, wScript_Main
    ld c, BANK(SCRIPT_Init)
    ld de, SCRIPT_Init
    XCall Script_Set

    jp Game_Loop

Game_Loop::
    ld hl, wScript_Main
    call Script_Do
    ; ld hl, wScript_Main
    ; call wScript_Secondary
    call VBlank_Await
    jr Game_Loop