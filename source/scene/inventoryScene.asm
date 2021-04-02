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
        ld      a, 0
        ld      [var_scene_counter], a

	ld      de, VoidVBlankFn
        call    SceneSetUpdateFn

        ld      de, InventorySceneFadeinVBlank
        call    SceneSetVBlankFn

        ret


;;; ----------------------------------------------------------------------------

InventorySceneUpdate:
        ldh     a, [hvar_joypad_current]
        and     PADF_START | PADF_B
        jr      Z, .idle

        ld      a, 255
        ld      [var_scene_counter], a

        call    VBlankIntrWait
        call    BlackScreenExcludeOverlay

        call    SoundSync

        call    VBlankIntrWait
        ld      a, 136
        ld      [rWY], a
        ld      [var_overlay_y_offset], a

        ld      a, 0
        ld      [var_overlay_alternate_pos], a

        call    ShowOverlay

        call    OverlayRepaintRow2

        call    DrawEntities

	ld      de, InventorySceneFadeOutVBlank
        call    SceneSetVBlankFn

        ld      de, VoidUpdateFn
        call    SceneSetUpdateFn

        call    SoundSync

        ret

.idle:
        LONG_CALL r8_InventoryUpdate, 8

        ret


;;; ----------------------------------------------------------------------------

InventorySceneFadeinVBlank:
        SET_BANK 7

        ld      a, [var_overlay_y_offset]
        ld      b, 136
        cp      b
        jr      C, .inc
        jr      .skip
.inc:
        inc     a
        ld      [var_overlay_y_offset], a
.skip:

        ld      a, [var_overlay_y_offset]
        ld      [rWY], a

        ld      a, [var_scene_counter]
	ld      c, a
        add     16
        jr      C, .transition
	jr      .continue

.transition:
        ld      de, VoidVBlankFn
        call    SceneSetVBlankFn

	ld      de, InventorySceneUpdate
        call    SceneSetUpdateFn

        ld      c, 255
        call    BlackScreenExcludeOverlay

        call    SoundPause      ;FIXME
        LONG_CALL r8_InventoryOpen, 8
        call    SoundResume
        ret

.continue:
        ld      [var_scene_counter], a
        call    FadeToBlackExcludeOverlay

        ret


;;; ----------------------------------------------------------------------------

InventorySceneFadeOutVBlank:
        SET_BANK 7

        ld      a, [var_scene_counter]
	ld      c, a
        sub     24
        jr      C, .transition
	jr      .continue

.transition:
        call    FadeNone

        ld      de, OverworldSceneUpdate
        call    SceneSetUpdateFn

        ld      de, OverworldSceneOnVBlank
        call    SceneSetVBlankFn

        ret

.continue:
        ld      [var_scene_counter], a

        call    FadeToBlackExcludeOverlay
        ret
