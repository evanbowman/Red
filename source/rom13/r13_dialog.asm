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


SECTION "ROM13_DIALOG", ROMX, BANK[13]


;;; ----------------------------------------------------------------------------

r13_InventoryPalettes::
DB $BF,$73, $1A,$20, $1A,$20, $62,$1c,
DB $BF,$73, $53,$5E, $2A,$39, $86,$18,
DB $BF,$73, $EC,$31, $54,$62, $06,$2D,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
r13_InventoryPalettesEnd::

r13_InventoryTiles::
DB $00,$FF,$00,$FF,$00,$FF,$10,$E0
DB $00,$E0,$80,$E7,$07,$E7,$07,$E7
DB $00,$FF,$00,$FF,$00,$FF,$08,$07
DB $00,$07,$00,$E7,$E0,$E7,$E0,$E7
DB $E0,$E7,$E0,$E7,$E0,$E7,$00,$07
DB $08,$07,$00,$FF,$00,$FF,$00,$FF
DB $07,$E7,$07,$E7,$07,$E7,$00,$E0
DB $10,$E0,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$00
DB $00,$00,$00,$FF,$FF,$FF,$FF,$FF
DB $07,$E7,$07,$E7,$07,$E7,$07,$E7
DB $07,$E7,$07,$E7,$07,$E7,$07,$E7
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $E0,$E7,$E0,$E7,$E0,$E7,$E0,$E7
DB $E0,$E7,$E0,$E7,$E0,$E7,$E0,$E7
DB $FF,$FF,$FF,$FF,$FF,$FF,$00,$00
DB $00,$00,$00,$FF,$00,$FF,$00,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$DF,$DF,$9F,$9F
DB $1F,$1F,$9F,$9F,$DF,$DF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FB,$FB,$F9,$F9
DB $F8,$F8,$F9,$F9,$FB,$FB,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$83,$83
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
r13_InventoryTilesEnd::

;;; ----------------------------------------------------------------------------


r13_DialogBoxTemplate:
.topRow:
DB $30, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34,
DB $34, $34, $34, $34, $31, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
.middleRows:
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
.bottomRow:
DB $33, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38
DB $38, $38, $38, $38, $32, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,



;;; ----------------------------------------------------------------------------

r13_DialogEngineStep:
        ld      hl, var_dialog_current_word
        ld      a, [var_dialog_current_char] ; \
        ld      c, a                         ; | Inc, write back char index.
        inc     a                            ; |
        ld      [var_dialog_current_char], a ; /

        ld      b, 0                         ; \ Seek pos in hl
        add     hl, bc                       ; /

        ld      a, [hl]                      ; \
        or      a                            ; | Check remaining chars in word.
        jr      Z, .getNextWord              ; /

        push    hl                       ; \
        ld      a, [var_dialog_cursor_y] ; |
        or      a                        ; |
        jr      Z, .firstRow             ; | \
.secondRow:                              ; | |
        ld      hl, $9c61                ; | | Determine which screen row to
        jr      .calc                    ; | | place the text into.
.firstRow:                               ; | |
        ld      hl, $9c21                ; | |
.calc:                                   ; | /
        ld      a, [var_dialog_cursor_x] ; |
        ld      c, a                     ; |
        ld      b, 0                     ; | Calculate destination position on
                                         ; | screen, into which to put the
        add     bc                       ; | character.
        ld      d, h                     ; |
        ld      e, l                     ; |
        pop     hl                       ; /

        ld      a, [hl]         ; \ Put character onscreen
        ld      [de], a         ; /

        VIDEO_BANK 1            ; \
        ld      a, $88          ; | Set attribute for character in vram bank 1
        ld      [de], a         ; |
        VIDEO_BANK 0            ; /

        ld      a, [var_dialog_cursor_x] ; \
        inc     a                        ; | Jump to next x position.
        ld      [var_dialog_cursor_x], a ; /
        ret

.getNextWord:
        fcall   r13_DialogLoadWord
        ld      a, [var_dialog_finished]
        or      a
        jr      NZ, .loopDone

        ld      hl, var_dialog_current_word
        fcall   SmallStrlen     ; result in c

        ld      a, [var_dialog_cursor_x] ; \
        ld      b, a                     ; | A now contains remaining chars
        ld      a, 18                    ; | in row.
        sub     b                        ; /

        cp      c               ; \ If remaining less than required, go to next
        jr      C, .nextRow     ; / screen row...

        ld      a, [var_dialog_cursor_x] ; \
        inc     a                        ; | Jump to next x position.
        ld      [var_dialog_cursor_x], a ; /

        ret

