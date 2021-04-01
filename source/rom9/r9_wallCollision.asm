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


;;; Super lazy code written in a hurry in ~30 minutes, I should really fix this
;;; sometime. I wrote this code specifically for the main player character, and
;;; later repurposed the code for testing wall collisions for other entities.


;;; ----------------------------------------------------------------------------


r9_WallCollisionCheckLeft:
;;; a - wall tile x
;;; b - wall tile y
;;; Now, we want the absolute position of the tile coordinates. Multiply by 16.
        swap    a
        swap    b
        ld      c, a

;;; We have the abs coords, now we want to check whether the absolute coord of
;;; the player falls within the bounds of the square tile. So we need to do a
;;; bounding box test:


;;; Player.y < tile.y? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_y]
        cp      b
	pop     bc
        jr      C, .false

;;; Player.y > tile.y + 16? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_y]
        ld      c, a
        ld      a, b
        add     16
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x < tile.x? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_x]
        sub     8
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x > tile.x + 16? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_x]
        sub     8
        ld      b, a
        ld      a, c
        add     16
        cp      b
        pop     bc
        jr      C, .false

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_LEFT
        ld      [hvar_wall_collision_result], a
.false:
        ret



r9_WallCollisionCheckUp:
;;; a - wall tile x
;;; b - wall tile y
;;; Now, we want the absolute position of the tile coordinates. Multiply by 16.
        swap    a
        swap    b
        ld      c, a

;;; We have the abs coords, now we want to check whether the absolute coord of
;;; the player falls within the bounds of the square tile. So we need to do a
;;; bounding box test:


;;; Player.y < tile.y? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_y]
        sub     8
        cp      b
	pop     bc
        jr      C, .false

;;; Player.y > tile.y + 16? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_y]
        sub     8
        ld      c, a
        ld      a, b
        add     16
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x < tile.x? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_x]
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x > tile.x + 16? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_x]
        ld      b, a
        ld      a, c
        add     16
        cp      b
        pop     bc
        jr      C, .false

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_UP
        ld      [hvar_wall_collision_result], a
.false:
        ret


r9_WallCollisionCheckDown:
;;; a - wall tile x
;;; b - wall tile y
;;; Now, we want the absolute position of the tile coordinates. Multiply by 16.
        swap    a
        swap    b
        ld      c, a

;;; We have the abs coords, now we want to check whether the absolute coord of
;;; the player falls within the bounds of the square tile. So we need to do a
;;; bounding box test:


;;; Player.y < tile.y? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_y]
        add     11
        cp      b
	pop     bc
        jr      C, .false

;;; Player.y > tile.y + 16? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_y]
        add     11
        ld      c, a
        ld      a, b
        add     16
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x < tile.x? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_x]
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x > tile.x + 16? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_x]
        ld      b, a
        ld      a, c
        add     16
        cp      b
        pop     bc
        jr      C, .false

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_DOWN
        ld      [hvar_wall_collision_result], a
.false:
        ret



r9_WallCollisionCheckRight:
;;; a - wall tile x
;;; b - wall tile y
;;; Now, we want the absolute position of the tile coordinates. Multiply by 16.
        swap    a
        swap    b
        ld      c, a

;;; We have the abs coords, now we want to check whether the absolute coord of
;;; the player falls within the bounds of the square tile. So we need to do a
;;; bounding box test:


;;; Player.y < tile.y? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_y]
        cp      b
	pop     bc
        jr      C, .false

;;; Player.y > tile.y + 16? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_y]
        ld      c, a
        ld      a, b
        add     16
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x < tile.x? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_x]
        add     8
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x > tile.x + 16? Then no collision
        push    bc
        ld      a, [hvar_wall_collision_source_x]
        add     8
        ld      b, a
        ld      a, c
        add     16
        cp      b
        pop     bc
        jr      C, .false

        ld      a, [hvar_wall_collision_result]
        or      COLLISION_RIGHT
        ld      [hvar_wall_collision_result], a
.false:
        ret


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


r9_WallCollisionCheck:
;;; This is manually unrolled, but what we're doing here, is checking a 3x3
;;; square of 16x16 tiles for collisions.

        ld      a, 0
        ld      [hvar_wall_collision_result], a

	call    r9_WallCollisionTileCoord

