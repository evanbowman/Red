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


;;; ----------------------------------------------------------------------------

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

        ld      a, b
        ldh     [rHDMA5], a             ; start DMA transfer
        ret


;;; ----------------------------------------------------------------------------

MapSpriteBlock:
; h target sprite index
; b vram index
; overwrites de
;;; Sprite blocks are 32x32 in size. Because 32x32 sprites occupy 256 bytes,
;;; indexing is super easy.

;;; NOTE: The sprite will be copied from the spritesheet bound to
;;; hvar_spritesheet. Remember to assign the spritesheet var before calling
;;; MapSpriteBlock.

        ld      a, h            ; \
        srl     a               ; |
        srl     a               ; | Divide sprite index by 64 to determine bank.
        and     $30             ; |
        swap    a               ; /

        ld      d, a            ; save a in d for later use

	push    hl                      ; \
        push    de                      ; |
        ldh     a, [hvar_spritesheet]   ; |
        ld      e, a                    ; | Look up the starting rom bank for
        ld      d, 0                    ; | the currently bound spritesheet.
        ld      hl, .spritesheetBankLut ; |
        add     de                      ; |
        ld      a, [hl]                 ; |
        pop     de                      ; |
        pop     hl                      ; /

        add     a, d            ; \ Add the starting rom bank to the bank number
        SET_BANK_FROM_A         ; / calculated above, assign the current bank.

        swap    d               ; \
        sla     d               ; | Multiply back up by 64
        sla     d               ; /

        ld      a, h            ; We have 64 sprite blocks per rom bank. So, we
        sub     d               ; need to subtract 64 * bank from our sprite num

        ld      h, a


        ld      de, r2_SpriteSheetData
        ld      l, 0
        add     hl, de                  ; h is in upper bits, so x256 for free

        push    hl
        ld      hl, _VRAM
        ld      c, 0
        add     hl, bc
        ld      d, h
        ld      e, l
        pop     hl

        ld      b, 15
        fcall   GDMABlockCopy
        ret

.spritesheetBankLut:
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
DB      SPRITESHEET1_ROM_BANK
.spritesheetBankLutEnd:


;;; ----------------------------------------------------------------------------

ShowSpriteSingle:
;;; l - oam start
;;; b - x
;;; c - y
;;; d - palette
;;; e - start tile
        push    de
        fcall   OamLoad
        pop     de

        ld      [hl], c
        inc     hl
        ld      [hl], b
        inc     hl
        ld      [hl], e
        inc     hl
        ld      [hl], d
        ret


;;; ----------------------------------------------------------------------------

ShowSpriteSquare16:
; l - oam start
; b - x
; c - y
; d - palette
; e - start tile
        push    de
        fcall   OamLoad
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
        ret     Z

        push    hl
        ld      hl, $0800
        add     hl, bc
        ld      b, h
        pop     hl

        jr      .loop


;;; ----------------------------------------------------------------------------

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
        fcall   OamLoad                 ; OAM pointer in hl
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
        ret     Z
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner2


;;; ----------------------------------------------------------------------------

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
        fcall   OamLoad                 ; OAM pointer in hl
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
        ret     Z
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner2


;;; ----------------------------------------------------------------------------

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
        fcall   OamLoad                 ; OAM pointer in hl
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
        ret     Z
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner2


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
        fcall   OamLoad
        ld      [hl], c
        inc     hl
        ld      [hl], b
        ret


;;; ----------------------------------------------------------------------------

OamSetTile:
; l - oam number
; a - tile
        fcall   OamLoad
        inc     hl
        inc     hl
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------

OamSetParams:
; l - oam number
; a - params
        fcall   OamLoad
        inc     hl
        inc     hl
        inc     hl
        ld      [hl],a
        ret


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

Fade:
;;; c - amount
;;; de - foreground palettes base ptr
;;; hl - background palettes base ptr
;;; trashes hl, b

        ld      b, 0

        push    de

        push    bc

