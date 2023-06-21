MACRO ImportPalette
SECTION "\1", ROMX
\1:
    db \1.End - \1.Start ; size
    .Start
        INCBIN \2
    .End
ENDM

MACRO ImportTilemap
    dw \2                ; width
    db \3                ; height
    .Start\@
        INCBIN \4
    .End\@
    DEF tmp = (\1.End\@ - \1.Start\@)
    ASSERT tmp == (\2)*(\3),"Width \2 * Height \3!= Size {u:tmp}"
ENDM

MACRO ImportTileAttrmap
SECTION "\1", ROMX
\1:
    ImportTilemap \1, \2, \3, STRCAT(\4, ".tilemap")
    ImportTilemap \1, \2, \3, STRCAT(\4, ".attrmap")
ENDM


MACRO ImportTileset
SECTION "\1", ROMX
\1:
    dw \1.End - \1.Start ; size
    .Start
        INCBIN \2
    .End
ENDM


MACRO ImportPortrait
SECTION "\1", ROMX
\1:
    INCBIN \2
ENDM

    ImportPalette PAL_TestSprite, "autogenerated/assets/AllSprites.pal"
    ImportPalette PAL_Menu, "autogenerated/assets/Menu.pal"

    ImportTileAttrmap STATICTILE_TestText, 20, 4, "assets/text_test"
    ImportTileAttrmap TILEMAP_TestText, 100, 10, "assets/game_test"

    ImportTileset TILESET_Girl, "autogenerated/assets/portrait/Girl.tileset"
    ImportTileset TILESET_Guard, "autogenerated/assets/portrait/Guard.tileset"
    ImportTileset TILESET_Numbers, "autogenerated/assets/NumberTestTilesets.tileset"

    ImportPortrait PORTRAIT_Girl, "autogenerated/assets/portrait/Girl.tileset"
    ImportPortrait PORTRAIT_Guard, "autogenerated/assets/portrait/Guard.tileset"

