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
;;; Video Routines
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


GDMABlockCopy:
; hl - sprite start address
; de - destination
; b - length
        ld      a, h
        ldh     [rHDMA1], a             ; HDMA source high
        ld      a, l
        ldh     [rHDMA2], a             ; HDMA source low

        ld      a, d
        ldh     [rHDMA3], a             ; HDMA destination high
        ld      a, e
        ldh     [rHDMA4], a             ; HDMA destination low

        ld      a, b                    ; transfer length = 5 (64 bytes)
        ldh     [rHDMA5], a             ; start DMA transfer
        ret


;;; ----------------------------------------------------------------------------

ShowSpriteSquare16:
; l - oam start
; b - x
; c - y
; d - palette
; e - start tile
        push    de
        call    OamLoad
        pop     de

        ld      a, 2
.loop:
        ld      [hl], c                 ; set y
        inc     hl
        ld      [hl], b                 ; set x
        inc     hl
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e
        inc     e

        dec     a
        or      a
        jr      z, .done

        push    hl
        ld      hl, $0800
        add     hl, bc
        ld      b, h
        pop     hl

        jr      .loop
.done:
        ret



ShowSpriteTall16x32:
;;; l - oam start
;;; b - x
;;; c - y
;;; d - palette
;;; e - start tile
;;; trashes most registers
        inc     e
        inc     e
        ld      a, b
        ld      b, 0                    ; Center stuff
        sub     b
        ld      b, a

        ld      a, c
        ld      c, 8
        sub     c
        ld      c, a

        push    de                      ; de trashed by OamLoad
        call    OamLoad                 ; OAM pointer in hl
        pop     de                      ; restore e

        push    bc                      ; for when we jump down a row

.loop_outer:
        ld      a, 1                    ; inner loop counter

.loop_inner:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e                       ; double inc b/c 8x16 tiles
        inc     e

        or      a                       ; test whether a has reached zero
        jr      z, .loop_outer_cond
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner

.loop_outer_cond:
        pop     bc                      ; see push at fn top

        push    hl

        ld      hl, $0010               ; y += 16
        add     hl, bc
        ld      c, l                    ; load upper half into y
        pop     hl

.loop_outer2:

        inc     e
        inc     e
        inc     e
        inc     e

        ld      a, 1                    ; inner loop counter

.loop_inner2:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e                       ; double inc b/c 8x16 tiles
        inc     e

        or      a                       ; test whether a has reached zero
        jr      z, .done
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner2
.done
        ret





;;; Note: 32x32 Square sprite consumes eight hardware sprites, given 8x16
;;; sprites.

