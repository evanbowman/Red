;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;; ASM Source code for Red GBC, by Evan Bowman, 2021
;;;
;;;
;;; The following licence covers the source code included in this file. The
;;; game's characters and artwork belong to Evan Bowman, and should not be used
;;; without permission.
;;;
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are met:
;;;
;;; 1. Redistributions of source code must retain the above copyright notice,
;;; this list of conditions and the following disclaimer.
;;;
;;; 2. Redistributions in binary form must reproduce the above copyright notice,
;;; this list of conditions and the following disclaimer in the documentation
;;; and/or other materials provided with the distribution.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;;; SUBSTITUTE GOODS OR SERVICES LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;; POSSIBILITY OF SUCH DAMAGE.
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


;;; ----------------------------------------------------------------------------

blizzard_str::
DB      "--blizzard--", 0


BlizzardSceneEnter:
        ld      de, BlizzardSceneUpdate
        fcall   SceneSetUpdateFn

        ld      de, BlizzardSceneVBlank
        fcall   SceneSetVBlankFn

        LONG_CALL r1_InitSnowflakes

        ld      a, 1
        ld      [var_blizzard_active], a

        ld      hl, blizzard_str
        fcall   OverlayPutText

        ret


;;; ----------------------------------------------------------------------------

BlizzardSceneUpdate:

.checkLevelup:
	ldh     a, [hvar_exp_levelup_ready_flag]
        or      a
        jr      Z, .checkExpChanged

        xor     a
        ldh     [hvar_exp_levelup_ready_flag], a
        ldh     [hvar_exp_changed_flag], a

        LONG_CALL r1_ExpDoLevelup
        fcall   OverlayRepaintRow2
	ret

.checkExpChanged:
        ldh     a, [hvar_exp_changed_flag]
        or      a
        jr      Z, .update

        xor     a
        ldh     [hvar_exp_changed_flag], a

	fcall   OverlayRepaintRow2
        ret

.update:

        fcall   UpdateEntities

        fcall   OverworldSceneAnimateWater
        fcall   OverworldSceneUpdateView

        fcall   DrawEntitiesSetup
        LONG_CALL r1_DrawSnowflakes
        ld      a, BLIZZARD_SNOWFLAKE_COUNT
        ld      [var_oam_top_counter], a
        fcall   DrawEntities

        ld      a, [var_blizzard_color_pulse_counter]
        inc     a
        ld      [var_blizzard_color_pulse_counter], a

        ld      c, a
        LONG_CALL r1_Sine

        sra     b
        sra     b
        sra     b
        sra     b

        ld      a, 32
        add     b

        ld      [var_blizzard_fade_amount], a

        fcall   OverworldSceneTryRoomTransition

        ret


;;; ----------------------------------------------------------------------------

BlizzardSceneVBlank:

        ld      a, [var_stamina_last_val]
        ld      b, a
        ld      a, [var_player_stamina]
        srl     b
        srl     a
        cp      b
        jr      Z, .skip
        fcall   ShowOverlay
        jr      .noFade
.skip:
        ld      a, [var_blizzard_last_fade_amount]
        ld      b, a
        ld      a, [var_blizzard_fade_amount]
        cp      b
        jr      Z, .noFade

        ;; We don't have enough space in vblank to copy over with animated tiles
        ;; and also flicker the screen palettes, pick one or the other,
        ;; depending on whether a palette update is actually required
        ld      [var_blizzard_last_fade_amount], a
        add     60
        ld      c, a
        fcall   FadeToWhite
        jr      .noWaterUpdate
.noFade:
	ld      a, [var_water_anim_changed]
        or      a
        fcallc  NZ, VBlankCopyWaterTextures

.noWaterUpdate:
        ld      a, [var_overlay_y_offset]
        ld      [rWY], a

        ld      a, [var_player_stamina]
        ld      [var_stamina_last_val], a

	fcall   VBlankCopySpriteTextures

        ret


;;; ----------------------------------------------------------------------------

BlizzardSceneExitVBlank:
        ld      a, [var_scene_counter]
	ld      c, a
        dec     a
        jr      Z, .transition
	jr      .continue

.transition:
        ld      de, OverworldSceneOnVBlank
        fcall   SceneSetVBlankFn

.continue:
        ld      [var_scene_counter], a
        fcall   FadeToWhite

	fcall   VBlankCopySpriteTextures
        ret


;;; ----------------------------------------------------------------------------

BlizzardSceneFadeInVBlank:
        ld      a, [var_scene_counter]
        ld      c, a
        add     2
        cp      60
        jr      Z, .transition
        jr      .continue

.transition:
        ld      de, BlizzardSceneEnter
        fcall   SceneSetUpdateFn

        ld      de, VoidVBlankFn
        fcall   SceneSetVBlankFn

.continue:
        ld      [var_scene_counter], a
        fcall   FadeToWhite

        fcall   VBlankCopySpriteTextures
        ret


;;; ----------------------------------------------------------------------------

BlizzardSceneFadeInUpdate:

        fcall   UpdateEntities

        fcall   OverworldSceneAnimateWater
        fcall   OverworldSceneUpdateView

        fcall   DrawEntitiesSimple

        ld      a, 1
        ld      [var_blizzard_active], a

        fcall   OverworldSceneTryRoomTransition
        ret


;;; ----------------------------------------------------------------------------
