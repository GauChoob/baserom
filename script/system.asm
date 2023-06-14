SECTION "SCRIPT_SYSTEM", ROMX

SCRIPT_None::
    End

SCRIPT_Test1::
    JumpTable Evaluation_RandBool, SCRIPT_Pal1, SCRIPT_Text
    End


SCRIPT_Pal1::
    End

SCRIPT_Text::
    Palette TestSprite, 0, PALETTE_UNPACK_SHADOW_MASK | PALETTE_UNPACK_TARGET_MASK
    Palette TestSprite, 64, PALETTE_UNPACK_SHADOW_MASK | PALETTE_UNPACK_TARGET_MASK
    Write "ell Hello!"
    End