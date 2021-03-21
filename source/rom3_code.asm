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


;;; ############################################################################


SECTION "ROM3_CODE", ROMX, BANK[3]


r3_PlayerCheckWallCollisionLeft:
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
        ld      a, [var_player_coord_y]
        cp      b
	pop     bc
        jr      C, .false

;;; Player.y > tile.y + 16? Then no collision
        push    bc
        ld      a, [var_player_coord_y]
        ld      c, a
        ld      a, b
        add     16
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x < tile.x? Then no collision
        push    bc
        ld      a, [var_player_coord_x]
        sub     8
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x > tile.x + 16? Then no collision
        push    bc
        ld      a, [var_player_coord_x]
        sub     8
        ld      b, a
        ld      a, c
        add     16
        cp      b
        pop     bc
        jr      C, .false

        ld      a, [var_player_spill1]
        or      COLLISION_LEFT
        ld      [var_player_spill1], a
.false:
        ret



r3_PlayerCheckWallCollisionUp:
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
        ld      a, [var_player_coord_y]
        sub     8
        cp      b
	pop     bc
        jr      C, .false

;;; Player.y > tile.y + 16? Then no collision
        push    bc
        ld      a, [var_player_coord_y]
        sub     8
        ld      c, a
        ld      a, b
        add     16
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x < tile.x? Then no collision
        push    bc
        ld      a, [var_player_coord_x]
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x > tile.x + 16? Then no collision
        push    bc
        ld      a, [var_player_coord_x]
        ld      b, a
        ld      a, c
        add     16
        cp      b
        pop     bc
        jr      C, .false

        ld      a, [var_player_spill1]
        or      COLLISION_UP
        ld      [var_player_spill1], a
.false:
        ret


r3_PlayerCheckWallCollisionDown:
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
        ld      a, [var_player_coord_y]
        add     8
        cp      b
	pop     bc
        jr      C, .false

;;; Player.y > tile.y + 16? Then no collision
        push    bc
        ld      a, [var_player_coord_y]
        add     8
        ld      c, a
        ld      a, b
        add     16
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x < tile.x? Then no collision
        push    bc
        ld      a, [var_player_coord_x]
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x > tile.x + 16? Then no collision
        push    bc
        ld      a, [var_player_coord_x]
        ld      b, a
        ld      a, c
        add     16
        cp      b
        pop     bc
        jr      C, .false

        ld      a, [var_player_spill1]
        or      COLLISION_DOWN
        ld      [var_player_spill1], a
.false:
        ret



r3_PlayerCheckWallCollisionRight:
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
        ld      a, [var_player_coord_y]
        cp      b
	pop     bc
        jr      C, .false

;;; Player.y > tile.y + 16? Then no collision
        push    bc
        ld      a, [var_player_coord_y]
        ld      c, a
        ld      a, b
        add     16
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x < tile.x? Then no collision
        push    bc
        ld      a, [var_player_coord_x]
        add     8
        cp      c
        pop     bc
        jr      C, .false

;;; Player.x > tile.x + 16? Then no collision
        push    bc
        ld      a, [var_player_coord_x]
        add     8
        ld      b, a
        ld      a, c
        add     16
        cp      b
        pop     bc
        jr      C, .false

        ld      a, [var_player_spill1]
        or      COLLISION_RIGHT
        ld      [var_player_spill1], a
.false:
        ret


r3_PlayerTileCoord:
;;; return b - y
;;; return a - x
        ld      a, [var_player_coord_y]
        swap    a               ; Tiles are 16x16, so divide player pos by 16
	and     $0f             ; swap + mask == division by 16
        ld      b, a

        ld      a, [var_player_coord_x]
        swap    a
        and     $0f
        ret


r3_PlayerCheckWallCollisions:
;;; This is manually unrolled, but what we're doing here, is checking a 3x3
;;; square of 16x16 tiles for collisions.

        ld      a, 0
        ld      [var_player_spill1], a

	call    r3_PlayerTileCoord

;;; ...... x - 1, y - 1
        push    af
        push    bc

        dec     a
        dec     b

        ld      hl, var_map_info
        call    MapGetTile

        ld      a, b
        cp      15

        jr      C, .test_xm1_ym1
        jr      .skip_xm1_ym1

