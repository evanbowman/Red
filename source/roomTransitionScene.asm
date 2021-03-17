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
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


RoomTransitionSceneDownVBlank:
        ld      a, [var_room_load_y_counter]

;;; Why only 24 rows? Otherwise, we will see the rows change as the screen
;;; scrolls. We will finish up the rest of the rows after the transition.
        cp      24

	jr      Z, .done

        ld      c, a

        push    bc

        call    MapShowRow

        pop     bc

        inc     c
        ld      a, c
        ld      [var_room_load_y_counter], a

.done:
        jp      VBlankFnResume


;;; ----------------------------------------------------------------------------

;;; This handler takes care of the remaining rows, after the transition is
;;; complete.
RoomTransitionSceneDownFinishUpVBlank:
        ld      a, [var_room_load_y_counter]

        cp      32

	jr      Z, .done

        ld      c, a

        push    bc

        call    MapShowRow

        pop     bc

        inc     c
        ld      a, c
        ld      [var_room_load_y_counter], a

        jr      .return
.done:

        ld      de, OverworldSceneUpdate
        call    SceneSetUpdateFn

        ld      de, OverworldSceneOnVBlank
        call    SceneSetVBlankFn

.return:
        jp      VBlankFnResume


;;; ----------------------------------------------------------------------------

RoomTransitionSceneDownUpdate:
        ld      a, [var_view_y]
        cp      0
        jr      Z, .done

        inc     a
        inc     a
        inc     a
        cp      1
        jr      NZ, .skip
        ld      a, 0
        cp      2
        jr      NZ, .skip
        ld      a, 0


.skip:
        ld      [var_view_y], a

	ld      hl, var_player_coord_y
        ld      b, 0
	ld      c, 148
        call    FixnumAdd

        call    DrawEntities

        jr      .continue
.done:
;;; No more update code to run, set a void handler, and let the vblank handler
;;; take care of populating the remaining map rows.
        ld      de, VoidUpdateFn
        call    SceneSetUpdateFn

        ld      de, RoomTransitionSceneDownFinishUpVBlank
        call    SceneSetVBlankFn

;;; ...
.continue:
        jp      UpdateFnResume


;;; ----------------------------------------------------------------------------

RoomTransitionSceneUpUpdate:
        ld      a, [var_view_y]
        cp      121
        jr      Z, .done

        dec     a
        dec     a
        dec     a

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
        call    FixnumSub

        call    DrawEntities
        jr      .continue

.done:
        ld      de, VoidUpdateFn
        call    SceneSetUpdateFn

        ld      de, RoomTransitionSceneUpFinishUpVBlank
        call    SceneSetVBlankFn

.continue:
	jp      UpdateFnResume



;;; ----------------------------------------------------------------------------

RoomTransitionSceneUpVBlank:
        ld      a, [var_room_load_y_counter]

        cp      8

	jr      Z, .done

        ld      c, a

        push    bc

        call    MapShowRow

        pop     bc

        dec     c
        ld      a, c
        ld      [var_room_load_y_counter], a

.done:
        jp      VBlankFnResume


;;; ----------------------------------------------------------------------------

RoomTransitionSceneUpFinishUpVBlank:
        ld      a, [var_room_load_y_counter]

        cp      255                     ; Intentional overflow

	jr      Z, .done

        ld      c, a

        push    bc

        call    MapShowRow

        pop     bc

        dec     c
        ld      a, c
        ld      [var_room_load_y_counter], a

        jr      .return
.done:

        ld      de, OverworldSceneUpdate
        call    SceneSetUpdateFn

        ld      de, OverworldSceneOnVBlank
        call    SceneSetVBlankFn

.return:
        jp      VBlankFnResume


;;; ----------------------------------------------------------------------------

RoomTransitionSceneRightUpdate:
        ld      a, [var_view_x]
        cp      0
        jr      Z, .done

        inc     a
        inc     a
        inc     a
        cp      1
        jr      NZ, .skip
        ld      a, 0
        cp      2
        jr      NZ, .skip
        ld      a, 0

.skip:
        ld      [var_view_x], a

	ld      hl, var_player_coord_x
        ld      b, 0
	ld      c, 148
        call    FixnumAdd

        call    DrawEntities

        jr      .continue
.done:

        ld      de, VoidUpdateFn
        call    SceneSetUpdateFn

        ld      de, RoomTransitionSceneRightFinishUpVBlank
        call    SceneSetVBlankFn

.continue:
        jp      UpdateFnResume


;;; ----------------------------------------------------------------------------

RoomTransitionSceneRightFinishUpVBlank:
        ld      a, [var_room_load_x_counter]

        cp      32

	jr      Z, .done

        ld      c, a

        push    bc

        call    MapShowColumn

        pop     bc

        inc     c
        ld      a, c
        ld      [var_room_load_x_counter], a

        jr      .return
.done:

        ld      de, OverworldSceneUpdate
        call    SceneSetUpdateFn

        ld      de, OverworldSceneOnVBlank
        call    SceneSetVBlankFn

.return:
        jp      VBlankFnResume


;;; ----------------------------------------------------------------------------


RoomTransitionSceneRightVBlank:
        ld      a, [var_room_load_x_counter]

        cp      20

	jr      Z, .done

        ld      c, a

        push    bc

        call    MapShowColumn

        pop     bc

        inc     c
        ld      a, c
        ld      [var_room_load_x_counter], a

.done:
        jp      VBlankFnResume


;;; ----------------------------------------------------------------------------

RoomTransitionSceneLeftUpdate:
        ld      a, [var_view_x]
        cp      95
        jr      Z, .done

        dec     a
        dec     a
        dec     a

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
        call    FixnumSub

        call    DrawEntities
        jr      .continue

.done:
        ld      de, VoidUpdateFn
        call    SceneSetUpdateFn

        ld      de, RoomTransitionSceneLeftFinishUpVBlank
        call    SceneSetVBlankFn

.continue:
	jp      UpdateFnResume


;;; ----------------------------------------------------------------------------

RoomTransitionSceneLeftVBlank:
        ld      a, [var_room_load_x_counter]

        cp      12

	jr      Z, .done

        ld      c, a

        push    bc

        call    MapShowColumn

        pop     bc

        dec     c
        ld      a, c
        ld      [var_room_load_x_counter], a

.done:
        jp      VBlankFnResume


;;; ----------------------------------------------------------------------------


RoomTransitionSceneLeftFinishUpVBlank:
        ld      a, [var_room_load_x_counter]

        cp      255                     ; Intentional overflow

	jr      Z, .done

        ld      c, a

        push    bc

        call    MapShowColumn

        pop     bc

        dec     c
        ld      a, c
        ld      [var_room_load_x_counter], a

        jr      .return
.done:

        ld      de, OverworldSceneUpdate
        call    SceneSetUpdateFn

        ld      de, OverworldSceneOnVBlank
        call    SceneSetVBlankFn

.return:
        jp      VBlankFnResume


;;; ----------------------------------------------------------------------------
