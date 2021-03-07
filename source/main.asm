;;; ----------------------------------------------------------------------------
;;;
;;; Main:
;;;
;;; ----------------------------------------------------------------------------

        INCLUDE "hardware.inc"
        INCLUDE "defs.inc"


;;; ############################################################################

        SECTION "MAIN", ROM0



;;; ----------------------------------------------------------------------------

Main:
        ld	a, IEF_VBLANK	        ; vblank interrupt
	ld	[rIE], a	        ; setup


.sample_image:
	ld	hl,picture_chr		; picture data
	ld	de,_VRAM		; place it between $8000-8FFF (tiles are numbered here from 0 to 255)
	ld	bc,3952			; gbhorror.chr file size
	call 	Memcpy

	ld	hl,picture_map		; picture map (160x144px padded = 32*18)
	ld	de,_SCRN0		; place it at $9800
	ld	bc,576			; gbcyus.map file size
	call	Memcpy

	ld	a,1			; switch to vram bank 1
	ld	[rVBK],a		; this is where we place attribute map

	ld	hl,picture_atr		; picture attributes
	ld	de,_SCRN0		; place it at $9800 just like map
	ld	bc,576			; gbcyus.atr file size
	call	Memcpy

	xor	a			; switch back to vram bank 0
	ld	[rVBK],a

	ld	hl,picture_pal		; picture palette
	ld	b,64			; gbcyus.pal file size
					; 1 palette has 4 colors, 1 color takes 2 bytes, so 8 palettes = 64 bytes
	call	set_bg_pal


.activate_screen:
        ld	a, SCREEN_MODE
        ld	[rLCDC], a	        ; enable lcd
        ei

.loop:
        call    VBlankIntrWait          ; vsync

        jr      .loop



;;; ----------------------------------------------------------------------------

;;; Borrowed from a tutorial, TODO: write a better version.
set_bg_pal:

	ld	a,%10000000			; bit 7 - enable palette auto increment
						; bits 5,4,3 - palette number (0-7)
						; bits 2,1 - color number (0-3)
	ld	[rBCPS],a			; we start from color #0 in palette #0 and let the hardware to auto increment those values while we copy palette data
.copy
	ld	a,[hl+]				; this is really basic = slow way of doing things
	ldh	[rBCPD],a
	dec	b
	jr	nz,.copy
	ret


;;; ----------------------------------------------------------------------------


;;; SECTION MAIN


;;; ############################################################################
