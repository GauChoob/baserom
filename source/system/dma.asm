SECTION "DMA", ROMX
DMA_Init::
    ld c, LOW(hDMA_Transfer)
    ld b, (hDMA_Transfer.End - hDMA_Transfer)
    ld hl, DMA_HRAMCode
	.CopyLoop:
	    ld a, [hl+]
	    ld [$FF00+c], a
	    inc c
	    dec b
	    jr nz, .CopyLoop
    ret


DMA_HRAMCode::
LOAD "HRAM_RUNDMA", HRAM
hDMA_Transfer::
    Set8 rDMA, HIGH(wOAM_Shadow)
    ld a, $28
    .WaitLoop:
        dec a
        jr nz, .WaitLoop
    ret
    .End:
ENDL