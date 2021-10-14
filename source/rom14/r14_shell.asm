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

r14_RefreshRoom:
;;; Redisplay room after updating room variables.
        WIDE_CALL r1_StoreRoomEntities ; ...
        WIDE_CALL MapLoad2__rom0_only  ; Load the room data into ram.
        WIDE_CALL MapShow              ; Write the room's tiles to vram
        WIDE_CALL r1_PlayerNew         ; Add the player to the room
        WIDE_CALL r1_LoadRoomEntities  ; Load entities from the new room's data
        ret


;;; ----------------------------------------------------------------------------

r14_ShellRoomCommandName:
DB      "room", 0
r14_ShellRoomCommand:
;;; Jump to a specific room. room <x> <y>

        ;; Probably the most complex command, in its implementation. Requires
        ;; a bunch of stuff to be called in a specific order.

        fcall   r14_ShellCommandReadIntegerArgument
        ld      b, a
        push    bc
        fcall   r14_ShellCommandReadIntegerArgument
        pop     bc
        ld      c, a

        push    bc                     ; \
        WIDE_CALL r1_StoreRoomEntities ; | Write back current room entities to
        pop     bc                     ; / map ram.

        ld      a, b            ; \
        ld      [var_room_x], a ; | Adjust current room coordinates to desired
        ld      a, c            ; | room.
        ld      [var_room_y], a ; /

        ;; MapLoad2 switches banks, i.e. must use widecall
        WIDE_CALL MapLoad2__rom0_only ; Load the room data into ram.
        ;; MapShow contains a plain LONG_CALL, i.e. must use widecall
        WIDE_CALL MapShow       ; Write the room's tiles to vram

        WIDE_CALL r1_PlayerNew  ; Add the player to the room
        WIDE_CALL r1_LoadRoomEntities ; Load entities from the new room's data
        ret


;;; ----------------------------------------------------------------------------

r14_ShellItemCommandName:
DB      "item", 0
r14_ShellItemCommand:
;;; Add an item to the player's inventory. item <n>
        fcall   r14_ShellCommandReadIntegerArgument
        ld      b, a
        fcall   InventoryAddItem
        ret


;;; ----------------------------------------------------------------------------

r14_ShellLivesCommandName:
DB      "lives", 0
r14_ShellLivesCommand:
;;; Set lives. lives <n>
        fcall   r14_ShellCommandReadIntegerArgument
        or      a               ; \ Cannot set lives to zero.
        ret     Z               ; /

        ld      b, a
        ld      a, 9
        cp      b
        ret     C               ; cannot set lives > 9.
        ld      a, b
        ld      [var_lives], a
        ret


;;; ----------------------------------------------------------------------------

r14_ShellLevelCommandName:
DB      "level", 0
r14_ShellLevelCommand:
;;; Set player's level. level <n>
        fcall   r14_ShellCommandReadIntegerArgument
        ld      [var_level], a
        ret


;;; ----------------------------------------------------------------------------

r14_ShellRoomSetFlagsCommandName:
DB      "rm-set-fl", 0
r14_ShellRoomSetFlagsCommand:
;;; Set flags for the current room. rm-set-fl <byte>
        ld      a, [var_room_x]
        ld      b, a

        ld      a, [var_room_y]
        ld      c, a

        RAM_BANK 1
        WIDE_CALL r1_LoadRoom

        push    hl
        fcall   r14_ShellCommandReadIntegerArgument
        pop     hl

        ld      [hl], a

        fcall   r14_RefreshRoom
        ret


;;; ----------------------------------------------------------------------------

r14_ShellRoomSetVariantCommandName:
DB      "rm-set-vr", 0
r14_ShellRoomSetVariantCommand:
;;; Set the current room's variant. rm-set-vr <n>
        ld      a, [var_room_x]
        ld      b, a

        ld      a, [var_room_y]
        ld      c, a

        RAM_BANK 1
        WIDE_CALL r1_LoadRoom
        inc     hl

        push    hl
        fcall   r14_ShellCommandReadIntegerArgument
        pop     hl

        ld      [hl], a

        fcall   r14_RefreshRoom
        ret


