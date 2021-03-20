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


;;; ############################################################################


SECTION "ROM1_CODE", ROMX, BANK[1]


;;; ----------------------------------------------------------------------------

r1_GameboyColorNotDetectedText::
DB " CGB  Required", 0


r1_DMGPutText:
;;; hl - text
;;; b - x
;;; c - y
        ld      de, $9cc2
.loop:
        ld      a, [hl]
        cp      0
	jr      Z, .done

        call    AsciiToGlyph
        ld      [de], a

        inc     hl
        inc     de

        jr      .loop
.done:
        ret


;;; NOTE: This function MUST be in rom0 or rom1.
r1_GameboyColorNotDetected:
        ld      hl, _SCRN1
        ld      a, $32
        ld      bc, $9FFF - $9C00 ; size of scrn1
        call    Memset

        ld      hl, _OAMRAM
        ld      a, 0
        ld      bc, $FE9F - $FE00
        call    Memset

        ld      b, 1
        ld      c, 1
        ld      hl, r1_GameboyColorNotDetectedText
        call    r1_DMGPutText
        call    LcdOn

        ld      a, 7
        ld      [rWX], a

        halt


;;; ----------------------------------------------------------------------------

r1_VBlankPoll:
; Intended for waiting on vblank while interrupts are disabled, but the screen
; is still on.
        ld      a, [rLY]
        cp      SCRN_Y
        jr      nz, r1_VBlankPoll
        ret


;;; ----------------------------------------------------------------------------

r1_GameboyAdvanceDetected:
        ld      a, 1
        ldh     [agb_detected], a

	ret


;;; ----------------------------------------------------------------------------

r1_InitWRam:
        ld      a, 0
        ld      hl, _RAM
        ;; We don't want to zero the stack, or how will we return from this fn?
        ld      bc, STACK_END - _RAM
        call    Memset

        ld      d, 1
.loop:
        ld      a, d
        cp      8
        jr      Z, .done

        ld      [rSVBK], a

        ld      hl, _RAMBANK
        ld      bc, ($DFFF - _RAMBANK) - 1
        ld      a, 0
        call    Memset

        inc     d
        jr      .loop

.done:
        ld      a, 0
        ld      [rSVBK], a


        ret


r1_InitRam:
;;; trashes hl, bc, a
        ld      a, 0

        ld      hl, _HRAM
        ld      bc, $80
        call    Memset

        call    r1_InitWRam

        ret


;;; ----------------------------------------------------------------------------

r1_SetCpuFast:
        ld      a, [rKEY1]
        bit     7, a
        jr      z, .impl
        ret

.impl:
        ld      a, $30
        ld      [rP1], a
        ld      a, $01
        ld      [rKEY1], a

        stop
        ret


;;; ----------------------------------------------------------------------------

r1_CopyDMARoutine:
        ld      hl, DMARoutine
        ld      b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
        ld      c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
        ld      a, [hli]
        ldh     [c], a
        inc     c
        dec     b
        jr      nz, .copy
        ret

DMARoutine:
        ldh     [rDMA], a

        ld      a, 40
.wait
        dec     a
        jr      nz, .wait
        ret
DMARoutineEnd:


;;; ----------------------------------------------------------------------------

r1_MapExpandRow:
;;; c - row
        ld      e, c

;;; Because tiles are 16x16
        bit     0, e                    ; Determine which row we are in
        ld      a, 0
        jr      Z, .setParity
        ld      a, 1
.setParity:
        ld      [var_room_load_parity], a

        srl     e                       ; 32x32 index as input, downsample
        ld      d, 0

        ;; Map tiles are 16x16. Multiply y by 16 and add, to jump to row.
        swap    e

        ld      hl, var_map_info
        add     hl, de
        ld      d, h
        ld      e, l

        ld      hl, var_room_load_slab

        ld      b, 0
.copy:
        ld      a, [var_room_load_parity]
        or      a
        ld      a, [de]
        jr      Z, .evenParity


        sla     a                       ; \ Four tiles per metatile in vram,
        sla     a                       ; / so multiply by four
        add     $90                     ; $90 is the first map tile in vram

        ;; For odd parity, skip to the next two vram indices
        inc     a
        inc     a
        jr      .meta

