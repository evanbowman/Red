;;; ----------------------------------------------------------------------------
;;;
;;; Boot:
;;;
;;; ----------------------------------------------------------------------------

        INCLUDE "hardware.inc"


;;; ############################################################################

        SECTION "BOOT", ROM0[$100]

;;; ----------------------------------------------------------------------------

EntryPoint:
        nop
        jp      Start


;;; ----------------------------------------------------------------------------


;;; SECTION BOOT


;;; ############################################################################

        SECTION "START", ROM0[$150]

;;; ----------------------------------------------------------------------------

Start:
        di                              ; Turn of interrupts during startup.
        ld      sp, $E000               ; Setup stack.

        call    VBlankPoll              ; Wait for vbl before disabling lcd.

	xor	a
	ld	[rIF], a        	; reset important registers
	ld	[rLCDC], a
	ld	[rSTAT], a
	ld	[rSCX], a
	ld	[rSCY], a
	ld	[rLYC], a
	ld	[rIE], a

        call    ClearRam
        call    ClearHRam
        call    ClearVRam

        ld	a, IEF_VBLANK	        ; vblank interrupt
	ld	[rIE], a	        ; setup

        ld	a,LCDCF_ON | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJ8 | LCDCF_OBJOFF | LCDCF_WINOFF | LCDCF_BGON
        ld	[rLCDC], a	        ; enable lcd
        ei

        call    Main


;;; ----------------------------------------------------------------------------


;;; SECTION START


;;; ############################################################################