.test_xm1_ym1:
        call    r3_PlayerTileCoord
        dec     a
        dec     b
        call    r3_PlayerCheckWallCollisionLeft

        call    r3_PlayerTileCoord
        dec     a
        dec     b
        call    r3_PlayerCheckWallCollisionUp


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
        cp      15

        jr      C, .test_xm1_y
        jr      .skip_xm1_y

.test_xm1_y:
        call    r3_PlayerTileCoord
        dec     a
        call    r3_PlayerCheckWallCollisionLeft


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
        cp      15

        jr      C, .test_xm1_yp1
        jr      .skip_xm1_yp1

.test_xm1_yp1:
        call    r3_PlayerTileCoord
        dec     a
        inc     b
        call    r3_PlayerCheckWallCollisionLeft

        call    r3_PlayerTileCoord
        dec     a
        inc     b
        call    r3_PlayerCheckWallCollisionDown


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
        cp      15

        jr      C, .test_x_ym1
        jr      .skip_x_ym1

.test_x_ym1:
        call    r3_PlayerTileCoord
        dec     b
        call    r3_PlayerCheckWallCollisionUp


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
        cp      15

        jr      C, .test_x_yp1
        jr      .skip_x_yp1

.test_x_yp1:
        call    r3_PlayerTileCoord
        inc     b
        call    r3_PlayerCheckWallCollisionDown

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
        cp      15

        jr      C, .test_xp1_ym1
        jr      .skip_xp1_ym1

.test_xp1_ym1:
        call    r3_PlayerTileCoord
        inc     a
        dec     b
        call    r3_PlayerCheckWallCollisionRight

        call    r3_PlayerTileCoord
        inc     a
        dec     b
        call    r3_PlayerCheckWallCollisionUp

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
        cp      15

        jr      C, .test_xp1_y
        jr      .skip_xp1_y

.test_xp1_y:
        call    r3_PlayerTileCoord
        inc     a
        call    r3_PlayerCheckWallCollisionRight


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
        cp      15

        jr      C, .test_xp1_yp1
        jr      .skip_xp1_yp1

.test_xp1_yp1:
        call    r3_PlayerTileCoord
        inc     a
        inc     b
        call    r3_PlayerCheckWallCollisionRight

        call    r3_PlayerTileCoord
        inc     a
        inc     b
        call    r3_PlayerCheckWallCollisionDown


.skip_xp1_yp1:

        pop     bc
        pop     af


;;; TODO... We want to check collisions based on all tiles around the player.

        ret


r3_PlayerUpdateMovement:
        call    r3_PlayerCheckWallCollisions


;;; try walk left
        ld      a, [var_player_spill1]  ; Load collision mask
        and     COLLISION_LEFT
        ld      [var_player_spill2], a  ; Store part of mask in temp var

        ld      hl, var_player_coord_x
        ld      b, 0

        ldh     a, [var_joypad_raw]
        and     PADF_DOWN | PADF_UP
        ld      c, a

        ldh     a, [var_joypad_raw]
        and     PADF_LEFT
        ld      e, SPRID_PLAYER_WL
        call    PlayerJoypadResponse



;;; try walk right
        ld      a, [var_player_spill1]  ; Load collision mask
        and     COLLISION_RIGHT
        ld      [var_player_spill2], a  ; Store part of mask in temp var

        ld      hl, var_player_coord_x
        ld      b, 1

        ;; c param is unchanged for this next call
        ldh     a, [var_joypad_raw]
        and     PADF_RIGHT
        ld      e, SPRID_PLAYER_WR
        call    PlayerJoypadResponse



;;; try walk down
        ld      a, [var_player_spill1]  ; Load collision mask
        and     COLLISION_DOWN
        ld      [var_player_spill2], a  ; Store part of mask in temp var

	ld      hl, var_player_coord_y
        ld      b, 1

        ldh     a, [var_joypad_raw]
        and     PADF_LEFT | PADF_RIGHT
        ld      c, a

        ldh     a, [var_joypad_raw]
	and     PADF_DOWN
        ld      e, SPRID_PLAYER_WD
        call    PlayerJoypadResponse



;;; try walk up
        ld      a, [var_player_spill1]  ; Load collision mask
        and     COLLISION_UP
        ld      [var_player_spill2], a  ; Store part of mask in temp var

	ld      hl, var_player_coord_y
        ld      b, 0

        ldh     a, [var_joypad_raw]
	and     PADF_UP
        ld      e, SPRID_PLAYER_WU
        call    PlayerJoypadResponse

        ret


;;; SECTION ROM3_CODE


;;; ############################################################################