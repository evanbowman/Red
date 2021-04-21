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


r1_MapExpandRow:
;;; c - row
        ld      e, c

;;; Because tiles are 16x16
        bit     0, e                    ; Determine which row we are in
        ld      a, 0
        jr      Z, .setParity
        ld      a, 1
.setParity:
        ld      [var_room_load_parity], a

        srl     e                       ; 32x32 index as input, downsample
        ld      d, 0

        ;; Map tiles are 16x16. Multiply y by 16 and add, to jump to row.
        swap    e

        ld      hl, var_map_info
        add     hl, de
        ld      d, h
        ld      e, l

        push    de

        ld      hl, var_room_load_slab

        ld      b, 0
.copy:
        ld      a, [var_room_load_parity]
        or      a
        ld      a, [de]
        jr      Z, .evenParity


        sla     a                       ; \ Four tiles per metatile in vram,
        sla     a                       ; / so multiply by four
        add     $90                     ; $90 is the first map tile in vram

        ;; For odd parity, skip to the next two vram indices
        inc     a
        inc     a
        jr      .meta

.evenParity:
        sla     a                       ; \ Four tiles per metatile in vram,
        sla     a                       ; / so multiply by four
        add     $90                     ; $90 is the first map tile in vram

.meta:
        ld      [hl], a

        inc     hl

        inc     a
        ld      [hl], a

        inc     hl

        inc     de

        inc     b
        ld      a, b
        cp      16
        jr      NZ, .copy


        pop     de
        ld      hl, var_room_load_colors

        ld      b, 0

.prepColors:
        ld      a, [de]
        call    r1_SetTileColor

        inc     hl
        ld      a, [de]
        call    r1_SetTileColor

        inc     hl
        inc     de

        inc     b
        ld      a, b
        cp      16
        jr      NZ, .prepColors

        ret


;;; ----------------------------------------------------------------------------


r1_SetTileColor:
;;; a - tile
;;; hl - dest
;;; trashes a
.check_cliff_tile:
        cp      a, 17
        jr      NZ, .check_water_tile1

        ld      a, 4
        ld      [hl], a
        ret

.check_water_tile1:
        cp      a, 18
        jr      NZ, .check_water_tile2

        ld      a, 5
        ld      [hl], a
        ret

.check_water_tile2:
        cp      a, 19
        jr      NZ, .regular_tile

        ld      a, 5
        ld      [hl], a
        ret

.regular_tile:
        ld      a, 2
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------


r1_MapShowRow:
;;; c - row
        push    bc                      ; \
        ld      hl, _SCRN0              ; |
        ld      e, 32                   ; |
        ld      d, 0                    ; |
.loop:                                  ; | seek offset in vram
        ld      a, 0                    ; |
        or      c                       ; |
	jr      Z, .ready               ; |
        dec     c                       ; |
        add     hl, de                  ; |
        jr      .loop                   ; /
.ready:
        pop     bc

        ;; Now, hl contains pointer to correct row in vram

        push    hl
        pop     de
        push    de

        ld      hl, var_room_load_slab

.copy:
        ld      bc, 32
        call    Memcpy

        pop     de

        VIDEO_BANK 1
        ld      bc, 32
        ld      hl, var_room_load_colors
        call    Memcpy
        VIDEO_BANK 0

        ret


;;; ----------------------------------------------------------------------------

;;; Fills var_room_slab with expanded tile data. Then, the vblank handler just
;;; needs to copy stuff.
r1_MapExpandColumn:
        ld      e, c
        bit     0, e
        ld      a, 0
        jr      Z, .setParity
        ld      a, 1
.setParity:
        ld      [var_room_load_parity], a


        ld      hl, var_map_info

        ld      e, c
	srl     e
        ld      d, 0

        add     hl, de
        ld      d, h
        ld      e, l

        push    de

        ld      hl, var_room_load_slab

        ld      b, 0
.copy:
        ld      a, [var_room_load_parity]
        or      a
        ld      a, [de]
        jr      Z, .evenParity

        sla     a                       ; \ Four tiles per metatile in vram,
        sla     a                       ; / so multiply by four
        add     $90                     ; $90 is the first map tile in vram

        inc     a                       ; Inc 1, to second column of 16x16p tile
        jr      .meta

