INCLUDE "source/system/banks.asm"
INCLUDE "source/system/call.asm"

INCLUDE "source/system/dma.asm"
INCLUDE "source/system/interrupt.asm"
INCLUDE "source/system/joypad.asm"
INCLUDE "source/system/lcd.asm"
INCLUDE "source/system/math.asm"
INCLUDE "source/system/mem.asm"
INCLUDE "source/system/oam.asm"
INCLUDE "source/system/palette.asm"
INCLUDE "source/system/speed.asm"
INCLUDE "source/system/stack.asm"

SECTION "System", ROM0

System_Init::
    ; Run Stack_Init before calling any function including this one

    xor a
    ld [rRP], a     ; Disable infrared port
    ld [rRAMG], a   ; Disable RAM
    ld [rROMB1], a  ; High bit of Bank is always 0
    ld [rNR52], a   ; Sound off

    Call Banks_Init
    XCall Speed_Double

    XCall DMA_Init
    XCall OAM_Init
    XCall Interrupt_Init
    XCall Joypad_Init
    XCall LCD_Init
    XCall Math_Init
    XCall OAM_Init
    XCall Palette_Init
    ret