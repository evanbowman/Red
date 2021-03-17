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
;;;  Overworld Scene
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


OverworldSceneEnter:
        call    VBlankIntrWait

        ld      a, 0
	ld	[rLCDC], a

;;; LCD Disabled

        call    LoadOverworldPalettes

        ld      hl, OverlayTiles
        ld      bc, OverlayTilesEnd - OverlayTiles
        ld      de, $9000
        call    Memcpy

        ld      hl, BackgroundTiles
        ld      bc, BackgroundTilesEnd - BackgroundTiles
        ld      de, $8800
        call    Memcpy

        ld      hl, SpriteDropShadow
        ld      bc, SpriteDropShadowEnd - SpriteDropShadow
        ld      de, $87c0
        call    Memcpy

        ld      a, 136
        ld      [rWY], a

        ld      a, 7
        ld      [rWX], a

        call    TestOverlay

;;; TODO: reload map tiles

        ld      a, SCREEN_MODE
        ld      [rLCDC], a

;;; LCD Enabled

        ld      de, OverworldSceneUpdate
        call    SceneSetUpdateFn

        ld      de, OverworldSceneOnVBlank
        call    SceneSetVBlankFn

        jp      UpdateFnResume


;;; ----------------------------------------------------------------------------


OverworldSceneUpdateView:
        ld      a, [var_player_coord_x]
        ld      d, a
        ld      a, 175                  ; 255 - (screen_width / 2)
        cp      d
        jr      C, .xFixedRight
        ld      a, d
        ld      d, 80
	sub     d
        jr      C, .xFixedLeft
        ld      [var_view_x], a

        jr      .setY

.xFixedLeft:
        ld      a, 0
        ld      [var_view_x], a
        jr      .setY

.xFixedRight:
        ld      a, 95                   ; 255 - screen_width
        ld      [var_view_x], a

.setY:
        ld      a, [var_player_coord_y]
        add     a, 8                    ; Menu bar takes up one row, add offset
        ld      d, a
        ld      a, (183 + 19)           ; FIXME: why does this val work?
        cp      d
        jr      C, .yFixedBottom
        ld      a, d
        ld      d, 80
        sub     d
        jr      C, .yFixedTop
        ld      [var_view_y], a

        jr      .done

.yFixedTop:
        ld      a, 0
        ld      [var_view_y], a
        jr      .done

.yFixedBottom:
        ld      a, 121                  ; FIXME: how'd I decide on this number?
        ld      [var_view_y], a

.done:
        ret


;;; ----------------------------------------------------------------------------


OverworldSceneUpdate:
        ld      de, var_entity_buffer
        ld      a, [var_entity_buffer_size]

;;; intentional fallthrough
EntityUpdateLoop:
        cp      0               ; compare loop counter in a
        jr      Z, EntityUpdateLoopDone
        dec     a
        push    af

        ld      a, [de]         ; \
        ld      h, a            ; |
        inc     de              ; |  entity pointer from buffer into hl
        ld      a, [de]         ; |
        ld      l, a            ; |
        inc     de              ; /

	push    de              ; save entity buffer pointer on stack

        ld      e, 13           ; \
        ld      d, 0            ; | jump to position of update routine in entity
        add     hl, de          ; /

        ld      d, [hl]         ; \
        inc     hl              ; | load entity update function ptr
        ld      e, [hl]         ; /

        ld      h, d            ; \
        ld      l, e            ; | Jump to entity update address
        jp      hl              ; /

;;; Now, we could push the stack pointer, thus allowing entity update functions
;;; to be actual functions. For now, entity update functions need to jump back
;;; to this address.
EntityUpdateLoopResume:

        pop     de              ; restore entity buffer pointer
        pop     af              ; restore loop counter
        jr      EntityUpdateLoop

;;; intentional fallthrough
EntityUpdateLoopDone:

;;; If it wasn't for view scrolling, the update and draw stuff could be done in
;;; the same loop.
        call    OverworldSceneUpdateView

        ld      a, 255
        ld      [var_last_entity_y], a
        ld      [var_last_entity_idx], a

        ld      a, 0
        ld      [var_oam_top_counter], a
        ld      a, 38
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
        ld      l, a
        sub     2                       ; Shadows are 16x16, grow from oam end
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
        jp      UpdateFnResume


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


OverworldSceneOnVBlank:
        call    UpdateStaminaBar

;;; Now, this entity buffer code looks pretty nasty. But, we are just doing a
;;; bunch of work upfront, because we do not always need to actually run the
;;; dma. Iterate through each entity, check its swap flag. If the entity
;;; requires a texture swap, map the texture into vram with GDMA.
        ld      a, SPRITESHEET1_ROM_BANK
        ld      [rROMB0], a

        ld      de, var_entity_buffer
        ld      a, [var_entity_buffer_size]

.textureCopyLoop:
        cp      0
        jr      Z, .textureCopyLoopDone
        dec     a
        push    af              ; store loop counter

;;; Even with DMA, we can only fit so many texture copies into the vblank
;;; window. If we think that we're going to exceed the vblank, defer the
;;; copies to the next iteration. The code is just checking entities for
;;; a flag which indicates that a texture copy is needed, so we can just as
;;; easily process the texture copy after the next frame.
        ld      a, [rLY]
        ld      b, a
        ld      a, 153 - 4
        cp      b
        jr      C, .textureCopyLoopTimeout


        ld      a, [de]         ; \
        ld      h, a            ; |
        inc     de              ; |  Fetch entity pointer from entity buffer
        ld      a, [de]         ; /
        ld      l, a            ; Now we have the entity pointer in hl
        inc     de

        ld      a, [hl]         ; load texture swap flag from entity
        or      a
        jr      Z, .noTextureCopy ; swap flag false, nothing to do
        ld      a, 0
        ld      [hl], a         ; We're swapping the texture, zero the flag

        push    de              ; store entity buffer pointer on stack

        ld      d, 0
        ld      e, 1 + FIXNUM_SIZE * 2 + 1
	add     hl, de          ; jump to offset of keyframe in entity

        ld      a, [hl+]
        ld      d, [hl]         ; load frame base
        inc     hl
        ld      b, [hl]
.test:
        add     d               ; keyframe + framebase is spritesheet index
        ld      h, a            ; pass spritesheet index in h
        call    MapSpriteBlock  ; DMA copy the sprite into vram

        pop     de              ; restore entity buffer pointer
.noTextureCopy:

        pop     af              ; restore loop counter
        jr      .textureCopyLoop


.textureCopyLoopTimeout:
        pop     af              ; Was pushed at the top of the loop

;;; intentional fallthrough

.textureCopyLoopDone:
;;; The whole point of the above loop was to copy sprites from various rom banks
;;; into vram. So we should set the rom bank back to one, which is the standard
;;; rom bank for most purposes.
        ld      a, 1
        ld      [rROMB0], a

.done:
        jp      VBlankFnResume


;;; ----------------------------------------------------------------------------