.evenParity:

        sla     a
        sla     a
        add     $90
.meta:

        ld      [hl], a

        inc     a                       ; \ Go to next column tile in 16x16px
        inc     a                       ; / meta tile.

        inc     hl

        ld      [hl], a

        inc     hl

        push    hl                      ; \
        ld      l, 16                   ; |
        ld      h, 0                    ; |
        add     hl, de                  ; | Jump to next row in tile map
        ld      d, h                    ; |
        ld      e, l                    ; |
        pop     hl                      ; /

        inc     b
        ld      a, b
        cp      16
        jr      NZ, .copy



        pop     de
        ld      hl, var_room_load_colors

        ld      b, 0

.prepColors:
        ld      a, [de]
        call    r1_SetTileColor

        inc     hl
        ld      a, [de]
        call    r1_SetTileColor

        inc     hl

        push    hl                      ; \
        ld      l, 16                   ; |
        ld      h, 0                    ; |
        add     hl, de                  ; | Jump to next row in tile map
        ld      d, h                    ; |
        ld      e, l                    ; |
        pop     hl                      ; /

        inc     b
        ld      a, b
        cp      16
        jr      NZ, .prepColors

        ret


;;; ----------------------------------------------------------------------------

r1_MapShowColumn:
;;; c - column

        ld      hl, _SCRN0

        ld      d, 0                    ; \
        ld      e, c                    ; | Jump to proper column
        add     hl, de                  ; /

        ld      de, 32

        ;; Intentionally unrolled. We aren't in rom0, so who cares about
        ;; space :3

        push    hl

        ld      a, [var_room_load_slab+0]
        ld      [hl], a
        add     hl, de                  ; Jump down a full row in vram

        ld      a, [var_room_load_slab+1]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+2]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+3]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+4]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+5]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+6]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+7]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+8]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+9]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+10]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+11]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+12]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+13]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+14]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+15]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+16]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+17]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+18]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+19]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+20]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+21]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+22]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+23]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+24]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+25]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+26]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+27]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+28]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+29]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+30]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_slab+31]
        ld      [hl], a
        add     hl, de

        pop     hl

        VIDEO_BANK 1

        ld      a, [var_room_load_colors+0]
        ld      [hl], a
        add     hl, de                  ; Jump down a full row in vram

        ld      a, [var_room_load_colors+1]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+2]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+3]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+4]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+5]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+6]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+7]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+8]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+9]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+10]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+11]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+12]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+13]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+14]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+15]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+16]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+17]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+18]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+19]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+20]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+21]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+22]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+23]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+24]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+25]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+26]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+27]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+28]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+29]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+30]
        ld      [hl], a
        add     hl, de

        ld      a, [var_room_load_colors+31]
        ld      [hl], a
        add     hl, de

        VIDEO_BANK 0

        ret


;;; ----------------------------------------------------------------------------

r1_WorldMapPalettes::
DB $1B,$4B, $57,$32, $ed,$10, $02,$2c,
DB $1B,$4B, $57,$32, $1f,$21, $02,$2c,
r1_WorldMapPalettesEnd::


r1_WorldMapTemplateTop::
DB $00, $04, $05, $04, $05, $04, $05, $04, $05, $04, $05, $04, $05, $04, $05
DB $04, $05, $04, $05, $01
r1_WorldMapTemplateTopEnd::


r1_WorldMapTemplateRow0::
DB $06, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
DB $08, $08, $08, $08, $07
r1_WorldMapTemplateRow0End::


r1_WorldMapTemplateRow1::
DB $07, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
DB $08, $08, $08, $08, $06
r1_WorldMapTemplateRow1End::


r1_WorldMapTemplateBottom::
DB $03, $05, $04, $05, $04, $05, $04, $05, $04, $05, $04, $05, $04, $05, $04
DB $05, $04, $05, $04, $02
r1_WorldMapTemplateBottomEnd::




