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

r1_HalfSineLut::
DB $00, $03, $06, $09, $0C, $0F, $12, $15,
DB $18, $1C, $1F, $22, $25, $28, $2B, $2E,
DB $30, $33, $36, $39, $3C, $3F, $41, $44,
DB $47, $49, $4C, $4E, $51, $53, $55, $58,
DB $5A, $5C, $5E, $60, $62, $64, $66, $68,
DB $6A, $6C, $6D, $6F, $70, $72, $73, $75,
DB $76, $77, $78, $79, $7A, $7B, $7C, $7C,
DB $7D, $7E, $7E, $7F, $7F, $7F, $7F, $7F,
DB $80, $7F, $7F, $7F, $7F, $7F, $7E, $7E,
DB $7D, $7C, $7C, $7B, $7A, $79, $78, $77,
DB $76, $75, $73, $72, $70, $6F, $6D, $6C,
DB $6A, $68, $66, $64, $62, $60, $5E, $5C,
DB $5A, $58, $55, $53, $51, $4E, $4C, $49,
DB $47, $44, $41, $3F, $3C, $39, $36, $33,
DB $30, $2E, $2B, $28, $25, $22, $1F, $1C,
DB $18, $15, $12, $0F, $0C, $09, $06, $03,
r1_HalfSineLutEnd::
ASSERT(r1_HalfSineLutEnd - r1_HalfSineLut == 128)


;;; One half period of a sine (just the positive part).
r1_HalfSine:
;;; c - value
;;; hl
;;; result in b
;;; preserves a
        srl     c
        ld      b, 0
        ld      hl, r1_HalfSineLut
        add     hl, bc
        ld      b, [hl]
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
;;; preserves a
        ld      b, 0
        ld      hl, r1_SineLut
        add     hl, bc
        ld      b, [hl]
        ret


;;; ----------------------------------------------------------------------------


r1_ScreenshakeMasterYLut::
._0:
DB $00, $00, $00, $01, $01, $00, $00, $7F,
DB $7F, $7F, $7F, $7F, $7F, $00, $00, $00,
DB $00, $00, $00, $00, $7F, $7F, $7F, $7F,
DB $7F, $7F, $00, $00, $00, $00, $00, $00,
._1:
DB $00, $01, $01, $02, $02, $01, $00, $7F,
DB $80, $80, $80, $80, $7F, $00, $00, $01,
DB $01, $01, $00, $00, $7F, $7F, $7F, $7F,
DB $7F, $7F, $00, $00, $00, $00, $00, $00,
._2:
DB $00, $02, $03, $04, $03, $02, $00, $80,
DB $81, $82, $82, $81, $80, $00, $01, $02,
DB $02, $01, $01, $00, $7F, $80, $80, $80,
DB $7F, $7F, $00, $00, $00, $00, $00, $00,
._3:
DB $00, $02, $04, $05, $05, $03, $01, $80,
DB $82, $83, $83, $82, $80, $00, $02, $02,
DB $03, $02, $01, $00, $7F, $80, $80, $80,
DB $80, $7F, $00, $00, $00, $00, $00, $00,
._4:
DB $00, $03, $06, $07, $06, $04, $01, $80,
DB $83, $84, $84, $83, $80, $00, $02, $03,
DB $04, $03, $02, $00, $80, $81, $81, $81,
DB $80, $7F, $00, $00, $00, $00, $00, $00,
._5:
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
        jr      Z, .update
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

r1_SmallIntegerToString:
;;; c - integer
;;; de - buffer to fill data with
        fcall   r1_SmallIntToStringImpl ; result in hl
        push    hl
        fcall   SmallStrlen     ; result in c
        inc     c               ; we want to copy the null terminator too.
        pop     hl

        ld      b, 0            ; clear b, bc now holds size to copy
        fcall   Memcpy
        ret


;;; ----------------------------------------------------------------------------


;;; NOTE: should not be called outside of rom1 or rom0. Returns a pointer to a
;;; string in rom1, so other rom banks can't really use the data for anything.
;;; we have a more substantial int to string function for 16 bit integers
;;; anyway.
r1_SmallIntToStringImpl:
;;; c - int
;;; trashes bc, hl
        xor     a
        sla     c               ; \
        adc     0               ; |
        sla     a               ; | Multiply c * 4, result in bc.
        sla     c               ; |
        adc     0               ; |
        ld      b, a            ; /
        ld      hl, .table
        add     hl, bc
        ret
