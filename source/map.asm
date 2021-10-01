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
;;; Overworld Map
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


;;; ----------------------------------------------------------------------------


IsTileCollectible:
;;; a - tile
        cp      COLLECTIBLE_TILE_POTATO
        ret     Z
        cp      COLLECTIBLE_TILE_STICK
        ret     Z
        ret


;;; ----------------------------------------------------------------------------


;;; Copy map from wram to vram
MapShow:
        ld      c, 0
.loop:
        ;; All of the levels are typically loaded incrementally as the screen
        ;; scrolls, with the exception of the first room, which we need to
        ;; load all at once. But, we just build this on top of the incremental
        ;; loading code.
        push    bc
        LONG_CALL r1_MapExpandRow
        pop     bc

        fcall   VBlankIntrWait          ; r1_MapShowRow writes to vram.

        push    bc
        LONG_CALL r1_MapShowRow
        pop     bc

        inc     c
        ld      a, c
        cp      32
        jr      NZ, .loop

        ret


;;; ----------------------------------------------------------------------------

MapGetTile:
;;; hl - map
;;; a - x
;;; b - y
;;; return value in b
;;; trashes hl, c
        swap    b                       ; map is 16 wide
        add     b
        ld      c, a
        ld      b, 0
        add     hl, bc
        ld      b, [hl]
        ret


;;; ----------------------------------------------------------------------------

MapSetTile:
;;; hl - map
;;; a - x
;;; b - y
;;; d - tile
;;; trashes hl, c, a, b
        swap    b
        add     b
        ld      c, a
        ld      b, 0
        add     hl, bc
        ld      [hl], d
        ret


;;; ----------------------------------------------------------------------------


;;; May only be called from rom0, due to all of the bank swapping.
GetRoomData__rom0_only:
;;; b - room x
;;; c - room y
;;; return hl - pointer to room's tilemap
        RAM_BANK 1

        LONG_CALL r1_LoadRoom

        ld      a, [hl+]                ; \ Load adjacency mask from room data
        and     $0f                     ; /

        ld      b, [hl]                 ; Load room variant

        ld      e, a
        ld      d, 0

        ld      hl, .roomDataBankTab    ; \
        add     hl, de                  ; | Set bank where we'll look for the
        ld      a, [hl]                 ; | map data.
        SET_BANK_FROM_A                 ; /

        sla     e                       ; Two bytes per pointer in roomdata lut

        ld      hl, .roomDataLookupTab  ; \ Load pointer to room data array
        add     hl, de                  ; /
        ld      e, [hl]
        inc     hl
        ld      d, [hl]
        ld      h, d
        ld      l, e

        ld      c, 0                    ; Jump to variant in room table
                                        ; b is the higher byte, so implicit x256
        add     hl, bc

        ret


.roomDataLookupTab::
DW      r10_TEST_MAP_2
DW      r10_room_data_d
DW      r10_room_data_u
DW      r10_room_data_du
DW      r10_room_data_r
DW      r10_room_data_dr
DW      r10_room_data_ur
DW      r10_room_data_dur
DW      r10_room_data_l
DW      r10_room_data_dl
DW      r10_room_data_ul
DW      r10_room_data_dul
DW      r10_room_data_rl
DW      r10_room_data_drl
DW      r10_room_data_url
DW      r10_room_data_durl
.roomDataLookupTabEnd::

.roomDataBankTab::
DB      10
DB      10
DB      10
DB      10
DB      10
DB      10
DB      10
DB      10
DB      10
DB      10
DB      10
DB      10
DB      10
DB      10
DB      10
DB      10
.roomDataBankTabEnd::


;;; ----------------------------------------------------------------------------


;;; Does a bunch of bank swapping, may only be called from rom0.
MapLoad2__rom0_only:

        ld      a, [var_room_x]
        ld      b, a
        ld      a, [var_room_y]
        ld      c, a

        fcall   GetRoomData__rom0_only

.copy:
        ld      bc, ROOM_DATA_SIZE
        ld      de, var_map_info
	fcall   Memcpy

        ;; Now, the room data is sitting in RAM. We can safely call back into
        ;; bank 1 to do whatever other loading or level generation that we want
        ;; to do.

        LONG_CALL r1_InitializeRoom

        ret


;;; ----------------------------------------------------------------------------