.nextRow:
        ld      a, [var_dialog_cursor_y]
	or      a
        jr      NZ, .awaitButton

        inc     a
        ld      [var_dialog_cursor_y], a

        xor     a
        ld      [var_dialog_cursor_x], a

        ret

.loopDone:
        ret

.awaitButton:
        ld      de, DialogSceneAwaitButtonVBlank
        fcall   SceneSetVBlankFn

        fcall   r13_DialogInit
        ret


;;; ----------------------------------------------------------------------------

r13_DialogInit:
;;; bc - dialog string
        xor     a
        ld      [var_dialog_current_char], a
        ld      [var_dialog_counter], a
        ld      [var_dialog_finished], a
        ld      [var_dialog_cursor_x], a
        ld      [var_dialog_cursor_y], a
        ret


;;; ----------------------------------------------------------------------------

r13_DialogLoadWord:
        xor     a
        ld      [var_dialog_current_char], a
        ld      hl, var_dialog_current_word
        ld      bc, 18
        fcall   Memset

        ld      a, [var_dialog_string]
        ld      h, a
        ld      a, [var_dialog_string + 1]
        ld      l, a

.skipWhitespace:
        ld      a, [hl]
        cp      0               ; \ If null terminator, return
        jr      Z, .noWords     ; /
        cp      $32             ; \ If space, skip.
        jr      NZ, .store      ; /
        inc     hl
        jr      .skipWhitespace

.store:
        ld      de, var_dialog_current_word

.loop:
        ld      a, [hl+]
        cp      0
        jr      Z, .finished
        cp      $32
        jr      Z, .result

	ld      [de], a
        inc     de

        jr      .loop

.finished:                      ; \ No more words to parse, dec pointer back to
        dec     hl              ; / the null char.

.result:
        ld      a, h
        ld      [var_dialog_string], a
        ld      a, l
        ld      [var_dialog_string + 1], a
        ret

.noWords:
        ld      a, 1
        ld      [var_dialog_finished], a
        ret


;;; ----------------------------------------------------------------------------

r13_DialogGetNextChar:
        ret


;;; ----------------------------------------------------------------------------

r13_DialogLoadString:
        ret


;;; ----------------------------------------------------------------------------

r13_DialogOpen:
        ld      hl, r13_InventoryPalettes
        ld      b, 32
        fcall   LoadBackgroundColors

        ld      a, 104
        ld      [rWY], a

        ld      hl, r13_DialogBoxTemplate
        ld      de, $9c00
        ld      b, 9
        fcall   GDMABlockCopy

        ld      hl, r13_InventoryTiles
        ld      de, $9300
        ld      b, ((r13_InventoryTilesEnd - r13_InventoryTiles) / 16) - 1
        fcall   GDMABlockCopy

        VIDEO_BANK 1
        ld      a, $83
        ld      hl, $9c00
        ld      bc, 20
        fcall   Memset

        ld      hl, $9c20
        ld      bc, 20
        fcall   Memset

        ld      hl, $9c40
        ld      bc, 20
        fcall   Memset

        ld      hl, $9c60
        ld      bc, 20
        fcall   Memset

        ld      hl, $9c80
        ld      bc, 20
        fcall   Memset

        VIDEO_BANK 0
        ret


;;; ----------------------------------------------------------------------------

r13_DialogOpenedMessageBroadcast:
        push    bc                           ; second two message bytes, empty
        ld      c, MESSAGE_DIALOG_BOX_OPENED ; \ First two message bytes:
        push    bc                           ; / Message type, null

        ld      hl, sp+0                ; Pass pointer to message on stack

        fcall   MessageBusBroadcast

        pop     bc              ; \ Pop message arg from stack
        pop     bc              ; /
        ret


;;; ----------------------------------------------------------------------------

r13_DialogClosedMessageBroadcast:
        push    bc                           ; second two message bytes, empty
        ld      c, MESSAGE_DIALOG_BOX_CLOSED ; \ First two message bytes:
        push    bc                           ; / Message type, null

        ld      hl, sp+0                ; Pass pointer to message on stack

        fcall   MessageBusBroadcast

        pop     bc              ; \ Pop message arg from stack
        pop     bc              ; /
        ret


;;; ----------------------------------------------------------------------------
