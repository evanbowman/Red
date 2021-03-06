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
;;; Utility Routines
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


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
	jr	NZ, .fill
	dec	b
	jr	NZ, .fill
.done:
	ret


;;; ----------------------------------------------------------------------------

Memcpy:
;;; hl - source
;;; de - dest
;;; bc - size

	inc	b
	inc	c
	jr	.skip
.copy:
	ld	a, [hl+]
	ld	[de], a
	inc	de
.skip:
	dec	c
	jr	NZ, .copy
	dec	b
	jr	NZ, .copy
	ret


;;; ----------------------------------------------------------------------------

Memeq:                          ; Equality test for up to 254 bytes of memory.
;;; hl - lhs pointer
;;; de - rhs pointer
;;; c - count
;;; return value: contents of the zero flag (zero if equal)
	inc	c
	jr	.skip
.check:
	ld	b, [hl]
	ld	a, [de]
        cp      b
        ret     NZ              ; return nonzero flag
	inc	de
        inc     hl
.skip:
	dec	c
	jr	NZ, .check
        xor     a               ; set zero flag
	ret


;;; ----------------------------------------------------------------------------

PointerEq:
;;; hl - lhs
;;; de - rhs
;;; return a == 0 if equal, a == 1 otherwise
        ;; Missing sbc instruction for hl is one of the most annoying things
        ;; about gb programming.
        ld      a, d
        cp      h
        jr      NZ, .notEq
        ld      a, e
        cp      l
        jr      NZ, .notEq
        xor     a
        ret
.notEq:
        ld      a, 1
        ret


;;; ----------------------------------------------------------------------------

SystemReboot:
        ld      a, $0
        ld      b, a
        ld      a, BOOTUP_A_CGB
        jp      $0100


;;; ----------------------------------------------------------------------------

ScheduleSleep:
;;; e - frames to sleep
        ldh     a, [hvar_sleep_counter]
        cp      e
        jr      C, .set
        ret
.set:
        add     a, e
        ldh     [hvar_sleep_counter], a
        ret


;;; ----------------------------------------------------------------------------

;;; Version of ForceSleep that calls per-frame update code required during the
;;; overworld scene.
ForceSleepOverworld:
;;; e - frames to sleep
        push    de
        push    bc
        fcall   DrawEntitiesSimple
        pop     bc
        pop     de

        fcall   VBlankIntrWait
        push    bc
        ld      a, HIGH(var_oam_back_buffer)
        fcall   hOAMDMA
        pop     bc

        dec     e
        ld      a, e
        cp      0
        jr      NZ, ForceSleepOverworld
        ret


;;; ----------------------------------------------------------------------------

ForceSleep:
;;; e - frames to sleep
        fcall   VBlankIntrWait
        dec     e
        ld      a, e
        cp      0
        jr      NZ, ForceSleep
        ret


;;; ----------------------------------------------------------------------------

VBlankIntrWait:
;;; NOTE: We reset the vbl flag before the loop, in case our game logic ran
;;; slow, and we missed the vblank.
        ld      a, 0
        ldh     [hvar_vbl_flag], a

.loop:
        halt
        ;; The assembler inserts a nop here to fix a hardware bug.
        ldh     a, [hvar_vbl_flag]
        or      a
        jr      z, .loop
        xor     a
        ldh     [hvar_vbl_flag], a
        ret


;;; ----------------------------------------------------------------------------

;;; This function should only be used for loading stuff during scene
;;; transitions, when you don't want to turn off the lcd. High overhead.
;;; Note: do not assume anything about the scanline position after calling this
;;; function. VramSafeMemcpy may likely return during the blank window, but
;;; don't assume anything.
;;; Also note: this is a blocking call, and the cpu will be halted outside of
;;; the vblank window.
VramSafeMemcpy:
;;; hl - source
;;; de - dest
;;; bc - size

;;; TODO: technically, we can also speed this up by copying during the hblanks,
;;; right?

        ld      a, [rLY]
        cp      145
        jr      C, .needsInitialVSync
	jr      .start

.needsInitialVSync:
        fcall   VBlankIntrWait

