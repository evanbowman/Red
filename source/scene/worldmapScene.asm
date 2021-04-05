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
;;;  Worldmap Scene
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


WorldmapSceneEnter:
        ld      a, 0
        ld      [var_scene_counter], a

	ld      de, VoidVBlankFn
        call    SceneSetUpdateFn

        ld      de, WorldmapSceneFadeinVBlank
        call    SceneSetVBlankFn

        ret


;;; ----------------------------------------------------------------------------

WorldmapSceneUpdate:
        ldh     a, [hvar_joypad_current]
        bit     PADB_SELECT, a
        jr      Z, .idle

        ld      a, 255
        ld      [var_scene_counter], a

        call    VBlankIntrWait
;;; i.e. Hide all tiles onscreen
        call    TanScreen

        ld      a, 128
        ld      [rWY], a

        call    OverworldSceneInitOverlayVRam

        call    OverlayRepaintRow2

	ld      de, WorldmapSceneFadeOutVBlank
        call    SceneSetVBlankFn

        ld      de, VoidUpdateFn
        call    SceneSetUpdateFn

.idle:
        ret


;;; ----------------------------------------------------------------------------

WorldmapSceneFadeinVBlank:
        ld      a, [var_scene_counter]
	ld      c, a
        add     16
        jr      C, .transition
	jr      .continue

.transition:
        ld      de, VoidVBlankFn
        call    SceneSetVBlankFn

	ld      de, WorldmapSceneUpdate
        call    SceneSetUpdateFn

        call    TanScreen

        LONG_CALL r1_WorldMapShow

        ret

.continue:
        ld      [var_scene_counter], a
        call    FadeToTan
        ret


;;; ----------------------------------------------------------------------------

WorldmapSceneFadeOutVBlank:
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
        call    FadeToTan

        ret
