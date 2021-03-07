;;; ----------------------------------------------------------------------------
;;;
;;; Sorry about the gigantic file. I had trouble with the linker putting code in
;;; incorrect sections, and then the code would raise illegal instruction
;;; warnings during runtime.
;;;
;;; ----------------------------------------------------------------------------

        INCLUDE "hardware.inc"
        INCLUDE "defs.inc"


;; ############################################################################

        SECTION "SLEEP_COUNTER", HRAM

var_sleep_counter:     DS      1


;;; SECTION SLEEP_COUNTER


;; ############################################################################

        SECTION "JOYPAD_VARS", HRAM

var_joypad_current:     DS      1
var_joypad_previous:    DS      1


;;; SECTION JOYPAD_VARS


;;; ############################################################################

        SECTION "IRQ_VARIABLES", HRAM

var_vbl_flag:   DS      1


;;; SECTION IRQ_VARIABLES


;;; ############################################################################

        SECTION "OAM_BACK_BUFFER", WRAM0, ALIGN[8]

var_oam_back_buffer:
        ds OAM_SIZE * OAM_COUNT


;;; SECTION OAM_BACK_BUFFER


;;; ############################################################################

        SECTION "VBL", ROM0[$0040]
	jp	Vbl_isr

;;; ----------------------------------------------------------------------------

Vbl_isr:
        push    af
        ld      a, 1
        ldh     [var_vbl_flag], a
        pop     af
        reti


;;; ----------------------------------------------------------------------------


;;; SECTION VBL


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

        ldh     [var_vbl_flag], a
        ldh     [var_sleep_counter], a

        ld      hl, var_oam_back_buffer ; zero out the oam back buffer
        ld      bc, OAM_SIZE * OAM_COUNT
        call    Memset                  ; Note param a already holds 0 (above)

        jr      Main


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


Main:
        ld	a, IEF_VBLANK	        ; vblank interrupt
	ld	[rIE], a	        ; setup

        call    CopyDMARoutine

        call    ShowSampleImage

.activate_screen:
        ld	a, SCREEN_MODE
        ld	[rLCDC], a	        ; enable lcd
        ei

.loop:
        call    ReadKeys

.sched_sleep:
        ldh     a, [var_sleep_counter]
        or      a
        jr      z, .vsync
        dec     a
        ldh     [var_sleep_counter], a
        call    VBlankIntrWait
        jr      .sched_sleep

.vsync:
        call    VBlankIntrWait          ; vsync

        ld      a, HIGH(var_oam_back_buffer)
        call    hOAMDMA

;;; ld hl spriteStartAddress
;;; ld de vramSpriteDestAddress
;;; ld b copyLen
;;; call GDMABlockCopy

        jr      .loop


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


ReadKeys:
; b - returns raw state
; c - returns debounced state (edge-triggered)

        ld      a, $20                  ; read P15 - returns a, b, select, start
        ldh     [rP1], a
        ldh     a, [rP1]                ; mandatory
        ldh     a, [rP1]
        cpl                             ; rP1 returns not pressed keys as 1 and pressed as 0, invert it to make result more readable
        and     $0f                     ; lower nibble has a, b, select, start state
        swap    a
        ld      b, a

        ld      a, $10                  ; read P14 - returns up, down, left, right
        ldh     [rP1], a
        ldh     a, [rP1]                ; mandatory
        ldh     a, [rP1]
        ldh     a, [rP1]
        ldh     a, [rP1]
        ldh     a, [rP1]
        ldh     a, [rP1]
        cpl                             ; rP1 returns not pressed keys as 1 and pressed as 0, invert it to make result more readable
        and     $0f                     ; lower nibble has up, down, left, right state
        or      b                       ; combine P15 and P14 states in one byte
        ld      b, a                    ; store it

        ldh     a, [var_joypad_previous]; this is when important part begins, load previous P15 & P14 state
        xor     b                       ; result will be 0 if it's the same as current read
        and     b                       ; keep buttons that were pressed during this read only
        ldh     [var_joypad_current], a ; store final result in variable and register
        ld      c, a
        ld      a, b                    ; current P15 & P14 state will be previous in next read
        ldh     [var_joypad_previous], a

        ld      a, $30                  ; reset rP1
        ldh     [rP1], a

        ret


;;; ---------------------------------------------------------------------------


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

        ld      a, b                    ; transfer length = 5 (64 bytes)
        ldh     [rHDMA5], a             ; start DMA transfer
        ret


;;; ----------------------------------------------------------------------------


CopyDMARoutine:
        ld      hl, DMARoutine
        ld      b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
        ld      c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
        ld      a, [hli]
        ldh     [c], a
        inc     c
        dec     b
        jr      nz, .copy
        ret

DMARoutine:
        ldh     [rDMA], a

        ld      a, 40
.wait
        dec     a
        jr      nz, .wait
        ret
DMARoutineEnd:


;;; Testing stuff (remove me later)
;;; ----------------------------------------------------------------------------

ShowSampleImage:
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
        ret



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


;;; IMAGE DATA


picture_chr:					; bmp2cgb -e0 picture.bmp
        INCBIN	"picture.chr"
picture_map:
	INCBIN	"picture.map"
picture_atr:
	INCBIN	"picture.atr"
picture_pal:
	INCBIN	"picture.pal"



;;; SECTION START


;;; ############################################################################


        SECTION "OAM_DMA_ROUTINE", HRAM

hOAMDMA::
        ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to


;;; SECTION OAM_DMA_ROUTINE


;;; ############################################################################
