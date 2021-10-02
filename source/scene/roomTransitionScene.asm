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
;;;  Room Transition Scene
;;;
;;; TODO: there's a bunch of repeated code here. We could save a decent amount
;;; of ROM by refactoring this stuff. e.g. the down and right vblank handlers
;;; differ only by MapShowRow/MapShowColumn
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


RoomTransitionSceneDownVBlank:
        ld      a, [var_room_load_counter]

;;; Why only 30 rows? Otherwise, we will see the rows change as the screen
;;; scrolls. We will finish up the rest of the rows after the transition.
        cp      30

	ret     Z

        ld      c, a

        push    bc

        LONG_CALL r1_MapShowRow

        pop     bc

        inc     c
        ld      a, c
        ld      [var_room_load_counter], a

.done:
        ret

;;; ----------------------------------------------------------------------------

RoomTransitionDone:
	ld      de, OverworldSceneUpdate
        fcall   SceneSetUpdateFn

        ld      de, OverworldSceneOnVBlank
        fcall   SceneSetVBlankFn

        LONG_CALL r1_SetRoomVisited

;;; In case we missed any key presses during the transition
        ld      a, [var_room_load_joypad_cache]
        ld      [hvar_joypad_raw], a

        LONG_CALL r1_LoadRoomEntities

        fcall   VBlankIntrWait

        ret


;;; ----------------------------------------------------------------------------

;;; This handler takes care of the remaining rows, after the transition is
;;; complete.
RoomTransitionSceneDownFinishUpVBlank:
        ld      a, [var_room_load_counter]

        cp      32

	jr      Z, .done

        ld      c, a

        push    bc

        LONG_CALL r1_MapShowRow

        pop     bc

        inc     c
        ld      a, c
        ld      [var_room_load_counter], a

        jr      .return
.done:
        fcall   RoomTransitionDone

.return:
        ret


;;; ----------------------------------------------------------------------------

RoomTransitionSceneDownUpdate:
        ld      a, [var_view_y]
        cp      0
        jr      Z, .done

        add     4

        cp      5
        jr      C, .correct
        jr      .skip
.correct:
        ld      a, 0


.skip:
        ld      [var_view_y], a

	ld      hl, var_player_coord_y
        ld      b, 0
	ld      c, 148
        fcall   FixnumAdd

        fcall   DrawEntities

        ld      a, [var_room_load_counter]
        ld      c, a
        LONG_CALL r1_MapExpandRow

        jr      .continue
.done:
;;; The vblank handler is still updating map rows, so we won't set the vblank
;;; handler for remapping sprites yet. But if we don't allow the player to move
;;; while we're copying the rest of the map rows, it's kind of annoying to the
;;; user, because there's a split-second pause otherwise.
        ld      de, RoomTransitionSceneUDUpdateRest
        fcall   SceneSetUpdateFn

        ld      de, RoomTransitionSceneDownFinishUpVBlank
        fcall   SceneSetVBlankFn

;;; ...
.continue:
        ret


;;; ----------------------------------------------------------------------------

RoomTransitionSceneUpUpdate:
        ld      a, [var_view_y]
        cp      121
        jr      Z, .done

        sub     4

        cp      121
        jr      C, .fixView     ; fix overcorrection (aka clamp)
        jr      .setView
.fixView:
        ld      a, 121

.setView:
        ld      [var_view_y], a

        ld      hl, var_player_coord_y
        ld      b, 0
	ld      c, 148
        fcall   FixnumSub

        fcall   DrawEntities

        ld      a, [var_room_load_counter]
        ld      c, a
        LONG_CALL r1_MapExpandRow

        jr      .continue

.done:
        ld      de, RoomTransitionSceneUDUpdateRest
        fcall   SceneSetUpdateFn

        ld      de, RoomTransitionSceneUpFinishUpVBlank
        fcall   SceneSetVBlankFn

.continue:
	ret



;;; ----------------------------------------------------------------------------

RoomTransitionSceneUpVBlank:
        ld      a, [var_room_load_counter]

        cp      2

	jr      Z, .done

        ld      c, a

        push    bc

        LONG_CALL r1_MapShowRow

        pop     bc

        dec     c
        ld      a, c
        ld      [var_room_load_counter], a

.done:
        ret


;;; ----------------------------------------------------------------------------

