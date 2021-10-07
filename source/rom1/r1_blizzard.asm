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


TESTC EQU 6


;;; 7a
;;; 87a0

;;; ----------------------------------------------------------------------------

r1_InitSnowflakes:
        ld      hl, var_entity_mem_used
        ld      bc, var_entity_mem_used_end - var_entity_mem_used
        xor     a
        fcall   Memset
        ret


;;; ----------------------------------------------------------------------------

r1_UpdateSnowflakes:
        ld      b, TESTC
	ld      hl, var_blizzard_snowflakes

.loop:
        ld      a, b
        or      a
        ret     Z

        ld      a, [hl]
        add     2
        ld      c, a
        ld      a, 168
        cp      c
        jr      C, .reset0
        ld      a, c
        ld      [hl+], a

        ld      a, [hl]
        inc     a
        ld      c, a
        ld      a, 144
        cp      c
        jr      C, .reset1
        ld      a, c
        ld      [hl+], a

.resume:
        inc     hl              ; \ Skip the second two bytes.
        inc     hl              ; /

        dec     b
        jr      .loop

.reset1:
        dec     hl              ; backtrack to first byte of struct

.reset0:
.setPosRandom:
        push    hl
        fcall   GetRandom
        ld      a, h
        pop     hl
        bit     0, a
        jr      Z, .pinLeft

.pinTop:
        ld      [hl+], a
        ld      a, 0
        ld      [hl+], a
	jr      .resume

.pinLeft:
        inc     hl
        ld      [hl], a
        ld      a, 0
        dec     hl
        ld      [hl+], a
        inc     hl
        jr      .resume


;;; ----------------------------------------------------------------------------

r1_DrawSnowflakes:
	fcall   r1_UpdateSnowflakes

        ld      b, TESTC
        ld      hl, var_blizzard_snowflakes

.loop:
        ld      a, b
        or      a
        ret     Z

        ld      d, b
        dec     d               ; otherwise off-by-one

        push    bc
	ld      a, [hl+]
        ld      b, a
        ld      a, [hl+]
        ld      c, a

        push    hl
        ld      l, d
        ld      d, 1
        ld      e, $78
        fcall   ShowSpriteSingle
        pop     hl
        pop     bc

        inc     hl
        inc     hl

        dec     b
        jr      .loop


;;; ----------------------------------------------------------------------------
