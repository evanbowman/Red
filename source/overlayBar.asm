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
;;; Overlay UI at the bottom of the screen.
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


;;; ----------------------------------------------------------------------------


SetOverlayTile:
;;; c - screen overlay x index
;;; a - tile number (overlay tiles start at $80)
;;; trashes b
        ld      hl, var_overlay_back_buffer
        ld      b, 0
        add     hl, bc
        ld      [hl], a
        ret


ShowOverlay:
        ld      de, _SCRN1
        ld      a, [var_overlay_alternate_pos]
        or      a
        jr      Z, .skip
        ld      de, $9e20
.skip:
        push    de
        ld      hl, var_overlay_back_buffer
        ld      bc, 20
        call    Memcpy

	ld      a, 1
        ld      [rVBK], a

        pop     hl
        ld      b, 0
.loop:
        ld      a, 20
        cp      b
        jr      Z, .loopDone

        ld      a, $80
        ld      [hl], a

        inc     hl
        inc     b
        jr      .loop

.loopDone:
        ld      a, 0
        ld      [rVBK], a

        ret


;;; ----------------------------------------------------------------------------


UpdateStaminaBar:
        ld      hl, var_player_stamina
        call    FixnumUpper
        ld      c, 1

.loopFull:
        ld      a, e
        ld      e, 16
        cp      e
        ld      e, a
        jr      C, .partial

        ld      a, e
        ld      e, 16
        sub     e
        ld      e, a
        ld      a, $2 + 8
        call    SetOverlayTile
        inc     c

        ld      a, 18
        cp      c
        jr      Z, .done
        jr      .loopFull

.partial:
        ld      a, $2
        srl     e
        add     a, e
        call    SetOverlayTile

        inc     c
        ld      a, 17
        cp      c
        jr      Z, .done

.empty:
        ld      a, $02
        call    SetOverlayTile
        inc     c
        ld      a, 17
        cp      c
        jr      NZ, .empty

.done:

        ld      a, [var_overlay_y_offset]
        ld      b, a
        ld      a, 128
        cp      b
        jr      C, .dec
        ret
.dec:
        dec     b
        ld      a, b
        ld      [var_overlay_y_offset], a

        ret


;;; ----------------------------------------------------------------------------


OverlayRow2Attrs::
DB      $8b, $8b, $8b, $8b, $83, $8b, $8b, $8b, $8b, $8b, $8b, $8b, $83
DB      $80, $80, $80, $80, $80, $80, $80 ; Whitespace, TODO...
OverlayRow2AttrsEnd::


level_str::
DB      "lv", 0


OverlayRow2TempWhitespace::
DB      $00, $00, $00, $00, $00, $00, $00


OverlayPutText:
;;; hl - text
        call    VBlankIntrWait

        push    hl
        call    SmallStrlen
        pop     hl

	push    hl
        ld      hl, $9c20
        ld      a, 20                   ; \
        sub     c                       ; |
        ld      c, a                    ; | Pad text with a margin
        srl     c                       ; |
        ld      b, 0                    ; |
        add     hl, bc                  ; /
        push    hl
        pop     de

        pop     hl


        push    hl
        push    de
        ld      hl, $9c20
        ld      bc, 20
        ld      a, $32
        call    Memset
        pop     de
        pop     hl

        call    PutTextSimple


        VIDEO_BANK 1

        ld      hl, $9c20
        ld      bc, 20
        ld      a, $8b
        call    Memset

        VIDEO_BANK 0

        ret



;;; Intended to be called infrequently, as it needs to wait on a vblank.
OverlayShowEnemyHealth:
;;; a - enemy health
	ld      e, a

        call    VBlankIntrWait
        ld      hl, $9c20
        ld      a, $0f
        ld      [hl+], a

        ld      c, 1

.loopFull:
        ld      a, e
        ld      e, 16
        cp      e
        ld      e, a
        jr      C, .partial

        ld      a, e
        ld      e, 16
        sub     e
        ld      e, a

        ld      a, $0a
        ld      [hl+], a

        inc     c

        ld      a, 18
        cp      c
        jr      Z, .done
        jr      .loopFull

.partial:
        ld      a, 2
        srl     e
        srl     e
        srl     e
        add     a, e
        ld      [hl+], a

        inc     c
        ld      a, 17
        cp      c
        jr      Z, .done

.empty:
        ld      a, $02
        ld      [hl+], a
        inc     c
        ld      a, 17
        cp      c
        jr      NZ, .empty


.done:
        ld      a, $0b
        ld      [hl], a

        VIDEO_BANK 1

        ld      hl, $9c20
        ld      bc, 20
        ld      a, $80
        call    Memset

        VIDEO_BANK 0

        ret


OverlayRow2ResetVars:
        ld      hl, OverlayRow2TempWhitespace
        ld      de, $9c2d
        ld      bc, 7
        call    Memcpy

        ret



;;; The second row of the overlay just stores some vars that don't change too
;;; frequently (level, exp, etc...), so I haven't optimized this code much.
OverlayRepaintRow2:
        ld      a, [var_level]
        ld      h, 0
        ld      l, a
        ld      de, var_temp_str1
        call    IntegerToString


        ld      a, [var_exp]
        ld      h, a
        ld      a, [var_exp + 1]
        ld      l, a
        ld      de, var_temp_str2
        call    IntegerToString


        ld      a, [var_exp_to_next_level]
        ld      h, a
        ld      a, [var_exp_to_next_level + 1]
        ld      l, a
        ld      de, var_temp_str3
        call    IntegerToString


	call    VBlankIntrWait  ; Just to be safe. Again, this code rarely runs.

        VIDEO_BANK 1
        ld      hl, OverlayRow2Attrs
        ld      de, $9c20
        ld      bc, OverlayRow2AttrsEnd - OverlayRow2Attrs
        call    Memcpy
        VIDEO_BANK 0

        ld      hl, $9c28       ; \
        ld      a, $7e          ; | Slash separator in exp fraction
        ld      [hl], a         ; /

        ld      de, $9c20
        ld      hl, level_str
        call    PutTextSimple

        ld      hl, var_temp_str1
        inc     hl
        inc     hl
        inc     hl
        ld      de, $9c22
        call    PutTextSimple

        ld      hl, var_temp_str2
        inc     hl
        inc     hl
        ld      de, $9c25
        call    PutTextSimple

        ld      hl, var_temp_str3
        inc     hl
        inc     hl
        ld      de, $9c29
        call    PutTextSimple

        call    OverlayRow2ResetVars

        ld      hl, $9c24
        ld      a, $0c
        ld      [hl], a

        ld      a, $0c
        ld      hl, $9c2c
        ld      [hl], a

        ret


;;; ----------------------------------------------------------------------------


InitOverlay:
        ld      c, 0
        ld      a, $1
        call    SetOverlayTile

        inc     c

        ld      a, $2
        call    SetOverlayTile

        inc     c

.loop1:
        ld      a, $2
        call    SetOverlayTile
        inc     c
        ld      a, 17
        cp      c
        jr      NZ, .loop1

	ld      a, $B
        call    SetOverlayTile

        inc     c

.loop2:
        ld      a, $0
        call    SetOverlayTile
        inc     c
        ld      a, 20
        cp      c
        jr      NZ, .loop2

	dec     c
        dec     c
        ld      a, $D
        call    SetOverlayTile
        inc     c
        ld      a, $E
        call    SetOverlayTile

        ret


;;; ----------------------------------------------------------------------------


OverlayPushMessage:

        ret


;;; ----------------------------------------------------------------------------
