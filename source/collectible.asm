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

;;; Collectibles: persistent tiles, typically corresponding to items that the
;;; player can pick up. In a few cases, I'm mis-using the collectible tile
;;; engine for other things, like locked doors, for which changes need to be
;;; persistent, but which don't yield actual items.


COLLECTIBLE_TILE_POTATO EQU 15
COLLECTIBLE_TILE_STICK  EQU 16
COLLECTIBLE_TILE_KEY    EQU 22
COLLECTIBLE_TILE_DOOR   EQU 23
COLLECTIBLE_TILE_NULL   EQU 0


;;; ----------------------------------------------------------------------------

CollectiblesLoad:
;;; no arguments
;;; returns a pointer to an array of collectible items
;;; sets ram bank to 2
;;; trashes hl, bc
        ld      a, [var_room_x]
        ld      b, a

        ld      a, [var_room_y]
        ld      c, a

        fcall   __CollectiblesLoad

        ret


;;; ----------------------------------------------------------------------------

__CollectiblesLoad:
;;; b - x
;;; c - y
;;; returns a pointer to an array of collectible items
;;; sets ram bank to 2
;;; trashes hl, bc
        RAM_BANK 2

        push    bc

        ;; hl = y * 18 * 2(bytes per collectible) * 7(collectibles per room)
        fcall   l16Mul18Fast    ; x18
        add     hl, hl          ; x2

        ld      b, h
        ld      c, l
        add     hl, hl          ; \ \ x4
        add     hl, hl          ; | /
        add     hl, bc          ; |
        add     hl, bc          ; |
        add     hl, bc          ; / x7 FIXME: quit being lazy

        pop     bc

        push    hl

        ;; hl = x * 4
        ld      l, b
        ld      h, 0
        add     hl, hl          ; | x2

        ld      c, b
        ld      b, 0

        ld      b, h
        ld      c, l
        add     hl, hl          ; \ \ x4
        add     hl, hl          ; | /
        add     hl, bc          ; |
        add     hl, bc          ; |
        add     hl, bc          ; / x7 FIXME: quit being lazy

        pop     bc              ; Previous hl to bc

        add     hl, bc
        ld      bc, wram2_var_collectibles
        add     hl, bc

        ret


;;; ----------------------------------------------------------------------------


CollectibleItemErase:
        fcall   CollectiblesLoad
.loop:
        ld      a, 7
        cp      b
        jr      Z, .endLoop

        ld      a, [var_collect_item_xy]
        swap    a
        ld      c, [hl]
        cp      c
        jr      NZ, .next

        inc     hl
        ld      a, 0
        ld      [hl], a
        jr      .endLoop

.next:
        inc     b
        inc     hl
        inc     hl
        jr      .loop
.endLoop:

	ret


;;; ----------------------------------------------------------------------------

CollectibleItemAdd:
;;; hl - collectibles
;;; a - item
;;; c - xy
        ld      b, 0

        ld      d, a
.loop:
        ld      a, 7
        cp      b
        jr      Z, .endLoop

        ld      a, [hl]
        or      a
        jr      NZ, .next

        ld      [hl], c
        inc     hl
        ld      [hl], d
        jr      .endLoop

.next:
        inc     b
        inc     hl
        inc     hl
        jr      .loop
.endLoop:

        ret


;;; ----------------------------------------------------------------------------
