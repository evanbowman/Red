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


SECTION "ROM14_SHELL_CODE", ROMX, BANK[14]


;;; ----------------------------------------------------------------------------

r14_ShellKeypad_r0:
DB      "zygfvq", 0, 0
r14_ShellKeypad_r1:
DB      "mbidlj", 0, 0
r14_ShellKeypad_r2:
DB      "waoeuk", 0, 0
r14_ShellKeypad_r3:
DB      "phtnsr", 0, 0
r14_ShellKeypad_r4:
DB      "xc()- ", 0, 0
r14_ShellKeypad_r5:
DB      ",'0123", 0, 0
r14_ShellKeypad_r6:
DB      "456789", 0, 0


;;; ----------------------------------------------------------------------------

r14_InventoryPalettes::
DB $00,$04, $1A,$20, $1A,$20, $1A,$20,
DB $BF,$73, $53,$5E, $2A,$39, $86,$18,
DB $BF,$73, $EC,$31, $54,$62, $06,$2D,
DB $D7,$6A, $6B,$49, $00,$00, $00,$04,
DB $BF,$73, $53,$5E, $AD,$24, $27,$6A,
DB $BF,$73, $27,$6A, $43,$59, $14,$36,
DB $BF,$73, $5F,$4B, $55,$36, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
r14_InventoryPalettesEnd::


;;; ----------------------------------------------------------------------------

r14_ShellCommandSceneEnterImpl:
        fcall   r14_ShellInit

        ld      de, VoidVBlankFn
        fcall   SceneSetVBlankFn

        xor     a
        ld      [var_shell_cursor_x], a
        ld      [var_shell_cursor_y], a

        ;; Eh, it's just the admin shell, who cares if the screen flickers.
        fcall   LcdOff

        ld      hl, var_oam_back_buffer
        xor     a
        ld      bc, OAM_SIZE * OAM_COUNT
        fcall   Memset

        ld      hl, $9c00
        ld      a, $32
        ld      bc, 32 * 18
        fcall   Memset

        VIDEO_BANK 1
        ld      hl, $9c00
        ld      a, $8b
        ld      bc, 32 * 18
        fcall   Memset
        VIDEO_BANK 0

        ld      hl, r14_ShellKeypad_r0
        ld      de, $9c41
        ld      b, $8B
        fcall   PutText

        ld      hl, r14_ShellKeypad_r1
        ld      de, $9c61
        ld      b, $8B
        fcall   PutText

        ld      hl, r14_ShellKeypad_r2
        ld      de, $9c81
        ld      b, $8B
        fcall   PutText

        ld      hl, r14_ShellKeypad_r3
        ld      de, $9ca1
        ld      b, $8B
        fcall   PutText

        ld      hl, r14_ShellKeypad_r4
        ld      de, $9cc1
        ld      b, $8B
        fcall   PutText

	ld      hl, r14_ShellKeypad_r5
        ld      de, $9ce1
        ld      b, $8B
        fcall   PutText

	ld      hl, r14_ShellKeypad_r6
        ld      de, $9d01
        ld      b, $8B
        fcall   PutText

        ld      b, r14_InventoryPalettesEnd - r14_InventoryPalettes
        ld      hl, r14_InventoryPalettes
        fcall   LoadBackgroundColors


        ld      a, HIGH(var_oam_back_buffer)
        fcall   hOAMDMA

        xor     a
        ld      [rWY], a

        fcall   LcdOn

        ret


;;; ----------------------------------------------------------------------------

r14_ShellCursorTileAddress:
;;; trashes bc
;;; result in hl
        ld      a, [var_shell_cursor_y]
        ld      c, a
        ld      b, 0
        fcall   Mul32
        ld      hl, $9c41
        add     hl, bc

        ld      a, [var_shell_cursor_x]
        ld      c, a
        ld      b, 0

        add     hl, bc

        ret


;;; ----------------------------------------------------------------------------

r14_ShellCommandSceneUpdateImpl:
        fcall   VBlankIntrWait
        fcall   r14_ShellCursorTileAddress
        VIDEO_BANK 1
        ld      a, $8b
        ld      [hl], a
        VIDEO_BANK 0

.checkUp:
        ldh     a, [hvar_joypad_current]
        bit     PADB_UP, a
        jr      Z, .checkDown

	ld      a, [var_shell_cursor_y]
        cp      0
        jr      Z, .checkDown

        dec     a
        ld      [var_shell_cursor_y], a

.checkDown:
        ldh     a, [hvar_joypad_current]
        bit     PADB_DOWN, a
        jr      Z, .checkLeft

        ld      a, [var_shell_cursor_y]
        ld      b, a
        ld      a, 5
        cp      b
        jr      C, .checkLeft

        inc     b
        ld      a, b
        ld      [var_shell_cursor_y], a

.checkLeft:
        ldh     a, [hvar_joypad_current]
        bit     PADB_LEFT, a
        jr      Z, .checkRight

        ld      a, [var_shell_cursor_x]
        cp      0
        jr      Z, .checkRight
        dec     a
        ld      [var_shell_cursor_x], a

.checkRight:
        ldh     a, [hvar_joypad_current]
        bit     PADB_RIGHT, a
        jr      Z, .update

        ld      a, [var_shell_cursor_x]
        ld      b, a
        ld      a, 4
        cp      b
        jr      C, .update

        inc     b
        ld      a, b
        ld      [var_shell_cursor_x], a

.update:
        fcall   r14_ShellCursorTileAddress
        VIDEO_BANK 1
        ld      a, $88
        ld      [hl], a
        VIDEO_BANK 0


