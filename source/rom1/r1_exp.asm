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


;;; ----------------------------------------------------------------------------


r1_ExpDoLevelup:
	ld      a, [var_exp_to_next_level]      ; \
        cpl                                     ; |
        ld      h, a                            ; |
        ld      a, [var_exp_to_next_level + 1]  ; | Load negative levelup exp
        cpl                                     ; |
        ld      l, a                            ; |
        inc     hl                              ; /

        ld      a, [var_exp]            ; \
        ld      b, a                    ; | Load exp
        ld      a, [var_exp + 1]        ; |
        ld      c, a                    ; /

        add     hl, bc                  ; Subtract

        ld      a, h
        ld      [var_exp], a
        ld      a, l
        ld      [var_exp + 1], a

        ld      a, [var_level]
        ld      b, 99
        cp      b
        jr      Z, .levelMaxed

        inc     a
        ld      [var_level], a

        call    r1_SetLevelupExp
        ret

.levelMaxed:
        ret

;;; ----------------------------------------------------------------------------


r1_SetLevelupExp:
        ld      a, [var_level]
        ld      b, a
        call    r1_GetLevelupExp
        ld      a, c
        ld      [var_exp_to_next_level + 1], a
        ld      a, b
        ld      [var_exp_to_next_level], a
        ret


;;; ----------------------------------------------------------------------------


r1_GetLevelupExp:
;;; b - current level
;;; bc - result
;;; trashes hl
        ld      a, b
        ld      b, 99
        cp      b
        jr      Z, .finalLevel

        dec     a               ; level values start from 1
        sla     a               ; two bytes per exp num
        ld      c, a
        ld      b, 0
        ld      hl, r1_exp_leveling_lut
        add     hl, bc

        ld      c, [hl]
        inc     hl
        ld      b, [hl]

        ret

.finalLevel:
        ld      bc, 0
        ret


r1_exp_leveling_lut::
DB $04,$00, $08,$00, $0D,$00, $12,$00, $17,$00, $1C,$00, $21,$00,
DB $26,$00, $2B,$00, $31,$00, $37,$00, $3C,$00, $42,$00, $48,$00,
DB $4E,$00, $54,$00, $5B,$00, $61,$00, $68,$00, $6E,$00, $75,$00,
DB $7C,$00, $83,$00, $8A,$00, $92,$00, $99,$00, $A0,$00, $A8,$00,
DB $B0,$00, $B8,$00, $C0,$00, $C8,$00, $D0,$00, $D8,$00, $E1,$00,
DB $E9,$00, $F2,$00, $FB,$00, $04,$01, $0D,$01, $16,$01, $1F,$01,
DB $29,$01, $32,$01, $3C,$01, $46,$01, $50,$01, $5A,$01, $64,$01,
DB $6E,$01, $78,$01, $83,$01, $8E,$01, $98,$01, $A3,$01, $AE,$01,
DB $B9,$01, $C4,$01, $D0,$01, $DB,$01, $E7,$01, $F2,$01, $FE,$01,
DB $0A,$02, $16,$02, $22,$02, $2F,$02, $3B,$02, $48,$02, $54,$02,
DB $61,$02, $6E,$02, $7B,$02, $88,$02, $95,$02, $A3,$02, $B0,$02,
DB $BE,$02, $CB,$02, $D9,$02, $E7,$02, $F5,$02, $03,$03, $12,$03,
DB $20,$03, $2F,$03, $3D,$03, $4C,$03, $5B,$03, $6A,$03, $79,$03,
DB $88,$03, $98,$03, $A7,$03, $B7,$03, $C7,$03, $D7,$03, $E7,$03,
r1_exp_leveling_lut_end::
