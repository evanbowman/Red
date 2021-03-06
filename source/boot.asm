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


.checkGameboyColor:
        cp      a, BOOTUP_A_CGB         ; Boot leaves value in reg-a
        jr      z, .gbcDetected         ; if a == 0, then we have gbc
        jr      .checkGameboyColor      ; Freeze

;;; TODO: Display some text to indicate that the game requires a gbc. There's no
;;; need to waste space in bank zero for this stuff, though.


.gbcDetected:
        call    SetCpuFast
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

SetCpuFast:
    ld      a, [rKEY1]
    bit     7, a
    jr      z, .impl
    ret

.impl:
    ld      a, $30
    ld      [rP1], a
    ld      a, $01
    ld      [rKEY1], a

    stop
    ret


;;; ----------------------------------------------------------------------------


;;; SECTION START


;;; ############################################################################
