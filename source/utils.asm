;;; ----------------------------------------------------------------------------
;;;
;;; Utils:
;;;
;;; ----------------------------------------------------------------------------


;; ############################################################################

        SECTION "SLEEP_COUNTER", HRAM

var_sleep_counter:     DS      1


;;; SECTION SLEEP_COUNTER


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

ScheduleSleep:
; e - frames to sleep
        ldh     a, [var_sleep_counter]
        add     a, e
        ldh     [var_sleep_counter], a
        ret


;;; ----------------------------------------------------------------------------

VBlankIntrWait:
.loop:
;;; NOTE: We reset the vbl flag before the halt, in case our game logic ran
;;; slow, and we missed the vblank.
        ld      a, 0
        ldh     [var_vbl_flag], a

        halt
        ;; The assembler inserts a nop here to fix a hardware bug.
        ldh     a, [var_vbl_flag]
        or      a
        jr      z, .loop
        xor     a
        ldh     [var_vbl_flag], a
        ret


;;; ----------------------------------------------------------------------------


;;; SECTION UTILS


;;; ############################################################################
