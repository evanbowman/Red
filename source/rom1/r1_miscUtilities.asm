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


r1_VBlankPoll:
; Intended for waiting on vblank while interrupts are disabled, but the screen
; is still on.
        ld      a, [rLY]
        cp      SCRN_Y
        jr      nz, r1_VBlankPoll
        ret


;;; ----------------------------------------------------------------------------

r1_InitWRam:
        ld      a, 0
        ld      hl, _RAM
        ;; We don't want to zero the stack, or how will we return from this fn?
        ld      bc, STACK_END - _RAM
        fcall   Memset

        ld      d, 1
.loop:
        ld      a, d
        cp      8
        jr      Z, .done

        ld      [rSVBK], a

        ld      hl, _RAMBANK
        ld      bc, ($DFFF - _RAMBANK) - 1
        ld      a, 0
        fcall   Memset

        inc     d
        jr      .loop

.done:
        ld      a, 0
        ld      [rSVBK], a


        ret


r1_InitRam:
;;; trashes hl, bc, a
        ld      a, 0

        ld      hl, _HRAM
        ld      bc, $80
        fcall   Memset

        fcall   r1_InitWRam

        ret


;;; ----------------------------------------------------------------------------

r1_SetCpuFast:
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

r1_CopyDMARoutine:
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


;;; ----------------------------------------------------------------------------

r1_SmoothstepLut::
DB $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00, $01, $01, $01, $01, $02, $02,
DB $02, $03, $03, $04, $04, $04, $05, $05,
DB $06, $06, $07, $07, $08, $09, $09, $0A,
DB $0B, $0B, $0C, $0D, $0D, $0E, $0F, $10,
DB $10, $11, $12, $13, $14, $15, $15, $16,
DB $17, $18, $19, $1A, $1B, $1C, $1D, $1E,
DB $1F, $20, $21, $22, $23, $24, $25, $27,
DB $28, $29, $2A, $2B, $2C, $2D, $2F, $30,
DB $31, $32, $33, $35, $36, $37, $38, $3A,
DB $3B, $3C, $3E, $3F, $40, $42, $43, $44,
DB $46, $47, $48, $4A, $4B, $4D, $4E, $4F,
DB $51, $52, $54, $55, $56, $58, $59, $5B,
DB $5C, $5E, $5F, $61, $62, $63, $65, $66,
DB $68, $69, $6B, $6C, $6E, $6F, $71, $72,
DB $74, $75, $77, $78, $7A, $7B, $7D, $7E,
DB $80, $81, $83, $84, $86, $87, $89, $8A,
DB $8C, $8D, $8F, $90, $92, $93, $95, $96,
DB $98, $99, $9B, $9C, $9D, $9F, $A0, $A2,
DB $A3, $A5, $A6, $A8, $A9, $AA, $AC, $AD,
DB $AF, $B0, $B1, $B3, $B4, $B6, $B7, $B8,
DB $BA, $BB, $BC, $BE, $BF, $C0, $C2, $C3,
DB $C4, $C6, $C7, $C8, $C9, $CB, $CC, $CD,
DB $CE, $CF, $D1, $D2, $D3, $D4, $D5, $D6,
DB $D7, $D9, $DA, $DB, $DC, $DD, $DE, $DF,
DB $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7,
DB $E8, $E9, $E9, $EA, $EB, $EC, $ED, $EE,
DB $EE, $EF, $F0, $F1, $F1, $F2, $F3, $F3,
DB $F4, $F5, $F5, $F6, $F7, $F7, $F8, $F8,
DB $F9, $F9, $FA, $FA, $FA, $FB, $FB, $FC,
DB $FC, $FC, $FD, $FD, $FD, $FD, $FE, $FE,
DB $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FF,
r1_SmoothstepLutEnd::


r1_Smoothstep:
;;; c - value
;;; a - return value
;;; trashes hl, b
        ld      b, 0
        ld      hl, r1_SmoothstepLut
        add     hl, bc
        ld      a, [hl]
        ld      c, a
        ret


