SECTION "Setup", ROM0

Boot::
    call Setup
    rst 0

Loop::
    jr Loop


Setup::
    XCall Banks_Init
    XCall DMA_Init
    XCall OAM_Init