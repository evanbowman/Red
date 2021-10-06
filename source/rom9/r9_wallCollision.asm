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

r9_WallCollisionInitCharacterHitbox:
;;; d - x offset
;;; e - y offset
;;; trashes hl, b, c
        ld      hl, var_temp_hitbox1

        ld      a, [hvar_wall_collision_source_x]
        add     d
        ld      [hl+], a
        ld      b, a

        ld      a, [hvar_wall_collision_source_y]
        add     e
        ld      [hl+], a
        ld      c, a

        ld      a, [hvar_wall_collision_size_x]
        add     b
        ld      [hl+], a

        ld      a, [hvar_wall_collision_size_y]
        add     c
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------

r9_WallCollisionInitWallHitbox:
;;; a - x (tile coord 0-15)
;;; b - y (tile coord 0-15)
;;; trashes a, b, hl
        swap    a
        swap    b

        dec     a               ; 1px padding around tile
        dec     b

        ld      hl, var_temp_hitbox2
        ld      [hl+], a        ; \ Top left
        ld      [hl], b         ; /

        inc     hl

        add     16 + 2          ; \ + 2 padding
        ld      [hl+], a        ; | Bottom right (top left (x,y) + (16,16))
        ld      a, b            ; |
        add     16 + 2          ; |
        ld      [hl], a         ; /
        ret


;;; ----------------------------------------------------------------------------

r9_WallCollisionTileCoord:
;;; return b - y
;;; return a - x
        ld      a, [hvar_wall_collision_source_y]
        swap    a               ; Tiles are 16x16, so divide player pos by 16
	and     $0f             ; swap + mask == division by 16
        ld      b, a

        ld      a, [hvar_wall_collision_source_x]
        swap    a
        and     $0f
        ret


;;; ----------------------------------------------------------------------------

r9_WallCollisionCheck:
;;; NOTE:
;;; Trashes a whole bunch of registers.
;;; Parameters configued via hvar_wall_collision_source_x, etc.
        ld      a, 0
        ldh     [hvar_wall_collision_result], a

        fcall   r9_WallCollisionCheckLeft
        fcall   r9_WallCollisionCheckRight
        fcall   r9_WallCollisionCheckUp
        fcall   r9_WallCollisionCheckDown
        ret


;;; ----------------------------------------------------------------------------

r9_WallCollisionCheckHorizontalOnly:
;;; Like r9_WallCollisionCheck, but only performs half of the work
;;; (use if you are only moving horizontally).
        ld      a, 0
        ldh     [hvar_wall_collision_result], a

        fcall   r9_WallCollisionCheckLeft
        fcall   r9_WallCollisionCheckRight
        ret


;;; ----------------------------------------------------------------------------

r9_WallCollisionCheckVerticalOnly:
;;; Like r9_WallCollisionCheck, but only performs half of the work
;;; (use if you are only moving vertically).
        ld      a, 0
        ldh     [hvar_wall_collision_result], a

        fcall   r9_WallCollisionCheckUp
        fcall   r9_WallCollisionCheckDown
        ret


;;; ----------------------------------------------------------------------------

r9_WallCollisionCheckRight:
        ld      a, [hvar_wall_collision_size_x]
        ld      d, a
        ld      e, 0
        fcall   r9_WallCollisionInitCharacterHitbox

.test0:
	fcall   r9_WallCollisionTileCoord
        inc     a
        ld      hl, var_map_info
        fcall   MapGetTile
        ld      a, b
        cp      WALL_TILES_END
        jr      NC, .test1

	fcall   r9_WallCollisionTileCoord
        inc     a
        fcall   r9_WallCollisionInitWallHitbox
        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        jr      NC, .test1

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_RIGHT
        ld      [hvar_wall_collision_result], a
        ret

.test1:
	fcall   r9_WallCollisionTileCoord
        inc     a
        inc     b
        ld      hl, var_map_info
        fcall   MapGetTile
        ld      a, b
        cp      WALL_TILES_END
        jr      NC, .test2

	fcall   r9_WallCollisionTileCoord
        inc     a
        inc     b
        fcall   r9_WallCollisionInitWallHitbox
        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        jr      NC, .test2

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_RIGHT
        ld      [hvar_wall_collision_result], a
        ret

.test2:
	fcall   r9_WallCollisionTileCoord
        inc     a
        dec     b
        ld      hl, var_map_info
        fcall   MapGetTile
        ld      a, b
        cp      WALL_TILES_END
        ret     NC

	fcall   r9_WallCollisionTileCoord
        inc     a
        dec     b
        fcall   r9_WallCollisionInitWallHitbox
        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        ret     NC

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_RIGHT
        ld      [hvar_wall_collision_result], a
        ret


;;; ----------------------------------------------------------------------------


r9_WallCollisionCheckLeft:
        ld      a, [hvar_wall_collision_size_x]
        cpl
        add     1
        ld      d, a
        ld      e, 0
        fcall   r9_WallCollisionInitCharacterHitbox

