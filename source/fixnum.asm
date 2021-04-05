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



;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;; Fixnum
;;;
;;; I'm using a sort of fixed point numbering format, kind of. Fixnums take up
;;; three bytes in memory, consisting of:
;;; 1 upper byte
;;; 1 lower byte
;;; 1 decimal byte
;;;
;;; Combining the upper byte and the lower byte, we have a sixteen bit number.
;;; Combining the lower byte and the decimal byte, we also have a sixteen bit
;;; number.
;;;
;;; This class is potentially over-engineered, but I am not sure how large the
;;; game's rooms will ultimately be, so I am using three-byte fixnums, in case
;;; I need a larger range of coordinates.
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


;;; ---------------------------------------------------------------------------


FixnumInit:
;;; hl - address of number
;;; bc - upper bits
;;; a - decimal
;;; destroys hl
        ld      [hl], c
        inc     hl
        ld      [hl+], a
        ld      [hl], b
        ret


;;; ----------------------------------------------------------------------------


FixnumAddClamped:
;;; hl - address of number
;;; b - small unit
;;; c - fractional unit
;;; destroys de, hl, bc, a
        ld      d, [hl]
        push    hl
        push    de
        call    FixnumAdd
        pop     de
        pop     hl

        ld      a, [hl]         ; \ If current health is less than new health,
        cp      d               ; / we wrapped around, clamp to max small value.
        jr      C, .clamp
	ret

.clamp:
        ld      a, 255
        ld      [hl+], a
        ld      a, 0
        ld      [hl+], a
        ld      [hl+], a
        ret


;;; ----------------------------------------------------------------------------


;;; Interprets the decimal bits and the middle bits of a fixnum as a 16 bit
;;; integer, adds them, and increments the high bits upon overflow.
FixnumAdd:
;;; hl - address of number
;;; b - small unit
;;; c - fractional unit
;;; destroys de, hl, bc, a
        push    hl                      ; Store address, for writing back later

        ld      d, [hl]                 ; Load fractional and small units
        inc     hl
        ld      e, [hl]

        ld      a, b                    ; Store small unit in a, load to h later

        inc     hl                      ; inc ptr to location of large unit
        ld      b, [hl]                 ; Load large unit

        ld      h, a                    ; store small unit argument in h

        ld      a, c                    ; load fractional unit argument into l
        ld      l, a

        add     hl, de                  ; Add small and fractional units params
        jr      NC, .writeback          ; If the addition did not overflow
.inc_large_unit:
;;; Ok, so at this point, our addition overflowed the fractional bits and the
;;; small bits, so we need to increment the large bits.
        inc     b
        ;; ld      d, 0  (should already be zeroed by overflow)
        ;; ld      e, 0  is this even necessary?

.writeback:
        ld      d, h
        ld      e, l
        pop     hl

        ld      [hl], d
        inc     hl
        ld      [hl], e
        inc     hl
        ld      [hl], b
        ret


;;; ----------------------------------------------------------------------------


FixnumSub:
;;; hl - address of number
;;; b - small unit
;;; c - fractional unit
;;; This is a bit more complicated, because there's no subtraction instruction
;;; for hl.
;;; return d - new upper byte
;;; return e - new lower byte
;;; return a - new fractional byte
        push    hl
        ld      e, [hl]                      ; small units
        inc     hl
        ld      a, [hl]
        inc     hl
        ld      d, [hl]

        sub     c
        push    af
        jr      C, .decFracBits
        jr      .subSmallBits
.decFracBits:
        ld      a, e
        or      a
        jr      Z, .decCarry
        jr      .doDec
.decCarry:
        dec     d
.doDec:
        dec     e
.subSmallBits:
        ld      a, e
        sub     b
        ld      e, a
        jr      C, .decUpperBits
        jr      .done
.decUpperBits:
        dec     d
.done:
        pop     af
        pop     hl
        ld      [hl], e
        inc     hl
        ld      [hl+], a
        ld      [hl], d
        ret


FixnumUpper:
;;; hl - address of number
;;; return result in de
;;; destroys hl
        ld      e, [hl]
        inc     hl
        inc     hl
        ld      d, [hl]
        ret



;;; ---------------------------------------------------------------------------
