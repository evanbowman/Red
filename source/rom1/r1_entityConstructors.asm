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


r1_EnemyInitStamina:
        ;; NOTE: assumes that the stamina fixnum is in the same locate in each
        ;; entity struct.
        push    hl
        ld      bc, GREYWOLF_VAR_STAMINA
        fcall   EntityGetSlack

        push    bc              ; \ bc -> hl
        pop     hl              ; /

        ld      bc, $ffff
        ld      a, $ff
        fcall   FixnumInit

        pop     hl

        ret


r1_PlayerNew:
        ld      hl, var_player_struct
        ld      bc, var_player_struct_end - var_player_struct
        ld      a, 0
        fcall   Memset

        ld      a, 0
        ld      [var_player_type], a

        ld      hl, var_player_coord_x
        ld      bc, $37
        fcall   FixnumInit

        ld      hl, var_player_coord_y
        ld      bc, $65
        fcall   FixnumInit

        ld      hl, var_player_coord_y  ; \
        ld      de, var_player_anchor_y ; | Set View Anchor
        ld      bc, FIXNUM_SIZE * 2     ; |
        fcall   Memcpy                  ; /

        ld      a, SPRID_PLAYER_SD
        ld      [var_player_fb], a

        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

        ld      a, SPRITE_SHAPE_T
        ld      [var_player_display_flag], a

        ld      hl, var_player_struct
        ld      de, PlayerUpdate
        fcall   EntitySetUpdateFn

        ld      de, var_player_struct
        fcall   EntityBufferEnqueue

        ld      hl, var_player_stamina
        ld      bc, $ffff
        ld      a, $ff
        fcall   FixnumInit

        ret


;;; ----------------------------------------------------------------------------


;;; Alloc and enqueue an entity, bind texture, misc other boilerplate
r1_EntityNew:
;;; b - x
;;; c - y
;;; e - type modifier bits
;;; return hl - entity pointer
        push    de
        push    bc

        fcall   AllocateEntity
        ld      a, 0
        or      h
        or      l
.failedAlloc:
        jr      Z, .failedAlloc

        push    hl
        push    hl
        pop     de
	fcall   EntityBufferEnqueue

        pop     hl
        pop     bc

        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [hl], a

        fcall   EntitySetPos

        push    hl
        fcall   AllocateTexture
        cp      0

.texturePoolLeak:
        jr      Z, .texturePoolLeak

        pop     hl
        fcall   EntitySetTexture

        pop     de              ; \
        swap    e               ; | Retrieve type modifier, move to lower two
        srl     e               ; | bits of register e.
        srl     e               ; /
        ld      a, e
	call    EntitySetTypeModifier

        ret


;;; ----------------------------------------------------------------------------


r1_BonfireNew:
;;; b - x
;;; c - y
;;; e - type modifier bits
        push    bc

        fcall   r1_EntityNew

        ld      a, SPRID_BONFIRE
        fcall   EntitySetFrameBase

        ld      a, 1
        fcall   EntitySetHWGraphicsAttributes

        ld      a, 0
        fcall   EntitySetDisplayFlags

        ld      a, ENTITY_TYPE_BONFIRE
        fcall   EntitySetType

        ld      de, BonfireUpdate
        fcall   EntitySetUpdateFn

	fcall   VBlankIntrWait  ; required b/c we're setting map tiles
        pop     bc
        srl     b
        srl     b
        srl     b
        dec     b
        dec     b               ; lol wtf does this code do? I don't remember
        ld      a, b            ; I think it's doing a division of some kind
        srl     c               ; TODO: add comments.
        srl     c
        srl     c
        dec     c
        dec     c
        ld      d, c
        ld      e, $80
        ld      c, 1
        fcall   SetBackgroundTile32x32
        ret


;;; ----------------------------------------------------------------------------


r1_GreywolfNew:
;;; b - x
;;; c - y
;;; e - type modifier bits
        fcall   r1_EntityNew

        ld      a, SPRID_GREYWOLF_RUN_L
        fcall   EntitySetFrameBase

        ld      a, 3
        fcall   EntitySetHWGraphicsAttributes

        ld      a, ENTITY_TYPE_GREYWOLF
        fcall   EntitySetType

        ld      de, GreywolfUpdate
        fcall   EntitySetUpdateFn

        ld      a, ENTITY_ATTR_HAS_SHADOW | ENTITY_ATTR_SHADOW_EVEN_PARITY | SPRITE_SHAPE_SQUARE_32
        fcall   EntitySetDisplayFlags


        ld      bc, GREYWOLF_VAR_SLAB
        fcall   EntityGetSlack

	push    bc              ; \ bc -> de
        pop     de              ; /

        push    hl
        push    de
        ld      d, 6
        fcall   SlabTableFindAnyUnused
        ld      a, c
        pop     de
        ld      [de], a         ; store slab in slack var

        ld      d, 6            ; our weight
        fcall   SlabTableBind
        pop     hl

	fcall   r1_EnemyInitStamina

        ret


;;; ----------------------------------------------------------------------------

r1_RabbitNew:
;;; b - x
;;; c - y
;;; e - type modifier bits

        fcall   r1_EntityNew

        ld      a, SPRID_RABBIT_R
        fcall   EntitySetFrameBase

        ld      a, 3
        fcall   EntitySetHWGraphicsAttributes

        ld      a, ENTITY_TYPE_RABBIT
        fcall   EntitySetType

        ld      de, RabbitUpdate
        fcall   EntitySetUpdateFn

        ld      a, SPRITE_SHAPE_SQUARE_16 | ENTITY_ATTR_HAS_SHADOW | ENTITY_ATTR_SHADOW_EVEN_PARITY | ENTITY_ATTR_SMALL_SHADOW
        fcall   EntitySetDisplayFlags

        ;; TODO: assign slab...

        ret


