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



AddExp:
;;; hl - amount
;;; trashes bc, de, hl
        ld      a, $ff
        ld      [hvar_exp_changed_flag], a

        ld      a, [var_exp]
        ld      b, a
        ld      a, [var_exp + 1]
        ld      c, a

        add     hl, bc

        ld      a, h
        ld      [var_exp], a
        ld      a, l
        ld      [var_exp + 1], a

        ;; Yeah, this is lazy. There's no sbc instruction for 16-bit numbers,
        ;; so we're converting to ascii and comparing the ascii strings.
        ;; Technically, there are probably bit-fiddling hacks that you can do
        ;; for comparing 16-bit, but this code is not on the fast path, and
        ;; there are things that I'd rather be doing than optimizing this.
        ld      a, [var_exp]
        ld      h, a
        ld      a, [var_exp + 1]
        ld      l, a
        ld      de, var_temp_str2
        fcall   IntegerToString

        ld      a, [var_exp_to_next_level]
        ld      h, a
        ld      a, [var_exp_to_next_level + 1]
        ld      l, a
        ld      de, var_temp_str3
        fcall   IntegerToString

        ld      de, var_temp_str3 + 2
        ld      hl, var_temp_str2 + 2

        ld      b, [hl]
        ld      a, [de]

        cp      b
        jr      C, .levelupReady
        jr      Z, .check2
	jr      .levelupNotReady

.check2:
        inc     hl
        inc     de

        ld      b, [hl]
        ld      a, [de]

        cp      b
        jr      C, .levelupReady
        jr      Z, .check3
	jr      .levelupNotReady

.check3:
        inc     hl
        inc     de

        ld      b, [hl]
        ld      a, [de]

        cp      b
        jr      C, .levelupReady
        jr      Z, .levelupReady

.levelupNotReady:

        ret


.levelupReady:

        ld      a, $ff
        ld      [hvar_exp_levelup_ready_flag], a

        ret