r1_WorldMapShowRowPair:
;;; de - first row address
;;; hl - second row address
        push    hl

        ld      hl, r1_WorldMapTemplateRow0
        ld      bc, r1_WorldMapTemplateRow0End - r1_WorldMapTemplateRow0
        call    VramSafeMemcpy

        pop     de

        ld      hl, r1_WorldMapTemplateRow1
        ld      bc, r1_WorldMapTemplateRow1End - r1_WorldMapTemplateRow1
        call    VramSafeMemcpy
        ret


r1_WorldMapShowRooms:
        call    VBlankIntrWait

        RAM_BANK 1

        ld      hl, wram1_var_world_map_info
        ld      de, $9C21       ; Pointer to data in scrn1


        ld      c, 0            ; y counter
.outer_loop:
        ld      b, 0            ; x counter

.inner_loop:
        ld      a, WORLD_MAP_WIDTH
        cp      b
        jr      Z, .outer_loop_step


        ld      a, [rLY]
        cp      152
        jr      Z, .vsync
        jr      .write
.vsync:
        call    VBlankIntrWait
.write:
        ld      a, [hl]
        and     ROOM_VISITED            ; Check for room visited flag
        jr      Z, .skip                ; The tile is empty by default

        ld      a, [hl]
        and     $0f                     ; Lower four bits hold connection mask

        push    af
	ld      a, [var_room_x]
        cp      b
        jr      NZ, .notCurrentRoom
        ld      a, [var_room_y]
        cp      c
        jr      NZ, .notCurrentRoom
        pop     af

.currentRoom:
        add     $18
        jr      .setTile
.notCurrentRoom:
	pop     af
        add     $09                     ; tile start index in vram
.setTile:
        ld      [de], a

        ld      a, 1
        ld	[rVBK], a
        ld      a, $81                  ; palette 1, show over objects
        ld      [de],  a
        ld      a, 0
        ld      [rVBK], a


.skip:
        push    de                      ; \
        ld      d, 0                    ; |
        ld      e, ROOM_DESC_SIZE       ; | Increment room pointer by room size
        add     hl, de                  ; |
        pop     de                      ; /

        inc     de                      ; Increment pointer to vram scrn1 tile

        inc     b
        jr      .inner_loop

.outer_loop_step:
        push    hl                      ; \
        ld      hl, $0e                 ; |
        add     hl, de                  ; | Jump de to next row in scrn1
        ld      d, h                    ; |
        ld      e, l                    ; |
        pop     hl                      ; /

        inc     c
        ld      a, WORLD_MAP_HEIGHT
        cp      c

        jr      NZ, .outer_loop

	ret


r1_WorldMapInitBorder:
        ld      d, 0

        ld      a, 1
        ld	[rVBK], a


        ld      hl, $9c20
.loop:
        ld      [hl], $80

        ld      bc, ($33 - $20)
        add     hl, bc

        ld      [hl], $80
        ld      bc, ($40 - $33)
        add     hl, bc

        inc     d
        ld      a, 16
        cp      d
        jr      NZ, .loop

        ld      a, 0
        ld      [rVBK], a

        ret


r1_WorldMapShow:
        ld      hl, r1_WorldMapTiles
        ld      bc, r1_WorldMapTilesEnd - r1_WorldMapTiles
        ld      de, $9000
        call    VramSafeMemcpy

        ld      hl, r1_WorldMapTemplateTop
        ld      bc, r1_WorldMapTemplateTopEnd - r1_WorldMapTemplateTop
        ld      de, $9C00
        call    VramSafeMemcpy

        call    r1_WorldMapInitBorder

        ld      de, $9C20
        ld      hl, $9C40
        call    r1_WorldMapShowRowPair

        ld      de, $9C60
        ld      hl, $9C80
        call    r1_WorldMapShowRowPair

        ld      de, $9CA0
        ld      hl, $9CC0
        call    r1_WorldMapShowRowPair

        ld      de, $9CE0
        ld      hl, $9D00
        call    r1_WorldMapShowRowPair

        ld      de, $9D20
        ld      hl, $9D40
        call    r1_WorldMapShowRowPair

        ld      de, $9D60
        ld      hl, $9D80
        call    r1_WorldMapShowRowPair

        ld      de, $9DA0
        ld      hl, $9DC0
        call    r1_WorldMapShowRowPair

        ld      de, $9DE0
        ld      hl, $9E00
        call    r1_WorldMapShowRowPair

        ld      hl, r1_WorldMapTemplateBottom
        ld      bc, r1_WorldMapTemplateBottomEnd - r1_WorldMapTemplateBottom
        ld      de, $9E20
        call    VramSafeMemcpy

        call    r1_WorldMapShowRooms

        call    VBlankIntrWait
        ld      b, r1_WorldMapPalettesEnd - r1_WorldMapPalettes
        ld      hl, r1_WorldMapPalettes
        call    LoadBackgroundColors

        ld      hl, $9E12
        ld      a, $09
        ld      [hl], a

        ld      a, 0
        ld      [rWY], a

        ret