.evenParity:
        sla     a                       ; \ Four tiles per metatile in vram,
        sla     a                       ; / so multiply by four
        add     $90                     ; $90 is the first map tile in vram

.meta:
        ld      [hl], a

        inc     hl

        inc     a
        ld      [hl], a

        inc     hl

        inc     de

        inc     b
        ld      a, b
        cp      16
        jr      NZ, .copy

        ret

;;; ----------------------------------------------------------------------------


r1_MapShowRow:
;;; c - row
        push    bc                      ; \
        ld      hl, _SCRN0              ; |
        ld      e, 32                   ; |
        ld      d, 0                    ; |
.loop:                                  ; | seek offset in vram
        ld      a, 0                    ; |
        or      c                       ; |
	jr      Z, .ready               ; |
        dec     c                       ; |
        add     hl, de                  ; |
        jr      .loop                   ; /
.ready:
        pop     bc

        ;; Now, hl contains pointer to correct row in vram

        ld      de, var_room_load_slab

        ld      b, 0
.copy:
        ld      a, [de]
        ld      [hl], a
        inc     de

        ld	a, 1                    ; \
	ld	[rVBK], a               ; |
        ld      a, 2                    ; | Set Palette
        ld      [hl], a                 ; |
        ld      a, 0                    ; |
	ld	[rVBK], a               ; /

        inc     hl

        ld      a, [de]
        ld      [hl], a

        ld	a, 1                    ; \
	ld	[rVBK], a               ; |
        ld      a, 2                    ; | Set Palette
        ld      [hl], a                 ; |
        ld      a, 0                    ; |
	ld	[rVBK], a               ; /

        inc     hl

        inc     de

        inc     b
        ld      a, b
        cp      16
        jr      NZ, .copy

        ret


;;; ----------------------------------------------------------------------------

;;; Fills var_room_slab with expanded tile data. Then, the vblank handler just
;;; needs to copy stuff.
r1_MapExpandColumn:
        ld      e, c
        bit     0, e
        ld      a, 0
        jr      Z, .setParity
        ld      a, 1
.setParity:
        ld      [var_room_load_parity], a


        ld      hl, var_map_info

        ld      e, c
	srl     e
        ld      d, 0

        add     hl, de
        ld      d, h
        ld      e, l

        ld      hl, var_room_load_slab

        ld      b, 0
.copy:
        ld      a, [var_room_load_parity]
        or      a
        ld      a, [de]
        jr      Z, .evenParity

        sla     a                       ; \ Four tiles per metatile in vram,
        sla     a                       ; / so multiply by four
        add     $90                     ; $90 is the first map tile in vram

        inc     a                       ; Inc 1, to second column of 16x16p tile
        jr      .meta

.evenParity:

        sla     a
        sla     a
        add     $90
.meta:

        ld      [hl], a

        inc     a                       ; \ Go to next column tile in 16x16px
        inc     a                       ; / meta tile.

        inc     hl

        ld      [hl], a

        inc     hl

        push    hl                      ; \
        ld      l, 16                   ; |
        ld      h, 0                    ; |
        add     hl, de                  ; | Jump to next row in tile map
        ld      d, h                    ; |
        ld      e, l                    ; |
        pop     hl                      ; /

        inc     b
        ld      a, b
        cp      16
        jr      NZ, .copy

        ret


;;; ----------------------------------------------------------------------------

r1_MapShowColumn:
;;; c - column

        ld      hl, _SCRN0

        ld      d, 0                    ; \
        ld      e, c                    ; | Jump to proper column
        add     hl, de                  ; /

        ld      de, var_room_load_slab

        ld      b, 0
.copy:
        ld      a, [de]
        ld      [hl], a

        inc     de

        ld	a, 1                    ; \
	ld	[rVBK], a               ; |
        ld      a, 2                    ; | Set Palette
        ld      [hl], a                 ; |
        ld      a, 0                    ; |
	ld	[rVBK], a               ; /


        push    de                      ; \
        ld      e, 32                   ; |
	ld      d, 0                    ; | Jump down a full row in vram
        add     hl, de                  ; |
        pop     de                      ; /

        ld      a, [de]
        ld      [hl], a

        inc     de

        ld	a, 1                    ; \
	ld	[rVBK], a               ; |
        ld      a, 2                    ; | Set Palette
        ld      [hl], a                 ; |
        ld      a, 0                    ; |
	ld	[rVBK], a               ; /

        push    de                      ; \
        ld      e, 32                   ; |
	ld      d, 0                    ; | Jump down a full row in vram
        add     hl, de                  ; |
        pop     de                      ; /

        inc     b
        ld      a, b
        cp      16
        jr      NZ, .copy

        ret


