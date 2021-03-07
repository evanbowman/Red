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

Memcpy:
; hl - destination
; a - byte to fill with
; bc - size

	inc	b
	inc	c
	jr	.skip
.copy:
	ld	a, [hl+]
	ld	[de], a
	inc	de
.skip:
	dec	c
	jr	nz, .copy
	dec	b
	jr	nz, .copy
	ret


;;; ----------------------------------------------------------------------------

VBlankPoll:
; Intended for waiting on vblank while interrupts are disabled, but the screen
; is still on.
        ld      a, [rLY]
        cp      SCRN_Y
        jr      nz, VBlankPoll
        ret


;;; ----------------------------------------------------------------------------

Reset:
        ld      a, $0
        ld      b, a
        ld      a, BOOTUP_A_CGB
;;; TODO: explicitly set the rom bank?
        jp      $0100


;;; ----------------------------------------------------------------------------

Sleep:
; e - frames to sleep
        call    VBlankPoll
        dec     e
        jr      nz, Sleep
        ret


;;; ----------------------------------------------------------------------------

VBlankIntrWait:
.loop:
        halt
        ;; The assembler inserts a nop here to fix a hardware bug.
        ld      a, [var_vbl_flag]
        or      a
        jr      z, .loop
        xor     a
        ld      [var_vbl_flag], a
        ret


;;; ----------------------------------------------------------------------------


;;; SECTION UTILS


;;; ############################################################################
