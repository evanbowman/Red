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
;;; Generate two main paths to the destination.

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
        or      ROOM_VISITED | ROOM_CONNECTED_D
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
        or      ROOM_VISITED | ROOM_CONNECTED_U
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
        or      ROOM_VISITED | ROOM_CONNECTED_R
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
        or      ROOM_VISITED | ROOM_CONNECTED_L
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
