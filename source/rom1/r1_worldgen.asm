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

r1_WorldGen:
        ld      hl, wram1_var_world_map_info
        ld      bc, wram1_var_world_map_info_end - wram1_var_world_map_info
        ld      a, 0
        call    Memset

        ld      a, ROOM_B3_PROXIMAL_PATH
        ld      [var_worldgen_path_flags], a

        ld      a, $ff / 2 - 28
        ld      [var_worldgen_path_w], a

        call    r1_WorldGen_RandomWalkProximalPath

        ld      a, $ff / 2 + 28
        ld      [var_worldgen_path_w], a

        call    r1_WorldGen_RandomWalkProximalPath


        ld      a, $ff / 2
        ld      [var_worldgen_path_w], a

        call    r1_WorldGen_RandomWalkDiagonalPath

        ld      a, $ff / 2 - 40
        ld      [var_worldgen_path_w], a

        call    r1_WorldGen_RandomWalkDiagonalPath

        ld      a, $ff / 2 + 40
        ld      [var_worldgen_path_w], a

        call    r1_WorldGen_RandomWalkDiagonalPath

.expand:
        call    r1_WorldGen_CountConnectedRooms

        ld      a, d
        or      a
        jr      NZ, .done

        ld      a, e            ; \ If the generated map so far is really small,
        cp      110             ; | try again.
        jr      C, .retry       ; /

	ld      a, 200
        cp      e
        jr      C, .done

        ;; If the generated room, so far, is smaller than 200 rooms, generate
        ;; some more, by various methods.

        call    r1_GenerateRandomBacktrackPath
        jr      .expand

.done:
        call    r1_WorldGen_AssignVariants

        call    r1_WorldGen_InitOrigin

        ret

.retry:
        jr      r1_WorldGen


;;; ----------------------------------------------------------------------------

r1_WorldGen_CountConnectedRooms:
;;; trashes most registers
;;; result in de
        ld      b, 0
        ld      c, 0

        call    r1_LoadRoom             ; rooms pointer in hl

        ld      de, 0                   ; Accumulator

        ld      a, 0
        ld      [hvar_temp_loop_counter1], a

.outer_loop:
        ld      a, 0
        ld      [hvar_temp_loop_counter2], a

.inner_loop:
        ld      a, [hl]                 ; \
        and     ROOM_B1_CONNECTIONS     ; | If room disconnected, then don't inc
        or      a                       ; | accumulator.
        jr      Z, .skip                ; /

        inc     de
.skip:
        ld      bc, ROOM_DESC_SIZE      ; \ Go to next room in array.
        add     hl, bc                  ; /


        ld      a, [hvar_temp_loop_counter2]
        inc     a
        ld      [hvar_temp_loop_counter2], a
        cp      WORLD_MAP_WIDTH
        jr      NZ, .inner_loop

        ld      a, [hvar_temp_loop_counter1]
        inc     a
        ld      [hvar_temp_loop_counter1], a
        cp      WORLD_MAP_HEIGHT
        jr      NZ, .outer_loop

        ret


;;; ----------------------------------------------------------------------------

r1_WorldGen_WalkUp:
        ld      a, [var_worldgen_curr_y]
        dec     a
        ld      [var_worldgen_curr_y], a

        ld      c, a

        RAM_BANK 1

        ld      a, [var_worldgen_curr_x]
        ld      b, a

        call    r1_LoadRoom

        ld      a, [hl]
        or      ROOM_CONNECTED_D
        ld      [hl+], a
        inc     hl

        ld      a, [var_worldgen_path_flags]
        ld      b, [hl]
        or      b
        ld      [hl], a

        ld      a, [var_worldgen_prev_y]
        ld      c, a
        ld      a, [var_worldgen_prev_x]
        ld      b, a

        call    r1_LoadRoom

        ld      a, [hl]
        or      ROOM_CONNECTED_U
        ld      [hl], a


        ld      a, [var_worldgen_curr_y]
        ld      [var_worldgen_prev_y], a

        ret


;;; ----------------------------------------------------------------------------

r1_WorldGen_WalkDown:
        ld      a, [var_worldgen_curr_y]
        inc     a
        ld      [var_worldgen_curr_y], a

        ld      c, a

        RAM_BANK 1

        ld      a, [var_worldgen_curr_x]
        ld      b, a

        call    r1_LoadRoom

        ld      a, [hl]
        or      ROOM_CONNECTED_U
        ld      [hl+], a
        inc     hl

        ld      a, [var_worldgen_path_flags]
        ld      b, [hl]
        or      b
        ld      [hl], a

        ld      a, [var_worldgen_prev_y]
        ld      c, a
        ld      a, [var_worldgen_prev_x]
        ld      b, a

        call    r1_LoadRoom

        ld      a, [hl]
        or      ROOM_CONNECTED_D
        ld      [hl], a


        ld      a, [var_worldgen_curr_y]
        ld      [var_worldgen_prev_y], a

        ret


