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
;;;     char texture_swap_flag_;
;;;     Fixnum coord_y_; // (three bytes)
;;;     Fixnum coord_x_; // (three bytes)
;;;     Animation anim_; // (two bytes)
;;;     char base_frame_;
;;;     char vram_index_;
;;;     char attributes_;
;;;     char flags_; {
;;;         char sprite_shape_ : 4;
;;;         char reserved_ : 3;
;;;         char has_shadow_ : 1;
;;;     }
;;;     Pointer update_fn_;
;;;     char type_;
;;; };
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


EntityBufferReset:
        ld      a, 0
        ld      [var_entity_buffer_size], a

;;; Because only the entity buffer is allowed to retain pointers to entity
;;; memory, we might as well free everything in bulk.
        ld      hl, var_entity_mem_used
        ld      bc, var_entity_mem_used_end - var_entity_mem_used
        ld      a, 0
        call    Memset

;;; Same here, we just cleared all entities, let's free the associated textures.
        ld      hl, var_texture_slots
        ld      bc, var_texture_slots_end - var_texture_slots
        ld      a, 0
        call    Memset

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
        call    AnimationAdvance
        pop     hl

        ld      d, a                    ; return frameChanged:true/false in d
        or      a
        jr      Z, .done

        ld      a, [hl]
        or      ENTITY_TEXTURE_SWAP_FLAG
        ld      [hl], a

.done:
        ret


;;; ----------------------------------------------------------------------------

EntityGetType:
;;; hl - entity
;;; return b - type
;;; trashes c
;;; preserves hl
        push    hl
        ld      bc, var_player_type - var_player_struct
        add     hl, bc
        ld      b, [hl]
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

EntitySetPalette:
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
        ld      a, 0

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


DrawEntities:
        ld      a, 255
        ld      [var_last_entity_y], a
        ld      [var_last_entity_idx], a

        ld      a, 0
        ld      [var_oam_top_counter], a
        ld      a, 40
        ld      [var_oam_bottom_counter], a
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

        ld      a, [var_view_y]
        ld      d, a
        ld      a, [hl+]         ; this is fine, due to layout of fixnum
        sub     d
        ld      c, a

;;; This is a bit delicate. We should really be adding the size of the fixnum
;;; field. But that would be a bunch of loads and an add instruction, so it
;;; wouldn't necessarily be faster.
        inc     hl                      ; jump to location of x coord in entity
        inc     hl                      ; fixnum occupies 3 bytes (see hl+ above)

        ld      a, [var_view_x]
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

        ld      a, [hl]                 ; Load flags
        push    hl                      ; Store entity pointer

        and     $f0
        ld      h, SPRITE_SHAPE_TALL_16_32
        cp      h
        jr      Z, .putTall16x32Sprite

        ld      h, SPRITE_SHAPE_T
        cp      h
        jr      Z, .putTSprite

        ld      h, SPRITE_SHAPE_SQUARE_32
        cp      h
        jr      Z, .putSquare32Sprite

        jr      .putSpriteFinished

.putTSprite:
	ld      a, [var_oam_top_counter]
        ld      l, a                    ; Oam offset
        add     6                       ; top row uses 2 oam, bottom row uses 4
        ld      [var_oam_top_counter], a
        push    bc
        call    ShowSpriteT
        pop     bc
        jr      .putSpriteFinished

.putSquare32Sprite:
        ld      a, [var_oam_top_counter]
        ld      l, a                    ; Oam offset
        add     8                       ; 32x32 sprite uses 8 oam
        ld      [var_oam_top_counter], a
        push    bc
        call    ShowSpriteSquare32
        pop     bc
        jr      .putSpriteFinished

.putTall16x32Sprite:
        ld      a, [var_oam_top_counter]
        ld      l, a                    ; Oam offset
        add     4                       ; 16x32 sprite uses 4 oam
        ld      [var_oam_top_counter], a
        push    bc
        call    ShowSpriteTall16x32
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

        ld      a, [hl]
        and     $0f
        or      a
        jr      Z, .skipShadow

        ld      a, c
        add     17
        ld      c, a

	ld      a, [var_oam_bottom_counter]
        sub     2                       ; Shadows are 16x16, grow from oam end
        ld      l, a
        ld      [var_oam_bottom_counter], a
        ld      e, $7c
        ld      d, 2
        call    ShowSpriteSquare16

.skipShadow:

        pop     de              ; restore entity buffer pointer
        pop     af              ; restore loop counter
        ld      [var_last_entity_idx], a
        jp      EntityDrawLoop

EntityDrawLoopDone:

        ld      a, [var_oam_top_counter]
        ld      b, a
        ld      l, b
        call    OamLoad

	ld      c, 0

.unusedOAMZeroLoop:
        ld      a, [var_oam_bottom_counter]
        cp      b
        jr      Z, .done

;;; Move unused object to (0,0), effectively hiding it
        ld      [hl], c
        inc     hl
        ld      [hl], c
        inc     hl
        inc     hl
        inc     hl

        inc     b
        jr      .unusedOAMZeroLoop

.done:
        ret



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
	call    Mul32

        ld      hl, var_entity_mem
        add     hl, bc

        push    hl

        ld      bc, 32
        ld      a, 0
        call    Memset

        pop     hl

        ret

.next:
        inc     hl
        inc     c
        jr      .loop

.failed:
        ld      hl, 0
        ret


;;; ----------------------------------------------------------------------------