;;; We want to convert from an index in the range of 0-255 to 0-31, as we
;;; support 32 levels of fading. Then, we'll want to shift left by six bits
;;; (each palette bank takes up 64 bytes). Because we essentially shifting
;;; right by three bits, and then shifting left by six bits, we can skip a bunch
;;; of the shifts by simply masking off the lower three bits.
        ld      a, c
        and     $f8
        ld      c, a

        ld      a, [var_last_fade_amount]
        cp      c
        ld      a, c
        ld      [var_last_fade_amount], a
        jr      Z, .skip

        ld      a, c                    ; \
        and     $e0                     ; | Transfer the upper three bits into
        swap    a                       ; | register b.
        srl     a                       ; |
	ld      b, a                    ; /

        sla     c                       ; \
        sla     c                       ; | Perform the shift.
        sla     c                       ; /


        add     hl, bc

        ld      b, 64
        fcall   LoadBackgroundColors


        pop     bc
        pop     hl                      ; We pushed from de, see above

        ld      a, c
;;; All of the code below is copy-pasted from above, just so that we can offset
;;; the sprite fades from the background fades.
        sub     16
        jr      C, .zero
        jr      .nominal
.zero:
        xor     a
.nominal:
        ld      c, a


        ld      a, c
        and     $f8
        ld      c, a

        ld      a, c                    ; \
        and     $e0                     ; | Transfer the upper three bits into
        swap    a                       ; | register b.
        srl     a                       ; |
	ld      b, a                    ; /

        sla     c                       ; \
        sla     c                       ; | Perform the shift.
        sla     c                       ; /


        add     hl, bc                  ; See pop, above

        ld      b, 64
        fcall   LoadObjectColors

        ret
.skip:
        pop bc
        pop de

        ret


;;; ----------------------------------------------------------------------------

LoadOverworldPalettes:
        ld      b, 64
        ld      hl, r7_SpritePalettes
        fcall   LoadObjectColors

        ld      b, 64
        ld      hl, r7_BackgroundPalette
        fcall   LoadBackgroundColors
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
        fcall   SetBackgroundTile
        pop     de

        inc     e
        inc     a

        push    de
        fcall   SetBackgroundTile
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

        push    bc
        fcall   BackgroundTileAddress
        pop     bc

        ld      d, c            ; move pal to d

        ld      c, 4
.outerLoop:
        ld      b, 4
.loop:
        ld      [hl], e         ; set tile

	ld	a, 1
	ld	[rVBK], a
        ld      [hl], d         ; set palette in other vram bank
        xor     a
        ld      [rVBK], a

        inc     e
        inc     hl

        dec     b
        ld      a, b
        or      a
        jr      NZ, .loop

	dec     c

        ld      a, c
        or      a
        ret     Z

        push    bc
        ld      bc, 28          ; go to next row
        add     hl, bc
        pop     bc

        jr      .outerLoop


;;; ----------------------------------------------------------------------------


BackgroundTileAddress:
;;; a - x index
;;; d - y index
        push    af

        ld      hl, _SCRN0
        ld      b, 0
        ld      c, 32
.loop:
        xor     a
        or      d
	jr      Z, .ready
        dec     d
        add     hl, bc
        jr      .loop

.ready:
        pop     af
        ld      c, a
        ld      b, 0

        add     hl, bc

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
        xor     a
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
        xor     a
        ld      [rVBK], a
        pop     af

        ret


;;; ----------------------------------------------------------------------------

LoadFont:
        SET_BANK 7

        ld      hl, r7_FontTiles
        ld      bc, r7_FontTilesEnd - r7_FontTiles
        ld      de, $9310

        ld	a, 1
	ld	[rVBK], a

	fcall   Memcpy

        xor     a
        ld      [rVBK], a

        ret


;;; ----------------------------------------------------------------------------


PutText:
;;; hl - text
;;; de - screen ptr
;;; b - attribute
;;; return de - updated screen ptr
.loop:
        ld      a, [hl]
        cp      0
	ret     Z

        ld      [de], a

        ld      a, 1
        ld      [rVBK], a
        ld      a, b
        ld      [de], a
        xor     a
	ld      [rVBK], a

        inc     hl
        inc     de

        jr      .loop


;;; ----------------------------------------------------------------------------


PutTextSimple:
;;; hl - text
;;; de - screen ptr
;;; return de - updated screen ptr
.loop:
        ld      a, [hl+]
        cp      0
        ret     Z

        ld      [de], a

        inc     de

        jr      .loop


;;; ----------------------------------------------------------------------------

LcdOff:
        xor     a
	ld	[rLCDC], a
        ret


;;; ----------------------------------------------------------------------------

LcdOn:
        ld      a, SCREEN_MODE
        ld      [rLCDC], a
        ret


