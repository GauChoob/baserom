SECTION "RST_00", ROM0[$0000]
    Crash

SECTION "RST_08", ROM0[$0008]
    Crash

SECTION "RST_10", ROM0[$0010]
    Crash

SECTION "RST_18", ROM0[$0018]
    Crash

SECTION "RST_20", ROM0[$0020]
    Crash

SECTION "RST_28", ROM0[$0028]
    Crash

SECTION "RST_30", ROM0[$0030]
    Crash

SECTION "RST_38", ROM0[$0038]
    Crash


SECTION "Interrupt_VBlank", ROM0[$0040]
Interrupt_VBlank::
    jp VBlank_Interrupt

SECTION "Interrupt_HBlank", ROM0[$0048]
Interrupt_HBlank::
    jp Timer_Interrupt

SECTION "Interrupt_Timer", ROM0[$0050]
Interrupt_Timer::
    Crash
    reti

SECTION "Interrupt_Serial", ROM0[$0058]
Interrupt_Serial::
    Crash
    reti

SECTION "Interrupt_Joypad", ROM0[$0060]
Interrupt_Joypad::
    Crash
    reti