MACRO Actor_Struct
.X:
    dw
.Y:
    db
.Z:
    db
.Bank:
    db
.Handler:
    dw
.OAMX:
    db
.OAMY:
    db
.OAMScript:
    dw

SECTION "WRAM Actor", WRAM0
wHero::
    Actor_Struct