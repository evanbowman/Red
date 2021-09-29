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

CarcassGetResource:
;;; a - Entity id
;;; a - result
        cp      ENTITY_TYPE_GREYWOLF_DEAD
        jr      Z, .gwd

        ld      a, ITEM_NONE
        ret
.gwd:
	ld      a, ITEM_RAW_MEAT
        ret


;;; ----------------------------------------------------------------------------

ScavengeSceneEnter:
        ld      de, ScavengeSceneAnimateIn0
        fcall   SceneSetUpdateFn

        ld      a, 128
        ld      [var_overlay_y_offset], a

        ld      a, 0
        ld      [var_scene_counter], a
        ret


;;; ----------------------------------------------------------------------------

ScavengeSceneAnimateIn0:
        fcall   OverworldSceneAnimateWater

        ld      a, [var_scene_counter]
        inc     a
        ld      [var_scene_counter], a

        cp      16
        jr      Z, .next

        swap    a               ; We're interpolating a position 1->16
        ld      c, a
        LONG_CALL r1_Smoothstep

        swap    a               ; \ Divide back down by 16
        and     $0f             ; /
        srl     a               ; Actually, I changed my mind, only offset by 8
        add     128             ; Start offset
        ld      [var_overlay_y_offset], a

        ret
.next:
        ld      a, 0
        ld      [var_scene_counter], a

        fcall   VBlankIntrWait

        ld      a, 136
        ld      [rWY], a

        fcall   VBlankIntrWait

        LONG_CALL r1_ClearOverlayBar
        LONG_CALL r8_ScavengeShowOptions

        ld      de, ScavengeSceneAnimateIn1
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

ScavengeSceneAnimateIn1:
        fcall   OverworldSceneAnimateWater

        ld      a, [var_scene_counter]
        inc     a
        inc     a
        ld      [var_scene_counter], a

        cp      24
        jr      Z, .next

        sla     a               ; \
        sla     a               ; | counter *= 8, b/c 256 / 32 == 8
        sla     a               ; /

        ld      c, a
        LONG_CALL r1_Smoothstep

        srl     a
        srl     a
        srl     a
        ld      c, a
        ld      a, 136
        sub     c
        ld      [var_overlay_y_offset], a
        ret
.next:
        ld      a, 0
        ld      [var_scavenge_selection], a

        ld      de, ScavengeSceneUpdate
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

ScavengeSceneUpdate:
        ;; fcall   OverworldSceneAnimateWater
        LONG_CALL r8_ScavengeUpdate
        ret


;;; ----------------------------------------------------------------------------

ScavengeSceneAnimateOut1:
        fcall   OverworldSceneAnimateWater

        ld      a, [var_scene_counter]
        inc     a
        ld      [var_scene_counter], a

        cp      8
        jr      Z, .next

        swap    a               ; We're interpolating a position 1->16
        ld      c, a
        LONG_CALL r1_Smoothstep

        swap    a               ; \ Divide back down by 16
        and     $0f             ; /
        ld      b, a
        ld      a, 136
        sub     b
        ld      [var_overlay_y_offset], a

        ret
.next:
        ld      de, OverworldSceneUpdate
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

ScavengeSceneAnimateOut0:
        fcall   OverworldSceneAnimateWater

        ld      a, [var_scene_counter]
        inc     a
        inc     a
        ld      [var_scene_counter], a

        cp      24
        jr      Z, .next

        sla     a               ; \
        sla     a               ; | counter *= 8, b/c 256 / 32 == 8
        sla     a               ; /

        ld      c, a
        LONG_CALL r1_Smoothstep

        srl     a
        srl     a
        srl     a
        ld      c, a
        ld      a, 112
        add     c
        ld      [var_overlay_y_offset], a
        ret
.next:
        fcall   VBlankIntrWait
        fcall   OverworldSceneInitOverlayVRam
        fcall   OverlayRepaintRow2

        ld      a, 0
        ld      [var_scene_counter], a

        ld      de, ScavengeSceneAnimateOut1
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------