RoomTransitionSceneUpFinishUpVBlank:
        ld      a, [var_room_load_counter]

        cp      255                     ; Intentional overflow

	jr      Z, .done

        ld      c, a

        push    bc

        LONG_CALL r1_MapShowRow

        pop     bc

        dec     c
        ld      a, c
        ld      [var_room_load_counter], a

        jr      .return
.done:
        fcall   RoomTransitionDone

.return:
        ret


;;; ----------------------------------------------------------------------------

RoomTransitionSceneRightUpdate:
        ld      a, [var_view_x]
        cp      0
        jr      Z, .done

        add     4

        cp      5
        jr      C, .correct
        jr      .skip
.correct:
        ld      a, 0

.skip:
        ld      [var_view_x], a

	ld      hl, var_player_coord_x
        ld      b, 0
	ld      c, 148
        fcall   FixnumAdd

        fcall   DrawEntities

        ld      a, [var_room_load_counter]
        ld      c, a
        LONG_CALL r1_MapExpandColumn

        jr      .continue
.done:

        ld      de, RoomTransitionSceneLRUpdateRest
        fcall   SceneSetUpdateFn

        ld      de, RoomTransitionSceneRightFinishUpVBlank
        fcall   SceneSetVBlankFn

.continue:
        ret


;;; ----------------------------------------------------------------------------

RoomTransitionSceneRightFinishUpVBlank:
        ld      a, [var_room_load_counter]

        cp      32

	jr      Z, .done

        ld      c, a

        push    bc

        LONG_CALL r1_MapShowColumn

        pop     bc

        inc     c
        ld      a, c
        ld      [var_room_load_counter], a

        jr      .return
.done:
        fcall   RoomTransitionDone

.return:
        ret


;;; ----------------------------------------------------------------------------


RoomTransitionSceneRightVBlank:
        ld      a, [var_room_load_counter]

        cp      23

	jr      Z, .done

        ld      c, a

        push    bc

        LONG_CALL r1_MapShowColumn

        pop     bc

        inc     c
        ld      a, c
        ld      [var_room_load_counter], a

.done:
        ret


;;; ----------------------------------------------------------------------------

RoomTransitionSceneLeftUpdate:
        ld      a, [var_view_x]
        cp      95
        jr      Z, .done

        sub     4

        cp      95
        jr      C, .fixView     ; fix overcorrection (aka clamp)
        jr      .setView
.fixView:
        ld      a, 95

.setView:
        ld      [var_view_x], a

        ld      hl, var_player_coord_x
        ld      b, 0
	ld      c, 148
        fcall   FixnumSub

        fcall   DrawEntities

        ld      a, [var_room_load_counter]
        ld      c, a
        LONG_CALL r1_MapExpandColumn

        jr      .continue

.done:
        ld      de, RoomTransitionSceneLRUpdateRest
        fcall   SceneSetUpdateFn

        ld      de, RoomTransitionSceneLeftFinishUpVBlank
        fcall   SceneSetVBlankFn

.continue:
	ret

;;; ----------------------------------------------------------------------------

RoomTransitionSceneUDUpdateRest:
        ld      a, [var_room_load_counter]
        ld      c, a
        LONG_CALL r1_MapExpandRow

        ret


;;; ----------------------------------------------------------------------------

RoomTransitionSceneLRUpdateRest:
        ld      a, [var_room_load_counter]
        ld      c, a
        LONG_CALL r1_MapExpandColumn

        ret


;;; ----------------------------------------------------------------------------

RoomTransitionSceneLeftVBlank:
        ld      a, [var_room_load_counter]

        cp      7

	jr      Z, .done

        ld      c, a

        push    bc

        LONG_CALL r1_MapShowColumn

        pop     bc

        dec     c
        ld      a, c
        ld      [var_room_load_counter], a

.done:
        ret


;;; ----------------------------------------------------------------------------


RoomTransitionSceneLeftFinishUpVBlank:
        ld      a, [var_room_load_counter]

        cp      255                     ; Intentional overflow

	jr      Z, .done

        ld      c, a

        push    bc

        LONG_CALL r1_MapShowColumn

        pop     bc

        dec     c
        ld      a, c
        ld      [var_room_load_counter], a

        jr      .return
.done:
        fcall   RoomTransitionDone

.return:
        ret


;;; ----------------------------------------------------------------------------