.tryAppendChar:
        ldh     a, [hvar_joypad_current]
        bit     PADB_A, a
        jr      Z, .tryPopChar

        ld      hl, var_shell_command_buffer ; \
        ld      a, [var_command_buffer_size] ; |
        cp      18                           ; | \ Skip if screen is full
        jr      Z, .tryPopChar               ; | /
        inc     a                            ; |
        ld      [var_command_buffer_size], a ; | Seek write position in command
        dec     a                            ; | buffer.
        ld      c, a                         ; |
        ld      b, 0                         ; |
        add     hl, bc                       ; /

        push    hl                         ; \
        fcall   r14_ShellCursorTileAddress ; | Load tile at cursor.
        ld      a, [hl]                    ; |
        pop     hl                         ; /

        ld      [hl], a         ; Put cursor tile into command buffer

.tryPopChar:
        ldh     a, [hvar_joypad_current]
        bit     PADB_B, a
        jr      Z, .showBuffer

        ld      hl, var_shell_command_buffer ; \
        ld      a, [var_command_buffer_size] ; |
        or      a                            ; | \ If empty, exit.
        jr      Z, .exitScene                ; | /
        dec     a                            ; |
        ld      [var_command_buffer_size], a ; | Seek write position in command
                                             ; | buffer.
        ld      c, a                         ; |
        ld      b, 0                         ; |
        add     hl, bc                       ; /
        ld      a, $32
        ld      [hl], a


.showBuffer:
        ld      hl, var_shell_command_buffer
        ld      de, $9e01
        ld      b, $8B
        fcall   PutText


.checkCommandEntry:
        ldh     a, [hvar_joypad_current]
        bit     PADB_START, a
        ret     Z
        fcall   r14_ShellEvalCommand

        fcall   r14_ShellInit
        ret

.exitScene:
        ld      de, OverworldSceneEnter
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

TEST_STR:
DB      "  room 3 5", 0



r14_ShellRoomCommandName:
DB      "room", 0
r14_ShellRoomCommand:
        ;; ...
        ret



;;; ----------------------------------------------------------------------------


r14_ShellCommandTable:
DW      r14_ShellRoomCommandName, r14_ShellRoomCommand
DW      $0000, $0000            ; Last row should contain null pointers.
r14_ShellCommandTableEnd:


r14_ShellLookupCommand:
;;; hl - command name
;;; trashes bc
;;; result in de
;;; sets the C flag if found, otherwise, reset (junk in de if not found)
        ld      bc, r14_ShellCommandTable

.loop:
        ld      a, [bc]
        ld      e, a
        inc     bc
        ld      a, [bc]
        ld      d, a
        inc     bc

        ld      a, d            ; \
        or      e               ; | Check if loaded command name is null
        jr      Z, .notFound    ; /

        push    hl
        push    bc
        fcall   r14_StringCompare
        pop     bc
        pop     hl
        jr      Z, .found

        inc     bc              ; \ Skip over the next two bytes in the table.
        inc     bc              ; /

        jr      .loop
        ret

.found:
        ld      a, [bc]
        ld      e, a
        inc     bc
        ld      a, [bc]
        ld      d, a
        scf                     ; set C flag if found
        ret

.notFound:
        or      a               ; reset C flag, not found
        ret


;;; ----------------------------------------------------------------------------



r14_ShellTest:
        RAM_BANK 7

        fcall   r14_ShellInit

        ld      hl, TEST_STR
        ld      de, var_shell_command_buffer
        ld      bc, 11
        fcall   Memcpy

        fcall   r14_ShellEvalCommand
        ret


;;; ----------------------------------------------------------------------------

r14_ShellInit:
	ld      hl, var_shell_command_buffer
        xor     a
        ld      [var_command_buffer_size], a
        ld      bc, 32
        fcall   Memset

	ld      hl, var_shell_command_buffer
        ld      a, $32
        ld      bc, 18
        fcall   Memset
        ret


;;; ----------------------------------------------------------------------------

r14_ShellParseCommandName:
        ld      hl, var_shell_parse_buffer
        ld      a, 0
        ld      bc, 32
        fcall   Memset

        ld      hl, var_shell_parse_buffer
        ld      de, var_shell_command_buffer

.skipLeadingWhitespace:
        ld      a, [de]
        cp      $32
        jr      NZ, .loop
        inc     de
        jr      .skipLeadingWhitespace

.loop:
	ld      a, [de]
        cp      $32             ; ' ', see charmap
        jr      Z, .done        ; \
        or      a               ; | Finish parsing if char is null or ' '
        jr      Z, .done        ; /
        ld      [hl+], a
        inc     de
        jr      .loop
        ret

.done:
        ld      a, d
        ld      [var_shell_argstring], a
        ld      a, e
        ld      [var_shell_argstring + 1], a
        ret



;;; ----------------------------------------------------------------------------


r14_StringCompare:
;;; hl - string 1
;;; de - string 2
;;; trashes b
;;; return Z flag if equal, NZ flag otherwise
	ld      a, [de]
	ld      b, a
	ld      a, [hl]
	cp      b
	ret     NZ
	cp      0
	ret     Z
	inc     hl
	inc     de
	jr      r14_StringCompare


;;; ----------------------------------------------------------------------------

r14_ShellEvalCommand:
        fcall   r14_ShellParseCommandName

        ld      hl, var_shell_parse_buffer
        fcall   r14_ShellLookupCommand
        jr      NC, .notFound

        ld      h, d
        ld      l, e

        INVOKE_HL
        ret

.notFound:
        ret


;;; ----------------------------------------------------------------------------
