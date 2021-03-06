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
;;;  Entity
;;;
;;;
;;; struct Entity {
;;;     char flags0_; {
;;;         char texture_swap_flag_ : 1;
;;;         char reserved_ : 3;
;;;         char spritesheet_number_ : 4;
;;;     }
;;;     Fixnum coord_y_; // (three bytes)
;;;     Fixnum coord_x_; // (three bytes)
;;;     Animation anim_; // (two bytes)
;;;     char base_frame_;
;;;     char vram_index_; (1)
;;;     char attributes_; (2)
;;;     char display_flags_; {
;;;         char sprite_shape_ : 4;
;;;         char reserved_ : 1;
;;;         char shadow_size_ : 1; (3)
;;;         char shadow_parity_ : 1;
;;;         char has_shadow_ : 1;
;;;     }
;;;     Pointer update_fn_;
;;;     char type_; (modifier 2 bits, 6 type bits)
;;;     Mid message_bus_number_;
;;;     char slack_space_[32 - sizeof(Entity)]; (4)
;;; };
;;;
;;; NOTES:
;;;
;;; (1) ID of the entity's texture in vram.
;;;
;;; (2) GBC hardware attributes, mainly used to set palette.
;;;
;;; (3) Zero for large, one for small.
;;;
;;; (4) Entities occupy 32 bytes in memory. The remaining space after the entity
;;; header may be used by entity implementations for member variables.
;;;
;;; * The type modifier bits were added retrospectively, to support the addition
;;; of persistent properties to the existing entity framework. For example, I
;;; wanted to attach items to dead entities, and identify which items had been
;;; collected by the player. So I used the type modifier bits, as the entity
;;; type byte was already stored persistently when entering/leaving a room.
;;;
;;; * The rendering engine will perform a VRAM copy when it sees that an
;;; entity's texture swap flag is set. The engine then resets the flag. If too
;;; many entities set their swap flags during the same frame, some entities
;;; will not be processed until the next vblank.
;;;
;;; * As base-frame is only a single byte, we are not able to index more than
;;; 256 frames with this variable. Instead, we include some bits in the entity
;;; header, allowing us to select between different spritesheets, each of which
;;; contains up to 256 keyframes. A spritesheet takes up four rom banks, which
;;; must be contiguous!
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


ENTITY_FLAG0_TEXTURE_SWAP       EQU $80
ENTITY_FLAG0_SPRITESHEET_MASK   EQU  $0f


ENTITY_TYPE_MASK                EQU  $3f
ENTITY_TYPE_MODIFIER_MASK       EQU  $c0


ENTITY_ATTR_SPRITE_SHAPE_MASK   EQU  $f0
ENTITY_ATTR_HAS_SHADOW          EQU  $01
;;; I suppose the shadow parity warrants some explanation. Entity drop shadows
;;; flicker in order to achieve translucency via interframe blending. Because
;;; drop-shadows are only visible half of the time anyway, we can fit more
;;; objects in a row without graphical glitches by assigning different 'parity'
;;; attributes, so that their shadows never display during the same frame.
ENTITY_ATTR_SHADOW_EVEN_PARITY  EQU  $02
ENTITY_ATTR_SMALL_SHADOW        EQU  $04
ENTOTY_ATTR_INVISIBLE           EQU  $08



EntityBufferReset:
        xor     a
        ld      [var_entity_buffer_size], a

;;; Because only the entity buffer is allowed to retain pointers to entity
;;; memory, we might as well free everything in bulk.
        ld      hl, var_entity_mem_used
        ld      bc, var_entity_mem_used_end - var_entity_mem_used
        xor     a
        fcall   Memset

;;; Same here, we just cleared all entities, let's free the associated textures.
        ld      hl, var_texture_slots
        ld      bc, var_texture_slots_end - var_texture_slots
        xor     a
        fcall   Memset

;;; And, we can clear out message queues as well.
        ld      hl, var_message_queues
        ld      bc, var_message_queues_end - var_message_queues
        xor     a
        fcall   Memset

        ld      hl, var_message_queue_memory
        ld      bc, var_message_queue_memeory_end - var_message_queue_memory
        xor     a
        fcall   Memset

        ret


;;; ----------------------------------------------------------------------------


