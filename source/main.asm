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


        ld	a, SCREEN_MODE
        ld	[rLCDC], a	        ; enable lcd
        ei

.loop:
        call    VBlankIntrWait          ; vsync

        jr      .loop



;;; ----------------------------------------------------------------------------


;;; SECTION MAIN


;;; ############################################################################
