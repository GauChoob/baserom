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