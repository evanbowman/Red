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


DialogSetString:
;;; bc - string
        ld      a, b
        ld      [var_dialog_string], a
        ld      a, c
        ld      [var_dialog_string + 1], a
        ret


;;; ----------------------------------------------------------------------------

DialogSceneEnter:
        ld      de, DialogSceneEnterVBlank
        fcall   SceneSetVBlankFn

        ld      de, VoidUpdateFn
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

DialogSceneEnterVBlank:
        LONG_CALL r13_DialogOpen

        ld      de, DialogSceneVBlank
        fcall   SceneSetVBlankFn

        ld      de, DialogSceneOnOpen
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

DialogSceneOnOpen:
        LONG_CALL r13_DialogOpenedMessageBroadcast
        ld      de, DialogSceneUpdate
        fcall   SceneSetUpdateFn

        ld      de, DialogScenePutcharVBlank
        fcall   SceneSetVBlankFn

        LONG_CALL r13_DialogInit

        LONG_CALL r13_DialogLoadWord
        ret


;;; ----------------------------------------------------------------------------

DialogSceneUpdate:
        fcall   UpdateEntities
        fcall   OverworldSceneAnimateWater
        fcall   DrawEntitiesSimple

        ld      a, [var_dialog_finished] ; \
        or      a                        ; |
        ret     Z                        ; | If dialog finished and A pressed,
        ldh     a, [hvar_joypad_current] ; | then exit the dialog box.
        bit     PADB_A, a                ; |
        ret     Z                        ; /

        LONG_CALL r13_DialogClosedMessageBroadcast

        ld      de, DialogSceneExitVBlank
        fcall   SceneSetVBlankFn

        ret


;;; ----------------------------------------------------------------------------

DialogSceneExitVBlank:
        ld      a, 128
        ld      [rWY], a

        fcall   ShowOverlay
        fcall   OverlayRepaintRow2

        fcall   FadeNone

        ld      de, OverworldSceneUpdate
        fcall   SceneSetUpdateFn

        ld      de, OverworldSceneOnVBlank
        fcall   SceneSetVBlankFn
        ret


;;; ----------------------------------------------------------------------------

DialogSceneAwaitButtonVBlank:
        ld      a, [var_water_anim_changed]
        or      a
        fcallc  NZ, VBlankCopyWaterTextures

        fcall   VBlankCopySpriteTextures

        ldh     a, [hvar_joypad_current]
        bit     PADB_A, a
        ret     Z

	xor     a

        ld      hl, $9c21
        ld      bc, 18
        fcall   Memset

        ld      hl, $9c61
        ld      bc, 18
        fcall   Memset

        VIDEO_BANK 1

        ld      a, $00

        ld      hl, $9c21
        ld      bc, 18
        fcall   Memset

        ld      hl, $9c61
        ld      bc, 18
        fcall   Memset

        VIDEO_BANK 0

        ld      de, DialogSceneVBlank
        fcall   SceneSetVBlankFn
        ret


;;; ----------------------------------------------------------------------------

DialogSceneVBlank:
        ld      a, [var_water_anim_changed]
        or      a
        fcallc  NZ, VBlankCopyWaterTextures

        fcall   VBlankCopySpriteTextures

        ldh     a, [hvar_joypad_raw]
        ld      b, a

        ld      a, [var_dialog_counter]
        inc     a
        bit     PADB_B, b
	jr      Z, .slow
.fast:
        cp      1
        jr      Z, .putChar
.slow:
        cp      5
        jr      Z, .putChar
.wait:
        ld      [var_dialog_counter], a
        ret

.putChar:
        xor     a
        ld      [var_dialog_counter], a

        ld      de, DialogScenePutcharVBlank
        fcall   SceneSetVBlankFn
        ret


;;; ----------------------------------------------------------------------------

DialogScenePutcharVBlank:
        ld      de, DialogSceneVBlank
        fcall   SceneSetVBlankFn

        LONG_CALL r13_DialogEngineStep

        ret


;;; ----------------------------------------------------------------------------
