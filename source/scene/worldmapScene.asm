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
        ld      [var_world_map_cursor_visible], a
        ld      [var_world_map_cursor_tx], a
        ld      [var_world_map_cursor_ty], a

        ld      a, [var_room_x]
        ld      [var_world_map_cursor_x], a
        ld      a, [var_room_y]
        ld      [var_world_map_cursor_y], a


	ld      de, DrawonlyUpdateFn
        fcall   SceneSetUpdateFn

        ld      de, WorldmapSceneFadeinVBlank
        fcall   SceneSetVBlankFn

        ret


;;; ----------------------------------------------------------------------------

WorldmapSceneUpdate:
        LONG_CALL r1_WorldMapUpdateCursor

        ldh     a, [hvar_joypad_current]
        bit     PADB_SELECT, a
        ret     Z

.exitScene:
        ld      a, 255
        ld      [var_scene_counter], a

;;; Clear out whatever objects might be in use by the world map
        ld      hl, var_oam_back_buffer
        ld      a, 0
        ld      bc, OAM_SIZE * OAM_COUNT
        fcall   Memset


        fcall   DrawEntities

        fcall   VBlankIntrWait
;;; i.e. Hide all tiles onscreen
        fcall   TanScreen

        ld      a, 128
        ld      [rWY], a

        fcall   OverworldSceneInitOverlayVRam

        fcall   OverlayRepaintRow2

        VIDEO_BANK 1
        ld      hl, $9e20
        ld      a, $00
        ld      bc, 20
        fcall   Memset
        VIDEO_BANK 0

	ld      de, WorldmapSceneFadeOutVBlank
        fcall   SceneSetVBlankFn

        ld      de, DrawonlyUpdateFn
        fcall   SceneSetUpdateFn

        ret


;;; ----------------------------------------------------------------------------

WorldMapSceneUpdateCursorRight:
	LONG_CALL r1_WorldMapSceneUpdateCursorRightImpl
        ret


WorldMapSceneUpdateCursorLeft:
	LONG_CALL r1_WorldMapSceneUpdateCursorLeftImpl
        ret


WorldMapSceneUpdateCursorDown:
	LONG_CALL r1_WorldMapSceneUpdateCursorDownImpl
        ret


WorldMapSceneUpdateCursorUp:
	LONG_CALL r1_WorldMapSceneUpdateCursorUpImpl
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
        fcall   SceneSetVBlankFn

	ld      de, WorldmapSceneUpdate
        fcall   SceneSetUpdateFn

        fcall   TanScreen

        LONG_CALL r1_WorldMapShow

        ret

.continue:
        ld      [var_scene_counter], a
        fcall   FadeToTan
        ret


;;; ----------------------------------------------------------------------------

WorldmapSceneFadeOutVBlank:
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
        fcall   FadeToTan

        ret


;;; ----------------------------------------------------------------------------

WorldMapSceneDescribeRoomVBlank:
	LONG_CALL r1_WorldMapDescribeRoomVBlankImpl
        ret


;;; ----------------------------------------------------------------------------