.test0:
	fcall   r9_WallCollisionTileCoord
        dec     a
        ld      hl, var_map_info
        fcall   MapGetTile
        ld      a, b
        cp      WALL_TILES_END
        jr      NC, .test1

	fcall   r9_WallCollisionTileCoord
        dec     a
        fcall   r9_WallCollisionInitWallHitbox
        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        jr      NC, .test1

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_LEFT
        ld      [hvar_wall_collision_result], a
        ret

.test1:
	fcall   r9_WallCollisionTileCoord
        dec     a
        inc     b
        ld      hl, var_map_info
        fcall   MapGetTile
        ld      a, b
        cp      WALL_TILES_END
        jr      NC, .test2

	fcall   r9_WallCollisionTileCoord
        dec     a
        inc     b
        fcall   r9_WallCollisionInitWallHitbox
        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        jr      NC, .test2

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_LEFT
        ld      [hvar_wall_collision_result], a
        ret

.test2:
	fcall   r9_WallCollisionTileCoord
        dec     a
        dec     b
        ld      hl, var_map_info
        fcall   MapGetTile
        ld      a, b
        cp      WALL_TILES_END
        ret     NC

	fcall   r9_WallCollisionTileCoord
        dec     a
        dec     b
        fcall   r9_WallCollisionInitWallHitbox
        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        ret     NC

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_LEFT
        ld      [hvar_wall_collision_result], a
        ret


;;; ----------------------------------------------------------------------------


r9_WallCollisionCheckUp:
        ld      d, 0
        ld      a, [hvar_wall_collision_size_y]
        cpl
        add     1
        ld      e, a
        fcall   r9_WallCollisionInitCharacterHitbox

.test0:
	fcall   r9_WallCollisionTileCoord
        dec     b
        ld      hl, var_map_info
        fcall   MapGetTile
        ld      a, b
        cp      WALL_TILES_END
        jr      NC, .test1

	fcall   r9_WallCollisionTileCoord
        dec     b
        fcall   r9_WallCollisionInitWallHitbox
        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        jr      NC, .test1

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_UP
        ld      [hvar_wall_collision_result], a
        ret

.test1:
	fcall   r9_WallCollisionTileCoord
        dec     b
        inc     a
        ld      hl, var_map_info
        fcall   MapGetTile
        ld      a, b
        cp      WALL_TILES_END
        jr      NC, .test2

	fcall   r9_WallCollisionTileCoord
        dec     b
        inc     a
        fcall   r9_WallCollisionInitWallHitbox
        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        jr      NC, .test2

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_UP
        ld      [hvar_wall_collision_result], a
        ret

.test2:
	fcall   r9_WallCollisionTileCoord
        dec     b
        dec     a
        ld      hl, var_map_info
        fcall   MapGetTile
        ld      a, b
        cp      WALL_TILES_END
        ret     NC

	fcall   r9_WallCollisionTileCoord
        dec     b
        dec     a
        fcall   r9_WallCollisionInitWallHitbox
        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        ret     NC

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_UP
        ld      [hvar_wall_collision_result], a
        ret


;;; ----------------------------------------------------------------------------


r9_WallCollisionCheckDown:
        ld      d, 0
        ld      a, [hvar_wall_collision_size_y]
        ld      e, a
        fcall   r9_WallCollisionInitCharacterHitbox

.test0:
	fcall   r9_WallCollisionTileCoord
        inc     b
        ld      hl, var_map_info
        fcall   MapGetTile
        ld      a, b
        cp      WALL_TILES_END
        jr      NC, .test1

	fcall   r9_WallCollisionTileCoord
        inc     b
        fcall   r9_WallCollisionInitWallHitbox
        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        jr      NC, .test1

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_DOWN
        ld      [hvar_wall_collision_result], a
        ret

.test1:
	fcall   r9_WallCollisionTileCoord
        inc     b
        inc     a
        ld      hl, var_map_info
        fcall   MapGetTile
        ld      a, b
        cp      WALL_TILES_END
        jr      NC, .test2

	fcall   r9_WallCollisionTileCoord
        inc     b
        inc     a
        fcall   r9_WallCollisionInitWallHitbox
        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        jr      NC, .test2

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_DOWN
        ld      [hvar_wall_collision_result], a
        ret

.test2:
	fcall   r9_WallCollisionTileCoord
        inc     b
        dec     a
        ld      hl, var_map_info
        fcall   MapGetTile
        ld      a, b
        cp      WALL_TILES_END
        ret     NC

	fcall   r9_WallCollisionTileCoord
        inc     b
        dec     a
        fcall   r9_WallCollisionInitWallHitbox
        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        ret     NC

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_DOWN
        ld      [hvar_wall_collision_result], a
        ret


;;; ----------------------------------------------------------------------------
