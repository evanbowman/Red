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


;;; Really bad, but who even cares? It's only for calculating damage, and
;;; doesn't take up much space in ROM.
SoftwareMul:
;;; hl - number
;;; a - repetitions
;;; trashes b, de
        ld      d, h
        ld      e, l

        ld      hl, 0

.loop:
        ld      b, 0
        cp      b
        jr      Z, .endLoop

        add     hl, de

        dec     a
        jr      .loop

.endLoop:
        ret


;;; ----------------------------------------------------------------------------


Mul16:
;;; hl - number
        ;; FIXME: `add hl, hl` repeatedly might be faster :)
        swap    h
        ld      a, h
        and     $f0
        ld      h, a

        ld      a, l
        swap    a
        and     $0f
        or      h
        ld      h, a

        ld      a, l
        swap    a
        and     $f0
        ld      l, a
        ret


;;; ----------------------------------------------------------------------------


Div16:
;;; hl - number
        swap    l
        ld      a, l
        and     $0f
        ld      l, a

        ld      a, h
        swap    a
        and     $f0
        or      l
        ld      l, a

        ld      a, h
        swap    a
        and     $0f
        ld      h, a
        ret


;;; ----------------------------------------------------------------------------


CalculateDamage:
;;; hl - attack base damage
;;; b - attacker's attack
;;; c - defender's defense

;;; Damage = B + ((B / 16) * A) - ((B / 16) * D)

        fcall   Mul16

        push    hl              ; Store original base damage

        fcall   Div16           ; \
        ld      a, b            ; | (Damage / 16) * Attacker's attack power
        push    bc              ; | Preserve c for defense calc later
        fcall   SoftwareMul     ; /
        pop     bc              ; restore c

        push    hl              ; \ copy hl -> de
        pop     de              ; /

        pop     hl              ; Restore base damage

        push    de              ; Store above calculation on stack


        push    hl              ; Store original base damage

	fcall   Div16           ; \
        ld      a, c            ; | Damage / 16 * Defender's defense power
        fcall   SoftwareMul     ; /

	push    hl              ; \ copy hl -> bc
        pop     bc              ; /

        pop     hl              ; Restore base damage

        pop     de              ; Restore first calculation

        add     hl, de

        ld      a, b            ; \
        cpl                     ; |
        ld      b, a            ; |
        ld      a, c            ; | Convert bc to a negative number.
        cpl                     ; |
        ld      c, a            ; |
        inc     bc              ; /

        add     hl, bc

        fcall   Div16

        ret


;;; ----------------------------------------------------------------------------


FormatDamage:
;;; hl - damage
;;; bc - result
	ld      a, l
        swap    a
        and     $f0
        ld      c, a

        ld      a, l
        swap    a
        and     $0f
        ld      b, a

        ld      a, h
        and     $0f
        swap    a
        or      b
        ld      b, a

        ret


;;; ----------------------------------------------------------------------------