EntityAnimationGetKeyframe:
;;; hl - entity
;;; trashes bc
;;; return a - keyframe
        push    hl
        ld      bc, 8
        add     hl, bc
        ld      a, [hl]
        pop     hl
        ret


;;; ----------------------------------------------------------------------------


;;; Set entity keyframe to zero, reset animation timer to zero.
EntityAnimationResetKeyframe:
;;; hl - entity
;;; trashes bc
        push    hl
        ld      bc, 7
        add     hl, bc
        xor     a
        ld      [hl+], a
        ld      [hl], a
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

EntitySetSpritesheet:
;;; hl - entity
;;; b - spritesheet (0 - 16)
;;; trashes a
        ld      a, [hl]
        and     LOW(~ENTITY_FLAG0_SPRITESHEET_MASK)
        or      b
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------

EntitySetTextureSwapFlag:
;;; hl - entity
;;; trashes a
        ld      a, [hl]
        or      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------


EntityAnimationAdvance:
;;; hl - entity
;;; e - frame time
;;; d - anim length
;;; trashes bc, d
;;; return d - true if frame swapped, false otherwise
        push    hl
        ld      bc, 7
        add     hl, bc
        ld      c, e
        fcall   AnimationAdvance
        pop     hl

        ld      d, a                    ; return frameChanged:true/false in d
        or      a
        ret     Z

        ld      a, [hl]
        or      ENTITY_FLAG0_TEXTURE_SWAP
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------

EntityGetFullType:
;;; hl - entity
;;; return a - type
;;; trashes c
;;; preserves hl
        push    hl
        ld      bc, var_player_type - var_player_struct
        add     hl, bc
        ld      a, [hl]
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

EntityGetType:
;;; hl - entity
;;; return a - type
;;; trashes bc
;;; preserves hl
        push    hl
        ld      bc, var_player_type - var_player_struct
        add     hl, bc
        ld      a, [hl]
        and     ENTITY_TYPE_MASK
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

EntitySetTypeModifier:
;;; hl - entity
;;; a - modifier
;;; trashes bc
        push    hl
        ld      bc, var_player_type - var_player_struct
        add     hl, bc

        push    af                        ; \
        ld      a, [hl]                   ; |
        and     ENTITY_TYPE_MASK          ; | Load entity type modifier into b
        ld      b, a                      ; |
        pop     af                        ; /

        swap    a               ; \
        sla     a               ; | Move modifier bits to upper part of register
        sla     a               ; /
        or      b               ; combine with previous type bits in b

        ld      [hl], a
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

EntitySetType:
;;; hl - entity
;;; a - type
;;; trashes bc
        push    hl
        ld      bc, var_player_type - var_player_struct
        add     hl, bc

        push    af                        ; \
        ld      a, [hl]                   ; |
        and     ENTITY_TYPE_MODIFIER_MASK ; | Load entity type modifier into b
        ld      b, a                      ; |
        pop     af                        ; /

        and     ENTITY_TYPE_MASK ; \ Mask out type bits from argument a, combine
        or      b                ; / with previous type modifier bits.

        ld      [hl], a
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

EntityGetFrameBase:
;;; hl - entity
;;; trashes c
;;; b - result
        push    hl
        ld      bc, 9
        add     hl, bc
        ld      b, [hl]
        pop     hl
        ret


;;; ----------------------------------------------------------------------------


EntitySetFrameBase:
;;; hl - entity
;;; a - frame base
;;; trashes bc
        push    hl
        ld      bc, 9
        add     hl, bc
        ld      [hl], a
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

EntitySetTexture:
;;; hl - entity
;;; a - texture
;;; trashes bc
        push    hl
        ld      bc, 10
        add     hl, bc
        ld      [hl], a
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

EntitySetHWGraphicsAttributes:
;;; hl - entity
;;; a - palette
;;; trashes bc
        push    hl
        ld      bc, 11
        add     hl, bc
        ld      [hl], a
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

EntitySetDisplayFlags:
;;; hl - entity
;;; a - display flags
;;; trashes bc
        push    hl
        ld      bc, 12
        add     hl, bc
        ld      [hl], a
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

EntitySetPos:
;;; hl - entity
;;; b - x
;;; c - y
        push    hl
        inc     hl
        xor     a

        ld      [hl], c
        inc     hl
        ld      [hl+], a
        ld      [hl+], a

        ld      [hl], b
        inc     hl
        ld      [hl+], a
        ld      [hl], a
        pop     hl
        ret


