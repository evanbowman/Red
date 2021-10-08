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


;;; For reference:
;;;
;;; struct Room {
;;;     char visited_ : 1;        \
;;;     char blizzard_ : 1;       |
;;;     char reserved_ : 2;       |  First byte.
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


;;; D - down, U - up, R - right, L - left
ROOM_CONNECTED_D        EQU $01
ROOM_CONNECTED_U        EQU $02
ROOM_CONNECTED_DU       EQU $03
ROOM_CONNECTED_R        EQU $04
ROOM_CONNECTED_DR       EQU $05
ROOM_CONNECTED_UR       EQU $06
ROOM_CONNECTED_DUR      EQU $07
ROOM_CONNECTED_L        EQU $08
ROOM_CONNECTED_DL       EQU $09
ROOM_CONNECTED_UL       EQU $0a
ROOM_CONNECTED_DUL      EQU $0b
ROOM_CONNECTED_RL       EQU $0c
ROOM_CONNECTED_DRL      EQU $0d
ROOM_CONNECTED_URL      EQU $0e
ROOM_CONNECTED_DURL     EQU $0f

ROOM_B1_CONNECTIONS     EQU $0f


ROOM_VISITED            EQU $80
ROOM_BLIZZARD           EQU $40

ROOM_B3_PROXIMAL_PATH   EQU $01 ; No longer used

WORLD_MAP_WIDTH         EQU 18
WORLD_MAP_HEIGHT        EQU 16
WORLD_ROOM_COUNT        EQU WORLD_MAP_WIDTH * WORLD_MAP_HEIGHT


ROOM_HEADER_SIZE        EQU 3
ROOM_ENTITYDESC_ARRAY_SIZE EQU 10
ROOM_DESC_SIZE          EQU ROOM_HEADER_SIZE + ROOM_ENTITYDESC_ARRAY_SIZE


ROOM_META_WIDTH         EQU 16
ROOM_META_HEIGHT        EQU 16

ROOM_DATA_SIZE          EQU ROOM_META_WIDTH * ROOM_META_HEIGHT





BLIZZARD_SNOWFLAKE_SIZE EQU 4
BLIZZARD_SNOWFLAKE_COUNT EQU 6