;;; ----------------------------------------------------------------------------

r1_ReadKeys:
; b - returns raw state
; c - returns debounced state (edge-triggered)
; d - trashed
        ldh     a, [var_joypad_raw]
        ld      d, a

        ld      a, $20                  ; read P15 - returns a, b, select, start
        ldh     [rP1], a
        ldh     a, [rP1]                ; mandatory
        ldh     a, [rP1]
        cpl                             ; rP1 returns not pressed keys as 1 and pressed as 0, invert it to make result more readable
        and     $0f                     ; lower nibble has a, b, select, start state
        swap    a
        ld      b, a

        ld      a, $10                  ; read P14 - returns up, down, left, right
        ldh     [rP1], a
        ldh     a, [rP1]                ; mandatory
        ldh     a, [rP1]
        ldh     a, [rP1]
        ldh     a, [rP1]
        ldh     a, [rP1]
        ldh     a, [rP1]
        cpl                             ; rP1 returns not pressed keys as 1 and pressed as 0, invert it to make result more readable
        and     $0f                     ; lower nibble has up, down, left, right state
        or      b                       ; combine P15 and P14 states in one byte
        ld      b, a                    ; store it

        ldh     a, [var_joypad_previous]; this is when important part begins, load previous P15 & P14 state
        xor     b                       ; result will be 0 if it's the same as current read
        and     b                       ; keep buttons that were pressed during this read only
        ldh     [var_joypad_current], a ; store final result in variable and register
        ld      c, a
        ld      a, b                    ; current P15 & P14 state will be previous in next read
        ldh     [var_joypad_previous], a

        ld      a, $30                  ; reset rP1
        ldh     [rP1], a

        ld      a, b
        ldh     [var_joypad_raw], a

        cpl                             ; cpl of current == not pressed keys
        and     d                       ; and with prev keys == released
        ldh     [var_joypad_released], a
        ret


;;; ---------------------------------------------------------------------------

r1_WorldMapPalettes::
DB $1B,$4B, $57,$32, $ed,$10, $23,$34,
r1_WorldMapPalettesEnd::


r1_WorldMapTemplateTop::
DB $00, $04, $05, $04, $05, $04, $05, $04, $05, $04, $05, $04, $05, $04, $05
DB $04, $05, $04, $05, $01
r1_WorldMapTemplateTopEnd::


r1_WorldMapTemplateRow0::
DB $06, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
DB $08, $08, $08, $08, $07
r1_WorldMapTemplateRow0End::


r1_WorldMapTemplateRow1::
DB $07, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
DB $08, $08, $08, $08, $06
r1_WorldMapTemplateRow1End::


r1_WorldMapTemplateBottom::
DB $03, $05, $04, $05, $04, $05, $04, $05, $04, $05, $04, $05, $04, $05, $04
DB $05, $04, $05, $04, $02
r1_WorldMapTemplateBottomEnd::




r1_WorldMapShowRowPair:
;;; de - first row address
;;; hl - second row address
        push    hl

        ld      hl, r1_WorldMapTemplateRow0
        ld      bc, r1_WorldMapTemplateRow0End - r1_WorldMapTemplateRow0
        call    VramSafeMemcpy

        pop     de

        ld      hl, r1_WorldMapTemplateRow1
        ld      bc, r1_WorldMapTemplateRow1End - r1_WorldMapTemplateRow1
        call    VramSafeMemcpy
        ret


r1_WorldMapShowRooms:
        call    VBlankIntrWait

        ld      a, 1
        ld      [rSVBK], a

        ld      hl, wram1_var_world_map_info
        ld      de, $9C21       ; Pointer to data in scrn1


        ld      c, 0            ; y counter
