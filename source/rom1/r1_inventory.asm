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


r1_InventoryTiles::
DB $FF,$FF,$FF,$FF,$FF,$FF,$F1,$E1
DB $E1,$E1,$E7,$E7,$E7,$E7,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$8F,$87
DB $87,$87,$E7,$E7,$E7,$E7,$FF,$FF
DB $FF,$FF,$E7,$E7,$E7,$E7,$87,$87
DB $8F,$87,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$E7,$E7,$E7,$E7,$E1,$E1
DB $F1,$E1,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$81,$81
DB $81,$81,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$E7,$E7,$E7,$E7,$E7,$E7
DB $E7,$E7,$E7,$E7,$E7,$E7,$FF,$FF
r1_InventoryTilesEnd::

r1_InventoryLowerBoxTopRow::
DB $30, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34
DB $34, $34, $34, $34, $31
r1_InventoryLowerBoxTopRowEnd::

r1_InventoryLowerBoxBottomRow::
DB $33, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34
DB $34, $34, $34, $34, $32
r1_InventoryLowerBoxBottomRowEnd::

r1_InventoryLowerBoxMiddleRow::
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $00, $00, $00, $35
r1_InventoryLowerBoxMiddleRowEnd::


r1_InventoryImageBoxTopRow::
DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $30, $34, $34, $34
DB $34, $34, $34, $34, $31
r1_InventoryImageBoxTopRowEnd::

r1_InventoryImageBoxBottomRow::
DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $33, $34, $34, $34
DB $34, $34, $34, $34, $32
r1_InventoryImageBoxBottomRowEnd::

r1_InventoryImageBoxMiddleRow::
DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $35, $00, $00, $00
DB $00, $00, $00, $00, $35
r1_InventoryImageBoxMiddleRowEnd::




r1_InventoryPalettes::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $49,$35, $00,$04,
r1_InventoryPalettesEnd::


r1_InventoryLowerBoxInitRow:
;;; de - address
        ld      hl, r1_InventoryLowerBoxMiddleRow
        ld      bc, r1_InventoryLowerBoxMiddleRowEnd - r1_InventoryLowerBoxMiddleRow
        call    VramSafeMemcpy
        ret


r1_InventoryImageBoxInitRow:
;;; de - address
        ld      hl, r1_InventoryImageBoxMiddleRow
        ld      bc, r1_InventoryImageBoxMiddleRowEnd - r1_InventoryImageBoxMiddleRow
        call    VramSafeMemcpy
        ret


r1_InventoryShow:
        ld      hl, r1_InventoryTiles
        ld      bc, r1_InventoryTilesEnd - r1_InventoryTiles
        ld      de, $9300
        call    VramSafeMemcpy

        ;; It's just simpler if objects are reset
        ld      hl, var_oam_back_buffer
        ld      a, 0
        ld      bc, OAM_SIZE * OAM_COUNT
        call    Memset

        call    VBlankIntrWait
        ld      a, HIGH(var_oam_back_buffer)
        call    hOAMDMA

        ld      a, 1
        ld	[rVBK], a

        ld      hl, (_SCRN1 + 32)
        ld      bc, $9e14 - (_SCRN1  + 32)
        ld      d, $81
        call    r1_VramSafeMemset
        ld      a, 0
        ld      [rVBK], a

        ld      hl, r1_InventoryLowerBoxTopRow
        ld      bc, r1_InventoryLowerBoxTopRowEnd - r1_InventoryLowerBoxTopRow
        ld      de, $9D00
        call    VramSafeMemcpy

        ld      de, $9C20
        call    r1_InventoryImageBoxInitRow

        ld      de, $9C40
        call    r1_InventoryImageBoxInitRow

        ld      de, $9C60
        call    r1_InventoryImageBoxInitRow

        ld      de, $9C80
        call    r1_InventoryImageBoxInitRow

	ld      de, $9CA0
        call    r1_InventoryImageBoxInitRow

	ld      de, $9CC0
        call    r1_InventoryImageBoxInitRow

        ld      hl, r1_InventoryImageBoxBottomRow
        ld      bc, r1_InventoryImageBoxBottomRowEnd - r1_InventoryImageBoxBottomRow
        ld      de, $9CE0
	call    VramSafeMemcpy

        ld      de, $9D20
        call    r1_InventoryLowerBoxInitRow

        ld      de, $9D40
        call    r1_InventoryLowerBoxInitRow

        ld      de, $9D60
        call    r1_InventoryLowerBoxInitRow

        ld      de, $9D80
        call    r1_InventoryLowerBoxInitRow

        ld      de, $9DA0
        call    r1_InventoryLowerBoxInitRow

	ld      de, $9DC0
        call    r1_InventoryLowerBoxInitRow

        ld      de, $9DE0
        call    r1_InventoryLowerBoxInitRow

        ld      hl, r1_InventoryLowerBoxBottomRow
        ld      bc, r1_InventoryLowerBoxBottomRowEnd - r1_InventoryLowerBoxBottomRow
        ld      de, $9E00
        call    VramSafeMemcpy

        ld      a, 1
        ld      [var_overlay_alternate_pos], a

        call    ShowOverlay

        call    VBlankIntrWait
        ld      b, r1_InventoryPalettesEnd - r1_InventoryPalettes
        ld      hl, r1_InventoryPalettes
        call    LoadBackgroundColors

;;; Now, we can draw the very top row! Jump the window up, and draw the top row
;;; in place of where the overlay bar used to be.
        ld      a, 0
        ld      [rWY], a

        ld      b, 0
        ld      hl, r1_InventoryImageBoxTopRow
        ld      de, _SCRN1
.loop:
        ld      a, [hl+]
        ld      [de], a

        ld      a, 1
        ld      [rVBK], a
        ld      a,  $81
        ld      [de], a
        ld      a, 0
        ld      [rVBK], a

        inc     de
        inc     b
        ld      a, 20
        cp      b
        jr      NZ, .loop
.done:
        ret


;;; ----------------------------------------------------------------------------

r1_VramSafeMemset:
; hl - destination
; d - byte to fill with
; bc - size
        ld      a, [rLY]
        cp      145
        jr      C, .needsInitialVSync
	jr      .start

.needsInitialVSync:
        call    VBlankIntrWait

.start:
	inc	b
	inc	c
	jr	.skip
.top:
        ld      a, [rLY]
        cp      152
        jr      Z, .vsync
        jr      .fill

.vsync:
	call    VBlankIntrWait
.fill:
	ld	[hl], d
        inc     hl
.skip:
	dec	c
	jr	nz, .top
	dec	b
	jr	nz, .top
.done:
	ret


;;; ----------------------------------------------------------------------------