;;; ----------------------------------------------------------------------------


EntityGetXPos:
;;; hl - entity
;;; return hl - x position
        ld      bc, 4
        add     hl, bc
        ret


EntityGetYPos:
;;; hl - entity
;;; return hl - y position
        inc     hl
        ret


;;; ----------------------------------------------------------------------------


EntityGetPos:
;;; hl - entity
;;; return b - x
;;; return c - y
        push    hl
        inc     hl
        ld      c, [hl]
        inc     hl
        inc     hl
        inc     hl
        ld      b, [hl]
        pop     hl
        ret


;;; ----------------------------------------------------------------------------


EntityBufferErase:
;;; TODO...
        ret


;;; ----------------------------------------------------------------------------


EntityBufferEnqueue:
;;; de - entity ptr
;;; trashes bc
        ld      a, [var_entity_buffer_size]
        cp      ENTITY_BUFFER_CAPACITY
        jr      Z, .failed

        inc     a
        ld      [var_entity_buffer_size], a
        dec     a

        ld      b, 0
        sla     a

	ld      c, a

        ld      hl, var_entity_buffer
        add     hl, bc

        ld      [hl], d
        inc     hl
        ld      [hl], e

.failed:
        ret


;;; ----------------------------------------------------------------------------

EntityGetUpdateFn:
;;; hl - entity
;;; de - result
        push    hl
        ld      de, 13
        add     hl, de
        ld      d, [hl]
        inc     hl
        ld      e, [hl]
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

EntitySetUpdateFn:
;;; hl - entity
;;; de - update fn address
        push    hl
        push    de
        ld      d, 0
        ld      e, 13
        add     hl, de
        pop     de

        ld      [hl], d
        inc     hl
        ld      [hl], e
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

UpdateEntities::
        ld      de, var_entity_buffer
        ld      a, [var_entity_buffer_size]

;;; intentional fallthrough
EntityUpdateLoop::
        cp      0               ; compare loop counter in a
        ret     Z
        dec     a
        push    af

        ld      a, [de]         ; \
        ld      h, a            ; |
        inc     de              ; |  entity pointer from buffer into hl
        ld      a, [de]         ; |
        ld      l, a            ; |
        inc     de              ; /

	push    de              ; save entity buffer pointer on stack
        push    hl              ; store hl, we will move it to bc later

        ld      e, 13           ; \
        ld      d, 0            ; | jump to position of flags in entity
        add     hl, de          ; /

        ld      d, [hl]         ; \
        inc     hl              ; | load entity update function ptr
        ld      e, [hl]         ; /

        pop     bc              ; load preious hl into bc
        ld      h, d            ; \
        ld      l, e            ; | Jump to entity update address
        jp      hl              ; /

;;; Now, we could push the stack pointer, thus allowing entity update functions
;;; to be actual functions. For now, entity update functions need to jump back
;;; to this address.
EntityUpdateLoopResume::

        pop     de              ; restore entity buffer pointer
        pop     af              ; restore loop counter
        jr      EntityUpdateLoop


;;; ----------------------------------------------------------------------------

DrawEntitiesSetup:
        xor     a
        ld      [var_oam_top_counter], a
        ld      a, 40
        ld      [var_oam_bottom_counter], a
        ret


;;; ----------------------------------------------------------------------------

FIXMEReallyBadHackManuallyDrawPlayerShadow:
        ;; Really bad hack: The player animation is the most complicated of all,
        ;; sometimes I need to shift the origin of the animation in order to get
        ;; large keyframes to fit into a 32x32 window. The entity header does
        ;; not offer any mechanism for setting the offset of an entity's drop
        ;; shadow, so I disabled the shadow on the Player's entity, and I
        ;; manually draw it using the location of the player's anchor variables.
        ;; FIXME: ultimately, the solution would be to put additional variables
        ;; into the entity header, whereby the origin of the dropshadow with
        ;; respect to the entity center could be adjusted.
        ldh     a, [hvar_view_y]
        ld      d, a
        ld      a, [var_player_anchor_y]
        sub     d
        add     17              ; shadow offset from spr top
        ld      c, a

        ldh     a, [hvar_view_x]
        ld      d, a
        ld      a, [var_player_anchor_x]
        sub     d
        ld      b, a

        ld      a, [var_oam_bottom_counter]
        sub     2
        ld      l, a
        ld      [var_oam_bottom_counter], a
        ld      e, $7c
        ld      d, 2
        fcall   ShowSpriteSquare16
        ret


