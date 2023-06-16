SECTION "MEM", ROM0

Mem_Copy::
    ; Inputs:
    ;   bc = source
    ;   hl = destination
    ;   de = size
    .Loop:
        LdHLIBCI
        Dec16Loop de, .Loop
    ret


Mem_Set::
    ; Inputs:
    ;   b = byte
    ;   hl = destination
    ;   de = size
    .Loop:
        ld a, b
        ld [hl+], a
        Dec16Loop de, .Loop
    ret