.table:
DB "0", 0, 0, 0,
DB "1", 0, 0, 0,
DB "2", 0, 0, 0,
DB "3", 0, 0, 0,
DB "4", 0, 0, 0,
DB "5", 0, 0, 0,
DB "6", 0, 0, 0,
DB "7", 0, 0, 0,
DB "8", 0, 0, 0,
DB "9", 0, 0, 0,
DB "10", 0, 0,
DB "11", 0, 0,
DB "12", 0, 0,
DB "13", 0, 0,
DB "14", 0, 0,
DB "15", 0, 0,
DB "16", 0, 0,
DB "17", 0, 0,
DB "18", 0, 0,
DB "19", 0, 0,
DB "20", 0, 0,
DB "21", 0, 0,
DB "22", 0, 0,
DB "23", 0, 0,
DB "24", 0, 0,
DB "25", 0, 0,
DB "26", 0, 0,
DB "27", 0, 0,
DB "28", 0, 0,
DB "29", 0, 0,
DB "30", 0, 0,
DB "31", 0, 0,
DB "32", 0, 0,
DB "33", 0, 0,
DB "34", 0, 0,
DB "35", 0, 0,
DB "36", 0, 0,
DB "37", 0, 0,
DB "38", 0, 0,
DB "39", 0, 0,
DB "40", 0, 0,
DB "41", 0, 0,
DB "42", 0, 0,
DB "43", 0, 0,
DB "44", 0, 0,
DB "45", 0, 0,
DB "46", 0, 0,
DB "47", 0, 0,
DB "48", 0, 0,
DB "49", 0, 0,
DB "50", 0, 0,
DB "51", 0, 0,
DB "52", 0, 0,
DB "53", 0, 0,
DB "54", 0, 0,
DB "55", 0, 0,
DB "56", 0, 0,
DB "57", 0, 0,
DB "58", 0, 0,
DB "59", 0, 0,
DB "60", 0, 0,
DB "61", 0, 0,
DB "62", 0, 0,
DB "63", 0, 0,
DB "64", 0, 0,
DB "65", 0, 0,
DB "66", 0, 0,
DB "67", 0, 0,
DB "68", 0, 0,
DB "69", 0, 0,
DB "70", 0, 0,
DB "71", 0, 0,
DB "72", 0, 0,
DB "73", 0, 0,
DB "74", 0, 0,
DB "75", 0, 0,
DB "76", 0, 0,
DB "77", 0, 0,
DB "78", 0, 0,
DB "79", 0, 0,
DB "80", 0, 0,
DB "81", 0, 0,
DB "82", 0, 0,
DB "83", 0, 0,
DB "84", 0, 0,
DB "85", 0, 0,
DB "86", 0, 0,
DB "87", 0, 0,
DB "88", 0, 0,
DB "89", 0, 0,
DB "90", 0, 0,
DB "91", 0, 0,
DB "92", 0, 0,
DB "93", 0, 0,
DB "94", 0, 0,
DB "95", 0, 0,
DB "96", 0, 0,
DB "97", 0, 0,
DB "98", 0, 0,
DB "99", 0, 0,
DB "100", 0,
DB "101", 0,
DB "102", 0,
DB "103", 0,
DB "104", 0,
DB "105", 0,
DB "106", 0,
DB "107", 0,
DB "108", 0,
DB "109", 0,
DB "110", 0,
DB "111", 0,
DB "112", 0,
DB "113", 0,
DB "114", 0,
DB "115", 0,
DB "116", 0,
DB "117", 0,
DB "118", 0,
DB "119", 0,
DB "120", 0,
DB "121", 0,
DB "122", 0,
DB "123", 0,
DB "124", 0,
DB "125", 0,
DB "126", 0,
DB "127", 0,
DB "128", 0,
DB "129", 0,
DB "130", 0,
DB "131", 0,
DB "132", 0,
DB "133", 0,
DB "134", 0,
DB "135", 0,
DB "136", 0,
DB "137", 0,
DB "138", 0,
DB "139", 0,
DB "140", 0,
DB "141", 0,
DB "142", 0,
DB "143", 0,
DB "144", 0,
DB "145", 0,
DB "146", 0,
DB "147", 0,
DB "148", 0,
DB "149", 0,
DB "150", 0,
DB "151", 0,
DB "152", 0,
DB "153", 0,
DB "154", 0,
DB "155", 0,
DB "156", 0,
DB "157", 0,
DB "158", 0,
DB "159", 0,
DB "160", 0,
DB "161", 0,
DB "162", 0,
DB "163", 0,
DB "164", 0,
DB "165", 0,
DB "166", 0,
DB "167", 0,
DB "168", 0,
DB "169", 0,
DB "170", 0,
DB "171", 0,
DB "172", 0,
DB "173", 0,
DB "174", 0,
DB "175", 0,
DB "176", 0,
DB "177", 0,
DB "178", 0,
DB "179", 0,
DB "180", 0,
DB "181", 0,
DB "182", 0,
DB "183", 0,
DB "184", 0,
DB "185", 0,
DB "186", 0,
DB "187", 0,
DB "188", 0,
DB "189", 0,
DB "190", 0,
DB "191", 0,
DB "192", 0,
DB "193", 0,
DB "194", 0,
DB "195", 0,
DB "196", 0,
DB "197", 0,
DB "198", 0,
DB "199", 0,
DB "200", 0,
DB "201", 0,
DB "202", 0,
DB "203", 0,
DB "204", 0,
DB "205", 0,
DB "206", 0,
DB "207", 0,
DB "208", 0,
DB "209", 0,
DB "210", 0,
DB "211", 0,
DB "212", 0,
DB "213", 0,
DB "214", 0,
DB "215", 0,
DB "216", 0,
DB "217", 0,
DB "218", 0,
DB "219", 0,
DB "220", 0,
DB "221", 0,
DB "222", 0,
DB "223", 0,
DB "224", 0,
DB "225", 0,
DB "226", 0,
DB "227", 0,
DB "228", 0,
DB "229", 0,
DB "230", 0,
DB "231", 0,
DB "232", 0,
DB "233", 0,
DB "234", 0,
DB "235", 0,
DB "236", 0,
DB "237", 0,
DB "238", 0,
DB "239", 0,
DB "240", 0,
DB "241", 0,
DB "242", 0,
DB "243", 0,
DB "244", 0,
DB "245", 0,
DB "246", 0,
DB "247", 0,
DB "248", 0,
DB "249", 0,
DB "250", 0,
DB "251", 0,
DB "252", 0,
DB "253", 0,
DB "254", 0,
DB "255", 0,
.end:



;;; ----------------------------------------------------------------------------