;;; ----------------------------------------------------------------------------


DrawEntitiesSimple:
        xor     a
        ld      [var_oam_top_counter], a
        ld      a, 40
        ld      [var_oam_bottom_counter], a
;;; Fallthrough

DrawEntities:

        ld      a, [hvar_shadow_state]
        xor     $ff
        ld      [hvar_shadow_state], a
        cp      $ff
        ld      a, 1
        jr      NZ, .skip
        xor     a
.skip:
        ld      [hvar_shadow_parity], a

        fcallc  Z, FIXMEReallyBadHackManuallyDrawPlayerShadow


        ld      a, 255
        ld      [var_last_entity_y], a
        ld      [var_last_entity_idx], a

        ld      de, var_entity_buffer
        ld      a, [var_entity_buffer_size] ; loop counter
EntityDrawLoop:
        cp      0               ; compare loop counter in a
        jp      Z, EntityDrawLoopDone
        dec     a
        push    af

        ld      a, [de]         ; fetch entity pointer from buffer
        ld      h, a
        inc     de
        ld      a, [de]
        ld      l, a            ; entity pointer now in hl
        inc     de

	push    de              ; save entity buffer pointer on stack



	inc     hl              ; hl now points to y coord in entity struct

        ldh     a, [hvar_view_y]
        ld      d, a
        ld      a, [hl+]         ; this is fine, due to layout of fixnum
        sub     d
        ld      c, a

;;; This is a bit delicate. We should really be adding the size of the fixnum
;;; field. But that would be a bunch of loads and an add instruction, so it
;;; wouldn't necessarily be faster.
        inc     hl                      ; jump to location of x coord in entity
        inc     hl                      ; fixnum occupies 3 bytes (see hl+ above)

        ldh     a, [hvar_view_x]
        ld      d, a
        ld      a, [hl]
        sub     d
        ld      b, a

;;; Now, we want to jump to the location of the texture offset in the entity
;;; struct.
;;; See entity struct docs at top of file.
;;; ptr + sizeof(Fixnum) + sizeof(Animation) + 1

        ld      d, 0
        ld      e, FIXNUM_SIZE + 2 + 1
        add     hl, de

        ld      e, [hl]                 ; Load texture index from struct
        inc     hl
        ld      d, [hl]                 ; Load palette index from struct
        inc     hl
;;; Each Sprite is 32x32, and our tile sizes are 8x16. So, to go from
;;; A sprite texture index to a starting tile index, we simply need to move
;;; the lower four bits of the index to the upper four bits (i.e. n x 16).
        swap    e                       ; ShowSprite... uses e as a start tile.

        push    hl                      ; Store entity pointer
        ldh     a, [hvar_overlay_y_offset] ; \ If the sprite is behind the
        cp      c                          ; | overlay, hide. Overlay color 0
        jr      C, .putSpriteFinished      ; / will not cover the sprite.

        ld      a, [hl]                 ; Load flags
        and     ENTITY_ATTR_SPRITE_SHAPE_MASK

        ;; NOTE: I thought about re-writing this as a jump table, but with only
        ;; four cases, it would be slower and trash a bunch of registers.
        cp      SPRITE_SHAPE_TALL_16_32
        jr      Z, .putTall16x32Sprite
        cp      SPRITE_SHAPE_T
        jr      Z, .putTSprite
        cp      SPRITE_SHAPE_SQUARE_32
        jr      Z, .putSquare32Sprite
        cp      SPRITE_SHAPE_SQUARE_16
        jr      Z, .putSquare16Sprite

        jr      .putSpriteFinished ; Invisible

.putSquare16Sprite:
        ld      a, [var_oam_top_counter]
        ld      l, a
        add     2               ; Uses two oam
        ld      [var_oam_top_counter], a
        push    bc
        ld      a, e            ; \ Most of the ShowSprite... implementations
        add     10              ; | adjust for the empty tiles that they skip,
        ld      e, a            ; / but ShowSpriteSquare16 does not. Skip row0+1

        ld      a, c            ; \ Because we skipped the first row of Oam,
        add     8              ; | jump the y coordinate down one row.
        ld      c, a            ; /
        fcall   ShowSpriteSquare16
        pop     bc
        jr      .putSpriteFinished