;;; ----------------------------------------------------------------------------

r1_WorldGen_WalkLeft:
        ld      a, [var_worldgen_curr_x]
        dec     a
        ld      [var_worldgen_curr_x], a

        ld      b, a

        RAM_BANK 1

        ld      a, [var_worldgen_curr_y]
        ld      c, a

        call    r1_LoadRoom

        ld      a, [hl]
        or      ROOM_CONNECTED_R
        ld      [hl+], a
        inc     hl

        ld      a, [var_worldgen_path_flags]
        ld      b, [hl]
        or      b
        ld      [hl], a

        ld      a, [var_worldgen_prev_y]
        ld      c, a
        ld      a, [var_worldgen_prev_x]
        ld      b, a

        call    r1_LoadRoom

        ld      a, [hl]
        or      ROOM_CONNECTED_L
        ld      [hl], a

        ld      a, [var_worldgen_curr_x]
        ld      [var_worldgen_prev_x], a

        ret


;;; ----------------------------------------------------------------------------

r1_WorldGen_WalkRight:
        ld      a, [var_worldgen_curr_x]
        inc     a
        ld      [var_worldgen_curr_x], a

        ld      b, a

        RAM_BANK 1

        ld      a, [var_worldgen_curr_y]
        ld      c, a

        call    r1_LoadRoom

        ld      a, [hl]
        or      ROOM_CONNECTED_L
        ld      [hl+], a
        inc     hl

        ld      a, [var_worldgen_path_flags]
        ld      b, [hl]
        or      b
        ld      [hl], a

        ld      a, [var_worldgen_prev_y]
        ld      c, a
        ld      a, [var_worldgen_prev_x]
        ld      b, a

        call    r1_LoadRoom

        ld      a, [hl]
        or      ROOM_CONNECTED_R
        ld      [hl], a

        ld      a, [var_worldgen_curr_x]
        ld      [var_worldgen_prev_x], a

        ret


;;; ----------------------------------------------------------------------------

r1_WorldGen_RandomWalkProximalPath:
        ld      a, 0
        ld      [var_worldgen_curr_x], a
        ld      [var_worldgen_curr_y], a
        ld      [var_worldgen_prev_x], a
        ld      [var_worldgen_prev_y], a

.loop:
        ld      a, [var_worldgen_curr_x]
        cp      17
        jr      Z, .moveDownOnly

        ld      a, [var_worldgen_curr_y]
        cp      15
        jr      Z, .moveRightOnly

        call    GetRandom
        ld      a, [var_worldgen_path_w]
        ld      b, a
        ld      a, h
        cp      b

        jr      C, .moveRight
	jr      .moveDown

.moveUp:
        call    r1_WorldGen_WalkUp
        jr      .cond

.moveLeft:
        call    r1_WorldGen_WalkLeft
        jr      .cond


.moveDown:
        ld      a, [var_worldgen_curr_y]
        or      a
        jr      Z, .skip1

        call    GetRandom
        ld      a, h
        cp      $ff / 4
        jr      C, .backtrackUp
        jr      .skip1
.backtrackUp:
        call    r1_WorldGen_WalkUp
        jr      .cond
.skip1:
        call    r1_WorldGen_WalkDown
        jr      .cond



.moveRight:
        ld      a, [var_worldgen_curr_x]
        or      a
        jr      Z, .skip2

        call    GetRandom
        ld      a, h
        cp      $ff / 4
        jr      C, .backtrackLeft
        jr      .skip2
.backtrackLeft:
        call    r1_WorldGen_WalkLeft
        jr      .cond
.skip2:
        call    r1_WorldGen_WalkRight

.cond:
        jr      .loop

        ret


.moveDownOnly:
        ld      a, [var_worldgen_curr_y]
        cp      15
        jr      Z, .md_done

        call    r1_WorldGen_WalkDown
        jr      .moveDownOnly

.md_done:
        ret

.moveRightOnly:
        ld      a, [var_worldgen_curr_x]
        cp      17
        jr      Z, .mr_done

        call    r1_WorldGen_WalkRight
        jr      .moveRightOnly
.mr_done:
        ret


;;; ----------------------------------------------------------------------------


r1_WorldGen_RandomWalkDiagonalPath:
        ld      a, 0
        ld      [var_worldgen_curr_x], a
        ld      [var_worldgen_prev_x], a

        ld      a, 15
        ld      [var_worldgen_curr_y], a
        ld      [var_worldgen_prev_y], a

.loop:
        ld      a, [var_worldgen_curr_x]
        cp      17
        jr      Z, .moveUpOnly

        ld      a, [var_worldgen_curr_y]
        cp      0
        jr      Z, .moveRightOnly

        call    GetRandom
        ld      a, [var_worldgen_path_w]
        ld      b, a
        ld      a, h
        cp      b

        jr      C, .moveRight


