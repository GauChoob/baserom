MACRO ImportPalette
SECTION "\1", ROMX
\1:
    db \1.End - \1.Start
    .Start
        INCBIN \2
    .End:
ENDM




    ImportPalette TestSprite, "autogenerated/assets/AllSprites.pal"