;;; ----------------------------------------------------------------------------

r1_SineLut::
DB $00, $03, $05, $06, $05, $04, $01, $80,
DB $83, $85, $85, $83, $81, $00, $03, $05,
DB $06, $05, $03, $00, $81, $83, $85, $85,
DB $83, $80, $01, $04, $05, $06, $05, $03,
DB $00, $82, $84, $85, $84, $83, $80, $01,
DB $04, $06, $06, $04, $02, $7F, $82, $84,
DB $85, $84, $82, $7F, $02, $04, $06, $06,
DB $04, $01, $80, $83, $84, $85, $84, $82,
DB $7F, $03, $05, $06, $05, $04, $01, $80,
DB $83, $85, $85, $83, $81, $00, $03, $05,
DB $06, $05, $03, $00, $81, $83, $85, $85,
DB $83, $80, $01, $04, $05, $06, $05, $03,
DB $7F, $82, $84, $85, $84, $83, $80, $01,
DB $04, $06, $06, $04, $02, $7F, $82, $84,
DB $85, $84, $82, $7F, $02, $04, $06, $06,
DB $04, $01, $80, $83, $84, $85, $84, $82,
DB $7F, $03, $05, $06, $05, $04, $01, $80,
DB $83, $85, $85, $83, $81, $00, $03, $05,
DB $06, $05, $03, $00, $81, $83, $85, $85,
DB $83, $80, $01, $04, $05, $06, $05, $03,
DB $7F, $82, $84, $85, $84, $83, $80, $01,
DB $04, $06, $06, $04, $02, $7F, $82, $84,
DB $85, $84, $82, $7F, $02, $04, $06, $06,
DB $04, $01, $80, $83, $84, $85, $84, $82,
DB $00, $03, $05, $06, $05, $04, $01, $80,
DB $83, $85, $85, $83, $81, $00, $03, $05,
DB $06, $05, $03, $00, $81, $83, $85, $85,
DB $83, $80, $01, $04, $05, $06, $05, $03,
DB $00, $82, $84, $85, $84, $83, $80, $01,
DB $04, $06, $06, $04, $02, $7F, $82, $84,
DB $85, $84, $82, $7F, $02, $04, $06, $06,
DB $04, $01, $80, $83, $84, $85, $84, $82,
r1_SineLutEnd::

r1_Sine:
;;; c - value
;;; hl
;;; result in b
        ld      b, 0
        ld      hl, r1_SineLut
        add     hl, bc
        ld      b, [hl]
        ret


;;; ----------------------------------------------------------------------------


r1_ScreenshakeMasterYLut::
._0:
DB $00, $01, $01, $02, $02, $01, $00, $7F,
DB $80, $80, $80, $80, $7F, $00, $00, $01,
DB $01, $01, $00, $00, $7F, $7F, $7F, $7F,
DB $7F, $7F, $00, $00, $00, $00, $00, $00,
._1:
DB $00, $02, $03, $04, $03, $02, $00, $80,
DB $81, $82, $82, $81, $80, $00, $01, $02,
DB $02, $01, $01, $00, $7F, $80, $80, $80,
DB $7F, $7F, $00, $00, $00, $00, $00, $00,
._2:
DB $00, $02, $04, $05, $05, $03, $01, $80,
DB $82, $83, $83, $82, $80, $00, $02, $02,
DB $03, $02, $01, $00, $7F, $80, $80, $80,
DB $80, $7F, $00, $00, $00, $00, $00, $00,
._3:
DB $00, $03, $06, $07, $06, $04, $01, $80,
DB $83, $84, $84, $83, $80, $00, $02, $03,
DB $04, $03, $02, $00, $80, $81, $81, $81,
DB $80, $7F, $00, $00, $00, $00, $00, $00,
._4:
DB $00, $04, $07, $09, $08, $05, $01, $81,
DB $84, $86, $85, $84, $81, $00, $03, $04,
DB $05, $04, $02, $00, $80, $81, $82, $81,
DB $80, $7F, $00, $01, $01, $00, $00, $00,
r1_ScreenshakeMasterYLutEnd::