;;; ----------------------------------------------------------------------------

r14_ShellAddEntityCommandName:
DB      "entity", 0
r14_ShellAddEntityCommand:
;;; Put an entity into the current room. entity <x> <y> <type>
        fcall   r14_ShellCommandReadIntegerArgument
        and     $0f
        swap    a
        ld      b, a
        push    bc
        fcall   r14_ShellCommandReadIntegerArgument
        and     $0f
        swap    a
        pop     bc
        ld      c, a

        push    bc
        fcall   r14_ShellCommandReadIntegerArgument
        pop     bc
        ld      e, a

        WIDE_CALL r1_SpawnEntityAlt

        ret


;;; ----------------------------------------------------------------------------

r14_ShellClearCommandName:
DB      "clear", 0
r14_ShellClearCommand:
;;; Clear entities from the current room.
        fcall   EntityBufferReset
        WIDE_CALL r1_PlayerNew

        ;; TODO: also clear collectibles (which requires a room refresh!).
        ret


;;; ----------------------------------------------------------------------------

r14_ShellRebootCommandName:
DB      "reboot", 0


;;; ----------------------------------------------------------------------------

;;; NOTE: command names should be no longer than nine characters.
r14_ShellCommandTable:
DW      r14_ShellRoomCommandName, r14_ShellRoomCommand
DW      r14_ShellItemCommandName, r14_ShellItemCommand
DW      r14_ShellLivesCommandName, r14_ShellLivesCommand
DW      r14_ShellLevelCommandName, r14_ShellLevelCommand
DW      r14_ShellAddEntityCommandName, r14_ShellAddEntityCommand
DW      r14_ShellRoomSetFlagsCommandName, r14_ShellRoomSetFlagsCommand
DW      r14_ShellRoomSetVariantCommandName, r14_ShellRoomSetVariantCommand
DW      r14_ShellClearCommandName, r14_ShellClearCommand
DW      r14_ShellRebootCommandName, SystemReboot
DW      $0000, $0000            ; Last row should contain null pointers.
r14_ShellCommandTableEnd:


;;; ----------------------------------------------------------------------------

r14_ShellCommandParseNextArgument:
;;; trashes a bunch of registers
;;; overwrites var_shell_parse_argument with the parsed string
        ld      hl, var_shell_parse_argument
        xor     a
        ld      bc, 32
        fcall   Memset

        ld      a, [var_shell_argstring]
        ld      d, a
        ld      a, [var_shell_argstring + 1]
        ld      e, a

.skipLeadingWhitespace:
        ld      a, [de]
        cp      $32
        jr      NZ, .setupStore
        inc     de
        jr      .skipLeadingWhitespace

.setupStore:
        ld      hl, var_shell_parse_argument

.store:
        ld      a, [de]
        cp      $32
        jr      Z, .done
        cp      0
        jr      Z, .done

        ld      [hl+], a
        inc     de

        jr      .store

.done:
        ld      a, d
        ld      [var_shell_argstring], a
        ld      a, e
        ld      [var_shell_argstring + 1], a
        ret


;;; ----------------------------------------------------------------------------

;;; r14_ShellParseCommandName stores a pointer to the command argument vector in
;;; ram. You may call r14_shellCommandReadInteger to parse each integer
;;; argument. NOTE: an argument must be either a decimal value, or of the form
;;; h<hex value>.
r14_ShellCommandReadIntegerArgument:
;;; trashes a bunch of registers
;;; result in a
        fcall   r14_ShellCommandParseNextArgument
        ld      hl, var_shell_parse_argument
        ld      a, [hl]
        cp      $44             ; 'h', see charmap
        jr      Z, .parseHexNumber