;;; ----------------------------------------------------------------------------

AllocateTexture:
;;; return a (0 on failure)
;;; trashes hl, c
        xor     a

        ld      c, 0

        ld      hl, var_texture_slots
.loop:
        ld      a, c
        cp      TEXTURE_SLOT_COUNT
        jr      Z, .failed

        ld      a, [hl]
        or      a
        jr      Z, .found
        jr      .next

.found:
        ld      a, 1
        ld      [hl], a         ; set slot used

        ld      a, c
        inc     a               ; Texture slots count from one.
        ret

.next:
        inc     hl
        inc     c
        jr      .loop

.failed:
        xor     a

        ret


;;; ----------------------------------------------------------------------------

FreeTexture:
;;; a - texture
        cp      0
        ret     Z

        dec     a               ; Texture slots count from one.

;;; TODO...

        ret


;;; ----------------------------------------------------------------------------


GetFadeToBlackBkgLut:
;;; result in hl
        ld      a, [var_fade_to_black_bkg_lut]
        ld      h, a
        ld      a, [var_fade_to_black_bkg_lut + 1]
        ld      l, a
        ret


GetFadeToBlackSprLut:
;;; result in de
        ld      a, [var_fade_to_black_spr_lut]
        ld      d, a
        ld      a, [var_fade_to_black_spr_lut + 1]
        ld      e, a
        ret


GetFadeToTanBkgLut:
;;; result in hl
        ld      a, [var_fade_to_tan_bkg_lut]
        ld      h, a
        ld      a, [var_fade_to_tan_bkg_lut + 1]
        ld      l, a
        ret


GetFadeToTanSprLut:
;;; result in de
        ld      a, [var_fade_to_tan_spr_lut]
        ld      d, a
        ld      a, [var_fade_to_tan_spr_lut + 1]
        ld      e, a
        ret



SetFadeBank:
        ld      a, [var_fade_bank]
        SET_BANK_FROM_A
        ret



FadeToBlack:
;;; c - amount
        fcall   SetFadeBank

        fcall   GetFadeToBlackBkgLut
        fcall   GetFadeToBlackSprLut
        fcall   Fade
        ret


FadeToBlackExcludeOverlay:
;;; c - amount
        fcall   SetFadeBank

        fcall   GetFadeToBlackBkgLut
        fcall   GetFadeToBlackSprLut
        fcall   Fade

        ld      b, 8
        fcall   GetFadeToBlackBkgLut
        fcall   LoadBackgroundColors

        ret


BlackScreenExcludeOverlay:
        fcall   SetFadeBank


        fcall   GetFadeToBlackBkgLut
        ld      bc, 1984       ; 64 colors * 31 yields the entry with total fade
        add     hl, bc
        ld      b, 64
        fcall   LoadBackgroundColors

        ld      b, 8
        fcall   GetFadeToBlackBkgLut
        fcall   LoadBackgroundColors

	fcall   GetFadeToBlackSprLut
        ld      h, d
        ld      l, e
        ld      bc, 1984
        add     hl, bc
        ld      b, 64
        fcall   LoadObjectColors

        ret


FadeNone:
        fcall   SetFadeBank
        ld      b, 64
        fcall   GetFadeToBlackBkgLut
        fcall   LoadBackgroundColors

        ld      b, 64
        fcall   GetFadeToBlackSprLut
        ld      h, d
        ld      l, e
        fcall   LoadObjectColors
        ret


FadeToTan:
        fcall   SetFadeBank
        fcall   GetFadeToTanBkgLut
        fcall   GetFadeToTanSprLut
        fcall   Fade
        ret


TanScreen:
        fcall   SetFadeBank
	fcall   GetFadeToTanBkgLut
        ld      bc, 1984       ; 64 colors * 31 yields the entry with total fade
        add     hl, bc
        ld      b, 64
        fcall   LoadBackgroundColors

        fcall   GetFadeToTanSprLut
        ld      h, d
        ld      l, e
        ld      bc, 1984
        add     hl, bc
        ld      b, 64
        fcall   LoadObjectColors
        ret


;;; ----------------------------------------------------------------------------

FadeToWhite:
        SET_BANK 30
        ld      hl, BkgFadeToWhiteLut
        ld      de, SprFadeToWhiteLut
        fcall   Fade
        ret


;;; ----------------------------------------------------------------------------