.moveUp:
        call    r1_WorldGen_WalkUp
        jr      .cond


.moveRight:
        call    r1_WorldGen_WalkRight

.cond:
        jr      .loop

        ret


.moveUpOnly:
        ld      a, [var_worldgen_curr_y]
        cp      0
        ret     Z

        call    r1_WorldGen_WalkUp
        jr      .moveUpOnly


.moveRightOnly:
        ld      a, [var_worldgen_curr_x]
        cp      17
        ret     Z

        call    r1_WorldGen_WalkRight
        jr      .moveRightOnly


;;; ----------------------------------------------------------------------------

r1_GenerateRandomBacktrackPath:
        call    r1_GetRandomRoom

        ld      a, [hl]
        and     ROOM_B1_CONNECTIONS
        or      a
        jr      NZ, r1_GenerateRandomBacktrackPath

        ld      a, b
        ld      [var_worldgen_curr_x], a
        ld      [var_worldgen_prev_x], a

        ld      a, c
        ld      [var_worldgen_curr_y], a
        ld      [var_worldgen_prev_y], a

        ld      a, 0
        ld      [var_worldgen_path_flags], a

.loop:
        ld      a, [var_worldgen_curr_x]
        ld      b, a
        ld      a, [var_worldgen_curr_y]
        ld      c, a
        call    r1_LoadRoom
        inc     hl
        inc     hl
        ld      a, [hl]
        and     ROOM_B3_PROXIMAL_PATH
        or      a
        ret     NZ


        ld      a, [var_worldgen_curr_x]
        cp      0
        jr      Z, .moveUpOnly

        ld      a, [var_worldgen_curr_y]
        cp      0
        jr      Z, .moveLeftOnly

        call    GetRandom
        ld      b, $ff / 2
        ld      a, h
        cp      b

        jr      C, .moveLeft


.moveUp:
        call    r1_WorldGen_WalkUp
        jr      .cond


.moveLeft:
        call    r1_WorldGen_WalkLeft

.cond:
        jr      .loop

        ret


.moveUpOnly:
        ld      a, [var_worldgen_curr_y]
        cp      0
        ret     Z

        call    r1_WorldGen_WalkUp
        jr      .moveUpOnly


.moveLeftOnly:
        ld      a, [var_worldgen_curr_x]
        cp      0
        ret     Z

        call    r1_WorldGen_WalkLeft
        jr      .moveLeftOnly


;;; ----------------------------------------------------------------------------

r1_GetRandomRoom:
;;; trashes a bunch of registers
;;; room in hl
;;; b - room x coord
;;; c - room y coord
        call    GetRandom
        ld      a, l
        and     15              ; l % 16
        ld      b, a

        ;; FIXME: we need to do a mod 18, but that's difficult, so we
        ;; technically are excluding the last two columns of rooms from our
        ;; selection.


        call    GetRandom
        ld      a, l
        and     15              ; l % 16 (world map height)
        ld      c, a

        push    bc
        call    r1_LoadRoom
        pop     bc
        ret


;;; ----------------------------------------------------------------------------

r1_WorldGen_AssignVariants:
;;; trashes most registers
;;; result in de
        ld      b, 0
        ld      c, 0

        call    r1_LoadRoom             ; rooms pointer in hl

        ld      de, 0                   ; Accumulator

        ld      a, 0
        ld      [hvar_temp_loop_counter1], a

.outer_loop:
        ld      a, 0
        ld      [hvar_temp_loop_counter2], a

.inner_loop:
        ld      a, [hl]                 ; \
        and     ROOM_B1_CONNECTIONS     ; | If room disconnected, then don't inc
        or      a                       ; | accumulator.
        jr      Z, .skip                ; /


        push    hl
        call    GetRandom
        ld      a, l
        and     1
        pop     hl

        inc     hl
        ld      [hl], a
        dec     hl


.skip:
        ld      bc, ROOM_DESC_SIZE      ; \ Go to next room in array.
        add     hl, bc                  ; /


        ld      a, [hvar_temp_loop_counter2]
        inc     a
        ld      [hvar_temp_loop_counter2], a
        cp      WORLD_MAP_WIDTH
        jr      NZ, .inner_loop

        ld      a, [hvar_temp_loop_counter1]
        inc     a
        ld      [hvar_temp_loop_counter1], a
        cp      WORLD_MAP_HEIGHT
        jr      NZ, .outer_loop

        ret


;;; ----------------------------------------------------------------------------

r1_WorldGen_InitOrigin:
        ld      b, 0
        ld      c, 0
        call    r1_LoadRoom

        ld      a, 0

        inc     hl
        ld      [hl+], a
        inc     hl

        ld      a, ENTITY_TYPE_BONFIRE
        ld      [hl+], a
        ld      a, $76
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------
