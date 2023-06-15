SECTION "SCRIPT_SYSTEM", ROMX

SCRIPT_None::
    End

SCRIPT_Test1::
    JumpTable Evaluation_RandBool, SCRIPT_Pal1, SCRIPT_Text
    End


SCRIPT_Pal1::
    End

SCRIPT_Text::
    Palette PAL_Menu, 56, PALETTE_UNPACK_SHADOW_MASK | PALETTE_UNPACK_TARGET_MASK
    Palette PAL_TestSprite, 64, PALETTE_UNPACK_SHADOW_MASK | PALETTE_UNPACK_TARGET_MASK
    StaticTilemap STATICTILE_TestText, $9800
    LCDOn
    Write "Well Hello! This is a sample text. !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFG" ;HIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz\{|}~ ¡¢£¤¥¦§¨©ª«¬®°±²³´µ¶¹º»¿×÷
    End

SCRIPT_LCD::
    Wait 3
    LCDOn
    Wait 3
    LCDOff
    Wait 3
    End
