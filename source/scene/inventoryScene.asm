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



;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;;  Inventory Scene
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


InventorySceneEnter:
        xor     a
        ld      [var_scene_counter], a

	ld      de, DrawonlyUpdateFn
        fcall   SceneSetUpdateFn

        ld      de, InventorySceneFadeinVBlank
        fcall   SceneSetVBlankFn

        ret


;;; ----------------------------------------------------------------------------

InventorySceneExit:
        ld      a, 255
        ld      [var_scene_counter], a

        fcall   VBlankIntrWait
        fcall   BlackScreenExcludeOverlay

        fcall   VBlankIntrWait
        ld      a, 136
        ld      [rWY], a
        ldh     [hvar_overlay_y_offset], a

        xor     a
        ld      [var_overlay_alternate_pos], a

        fcall   ShowOverlay

        fcall   OverlayRepaintRow2

        fcall   DrawEntitiesSimple

	ld      de, InventorySceneFadeOutVBlank
        fcall   SceneSetVBlankFn

        ld      de, DrawonlyUpdateFn
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

InventorySceneUpdate:
        ldh     a, [hvar_joypad_current]
        and     PADF_START | PADF_B
        jr      Z, .idle

        fcall   InventorySceneExit

        ret

.idle:
        LONG_CALL r8_InventoryUpdate

        ret


;;; ----------------------------------------------------------------------------

InventorySceneDiscardUpdate:
        LONG_CALL r8_InventorySceneDiscardUpdate
        ret


;;; ----------------------------------------------------------------------------

InventorySceneConsumeUpdate:
        LONG_CALL r8_InventorySceneConsumeUpdate
        ret


;;; ----------------------------------------------------------------------------

InventorySceneCraftOptionUpdate:
        LONG_CALL r8_InventorySceneCraftOptionUpdate
        ret


;;; ----------------------------------------------------------------------------

InventorySceneEquipUpdate:
        LONG_CALL r8_InventorySceneEquipUpdate
        ret


;;; ----------------------------------------------------------------------------

InventorySceneUseFirewoodUpdate:
        LONG_CALL r8_InventorySceneUseFirewoodUpdate
        ret


;;; ----------------------------------------------------------------------------

InventorySceneFadeinVBlank:

        ld      a, HIGH(var_oam_back_buffer)
        fcall   hOAMDMA

        SET_BANK 7

        ldh     a, [hvar_overlay_y_offset]
        ld      b, 136
        cp      b
        jr      C, .inc
        jr      .skip
.inc:
        inc     a
        ldh     [hvar_overlay_y_offset], a
.skip:

        ldh     a, [hvar_overlay_y_offset]
        ld      [rWY], a

        ld      a, [var_scene_counter]
	ld      c, a
        add     18
        jr      C, .transition
	jr      .continue

.transition:
        ld      de, VoidVBlankFn
        fcall   SceneSetVBlankFn

	ld      de, InventorySceneUpdate
        fcall   SceneSetUpdateFn

        ld      c, 255
        fcall   BlackScreenExcludeOverlay

        LONG_CALL r8_InventoryOpen
        ret

.continue:
        ld      [var_scene_counter], a
        fcall   FadeToBlackExcludeOverlay

        ret


;;; ----------------------------------------------------------------------------

InventorySceneFadeOutVBlank:

        ld      a, HIGH(var_oam_back_buffer)
        fcall   hOAMDMA

        SET_BANK 7

        ld      a, [var_scene_counter]
	ld      c, a
        sub     24
        jr      C, .transition
	jr      .continue

.transition:
        fcall   FadeNone

        ld      de, OverworldSceneUpdate
        fcall   SceneSetUpdateFn

        ld      de, OverworldSceneOnVBlank
        fcall   SceneSetVBlankFn

        ret

.continue:
        ld      [var_scene_counter], a

        fcall   FadeToBlackExcludeOverlay
        ret