.outer_loop:
        ld      b, 0            ; x counter

.inner_loop:
        ld      a, WORLD_MAP_WIDTH
        cp      b
        jr      Z, .outer_loop_step


        ld      a, [rLY]
        cp      152
        jr      Z, .vsync
        jr      .write
.vsync:
        call    VBlankIntrWait
.write:
        ld      a, [hl]
        and     $80                     ; Check for room visited flag
        jr      Z, .skip                ; The tile is empty by default

        ld      a, $0a
        ld      [de], a

.skip:
        push    de                      ; \
        ld      d, 0                    ; |
        ld      e, ROOM_DESC_SIZE       ; | Increment room pointer by room size
        add     hl, de                  ; |
        pop     de                      ; /

        inc     de                      ; Increment pointer to vram scrn1 tile

        inc     b
        jr      .inner_loop

.outer_loop_step:
        push    hl                      ; \
        ld      hl, $0e                 ; |
        add     hl, de                  ; | Jump de to next row in scrn1
        ld      d, h                    ; |
        ld      e, l                    ; |
        pop     hl                      ; /

        inc     c
        ld      a, WORLD_MAP_HEIGHT
        cp      c

        jr      NZ, .outer_loop

	ret


r1_WorldMapShow:
        ld      hl, r1_WorldMapTemplateTop
        ld      bc, r1_WorldMapTemplateTopEnd - r1_WorldMapTemplateTop
        ld      de, $9C00
        call    VramSafeMemcpy

        ld      de, $9C20
        ld      hl, $9C40
        call    r1_WorldMapShowRowPair

        ld      de, $9C60
        ld      hl, $9C80
        call    r1_WorldMapShowRowPair

        ld      de, $9CA0
        ld      hl, $9CC0
        call    r1_WorldMapShowRowPair

        ld      de, $9CE0
        ld      hl, $9D00
        call    r1_WorldMapShowRowPair

        ld      de, $9D20
        ld      hl, $9D40
        call    r1_WorldMapShowRowPair

        ld      de, $9D60
        ld      hl, $9D80
        call    r1_WorldMapShowRowPair

        ld      de, $9DA0
        ld      hl, $9DC0
        call    r1_WorldMapShowRowPair

        ld      de, $9DE0
        ld      hl, $9E00
        call    r1_WorldMapShowRowPair

        ld      hl, r1_WorldMapTemplateBottom
        ld      bc, r1_WorldMapTemplateBottomEnd - r1_WorldMapTemplateBottom
        ld      de, $9E20
        call    VramSafeMemcpy

        call    r1_WorldMapShowRooms

        call    VBlankIntrWait
        ld      b, r1_WorldMapPalettesEnd - r1_WorldMapPalettes
        ld      hl, r1_WorldMapPalettes
        call    LoadBackgroundColors

        ld      hl, $9E12
        ld      a, $09
        ld      [hl], a

        ld      hl, $9C21
        ld      a, $0a
        ld      [hl], a

        ld      a, 0
        ld      [rWY], a

        ret


;;; ---------------------------------------------------------------------------

;;; Used for indexing into our world map. The map is 18 blocks wide and 16
;;; blocks tall. We assume here that inputs are less than 16. This code will
;;; not work correctly if you pass a y value greater than 15.
r1_l16Mul18Fast:
;;; c - y value less than 16
;;; result in hl
;;; trashes b
        ld      h, 0
        ld      b, 0

;;; swap (aka left-shift by four for the x16 multiplication)
        ld      a, c
        swap    a
        ld      l, a

;;; Then, add twice, to reach x18
        add     hl, bc
        add     hl, bc

        ret


;;; I guess it's not _that_ fast :)
r1_Mul13Fast:
;;; hl - number, result
;;; trashes bc

        push    hl

;;; left-shift by three, then add five times
	ld      a, l
        and     $e0
        swap    a
	srl     a

        sla     h
        sla     h
        sla     h

        or      h
        ld      h, a

        sla     l
        sla     l
        sla     l

        pop     bc

        add     bc
        add     bc
        add     bc
        add     bc
        add     bc

        ret



;;; ---------------------------------------------------------------------------