;;; ---------------------------------------------------------------------------

;;; Used for indexing into our world map. The map is 18 blocks wide and 16
;;; blocks tall. We assume here that inputs are less than 16. This code will
;;; not work correctly if you pass a y value greater than 15.
r1_l16Mul18Fast:
;;; c - y value less than 16
;;; result in hl
;;; trashes b
        ld      h, 0
        ld      b, 0

;;; swap (aka left-shift by four for the x16 multiplication)
        ld      a, c
        swap    a
        ld      l, a

;;; Then, add twice, to reach x18
        add     hl, bc
        add     hl, bc

        ret


;;; I guess it's not _that_ fast :)
r1_Mul13Fast:
;;; hl - number, result
;;; trashes bc

        push    hl

;;; left-shift by three, then add five times
	ld      a, l
        and     $e0
        swap    a
	srl     a

        sla     h
        sla     h
        sla     h

        or      h
        ld      h, a

        sla     l
        sla     l
        sla     l

        pop     bc

        add     bc
        add     bc
        add     bc
        add     bc
        add     bc

        ret



;;; ----------------------------------------------------------------------------

;;; Collectible items are represented in a room's header by a bitmask. For
;;; easier access, we expand the collectible bitmask into an array of pairs
;;; in ram, where each pair contains {x,y} in the first byte, and a set/unset
;;; flag in the second byte. Places in the bitset are assigned to collectible
;;; tiles in the map data in the order that they appear.


r1_StoreCollectibles:
        RAM_BANK 1

        ld      a, [var_room_x]
        ld      b, a

        ld      a, [var_room_y]
        ld      c, a

        call    r1_LoadRoom

        inc     hl
        inc     hl

        ld      c, 0
        ld      b, 0

        ld      de, var_map_collectibles
        inc     de

.loop:
        sla     c
        ld      a, [de]
        or      c
        ld      c, a

        inc     de
        inc     de
        inc     b
        ld      a, 8
        cp      b
        jr      NZ, .loop

        ld      [hl], c

        ret


r1_ExpandCollectibles:
        ld      a, [var_room_x]
        ld      b, a

        ld      a, [var_room_y]
        ld      c, a

        call    r1_LoadRoom

        inc     hl                      ; \ Collectibles taken bitmask in byte
        inc     hl                      ; / three.

        ld      c, [hl]

        ld      de, var_map_collectibles


        ld      b, 0
.loop:
        inc     de

        sla     c
        jr      C, .set
        jr      .unset

.set:
        ld      a, 1
        jr      .store
.unset:
        ld      a, 0
.store:
        ld      [de], a


        inc     de
        inc     b
        ld      a, 8
        cp      b
        jr      NZ, .loop

        ret


;;; IMPORTANT: assumes that the switchable ram bank, where we store map info, is
;;; already set to bank 1!
r1_InitializeRoom:

        call    r1_ExpandCollectibles
.t2:
        ld      de, var_map_info
        ld      hl, var_map_collectibles

        ld      c, 0            ; y counter
.outer_loop:
        ld      b, 0            ; x counter