.putTSprite:
	ld      a, [var_oam_top_counter]
        ld      l, a                    ; Oam offset
        add     6                       ; top row uses 2 oam, bottom row uses 4
        ld      [var_oam_top_counter], a
        push    bc
        fcall   ShowSpriteT
        pop     bc
        jr      .putSpriteFinished

.putSquare32Sprite:
        ld      a, [var_oam_top_counter]
        ld      l, a                    ; Oam offset
        add     8                       ; 32x32 sprite uses 8 oam
        ld      [var_oam_top_counter], a
        push    bc
        fcall   ShowSpriteSquare32
        pop     bc
        jr      .putSpriteFinished

.putTall16x32Sprite:
        ld      a, [var_oam_top_counter]
        ld      l, a                    ; Oam offset
        add     4                       ; 16x32 sprite uses 4 oam
        ld      [var_oam_top_counter], a
        push    bc
        fcall   ShowSpriteTall16x32
        pop     bc

.putSpriteFinished:
        pop     hl                      ; Restore entity pointer

;;; Now, check whether the current entity's y value is greater than the previous
;;; entity's y value. If so, swap their entries in the entity buffer. Not as
;;; precise as a real sorting algorithm, but uses less cpu, and at 60fps, the
;;; entity buffer converges to a point where it's sorted by y value pretty
;;; quickly.
	ld      a, [var_last_entity_y]
	cp      c
        jr      C, EntitySwap
EntitySwapResume:

;;; Drop shadow
        ld      a, c
        ld      [var_last_entity_y], a

        ld      a, [hl]                ; \
        and     ENTITY_ATTR_HAS_SHADOW ; | Skip shadow rendering if shadow attr
        jr      Z, .skipShadow         ; /

        ld      a, [hl]                        ; \
        and     ENTITY_ATTR_SHADOW_EVEN_PARITY ; |
        srl     a                              ; | | shift bit(1) to lsb
        ld      d, a                           ; | If entity shadow parity !=
        ld      a, [hvar_shadow_parity]        ; | current parity, skip.
        cp      d                              ; |
        jr      NZ, .skipShadow                ; /

        ld      a, [hl]
        and     ENTITY_ATTR_SMALL_SHADOW
        jr      Z, .fullsizeShadow

.smallShadow:
        ld      a, c
        add     10
        ld      c, a

        ld      a, b
        add     4
        ld      b, a

        ld      a, [var_oam_bottom_counter]
        dec     a
        ld      l, a
        ld      [var_oam_bottom_counter], a

        ld      e, $7a
        ld      d, 2
        fcall   ShowSpriteSingle

        jr      .afterShadow

.fullsizeShadow:
        ld      a, c
        add     17
        ld      c, a

	ld      a, [var_oam_bottom_counter]
        sub     2                       ; Shadows are 16x16, grow from oam end
        ld      l, a
        ld      [var_oam_bottom_counter], a
        ld      e, $7c
        ld      d, 2
        fcall   ShowSpriteSquare16

.skipShadow:
.afterShadow:

        pop     de              ; restore entity buffer pointer
        pop     af              ; restore loop counter
        ld      [var_last_entity_idx], a
        jp      EntityDrawLoop

EntityDrawLoopDone:

        ld      a, [var_oam_top_counter]
        ld      b, a
        ld      l, b
        fcall   OamLoad

	ld      c, 0

.unusedOAMZeroLoop:
        ld      a, [var_oam_bottom_counter]
        cp      b
        ret     Z

;;; Move unused object to (0,0), effectively hiding it
        ld      [hl], c
        inc     hl
        ld      [hl], c
        inc     hl
        inc     hl
        inc     hl

        inc     b
        jr      .unusedOAMZeroLoop



EntitySwap:
;;; This entity swap code may not be very efficient, but it should happen
;;; infrequently.
        ld      a, [var_last_entity_idx]
        ld      d, 255                  ; Using 255 as a null index (before array beginning)
        cp      d
        jr      Z, EntitySwapResume
        push    hl
        ld      d, a
        inc     d
        ld      a, [var_entity_buffer_size]
        sub     d
        ld      hl, var_entity_buffer
        sla     a                       ; Double a, b/c a pointer is two bytes
        ld      e, a
        ld      d, 0

        add     hl, de