.parseDecimalNumber:
        fcall   strtob
        ret

.parseHexNumber:
        inc     hl              ; move to next byte, as first byte was 'h'
        fcall   strtoh
        ret


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

        ld      de, $9e20
        ld      a, $79
        ld      [de], a

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
        jr      Z, .wrapUp

        dec     a
        ld      [var_shell_cursor_y], a
        jr      .checkDown

.wrapUp:
        ld      a, 6
        ld      [var_shell_cursor_y], a

.checkDown:
        ldh     a, [hvar_joypad_current]
        bit     PADB_DOWN, a
        jr      Z, .checkLeft

        ld      a, [var_shell_cursor_y]
        ld      b, a
        ld      a, 5
        cp      b
        jr      C, .wrapDown

        inc     b
        ld      a, b
        ld      [var_shell_cursor_y], a
        jr      .checkLeft

.wrapDown:
        xor     a
        ld      [var_shell_cursor_y], a

.checkLeft:
        ldh     a, [hvar_joypad_current]
        bit     PADB_LEFT, a
        jr      Z, .checkRight

        ld      a, [var_shell_cursor_x]
        cp      0
        jr      Z, .wrapLeft
        dec     a
        ld      [var_shell_cursor_x], a
        jr      .checkRight

.wrapLeft:
        ld      a, 5
        ld      [var_shell_cursor_x], a

.checkRight:
        ldh     a, [hvar_joypad_current]
        bit     PADB_RIGHT, a
        jr      Z, .update

        ld      a, [var_shell_cursor_x]
        ld      b, a
        ld      a, 4
        cp      b
        jr      C, .wrapRight

        inc     b
        ld      a, b
        ld      [var_shell_cursor_x], a
        jr      .update

.wrapRight:
        xor     a
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
        ld      de, $9e21
        ld      b, $8B
        fcall   PutText


.checkCommandEntry:
        ldh     a, [hvar_joypad_current]
        bit     PADB_START, a
        jr      Z, .checkAutocomplete
        fcall   r14_ShellEvalCommand

        fcall   r14_ShellInit
        ret

.checkAutocomplete:
        ldh     a, [hvar_joypad_current]
        bit     PADB_SELECT, a
        ret     Z
        fcall   r14_ShellFindCompletions
        ld      a, [var_shell_completion_count]
        or      a
        ret     Z

	xor     a
        ld      [var_shell_completion_select], a

        ld      de, ShellCommandSceneSelectCompletion
        fcall   SceneSetUpdateFn

        fcall   r14_ShellCursorTileAddress
        VIDEO_BANK 1
        ld      a, $8b
        ld      [hl], a
        VIDEO_BANK 0
        ret

.exitScene:
        ld      de, OverworldSceneEnter
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

r14_ShellCommandSceneSelectCompletion:
        call    VBlankIntrWait

        VIDEO_BANK 1

        ld      a, [var_shell_completion_select]
        ld      c, a
        ld      b, 0
        fcall   Mul32
        ld      hl, $9c28
        add     hl, bc
        ld      a, $8b
        ld      bc, 10
        fcall   Memset


.checkUp:
        ldh     a, [hvar_joypad_current]
        bit     PADB_UP, a
        jr      Z, .checkDown

	ld      a, [var_shell_completion_select]
        cp      0
        jr      Z, .wrapUp

        dec     a
        ld      [var_shell_completion_select], a
        jr      .checkDown

.wrapUp:
        ld      a, [var_shell_completion_count]
        dec     a
        ld      [var_shell_completion_select], a

.checkDown:
        ldh     a, [hvar_joypad_current]
        bit     PADB_DOWN, a
        jr      Z, .checkA

        ld      a, [var_shell_completion_select]
        ld      b, a
        ld      a, [var_shell_completion_count]
        dec     a
        dec     a
        cp      b
        jr      C, .wrapDown

        inc     b
        ld      a, b
        ld      [var_shell_completion_select], a
        jr      .checkA