.inner_loop:
        ld      a, ROOM_META_WIDTH
        cp      b
        jr      Z, .outer_loop_step

        ld      a, [de]
        call    IsTileCollectible
        jr      NZ, .next

        ld      a, b            ; \ Because rooms are 16x16, this is sufficent
        swap    a               ; | to encode coords into a single byte.
        or      c               ; /

        ld      [hl], a         ; Store x,y in expanded collectible array
        inc     hl

        ld      a, [hl]         ; Test whether collectible has been collected
        inc     hl

        or      a
        jr      NZ, .next

        ld      a, EMPTY_TILE
        ld      [de], a

.next:
        inc     de
        inc     b
        jr      .inner_loop

.outer_loop_step:
        inc     c
        ld      a, ROOM_META_HEIGHT
        cp      c

        jr      NZ, .outer_loop

        ret


;;; ---------------------------------------------------------------------------

;;; IMPORTANT: assumes that the switchable ram bank, where we store map info, is
;;; already set to bank 1!
r1_LoadRoom:
;;; b - room x
;;; c - room y
;;; trashes a, bc
;;; result in hl

;;; Ok, so we have 18 rooms per row, and each room is thirteen bytes. So:
;;; room = &rooms[x * 13 + (y * 18 * 13)];
        push    bc

        ;; hl = y * 18 * 13
        call    r1_l16Mul18Fast
        call    r1_Mul13Fast

        pop     bc
        push    hl

        ;; hl = x * 13
        ld      l, b
        ld      h, 0
        call    r1_Mul13Fast

        pop     bc              ; previous hl to bc

        ;; hl = (x * 13) + (y * 18 * 13)
        add     bc

        ld      bc, wram1_var_world_map_info
        add     bc

        ret


;;; IMPORTANT: assumes that the switchable ram bank, where we store map info, is
;;; already set to bank 1!
r1_IsRoomVisited:
        ret


;;; NOTE: Sets ram bank to bank 1!
r1_SetRoomVisited:
;;; trashes a, hl, bc
	RAM_BANK 1

        ld      a, [var_room_x]
        ld      b, a

        ld      a, [var_room_y]
        ld      c, a

.test:
        call    r1_LoadRoom
        ld      a, [hl]

        or      ROOM_VISITED
        ld      [hl], a

        ret


;;; ----------------------------------------------------------------------------

r1_LoadRoomEntities:
	RAM_BANK 1

        ld      a, [var_room_x]
        ld      b, a
        ld      a, [var_room_y]
        ld      c, a
        call    r1_LoadRoom

        inc     hl              ; \
        inc     hl              ; | skip room header
        inc     hl              ; /

        ld      b, 0
.loop:
        ld      a, b
        cp      ROOM_ENTITYDESC_ARRAY_SIZE / 2
        jr      Z, .endloop

        ld      d, [hl]
        ld      a, 0
        cp      d
        jr      NZ, .test
        jr      .here
.test:
        inc     hl

        push    hl
	push    bc

        ld      a, [hl]
        and     $f0
        ld      c, a
        ld      a, [hl]
        and     $0f
        swap    a
        ld      b, a

        call    r1_SpawnEntity

        pop     bc
        pop     hl
.here:
        inc     hl
        inc     b
        jr      .loop
.endloop:

        ;; TODO: create entities based on contents of room's entity array.

        ret


;;; ----------------------------------------------------------------------------

r1_SpawnEntity:
;;; b - x
;;; c - y
;;; d - typeid
        ld      a, d
        cp      ENTITY_TYPE_BONFIRE
        jr      Z, .spawnBonfire
        cp      ENTITY_TYPE_SPIDER
        jr      Z, .spawnSpider
        cp      ENTITY_TYPE_GREYWOLF
        jr      Z, .spawnGreywolf
        cp      ENTITY_TYPE_GREYWOLF_DEAD
        jr      Z, .spawnGreywolfDead

.spawnBonfire:
        call    r1_BonfireNew
        ret

.spawnSpider:
;;; TODO...
        ret

.spawnGreywolf:
;;; TODO...
        call    r1_GreywolfNew
        ret

.spawnGreywolfDead:
        call    r1_GreywolfDeadNew
        ret


;;; ----------------------------------------------------------------------------

