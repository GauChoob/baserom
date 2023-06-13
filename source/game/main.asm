SECTION "Setup", ROM0

Boot::
    ; Verify if running on GBC
    cp a, BOOTUP_A_CGB
    jr z, Reset
    .DMG:
        Crash

Reset::
    Stack_Init
    call Setup
    XCall Interrupt_SetVBlank
    jp GameLoop


Setup::
    Call Banks_Init
    XCall Speed_Double
    XCall DMA_Init
    XCall OAM_Init
    XCall Joypad_Init
    XCall Interrupt_Init
    XCall Script_Init
    ret

GameLoop::
    ld hl, wScript_Main
    call Script_Do
    ; ld hl, wScript_Main
    ; call wScript_Secondary
    call VBlank_Await
    jr GameLoop