;;; ...... x - 1, y - 1
        push    af
        push    bc

        dec     a
        dec     b

        ld      hl, var_map_info
        call    MapGetTile

        ld      a, b
        cp      WALL_TILES_END

        jr      C, .test_xm1_ym1
        jr      .skip_xm1_ym1

.test_xm1_ym1:
        call    r9_WallCollisionTileCoord
        dec     a
        dec     b
        call    r9_WallCollisionCheckLeft

        call    r9_WallCollisionTileCoord
        dec     a
        dec     b
        call    r9_WallCollisionCheckUp


.skip_xm1_ym1:
        pop     bc
        pop     af

;;; ...... x - 1, y

        push    af
        push    bc

        dec     a

        ld      hl, var_map_info
        call    MapGetTile

        ld      a, b
        cp      WALL_TILES_END

        jr      C, .test_xm1_y
        jr      .skip_xm1_y

.test_xm1_y:
        call    r9_WallCollisionTileCoord
        dec     a
        call    r9_WallCollisionCheckLeft


.skip_xm1_y:
        pop     bc
        pop     af


;;; ...... x - 1, y + 1

        push    af
        push    bc

        dec     a
        inc     b

        ld      hl, var_map_info
        call    MapGetTile

        ld      a, b
        cp      WALL_TILES_END

        jr      C, .test_xm1_yp1
        jr      .skip_xm1_yp1

.test_xm1_yp1:
        call    r9_WallCollisionTileCoord
        dec     a
        inc     b
        call    r9_WallCollisionCheckLeft

        call    r9_WallCollisionTileCoord
        dec     a
        inc     b
        call    r9_WallCollisionCheckDown


.skip_xm1_yp1:

        pop     bc
        pop     af


;;; ...... x, y - 1

        push    af
        push    bc

        dec     b

        ld      hl, var_map_info
        call    MapGetTile

        ld      a, b
        cp      WALL_TILES_END

        jr      C, .test_x_ym1
        jr      .skip_x_ym1

.test_x_ym1:
        call    r9_WallCollisionTileCoord
        dec     b
        call    r9_WallCollisionCheckUp


.skip_x_ym1:

        pop     bc
        pop     af


;;; ...... x, y + 1

        push    af
        push    bc

        inc     b

        ld      hl, var_map_info
        call    MapGetTile

        ld      a, b
        cp      WALL_TILES_END

        jr      C, .test_x_yp1
        jr      .skip_x_yp1

.test_x_yp1:
        call    r9_WallCollisionTileCoord
        inc     b
        call    r9_WallCollisionCheckDown

.skip_x_yp1:

        pop     bc
        pop     af


;;; ...... x + 1, y - 1

        push    af
        push    bc

        inc     a
        dec     b

        ld      hl, var_map_info
        call    MapGetTile

        ld      a, b
        cp      WALL_TILES_END

        jr      C, .test_xp1_ym1
        jr      .skip_xp1_ym1

.test_xp1_ym1:
        call    r9_WallCollisionTileCoord
        inc     a
        dec     b
        call    r9_WallCollisionCheckRight

        call    r9_WallCollisionTileCoord
        inc     a
        dec     b
        call    r9_WallCollisionCheckUp

.skip_xp1_ym1:

        pop     bc
        pop     af


;;; ...... x + 1, y

        push    af
        push    bc

        inc     a

        ld      hl, var_map_info
        call    MapGetTile

        ld      a, b
        cp      WALL_TILES_END

        jr      C, .test_xp1_y
        jr      .skip_xp1_y

.test_xp1_y:
        call    r9_WallCollisionTileCoord
        inc     a
        call    r9_WallCollisionCheckRight


.skip_xp1_y:

        pop     bc
        pop     af


;;; ...... x + 1, y + 1

        push    af
        push    bc

        inc     a
        inc     b

        ld      hl, var_map_info
        call    MapGetTile

        ld      a, b
        cp      WALL_TILES_END

        jr      C, .test_xp1_yp1
        jr      .skip_xp1_yp1

.test_xp1_yp1:
        call    r9_WallCollisionTileCoord
        inc     a
        inc     b
        call    r9_WallCollisionCheckRight

        call    r9_WallCollisionTileCoord
        inc     a
        inc     b
        call    r9_WallCollisionCheckDown


.skip_xp1_yp1:

        pop     bc
        pop     af


;;; TODO... We want to check collisions based on all tiles around the player.

        ret
