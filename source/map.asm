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


;;; Copy map from wram to vram
MapShow:
        ld      c, 0
        ld      hl, var_map_info

.outerLoop:
	ld      b, 0
        ld      a, 16           ; map height
        cp      c
        jr      Z, .done

.innerLoop:
        ld      a, 16           ; map width
        cp      b
        jr      Z, .outerLoopInc

        push    bc

        ld      d, c
        sla     d

        ld      a, [hl]
        sla     a
        sla     a
        ld      e, $90
        add     e
        ld      e, a

        ld      c, 2

        ld      a, b
	sla     a

        push    hl
        call    SetBackgroundTile16x16
        pop     hl

        pop     bc

        inc     b
        inc     hl
	jr      .innerLoop

.outerLoopInc:
	inc     c
        jr      .outerLoop

.done:
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

;;; Does a bunch of bank swapping, may only be called from rom0.
MapLoad2__rom0_only:
        RAM_BANK 1

        ld      a, [var_room_x]
        ld      b, a
        ld      a, [var_room_y]
        ld      c, a
        LONG_CALL r1_LoadRoom, 1

        ld      a, [hl+]                ; \ Load adjacency mask from room data
        and     $0f                     ; /

        ld      b, [hl]                 ; Load room variant

        ld      e, a
        ld      d, 0

        ld      hl, .roomDataBankTab    ; \
        add     de                      ; | Set bank where we'll look for the
        ld      a, [hl]                 ; | map data.
        ld      [rROMB0], a             ; /

        sla     e                       ; Two bytes per pointer in roomdata lut
.here:
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

.copy:
        ld      bc, ROOM_DATA_SIZE
        ld      de, var_map_info
	call    Memcpy

        ;; Now, the room data is sitting in RAM. We can safely call back into
        ;; bank 1 to do whatever other loading or level generation that we want
        ;; to do.

        LONG_CALL r1_InitializeRoom, 1

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