;;; NOTE: assumes that the ram bank is already set to bank 1.
r1_CurrentRoomClearEntities:
        ld      a, [var_room_x]
        ld      b, a
        ld      a, [var_room_y]
        ld      c, a
        call    r1_LoadRoom

        ld      bc, ROOM_HEADER_SIZE
        add     hl, bc

        ld      a, 0
        ld      bc, ROOM_ENTITYDESC_ARRAY_SIZE
        call    Memset

        ret


;;; ---------------------------------------------------------------------------

;;; NOTE: assumes that the ram bank is already set to bank 1.
r1_CurrentRoomAppendEntityDesc:
;;; a - entity x tile coord
;;; c - entity y tile coord
;;; b - entity type
        swap    c
        or      c
        ld      c, a            ; glob x and y into one byte

        push    de
        push    bc
        ld      a, [var_room_x]
        ld      b, a
        ld      a, [var_room_y]
        ld      c, a
        call    r1_LoadRoom
        pop     bc

        inc     hl              ; skip header bytes
        inc     hl
        inc     hl

        ld      d, 0
.loop:
	ld      a, d
        cp      ROOM_ENTITYDESC_ARRAY_SIZE / 2
        jr      Z, .endloop

        ld      a, [hl]
        or      a
        jr      Z, .push
	jr      .next
.push:
        ld      [hl], b         ; Set entity desc type
        inc     hl
        ld      [hl], c         ; Set entity desc coordinate
        jr      .endloop
.next:
        inc     hl
        inc     hl
        inc     d
        jr      .loop
.endloop:

        pop     de
	ret


;;; ---------------------------------------------------------------------------

;;; Called when switching to a different room. Store entities info in memory.
r1_StoreRoomEntities:
	RAM_BANK 1

        call    r1_CurrentRoomClearEntities

        ld      de, var_entity_buffer
        ld      a, [var_entity_buffer_size]

.loop:
        cp      0               ; test loop counter
        jr      Z, .loopEnd
        dec     a
        push    af

        ld      a, [de]         ; \
        ld      h, a            ; |
        inc     de              ; |  entity pointer from buffer into hl
        ld      a, [de]         ; |
        ld      l, a            ; |
        inc     de              ; /

        call    EntityGetType
	ld      a, b
        cp      0
        jr      Z, .skip        ; Do not store the player entity in the room

        inc     hl
        ld      a, [hl]         ; fetch y coordinate
        and     $f0             ; \ convert to tile coordinate (y / 16)
        swap    a               ; /
        ld      c, a

        inc     hl
        inc     hl
        inc     hl

        ld      a, [hl]         ; \
        and     $f0             ; | fetch x coordinate
        swap    a               ; /

        call    r1_CurrentRoomAppendEntityDesc

.skip:

        pop     af
        jr      .loop

.loopEnd:
        ;; TODO: erase contents of room's entity array, serialize entities.

        call    EntityBufferReset

        ret


;;; ---------------------------------------------------------------------------