;;; IMPORTANT: assumes that the switchable ram bank, where we store map info, is
;;; already set to bank 1!
r1_LoadRoom:
;;; b - room x
;;; c - room y
;;; trashes a, bc
;;; result in hl

;;; Ok, so we have 18 rooms per row, and each room is thirteen bytes. So:
;;; room = &rooms[x * 13 + (y * 18 * 13)];
        push    bc

        ;; hl = y * 18 * 13
        call    r1_l16Mul18Fast
        call    r1_Mul13Fast

        pop     bc
        push    hl

        ;; hl = x * 13
        ld      l, b
        ld      h, 0
        call    r1_Mul13Fast

        pop     bc              ; previous hl to bc

        ;; hl = (x * 13) + (y * 18 * 13)
        add     bc

        ld      bc, wram1_var_world_map_info
        add     bc

        ret


;;; IMPORTANT: assumes that the switchable ram bank, where we store map info, is
;;; already set to bank 1!
r1_IsRoomVisited:
        ret


;;; NOTE: Sets ram bank to bank 1!
r1_SetRoomVisited:
;;; trashes a, hl, bc
        ld      a, 1
        ld      [rSVBK], a

        ld      a, [var_room_x]
        ld      b, a

        ld      a, [var_room_y]
        ld      c, a

.test:
        call    r1_LoadRoom
        ld      a, [hl]

        or      $80
        ld      [hl], a

        ret

;;; ---------------------------------------------------------------------------

r1_SmoothstepLut::
DB $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00, $01, $01, $01, $01, $02, $02,
DB $02, $03, $03, $04, $04, $04, $05, $05,
DB $06, $06, $07, $07, $08, $09, $09, $0A,
DB $0B, $0B, $0C, $0D, $0D, $0E, $0F, $10,
DB $10, $11, $12, $13, $14, $15, $15, $16,
DB $17, $18, $19, $1A, $1B, $1C, $1D, $1E,
DB $1F, $20, $21, $22, $23, $24, $25, $27,
DB $28, $29, $2A, $2B, $2C, $2D, $2F, $30,
DB $31, $32, $33, $35, $36, $37, $38, $3A,
DB $3B, $3C, $3E, $3F, $40, $42, $43, $44,
DB $46, $47, $48, $4A, $4B, $4D, $4E, $4F,
DB $51, $52, $54, $55, $56, $58, $59, $5B,
DB $5C, $5E, $5F, $61, $62, $63, $65, $66,
DB $68, $69, $6B, $6C, $6E, $6F, $71, $72,
DB $74, $75, $77, $78, $7A, $7B, $7D, $7E,
DB $80, $81, $83, $84, $86, $87, $89, $8A,
DB $8C, $8D, $8F, $90, $92, $93, $95, $96,
DB $98, $99, $9B, $9C, $9D, $9F, $A0, $A2,
DB $A3, $A5, $A6, $A8, $A9, $AA, $AC, $AD,
DB $AF, $B0, $B1, $B3, $B4, $B6, $B7, $B8,
DB $BA, $BB, $BC, $BE, $BF, $C0, $C2, $C3,
DB $C4, $C6, $C7, $C8, $C9, $CB, $CC, $CD,
DB $CE, $CF, $D1, $D2, $D3, $D4, $D5, $D6,
DB $D7, $D9, $DA, $DB, $DC, $DD, $DE, $DF,
DB $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7,
DB $E8, $E9, $E9, $EA, $EB, $EC, $ED, $EE,
DB $EE, $EF, $F0, $F1, $F1, $F2, $F3, $F3,
DB $F4, $F5, $F5, $F6, $F7, $F7, $F8, $F8,
DB $F9, $F9, $FA, $FA, $FA, $FB, $FB, $FC,
DB $FC, $FC, $FD, $FD, $FD, $FD, $FE, $FE,
DB $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FF,
r1_SmoothstepLutEnd::


r1_Smoothstep:
;;; c - value
;;; a - return value
;;; trashes hl, b
        ld      b, 0
        ld      hl, r1_SmoothstepLut
        add     hl, bc
        ld      a, [hl]
        ld      c, a
        ret

;;; ----------------------------------------------------------------------------


;;; SECTION ROM1_CODE


;;; ############################################################################
