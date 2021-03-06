;;; ----------------------------------------------------------------------------
;;;
;;; Utils:
;;;
;;; ----------------------------------------------------------------------------


;; ############################################################################

        SECTION "UTILS", ROM0
        INCLUDE "hardware.inc"


;;; ----------------------------------------------------------------------------

Memset:
; hl - destination
; a - byte to fill with
; bc - size

	inc	b
	inc	c
	jr	.skip
.fill:
	ld	[hl+], a
.skip:
	dec	c
	jr	nz, .fill
	dec	b
	jr	nz, .fill
	ret


;;; ----------------------------------------------------------------------------

VBlankPoll:

        ld      a, [rLY]
        cp      $90                     ; y value 144
        jr      nz, VBlankPoll
        ret


;;; ----------------------------------------------------------------------------

ClearRam:
        ld      a, 0
        ld	hl, _RAM                ; memset destination
	ld	bc, $2000-2		; size (watch out for stack)
	call	Memset
        ret


;;; ----------------------------------------------------------------------------

ClearHRam:
        ld      a, 0
	ld	hl, _HRAM		; clear hram
	ld	c, $80			; a = 0, b = 0 here, so let's save a byte and 4 cycles (ld c,$80 - 2/8 vs ld bc,$80 - 3/12)
	call	Memset
        ret


;;; ----------------------------------------------------------------------------

ClearVRam:
        ld      a, 0
	ld	hl, _VRAM		; clear vram, lcdc is disabled so you have 'easy' access
	ld	b, $18			; a = 0, bc should be $1800; c = 0 here, so..
	call	Memset
        ret


;;; ----------------------------------------------------------------------------


;;; SECTION UTILS


;;; ############################################################################
