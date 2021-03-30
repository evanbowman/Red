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


r1_PlayerNew:
        ld      hl, var_player_struct
        ld      bc, var_player_struct_end - var_player_struct
        ld      a, 0
        call    Memset

        ld      a, 0
        ld      [var_player_type], a

        ld      hl, var_player_coord_x
        ld      bc, $81
        call    FixnumInit

        ld      hl, var_player_coord_y
        ld      bc, $75
        call    FixnumInit

        ld      a, SPRID_PLAYER_SD
        ld      [var_player_fb], a

        ld      a, 1
        ld      [var_player_swap_spr], a

        or      SPRITE_SHAPE_T
        ld      [var_player_display_flag], a

        ld      hl, var_player_struct
        ld      de, PlayerUpdate
        call    EntitySetUpdateFn

        ld      de, var_player_struct
        call    EntityBufferEnqueue

        ld      hl, var_player_stamina
        ld      bc, $ffff
        ld      a, $ff
        call    FixnumInit

        ret


;;; ----------------------------------------------------------------------------


;;; Alloc and enqueue an entity, bind texture, misc other boilerplate
r1_EntityInit:
;;; b - x
;;; c - y
;;; return hl - entity pointer
        push    bc

        call    AllocateEntity
        ld      a, 0
        or      h
        or      l
.failedAlloc:
        jr      Z, .failedAlloc

        push    hl
        push    hl
        pop     de
	call    EntityBufferEnqueue

        pop     hl
        pop     bc

        ld      a, 1
        ld      [hl], a

        call    EntitySetPos

        push    hl
        call    AllocateTexture
        cp      0

.texturePoolLeak:
        jr      Z, .texturePoolLeak

        pop     hl
        call    EntitySetTexture

        ret


;;; ----------------------------------------------------------------------------


r1_BonfireNew:
;;; b - x
;;; c - y
        push    bc

        call    r1_EntityInit

        ld      a, SPRID_BONFIRE
        call    EntitySetFrameBase

        ld      a, 1
        call    EntitySetPalette

        ld      a, 0
        call    EntitySetDisplayFlags

        ld      a, ENTITY_TYPE_BONFIRE
        call    EntitySetType

        ld      de, BonfireUpdate
        call    EntitySetUpdateFn

        pop     bc
        call    LcdOff
        srl     b
        srl     b
        srl     b
        dec     b
        dec     b
        ld      a, b
        srl     c
        srl     c
        srl     c
        dec     c
        dec     c
        ld      d, c
        ld      e, $80
        ld      c, 1
        call    SetBackgroundTile32x32
        call    LcdOn
        ret


;;; ----------------------------------------------------------------------------


r1_GreywolfNew:
;;; b - x
;;; c - y
        call    r1_EntityInit

        ld      a, SPRID_GREYWOLF_RUN_L
        call    EntitySetFrameBase

        ld      a, 3
        call    EntitySetPalette

        ld      a, ENTITY_TYPE_GREYWOLF
        call    EntitySetType

        ld      de, GreywolfUpdate
        call    EntitySetUpdateFn

        ld      a, 1 | SPRITE_SHAPE_SQUARE_32
        call    EntitySetDisplayFlags


        ld      bc, GREYWOLF_VAR_SLAB
        call    EntityGetSlack

	push    bc              ; \ bc -> de
        pop     de              ; /


        ld      d, 6
        call    SlabTableFindAnyUnused
        ld      a, c
        ld      [de], a         ; store slab in slack var

        ld      d, 6            ; our weight
        call    SlabTableBind

        ;; FIXME: this scenario would happen if someone tries to put too many
        ;; enemies in the same initial map row.
.failed:
        or      a
        jr      Z, .failed

        ret


;;; ----------------------------------------------------------------------------
