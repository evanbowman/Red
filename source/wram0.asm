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

        SECTION "OAM_BACK_BUFFER", WRAM0, ALIGN[8]

var_oam_back_buffer:
        ds OAM_SIZE * OAM_COUNT


var_oam_top_counter:     DS      1
var_oam_bottom_counter:  DS      1


;;; SECTION OAM_BACK_BUFFER


;;; ############################################################################

        SECTION "MAP_INFO", WRAM0

MAP_TILE_WIDTH EQU 16
MAP_WIDTH EQU SCRN_VX / MAP_TILE_WIDTH
MAP_HEIGHT EQU SCRN_VY / MAP_TILE_WIDTH

var_map_info:    DS     MAP_WIDTH * MAP_HEIGHT

var_room_x:     DS      1
var_room_y:     DS      1


;;; SECTION MAP_INFO

;;; ############################################################################

        SECTION "PLAYER", WRAM0


;;; NOTE: The params here should match the layout of an entity EXACTLY AS
;;; DESCRIBED ABOVE.

var_player_struct:
;;; In the very first entry of each entity, store a flag, which tells the
;;; renderer that the entity's texture needs to be swapped.
var_player_swap_spr:   DS      1

var_player_coord_y:  DS      FIXNUM_SIZE
var_player_coord_x:  DS      FIXNUM_SIZE

var_player_animation:
var_player_tmr: DS      1       ; Timer
var_player_kf:  DS      1       ; Keyframe
var_player_fb:  DS      1       ; Frame base

var_player_texture:     DS   1  ; Texture offset in vram
var_player_palette:     DS   1
var_player_display_flag:DS   1

var_player_update_fn:   DS   2  ; Engine will call this fn to update player

var_player_struct_end:

ENTITY_SIZE EQU var_player_struct_end - var_player_struct

var_player_stamina:     DS      FIXNUM_SIZE


COLLISION_LEFT EQU $01
COLLISION_RIGHT EQU $02
COLLISION_UP EQU $04
COLLISION_DOWN EQU $08

;;; Just a scratch variable that simplifies other code.
var_player_spill1:      DS      1
var_player_spill2:      DS      1


var_debug_struct:
var_debug_swap_spr:     DS      1
var_debug_coord_y:      DS      FIXNUM_SIZE
var_debug_coord_x:      DS      FIXNUM_SIZE

var_debug_animation:
var_debug_timer:        DS      1
var_debug_kf:           DS      1
var_debug_fb:           DS      1

var_debug_texture:      DS      1
var_debug_palette:     DS   1
var_debug_display_flag:   DS      1

var_debug_update_fn:    DS      2
var_debug_struct_end:



;;; ############################################################################

        SECTION "ENTITY_BUFFER", WRAM0

ENTITY_BUFFER_CAPACITY EQU 8
ENTITY_POINTER_SIZE EQU 2

var_entity_buffer_size: DS      1
var_entity_buffer:      DS      ENTITY_POINTER_SIZE * ENTITY_BUFFER_CAPACITY

;;; Used as a placeholder value while sorting entities by y value.
var_last_entity_y:      DS      1
var_last_entity_idx:    DS      1


;;; ############################################################################

        SECTION "VIEW", WRAM0

var_view_x:    DS      1
var_view_y:    DS      1

var_room_load_counter:        DS      1
var_room_load_parity:         DS      1


;;; ############################################################################

        SECTION "SCENE", WRAM0

var_scene_update_fn:    DS      2
var_scene_vblank_fn:    DS      2
var_scene_counter:      DS      1


;;; ############################################################################