;;; Now, we just need to swap pointers in the array.

        push    bc
        push    hl
        ld      a, [hl+]
        ld      d, a
        ld      a, [hl+]
        ld      e, a                    ; Now we have the first value in de

        ld      a, [hl]
        ld      b, a
        ld      a, d
        ld      [hl+], a
        ld      a, [hl]
        ld      c, a
        ld      a, e
        ld      [hl], a

        pop     hl

        ld      a, b
        ld      [hl+], a
        ld      a, c
        ld      [hl], c

        pop     bc
        pop     hl
        jp      EntitySwapResume


;;; ----------------------------------------------------------------------------

Mul32:
;;; bc - number to shift by five
;;; trashes d
        ld      d, c
        ;; Right-shift contents of c by three, so upper five bits are now lsb
        srl     d
        srl     d
        srl     d

        ;; swap upper and lower nibbles in b, then shift left, and mask off upper three
        swap    b
        sla     b
        ld      a, b
        and     $e0

        ;; combine with the five bits from lower byte
        or      d
        ld      b, a

        ld      a, c
        swap    a
        sla     a
        and     $e0
        ld      c, a

        ret


;;; ----------------------------------------------------------------------------


AllocateEntity:
;;; hl - return value
;;; trashes bc
        ld      bc, 0

        ld      hl, var_entity_mem_used
.loop:
        ld      a, c
        cp      ENTITY_BUFFER_CAPACITY
        jr      Z, .failed

        ld      a, [hl]
        or      a
        jr      Z, .found
        jr      .next

.found:
        ld      a, 1
        ld      [hl], a         ; set entity mem used

        ;; Now, we want to multiply bc by the size of an entity (32)...
	fcall   Mul32

        ld      hl, var_entity_mem
        add     hl, bc

        push    hl

        ld      bc, 32
        xor     a
        fcall   Memset

        pop     hl

        push    hl                ; \
        push    hl                ; |
        fcall   MessageQueueAlloc ; |
        pop     hl                ; |
        ld      bc, 16            ; | Bind message queue to entity
        add     hl, bc            ; |
        ld      [hl], a           ; |
        pop     hl                ; /

        ret

.next:
        inc     hl
        inc     c
        jr      .loop

.failed:
        ld      hl, 0
        ret


;;; ----------------------------------------------------------------------------


EntityGetMessageQueue:
;;; hl - entity
;;; trashes bc
;;; return a - queue
        push    hl
        ld      bc, 16
        add     hl, bc
        ld      a, [hl]
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

EntityMessageQueueClear:
;;; hl - entity
        push    hl
        fcall   EntityGetMessageQueue
        fcall   MessageQueueLoad
        fcall   MessageQueueClear
        pop     hl
        ret


;;; ----------------------------------------------------------------------------


;;; Entities are 32 bytes in size, and the entity header only consumes about
;;; half of the reserved space. The rest of the slack space may be used by
;;; various entity implementations.
EntityGetSlack:
;;; hl - entity
;;; bc - offset into slack space array
;;; return bc - result (pointer to slack space)
;;; preserves a (important! some code probably depends on this.)
        push    hl
        add     hl, bc
        ld      bc, 17
        add     hl, bc
        ld      b, h
        ld      c, l
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

;;; A somewhat specialized helper function, for safely exiting a message loop
;;; and jumping to a new scene. If you jump out of a message loop before it
;;; completes, messages will still be left in the queue. We clear the entity's
;;; message queue, and then jump out of the loop, to begin executing the next
;;; scene. Most entities respond to at least one message type which requires a
;;; scene change (interacting with a dead enemy, for example, switches to a
;;; scene that opens the scavenge menu, interacting with a bonfire switches to
;;; a scene that opens the inventory, etc.).
EntityMessageLoopJumpToScene:
;;; hl - entity
;;; de - scene
        push    de
        fcall   EntityMessageQueueClear
        pop     de
        fcall   SceneSetUpdateFn
        jp      SceneUnwind


;;; ----------------------------------------------------------------------------