;;; ----------------------------------------------------------------------------

r1_StartScreenshake:
;;; b - magnitude
        ld      a, [var_shake_magnitude]
        cp      b
        jr      C, .update
        ret
.update:
        ld      a, b
        ld      [var_shake_magnitude], a
        ld      a, 0
        ld      [var_shake_timer], a
        ret


;;; ----------------------------------------------------------------------------


r1_Screenshake:
;;; b - screenshake magnitude
;;; c - screenshake index
        push    bc
        ;; First, we want to jump to the appropiate lookup table based on the
        ;; magnitude parameter. Each sub-table contains 32 bytes of data.
        dec     b               ; Magnitude counts from 1
        swap    b               ; \ Magnitude *= 32
        sla     b               ; /
        ld      hl, r1_ScreenshakeMasterYLut
        ld      c, b            ; \
        ld      b, 0            ; | Select sub table in hl based on magnitude.
        add     hl, bc          ; /
        pop     bc
        ld      b, 0            ; \ Key into sub table based on index
        add     hl, bc          ; /
        ld      b, [hl]

        ld      a, [var_view_y]
        ld      c, a
        fcall   r1_ViewAnchorAddSignedOffset

        ld      b, 121
        ld      c, 0
        fcall   Clamp
        ld      [var_view_y], a
        ret


;;; ----------------------------------------------------------------------------

r1_ViewAnchorAddSignedOffset:
;;; b - lhs
;;; c - rhs
;;; result in a.
;;; really stupid function that adds a signed 8-bit integer to an unsigned one,
;;; which I needed to do because my view coordinates are unsigned, and I want to
;;; add a damped sine wave to them.
        ld      a, b
	cp      127
        jr      C, .add

        sub     127
        ld      b, a
        ld      a, c
        sub     a, b
        jr      C, .zero
        ret
.zero:
        ld      a, 0
        ret     Z
.add:
        ld      a, c
        add     a, b
        ret


;;; ----------------------------------------------------------------------------


r1_fatalError:
        ld      hl, sp+0        ; Store old stack pointer.

        ;; We don't know if the fatal error may have resulted from a stack
        ;; overflow, so we should reset the stack pointer before calling any
        ;; functions.
        ld      sp, STACK_BEGIN

        ;; TODO: show a bunch of stats and an error screen. Include:
        ;; 1) Stack pointer
        ;; 2) Register contents
        ;; 3) Some of the stack

        di


        ei

        push    hl





        pop     hl

        fcall   SystemReboot
        ret


;;; ----------------------------------------------------------------------------

r1_ClearOverlayBar:
        fcall   VBlankIntrWait

	ld      hl, $9c20       ; |
        ld      bc, 20          ; |
        ld      a, $32          ; |
        fcall   Memset          ; |
	ld      hl, $9c40       ; |
        ld      bc, 20          ; |
        ld      a, $32          ; |
        fcall   Memset          ; |
        ld      hl, $9c60       ; |
        ld      bc, 20          ; |
        ld      a, $32          ; |
        fcall   Memset          ; | Fill rows with black tiles.
        call    VBlankIntrWait  ; |
        VIDEO_BANK 1            ; |
        ld      hl, $9c20       ; |
        ld      bc, 20          ; |
        ld      a, $8b          ; |
        fcall   Memset          ; |
        ld      hl, $9c40       ; |
        ld      bc, 20          ; |
        ld      a, $8b          ; |
        fcall   Memset          ; |
        ld      hl, $9c60       ; |
        ld      bc, 20          ; |
        ld      a, $8b          ; |
        fcall   Memset          ; |
        VIDEO_BANK 0            ; /

        ret


;;; ----------------------------------------------------------------------------
