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

        SECTION "WORLD_MAP", WRAMX, BANK[1]

WORLD_MAP_WIDTH EQU 18
WORLD_MAP_HEIGHT EQU 16
WORLD_ROOM_COUNT EQU WORLD_MAP_WIDTH * WORLD_MAP_HEIGHT


ROOM_HEADER_SIZE EQU 3
ROOM_ENTITYDESC_ARRAY_SIZE EQU 10
ROOM_DESC_SIZE EQU ROOM_HEADER_SIZE + ROOM_ENTITYDESC_ARRAY_SIZE

;;; For reference:
;;;
;;; struct Room {
;;;     char visited_ : 1;        \
;;;     char reserved_ : 3;       |  First byte.
;;;     char connections_ : 4:    /
;;;
;;;     char room_variant_;       Second byte.
;;;
;;;     char reserved_;           Third byte.
;;;
;;;     EntityDesc entities_[5];  Ten bytes.
;;; }; (13 bytes)
;;;
;;; struct EntityDesc {
;;;     char type_;
;;;     char x_ : 4;
;;;     char y_ : 4;
;;; }; (2 bytes)
;;;

wram1_var_world_map_info::
DS      WORLD_ROOM_COUNT * ROOM_DESC_SIZE
wram1_var_world_map_info_end::


;;; ############################################################################