;;; ----------------------------------------------------------------------------

r1_RabbitDeadNew:
;;; b - x
;;; c - y
;;; e - type modifier bits

        fcall   r1_EntityNew

        ld      a, SPRID_RABBIT_DEAD_R
        fcall   EntitySetFrameBase

        ld      a, 3
        fcall   EntitySetHWGraphicsAttributes

        ld      a, ENTITY_TYPE_RABBIT_DEAD
        fcall   EntitySetType

        ld      de, RabbitUpdateDead
        fcall   EntitySetUpdateFn

        ld      a, SPRITE_SHAPE_SQUARE_16
        fcall   EntitySetDisplayFlags
	ret


;;; ----------------------------------------------------------------------------


r1_SpiderNew:
;;; b - x
;;; c - y
;;; e - type modifier bits

        fcall   r1_EntityNew

        ld      a, SPRID_SPIDER_L
        fcall   EntitySetFrameBase

        ld      a, 2
        fcall   EntitySetHWGraphicsAttributes

        ld      a, ENTITY_TYPE_SPIDER
        fcall   EntitySetType

        ld      de, SpiderUpdate
        fcall   EntitySetUpdateFn

        ld      a, SPRITE_SHAPE_SQUARE_16 | ENTITY_ATTR_HAS_SHADOW | ENTITY_ATTR_SHADOW_EVEN_PARITY | ENTITY_ATTR_SMALL_SHADOW
        fcall   EntitySetDisplayFlags

        ld      bc, SPIDER_VAR_SLAB
        fcall   EntityGetSlack

	push    bc              ; \ bc -> de
        pop     de              ; /

        push    hl
        push    de
        ld      d, 6
        fcall   SlabTableFindAnyUnused
        ld      a, c
        pop     de
        ld      [de], a         ; store slab in slack var

        ld      d, 2            ; our weight
        fcall   SlabTableBind
        pop     hl

	fcall   r1_EnemyInitStamina

        ret


;;; ----------------------------------------------------------------------------

r1_SpiderDeadNew:
;;; b - x
;;; c - y
;;; e - type modifier bits
        push    bc              ; store x, y

	fcall   r1_EntityNew

        ld      a, ENTITY_TYPE_SPIDER_DEAD
        fcall   EntitySetType

	ld      de, SpiderUpdateDead
        fcall   EntitySetUpdateFn

        ld      a, SPRITE_SHAPE_INVISIBLE
        fcall   EntitySetDisplayFlags

        pop     bc              ; restore x, y

        ;; FIXME: I don't really like this tile effect. The enemy isn't
        ;; constrained to a grid, so sometimes the tile spawns off-center, and
        ;; it looks unprofessional.
        fcall   VBlankIntrWait  ; reqd. because we're setting a tile
        srl     b
        srl     b
        srl     b
        srl     c
        srl     c
        srl     c
        ld      a, b
        ld      d, c
        ld      e, $ec
        ld      c, ($08 | $02)
        fcall   SetBackgroundTile16x16

        ret


;;; ----------------------------------------------------------------------------


r1_BoarNew:
;;; b - x
;;; c - y
;;; e - type modifier bits
        fcall   r1_EntityNew

        ld      a, SPRID_BOAR_L
        fcall   EntitySetFrameBase

        ld      a, 3
        fcall   EntitySetHWGraphicsAttributes

        ld      a, ENTITY_TYPE_BOAR
        fcall   EntitySetType

        ld      de, BoarUpdate
        fcall   EntitySetUpdateFn

        ld      a, ENTITY_ATTR_HAS_SHADOW | ENTITY_ATTR_SHADOW_EVEN_PARITY | SPRITE_SHAPE_SQUARE_32
        fcall   EntitySetDisplayFlags

        ld      bc, BOAR_VAR_SLAB
        fcall   EntityGetSlack

	push    bc              ; \ bc -> de
        pop     de              ; /

        push    hl
        push    de
        ld      d, 6
        fcall   SlabTableFindAnyUnused
        ld      a, c
        pop     de
        ld      [de], a         ; store slab in slack var

        ld      d, 6            ; our weight
        fcall   SlabTableBind
        pop     hl

	fcall   r1_EnemyInitStamina

        ret


;;; ----------------------------------------------------------------------------

r1_GreywolfDeadNew:
;;; b - x
;;; c - y
;;; e - type modifier bits
        fcall   r1_EntityNew

        ld      a, SPRID_GREYWOLF_DEAD_L
        fcall   EntitySetFrameBase

        ld      a, 4
        fcall   EntitySetHWGraphicsAttributes

        ld      a, ENTITY_TYPE_GREYWOLF_DEAD
        fcall   EntitySetType

        ld      de, GreywolfUpdateDead
        fcall   EntitySetUpdateFn

        ld      a, SPRITE_SHAPE_T
        fcall   EntitySetDisplayFlags

        ;; TODO: add ourself to slab table...

        ret


;;; ----------------------------------------------------------------------------

r1_BoarDeadNew:
;;; b - x
;;; c - y
;;; e - type modifier bits
        fcall   r1_EntityNew

        ld      a, SPRID_BOAR_DEAD_L
        fcall   EntitySetFrameBase

        ld      a, 4
        fcall   EntitySetHWGraphicsAttributes

        ld      a, ENTITY_TYPE_BOAR_DEAD
        fcall   EntitySetType

        ld      de, BoarUpdateDead
        fcall   EntitySetUpdateFn

        ld      a, SPRITE_SHAPE_T
        fcall   EntitySetDisplayFlags

        ret


;;; ----------------------------------------------------------------------------
