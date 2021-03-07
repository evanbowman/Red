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
	ld	[rIF], a
	ld	[rLCDC], a
	ld	[rSTAT], a
	ld	[rSCX], a
	ld	[rSCY], a
	ld	[rLYC], a
	ld	[rIE], a
	ld	[rVBK], a
	ld	[rSVBK], a
	ld	[rRP], a

        ld      [var_vbl_flag], a

        ld      hl, var_oam_back_buffer ; zero out the oam back buffer
        ld      a, 0
        ld      bc, 4 * OAM_COUNT
        call    Memset

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

        SECTION "DATA", ROM0


picture_chr:					; bmp2cgb -e0 picture.bmp
        INCBIN	"picture.chr"
picture_map:
	INCBIN	"picture.map"
picture_atr:
	INCBIN	"picture.atr"
picture_pal:
	INCBIN	"picture.pal"


;;; SECTION DATA


;;; ############################################################################