.start:
	inc	b
	inc	c
	jr	.skip
.top:
        ld      a, [rLY]
        ; We could keep copying during line 153, but that's a bit dicey.
        cp      152
        jr      Z, .vsync
        jr      .copy

.vsync:
	fcall   VBlankIntrWait

.copy:
	ld	a, [hl+]
	ld	[de], a
	inc	de
.skip:
	dec	c
	jr	nz, .top
	dec	b
	jr	nz, .top

	ret


;;; ----------------------------------------------------------------------------

;;; Copied from implementation of memcpy. Works fine, as long as your dest is
;;; left (at a lower address) of the source.
MemmoveLeft:
;;; hl - source
;;; de - dest
;;; bc - size
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


IntegerToString:
;;; hl - integer
;;; de - dest string buffer
;;; return de - pointer to beginning of string in buffer
        fcall   .impl
        ld      a, 0
        ld      [de], a         ; Add null terminator
        ret

.impl:
;;; hl - integer
;;; de - dest string buffer
        ld      bc, -10000
        fcall   .one
        ld      bc, -1000
        fcall   .one
        ld      bc, -100
        fcall   .one
        ld      bc, -10
        fcall   .one
        ld      c, -1
.one
        ld      a, "0"-1
.two
        inc     a
        add     hl, bc
        jr      c, .two
        push    bc
        push    af
        ld      a, b
        cpl
        ld      b, a
        ld      a, c
        cpl
        ld      c, a
        inc     bc
        fcallc  c, .carry
        pop     af
        add     hl, bc
        pop     bc
        ld      [de], a
        inc     de
        ret

.carry;
        dec     bc
        ret


;;; ----------------------------------------------------------------------------


SmallStrlen:
;;; hl - text
;;; return c - len
        ld      c, 0
.loop:
        ld      a, [hl]
        cp      0
        ret     Z

        inc     c
        inc     hl
        jr      .loop


;;; ----------------------------------------------------------------------------

Clamp:
;;; a - value
;;; b - upper
;;; c - lower
;;; trashes b, c
;;; result in a
        cp      c               ; \ If value less than lower, goto .fixLower
        jr      C, .fixLower    ; /

        ld      c, a            ; \
        ld      a, b            ; | If upper < value, return upper.
        cp      c               ; |
        ret     C               ; /

        ld      a, c            ; Result: value
        ret
.fixLower:
        ld      a, c            ; Result: lower
        ret


;;; ----------------------------------------------------------------------------

strtob:
;;; hl - string containing a number
;;; a - parsed number
        xor     a
        call    .loop
        ld      a, d
        ret
.loop:
        ld      d, a
        ld      a, [hl]
        inc     hl
        sub     $3C + 1
        add     10
        ret     NC
        ld      e, a
        ld      a, d
        add     a, a     ; double our accumulator
        add     a, a     ; double again (now x4)
        add     a, d     ; add the original (now x5)
        add     a, a     ; double again (now x10)
        add     a, e     ; add in the incoming digit
        jr      .loop


;;; ----------------------------------------------------------------------------

strtoh:
;;; hl - string containing a hex number
;;; a - parsed number
;;; eh, this is probably inefficient, I wrote it in like ten minutes
        ld      a, [hl+]
        ld      b, a
        ld      a, $42
        sub     b               ; 'f', see charmap
        ld      b, a
        ld      a, 15
        sub     b
        ld      b, a

        ld      a, [hl]          ; \
        or      a                ; | Check for null byte after the first
        jr      Z, .returnSingle ; / character.

        swap    b
        ld      c, a
        ld      a, $42
        sub     c
        ld      c, a
        ld      a, 15
        sub     c
        or      b
        ret

.returnSingle:
        ld      a, b
        ret


;;; ----------------------------------------------------------------------------

StringCompare:
;;; hl - string 1
;;; de - string 2
;;; trashes b
;;; return Z flag if equal, NZ flag otherwise
	ld      a, [de]
	ld      b, a
	ld      a, [hl+]
	cp      b
	ret     NZ
	cp      0
	ret     Z
	inc     de
	jr      StringCompare


;;; ----------------------------------------------------------------------------
