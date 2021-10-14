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


r9_BonfireUpdateImpl:
;;; bc - self
        ld      h, b
        ld      l, c


        ld      e, 6
        ld      d, 5

        fcall   EntityAnimationAdvance

        fcall   r9_BonfireMessageLoop

        ret


;;; ----------------------------------------------------------------------------


r9_BonfireMessageLoop:
;;; bc - self
;;; trashes hl
        push    hl              ; hl -> de (see below)

        fcall   EntityGetMessageQueue
        fcall   MessageQueueLoad

        pop     de
        ld      bc, r9_BonfireOnMessage
        fcall   MessageQueueDrain
        ret


;;; ----------------------------------------------------------------------------


r9_BonfireOnMessage:
;;; bc - message pointer
;;; de - self
        ld      a, [bc]
        cp      MESSAGE_PLAYER_INTERACT
        jr      Z, .onPlayerInteract
        ret

.onPlayerInteract:
	ld      h, d
        ld      l, e

        push    hl
        fcall   EntityGetPos
        ld      hl, var_temp_hitbox1
        fcall   r9_BonfirePopulateHitbox

        ld      hl, var_temp_hitbox2
        fcall   r9_PlayerPopulateHitbox

        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        pop     hl
        ret     NC

        ld      a, 1
        ld      [var_inventory_scene_cooking_tab_avail], a

        ld      a, INVENTORY_TAB_COOK
        ld      [var_inventory_scene_tab], a

        ld      a, [var_bonfire_dialog_played]
        or      a
        jr      NZ, .skipDialog

	ld      a, 1
        ld      [var_bonfire_dialog_played], a

	ld      bc, TEST_STR
        ld      de, InventorySceneEnter
        fcall   DialogSetup

        ld      de, DialogSceneEnter
        jp      EntityMessageLoopJumpToScene

.skipDialog:
        ld      de, InventorySceneEnter
        jp      EntityMessageLoopJumpToScene


;;; ----------------------------------------------------------------------------


r9_BonfirePopulateHitbox:
;;; b - x coord
;;; c - y coord
;;; hl - hitbox
        ld      a, b
        sub     8
        ld      b, a
        ld      [hl], b
        inc     hl
        ld      a, c
        sub     8
        ld      c, a
        ld      [hl], c
        inc     hl

        ld      a, 48
        add     b
        ld      [hl+], a

        ld      a, 48
        add     c
        ld      [hl], a

        ret


;;; ----------------------------------------------------------------------------