ShowSpriteSquare32:
; l - oam start
; b - x
; c - y
; d - palette
; e - start tile
; overwrites a, b, c, d, e, h, l  :(

;;; NOTE: This used to be a nested loop. Now, the outer loop is manually
;;; unrolled, not necessarily for performance, but because I ran out of
;;; registers.

        ld      a, b
        ld      b, 8                    ; Center stuff
        sub     b
        ld      b, a

        ld      a, c
        ld      c, 8
        sub     c
        ld      c, a

        push    de                      ; de trashed by OamLoad
        call    OamLoad                 ; OAM pointer in hl
        pop     de                      ; restore e

        push    bc                      ; for when we jump down a row

.loop_outer:
        ld      a, 3                    ; inner loop counter

.loop_inner:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e                       ; double inc b/c 8x16 tiles
        inc     e

        or      a                       ; test whether a has reached zero
        jr      z, .loop_outer_cond
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner

.loop_outer_cond:
        pop     bc                      ; see push at fn top

        push    hl

        ld      hl, $0010               ; y += 16
        add     hl, bc
        ld      c, l                    ; load upper half into y
        pop     hl

.loop_outer2:
        ld      a, 3                    ; inner loop counter

.loop_inner2:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e                       ; double inc b/c 8x16 tiles
        inc     e

        or      a                       ; test whether a has reached zero
        jr      z, .done
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner2
.done
        ret



ShowSpriteT:
; l - oam start
; b - x
; c - y
; d - palette
; e - start tile
; overwrites a, b, c, d, e, h, l  :(
        inc     e
        inc     e

        ;; ld      a, b
        ;; ld      b, 8                    ; Center stuff
        ;; sub     b
        ;; ld      b, a

        ld      a, c
        ld      c, 8
        sub     c
        ld      c, a

        push    de                      ; de trashed by OamLoad
        call    OamLoad                 ; OAM pointer in hl
        pop     de                      ; restore e

        push    bc                      ; for when we jump down a row

.loop_outer:
        ld      a, 1                    ; inner loop counter

.loop_inner:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e                       ; double inc b/c 8x16 tiles
        inc     e

        or      a                       ; test whether a has reached zero
        jr      z, .loop_outer_cond
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner

.loop_outer_cond:
        inc     e
        inc     e

        pop     bc                      ; see push at fn top

        push    hl

        ld      hl, $0010               ; y += 16
        ld      a, b
        ld      b, 8
        sub     b
        ld      b, a
        add     hl, bc
        ld      c, l                    ; load upper half into y
        pop     hl

.loop_outer2:
        ld      a, 3                    ; inner loop counter

.loop_inner2:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e                       ; double inc b/c 8x16 tiles
        inc     e

        or      a                       ; test whether a has reached zero
        jr      z, .done
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner2
.done
        ret


;;; ----------------------------------------------------------------------------

OamLoad:
; l - oam number
; hl - return value
; de - trashed
        ld      h, $00
        add     hl, hl
        add     hl, hl
        ld      de, var_oam_back_buffer
        add     hl, de
        ret


;;; ----------------------------------------------------------------------------

OamSetPosition:
; l - oam number
; b - x
; c - y
        call    OamLoad
        ld      [hl], c
        inc     hl
        ld      [hl], b
        ret


;;; ----------------------------------------------------------------------------

OamSetTile:
; l - oam number
; a - tile
        call    OamLoad
        inc     hl
        inc     hl
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------

OamSetParams:
; l - oam number
; a - params
        call    OamLoad
        inc     hl
        inc     hl
        inc     hl
        ld      [hl],a
        ret


;;; ----------------------------------------------------------------------------

CopyDMARoutine:
        ld      hl, DMARoutine
        ld      b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
        ld      c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
        ld      a, [hli]
        ldh     [c], a
        inc     c
        dec     b
        jr      nz, .copy
        ret

DMARoutine:
        ldh     [rDMA], a

        ld      a, 40
.wait
        dec     a
        jr      nz, .wait
        ret
DMARoutineEnd:


;;; ----------------------------------------------------------------------------

LoadBackgroundColors:
;;; hl - source array
;;; b - count
        ld      a, %10000000
        ld      [rBCPS], a
.copy:
        ld      a, [hl+]
        ldh     [rBCPD], a
        dec     b
        jr      nz, .copy
        ret


;;; ----------------------------------------------------------------------------

LoadObjectColors:
;;; hl - source array
;;; b - count
        ld      a, %10000000
        ld      [rOCPS], a
.copy:
        ld      a, [hl+]
        ldh     [rOCPD], a
        dec     b
        jr      nz, .copy
        ret


;;; ----------------------------------------------------------------------------

LoadOverworldPalettes:
        ld      b, 24
        ld      hl, PlayerCharacterPalette
        call    LoadObjectColors

        ld      b, 24
        ld      hl, BackgroundPalette
        call    LoadBackgroundColors
        ret


;;; ----------------------------------------------------------------------------



SetBackgroundTile16x16:
;;; a - x index
;;; d - y index
;;; e - start tile
;;; c - palette
        ld      b, 2
.loop:
        push    bc

        push    de
        call    SetBackgroundTile
        pop     de

        inc     e
        inc     a

        push    de
        call    SetBackgroundTile
        pop     de

        inc     e
        ld      c, 1
        sub     c
        inc     d

        pop     bc

        dec     b
        push    af
        ld      a, b
        or      a
        pop     af
        jr      NZ, .loop

        ret


;;; Yeah I know, this code is not good.
SetBackgroundTile32x32:
;;; a - x index
;;; d - y index
;;; e - start tile
;;; c - palette
        ld      b, 4
.loop:
        push    bc

        push    de
        call    SetBackgroundTile
        pop     de

        inc     e
        inc     a

        push    de
        call    SetBackgroundTile
        pop     de

        inc     e
        inc     a

        push    de
        call    SetBackgroundTile
        pop     de

        inc     e
        inc     a

        push    de
        call    SetBackgroundTile
        pop     de

        inc     e
        ld      c, 3
        sub     c
        inc     d

        pop     bc

        dec     b
        push    af
        ld      a, b
        or      a
        pop     af
        jr      NZ, .loop

        ret


;;; ----------------------------------------------------------------------------


SetBackgroundTile:
;;; a - x index
;;; d - y index
;;; e - tile number
;;; c - palette
;;; FIXME: the map is vram 32 tiles wide, so we may be able to use sla
;;; instructions with the y value instead.
        push    bc
        push    af
        ld      hl, _SCRN0
        ld      b, 0
        ld      c, 32
.loop:
        ld      a, 0
        or      d
	jr      Z, .ready
        dec     d
        add     hl, bc
        jr      .loop

.ready:
        pop     af
        ld      c, a
        add     hl, bc
        ld      [hl], e

        pop     bc
        push    af
        ld	a, 1
	ld	[rVBK], a
        ld      [hl], c
        ld      a, 0
        ld      [rVBK], a
        pop     af

        ret


;;; ----------------------------------------------------------------------------


SetOverlayTile:
;;; NOTE: This writes to vram, careful!
;;; c - screen overlay x index
;;; a - tile number (overlay tiles start at $80)
;;; trashes b
        ld      hl, _SCRN1
        ld      b, 0
        add     hl, bc
        ld      [hl], a
        ld      a, 1
        ld      [rVBK], a
        ld      a, $80
        ld      [hl], a
        ld      a, 0
        ld      [rVBK], a
        ret


;;; ----------------------------------------------------------------------------


UpdateStaminaBar:
        ld      hl, var_player_stamina
        call    FixnumUpper
        ld      c, 1

.loopFull:
        ld      a, e
        ld      e, 16
        cp      e
        ld      e, a
        jr      C, .partial

        ld      a, e
        ld      e, 16
        sub     e
        ld      e, a
        ld      a, $2 + 8
        call    SetOverlayTile
        inc     c

        ld      a, 18
        cp      c
        jr      Z, .done
        jr      .loopFull

.partial:
        ld      a, $2
        SRL     e
        add     a, e
        call    SetOverlayTile

        inc     c
        ld      a, 18
        cp      c
        jr      Z, .done

.done:

        ret


TestOverlay:
        ld      c, 0
        ld      a, $1
        call    SetOverlayTile

        inc     c

        ld      a, $2
        call    SetOverlayTile

        inc     c

.loop1:
        ld      a, $2
        call    SetOverlayTile
        inc     c
        ld      a, 17
        cp      c
        jr      NZ, .loop1

	ld      a, $B
        call    SetOverlayTile

        inc     c

.loop2:
        ld      a, $0
        call    SetOverlayTile
        inc     c
        ld      a, 20
        cp      c
        jr      NZ, .loop2

        ret


;;; ----------------------------------------------------------------------------

LoadFont:
        ld      hl, FontTiles
        ld      bc, FontTilesEnd - FontTiles
        ld      de, $9330

        ld	a, 1
	ld	[rVBK], a

	call    Memcpy

        xor     a
        ld      [rVBK], a

        ret


;;; ----------------------------------------------------------------------------

PutText:
;;; hl - text

        ret


;;; ----------------------------------------------------------------------------

LcdOff:
        ld      a, 0
	ld	[rLCDC], a
        ret


;;; ----------------------------------------------------------------------------

LcdOn:
        ld      a, SCREEN_MODE
        ld      [rLCDC], a
        ret


;;; ----------------------------------------------------------------------------
