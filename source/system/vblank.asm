SECTION "HRAM VBLANK", HRAM
hVBlank_Await::
    ds 1

SECTION "VBLANK", ROM0

VBlank_Await::
    Set8 hVBlank_Await, 1
    halt
    nop
    .Wait:
        ld a, [hVBlank_Await]
        or a
        jr nz, .Wait
        ret

VBlank_Interrupt::
    SaveRegisters
    PushRAMBank
    PushROMBank
    
    ; TODO
    ;Get16 hl, wVBlank_HandlerFunc
    ;call CallHL

    XCall Joypad_Update

    xor a
    ld [hVBlank_Await], a

    ei
    PopROMBank
    PopRAMBank
    RestoreRegisters
    reti