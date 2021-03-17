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
;;; Overworld Map
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


MapInit:

        ret


;;; ----------------------------------------------------------------------------

MapShowColumn:
;;; c - column
        bit     0, e
        ld      a, 0
        jr      Z, .setParity
        ld      a, 1
.setParity:
        ld      [var_room_load_parity], a


        ld      hl, _SCRN0

        ld      d, 0                    ; \
        ld      e, c                    ; | Jump to proper column
        add     hl, de                  ; /


        push    hl

        ld      hl, var_map_info

        ld      e, c
	srl     e
        ld      d, 0

        add     hl, de
        ld      d, h
        ld      e, l

        pop     hl

;;; TODO...


        ret


;;; ----------------------------------------------------------------------------

MapShowRow:
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

        ld      hl, var_map_info
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

        add     hl, de
        ld      d, h
        ld      e, l

        pop     hl

        ;; Now, de holds a pointer to the map row, and hl holds a pointer to
        ;; the vram row.

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

        push    af
        ld	a, 1                    ; \
	ld	[rVBK], a               ; |
        ld      a, 2                    ; | Set Palette
        ld      [hl], a                 ; |
        ld      a, 0                    ; |
	ld	[rVBK], a               ; /
        pop     af

        inc     hl

        inc     a
        ld      [hl], a

        ld	a, 1                    ; \
	ld	[rVBK], a               ; |
        ld      a, 2                    ; | Set Palette
        ld      [hl], a                 ; |
        ld      a, 0                    ; |
	ld	[rVBK], a               ; /

        inc     hl

        inc     de

        inc     b
        ld      a, b
        cp      16
        jr      NZ, .copy

        ret


;;; ----------------------------------------------------------------------------

;;; Copy map from wram to vram
MapShow:
        ld      c, 0
        ld      hl, var_map_info

.outerLoop:
	ld      b, 0
        ld      a, 16           ; map height
        cp      c
        jr      Z, .done

.innerLoop:
        ld      a, 16           ; map width
        cp      b
        jr      Z, .outerLoopInc

        push    bc

        ld      d, c
        sla     d

        ld      a, [hl]
        sla     a
        sla     a
        ld      e, $90
        add     e
        ld      e, a

        ld      c, 2

        ld      a, b
	sla     a

        push    hl
        call    SetBackgroundTile16x16
        pop     hl

        pop     bc

        inc     b
        inc     hl
	jr      .innerLoop

.outerLoopInc:
	inc     c
        jr      .outerLoop

.done:
        ret


;;; ----------------------------------------------------------------------------

MapGetTile:
;;; hl - map
;;; a - x
;;; b - y
;;; return value in b
;;; trashes hl, c
        swap    b                       ; map is 16 wide
        add     b
        ld      c, a
        ld      b, 0
        add     hl, bc
        ld      b, [hl]
        ret


;;; ----------------------------------------------------------------------------

MapPutSampleData:
        ld      hl, TEST_MAP
        ld      bc, TEST_MAP_END - TEST_MAP
        ld      de, var_map_info
	call    Memcpy

        ret


;;; ----------------------------------------------------------------------------

MapLoad:
        call    MapPutSampleData
        call    MapShow
        ret



;;; ----------------------------------------------------------------------------