r1_WorldMapTiles::
DB $00,$00,$00,$00,$00,$00,$00,$1F
DB $00,$1F,$00,$18,$00,$18,$00,$18
DB $00,$00,$00,$00,$00,$00,$F8,$00
DB $F8,$00,$18,$00,$18,$00,$18,$00
DB $00,$18,$00,$18,$00,$18,$00,$F8
DB $00,$F8,$00,$00,$00,$00,$00,$00
DB $18,$00,$18,$00,$18,$00,$1F,$00
DB $1F,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$FF,$00
DB $FF,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$FF
DB $00,$FF,$00,$00,$00,$00,$00,$00
DB $18,$00,$18,$00,$18,$00,$18,$00
DB $18,$00,$18,$00,$18,$00,$18,$00
DB $00,$18,$00,$18,$00,$18,$00,$18
DB $00,$18,$00,$18,$00,$18,$00,$18
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$03,$03,$7F,$7F,$7F,$7F
DB $5D,$5D,$77,$77,$77,$77,$00,$00
DB $FF,$FF,$81,$81,$81,$81,$81,$81
DB $81,$81,$81,$81,$81,$81,$E7,$E7
DB $E7,$E7,$81,$81,$81,$81,$81,$81
DB $81,$81,$81,$81,$81,$81,$FF,$FF
DB $E7,$E7,$81,$81,$81,$81,$81,$81
DB $81,$81,$81,$81,$81,$81,$E7,$E7
DB $FF,$FF,$81,$81,$81,$81,$80,$80
DB $80,$80,$81,$81,$81,$81,$FF,$FF
DB $FF,$FF,$81,$81,$81,$81,$80,$80
DB $80,$80,$81,$81,$81,$81,$E7,$E7
DB $E7,$E7,$81,$81,$81,$81,$80,$80
DB $80,$80,$81,$81,$81,$81,$FF,$FF
DB $E7,$E7,$81,$81,$81,$81,$80,$80
DB $80,$80,$81,$81,$81,$81,$E7,$E7
DB $FF,$FF,$81,$81,$81,$81,$01,$01
DB $01,$01,$81,$81,$81,$81,$FF,$FF
DB $FF,$FF,$81,$81,$81,$81,$01,$01
DB $01,$01,$81,$81,$81,$81,$E7,$E7
DB $E7,$E7,$81,$81,$81,$81,$01,$01
DB $01,$01,$81,$81,$81,$81,$FF,$FF
DB $E7,$E7,$81,$81,$81,$81,$01,$01
DB $01,$01,$81,$81,$81,$81,$E7,$E7
DB $FF,$FF,$81,$81,$81,$81,$00,$00
DB $00,$00,$81,$81,$81,$81,$FF,$FF
DB $FF,$FF,$81,$81,$81,$81,$00,$00
DB $00,$00,$81,$81,$81,$81,$E7,$E7
DB $E7,$E7,$81,$81,$81,$81,$00,$00
DB $00,$00,$81,$81,$81,$81,$FF,$FF
DB $E7,$E7,$81,$81,$81,$81,$00,$00
DB $00,$00,$81,$81,$81,$81,$E7,$E7
DB $FF,$FF,$81,$81,$81,$81,$81,$99
DB $81,$99,$81,$81,$81,$81,$E7,$E7
DB $E7,$E7,$81,$81,$81,$81,$81,$99
DB $81,$99,$81,$81,$81,$81,$FF,$FF
DB $E7,$E7,$81,$81,$81,$81,$81,$99
DB $81,$99,$81,$81,$81,$81,$E7,$E7
DB $FF,$FF,$81,$81,$81,$81,$80,$98
DB $80,$98,$81,$81,$81,$81,$FF,$FF
DB $FF,$FF,$81,$81,$81,$81,$80,$98
DB $80,$98,$81,$81,$81,$81,$E7,$E7
DB $E7,$E7,$81,$81,$81,$81,$80,$98
DB $80,$98,$81,$81,$81,$81,$FF,$FF
DB $E7,$E7,$81,$81,$81,$81,$80,$98
DB $80,$98,$81,$81,$81,$81,$E7,$E7
DB $FF,$FF,$81,$81,$81,$81,$01,$19
DB $01,$19,$81,$81,$81,$81,$FF,$FF
DB $FF,$FF,$81,$81,$81,$81,$01,$19
DB $01,$19,$81,$81,$81,$81,$E7,$E7
DB $E7,$E7,$81,$81,$81,$81,$01,$19
DB $01,$19,$81,$81,$81,$81,$FF,$FF
DB $E7,$E7,$81,$81,$81,$81,$01,$19
DB $01,$19,$81,$81,$81,$81,$E7,$E7
DB $FF,$FF,$81,$81,$81,$81,$00,$18
DB $00,$18,$81,$81,$81,$81,$FF,$FF
DB $FF,$FF,$81,$81,$81,$81,$00,$18
DB $00,$18,$81,$81,$81,$81,$E7,$E7
DB $E7,$E7,$81,$81,$81,$81,$00,$18
DB $00,$18,$81,$81,$81,$81,$FF,$FF
DB $E7,$E7,$81,$81,$81,$81,$00,$18
DB $00,$18,$81,$81,$81,$81,$E7,$E7
r1_WorldMapTilesEnd::