.wrapDown:
        xor     a
        ld      [var_shell_completion_select], a

.checkA:
        ldh     a, [hvar_joypad_current]
        bit     PADB_A, a
        jr      Z, .checkB

        VIDEO_BANK 0

        fcall   r14_ShellInit
        ld      a, [var_shell_completion_select]
        ld      c, a
        ld      b, 0
        fcall   Mul32
        ld      hl, $9c28
        add     hl, bc

        ld      de, var_shell_command_buffer
        ld      bc, 10
        fcall   Memcpy

        ld      a, 5                    ; \
        ld      [var_shell_cursor_x], a ; | Move cursor to space character on
        dec     a                       ; | keyboard.
        ld      [var_shell_cursor_y], a ; /

        ld      hl, var_shell_command_buffer
        ld      d, 0
.countLoop:
        ld      a, [hl+]
        cp      $32
        jr      Z, .return
        inc     d
        ld      a, d
        ld      [var_command_buffer_size], a
        jr      .countLoop


.checkB:
        ldh     a, [hvar_joypad_current]
        bit     PADB_B, a
        jr      Z, .update

.return:
        ld      de, ShellCommandSceneUpdate
        fcall   SceneSetUpdateFn

        ld      d, 0
.clearLoop:
        ld      a, [var_shell_completion_count]
        cp      d
        ret     Z

        fcall   VBlankIntrWait

        push    de
        ld      c, d
        ld      b, 0
        fcall   Mul32
        ld      hl, $9c28
        add     hl, bc
        pop     de

        VIDEO_BANK 1
        push    hl
        ld      a, $8b
        ld      bc, 10
        fcall   Memset
        pop     hl
        VIDEO_BANK 0
        ld      a, $32
        ld      bc, 10
        fcall   Memset

        inc     d
        jr      .clearLoop


.update:
        ld      a, [var_shell_completion_select]
        ld      c, a
        ld      b, 0
        fcall   Mul32
        ld      hl, $9c28
        add     hl, bc
        ld      a, $88
        ld      bc, 10
        fcall   Memset

        VIDEO_BANK 0

        ret


;;; ----------------------------------------------------------------------------

r14_ShellFindCompletions:
        xor     a
        ld      [var_shell_completion_count], a

        fcall   r14_ShellParseCommandName
        ld      hl, var_shell_parse_buffer
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
        ret     Z               ; /

	push    de
        push    hl
        push    bc
        fcall   r14_StringComparePrefix
        pop     bc
        pop     hl
        pop     de
        jr      NZ, .next

.match:
        push    hl
        push    bc

        fcall   VBlankIntrWait
        ld      h, d
        ld      l, e

        push    hl
        ld      a, [var_shell_completion_count]
        ld      c, a
        ld      b, 0
        fcall   Mul32
        ld      hl, $9c28
        add     hl, bc
        ld      d, h
        ld      e, l
        pop     hl

        ld      b, $8B
        fcall   PutText

        ld      a, [var_shell_completion_count]
        inc     a
        ld      [var_shell_completion_count], a

        pop     bc
        pop     hl

.next:
        inc     bc
        inc     bc
        jr      .loop


;;; ----------------------------------------------------------------------------

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
        fcall   StringCompare
        pop     bc
        pop     hl
        jr      Z, .found

        inc     bc              ; \ Skip over the next two bytes in the table.
        inc     bc              ; /

        jr      .loop

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

r14_StringComparePrefix:
;;; hl - string 1
;;; de - string 2
;;; trashes b
;;; return Z flag if prefix equal, NZ flag otherwise
        ld      a, [hl+]
        or      a
        ret     Z
        ld      b, a

        ld      a, [de]
        or      a
        ret     Z

        cp      b
        ret     NZ

        inc     de
        jr      r14_StringComparePrefix


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
