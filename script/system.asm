SECTION "SCRIPT_SYSTEM", ROMX

SCRIPT_Init::
    Palette PAL_Menu, 56, PALETTE_UNPACK_SHADOW_MASK | PALETTE_UNPACK_TARGET_MASK
    Palette PAL_TestSprite, 64, PALETTE_UNPACK_SHADOW_MASK | PALETTE_UNPACK_TARGET_MASK
    Jump SCRIPT_Scene


SCRIPT_None::
    End

SCRIPT_Test1::
    JumpTable Evaluation_RandBool, SCRIPT_Pal1, SCRIPT_Text
    End


SCRIPT_Pal1::
    End

SCRIPT_Text::
    ;StaticTilemap STATICTILE_TestText, $9800
    LCDOn
    TextboxPortrait PORTRAIT_Girl
    TextboxOpen
    Write "Well Hello! This is a⭍sample text.🅐⭍How do you do?⭍:)🅐"

    TextboxPortrait PORTRAIT_Guard
    Write "Rawwwr⭍Scary.🅐⭍The end🅐"
    TextboxClose
    End

SCRIPT_LCD::
    Wait 3
    LCDOn
    Wait 3
    LCDOff
    Wait 3
    End

SCRIPT_Tileset::
    Tileset TILESET_Girl, $9000, 1
    GameTilemap TILEMAP_TestText

    LCDOn
    TextboxPortrait PORTRAIT_Girl
    TextboxOpen
    Write "Well Hello! This is a⭍sample text.🅐⭍How do you do?⭍:)🅐"
    TextboxClose
    End

SCRIPT_Scene::
    Tileset TILESET_Numbers, $9000, 0
    GameTilemap TILEMAP_TestText

    CameraOn
    LCDOn

    End