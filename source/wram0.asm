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

        SECTION "PERSISTENT_DATA", WRAM0

;;; A bunch of data that we want to write to sram. Put it all in one place so
;;; that we can simply memcpy this stuff.

PERSISTENT_STATE_DATA:

var_room_x:     DS      1
var_room_y:     DS      1

var_player_stamina:     DS      FIXNUM_SIZE


ITEM_SIZE EQU 2
INVENTORY_COUNT EQU 21
var_inventory:  DS      ITEM_SIZE * (INVENTORY_COUNT - 1)
var_inventory_last_item:        DS      ITEM_SIZE


var_level:              DS      1
var_exp:                DS      2
var_exp_to_next_level:  DS      2


var_equipped_item:      DS      1


;;; NOTE: max lives == 9, due to UI code.
var_lives:              DS      1


;;; Anchor vars:
;;; For some animations, we need to move the sprite origin left/right to fit
;;; the sprite within the 32x32 texture size. These anchor positions represent
;;; the player's real position, and the player's entity coordinates will be
;;; calculated by adding a texture origin to the entity's position fields, after
;;; copying them from these anchor variables.
;;; NOTE: y, followed by x, to match the layout in an entity.
var_player_anchor_y:    DS      FIXNUM_SIZE
var_player_anchor_x:    DS      FIXNUM_SIZE


PERSISTENT_STATE_DATA_END:


;;; ############################################################################

        SECTION "STATS", WRAM0


;;; TODO...


;;; ############################################################################

        SECTION "MAP_INFO", WRAM0

MAP_TILE_WIDTH EQU 16
MAP_WIDTH EQU SCRN_VX / MAP_TILE_WIDTH
MAP_HEIGHT EQU SCRN_VY / MAP_TILE_WIDTH

var_map_info:    DS     MAP_WIDTH * MAP_HEIGHT


var_map_slabs:   DS     MAP_HEIGHT / 2 ; Eight slabs


var_map_columns: DS     (MAP_HEIGHT / 2) * 2


;;; SECTION MAP_INFO


;;; ############################################################################

        SECTION "ENTITY_BUFFER", WRAM0

ENTITY_BUFFER_CAPACITY EQU 8
ENTITY_POINTER_SIZE EQU 2

var_entity_buffer_size: DS      1
var_entity_buffer:      DS      ENTITY_POINTER_SIZE * ENTITY_BUFFER_CAPACITY

;;; Used as a placeholder value while sorting entities by y value.
var_last_entity_y:      DS      1
var_last_entity_idx:    DS      1

;;; SECTION ENTITY_BUFFER


;;; ############################################################################

        SECTION "MESSAGE_BUS", WRAM0


MESSAGE_QUEUE_COUNT EQU ENTITY_BUFFER_CAPACITY - 1

var_message_queues::
DS      MESSAGE_QUEUE_COUNT
var_message_queues_end::


MESSAGE_SIZE EQU 4                      ; Four bytes per message

MESSAGE_QUEUE_CAPACITY EQU 7            ; Seven messages per queue

;;; Add one message to the queue capacity, for queue header (size, flags, etc.)
MESSAGE_QUEUE_SIZE EQU MESSAGE_SIZE * (MESSAGE_QUEUE_CAPACITY + 1)


var_message_queue_memory::
DS      MESSAGE_QUEUE_SIZE * (MESSAGE_QUEUE_COUNT + 1) ; +1 for player's queue
var_message_queue_memeory_end::


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
var_player_type:        DS   1

var_player_message_bus: DS   1

var_player_struct_end:

var_player_color_counter: DS   1

ENTITY_SIZE EQU var_player_struct_end - var_player_struct


;;; Just a scratch variable that simplifies other code.
var_player_spill2:      DS      1


var_collect_item_xy:    DS      1


;;; SECTION Player

;;; ############################################################################

	SECTION "DEBUG_TEST_ENTITY", WRAM0

;;; Sometimes I uncomment this, and allocate an entity from the static debug
;;; mem, so that I can see descriptive labels for the entity's variables in a
;;; debugger.

;; var_debug_struct:
;; var_debug_swap_spr:     DS      1
;; var_debug_coord_y:      DS      FIXNUM_SIZE
;; var_debug_coord_x:      DS      FIXNUM_SIZE

;; var_debug_animation:
;; var_debug_timer:        DS      1
;; var_debug_kf:           DS      1
;; var_debug_fb:           DS      1

;; var_debug_texture:      DS      1
;; var_debug_palette:     DS   1
;; var_debug_display_flag:   DS      1

;; var_debug_update_fn:    DS      2
;; var_debug_type:         DS      1
;; var_debug_struct_end:


;;; ############################################################################

        SECTION "ENTITY_RAM", WRAM0

STATIC_ASSERT(ENTITY_SIZE <= 32)
var_entity_mem:         DS  (ENTITY_SIZE + (32 - ENTITY_SIZE)) * ENTITY_BUFFER_CAPACITY

var_entity_mem_used::
DS      ENTITY_BUFFER_CAPACITY
var_entity_mem_used_end::

;;; SECTION ENTITY_RAM


;;; ############################################################################

	SECTION "TEXTURE_SLOTS", WRAM0

TEXTURE_SLOT_COUNT EQU ENTITY_BUFFER_CAPACITY - 1

var_texture_slots::
DS      TEXTURE_SLOT_COUNT
var_texture_slots_end::


;;; SECTION TEXTURE_SLOTS

;;; ############################################################################

        SECTION "VIEW", WRAM0


var_shake_magnitude:    DS      1
var_shake_timer:        DS      1


var_overlay_alternate_pos:    DS      1
var_stamina_last_val:         DS      1
var_overlay_back_buffer:      DS      20


;;; ############################################################################

        SECTION "SCENE", WRAM0

var_scene_update_fn:    DS      2
var_scene_vblank_fn:    DS      2


var_scene_counter:      DS      1

var_scene_union:
        UNION
var_world_map_cursor_x:       DS      1
var_world_map_cursor_y:       DS      1
var_world_map_cursor_tx:      DS      1
var_world_map_cursor_ty:      DS      1
var_world_map_cursor_visible: DS      1
var_world_map_cursor_moving:  DS      1

var_world_map_debug_counter:  DS      1
        NEXTU
;;; Room loading vars
var_room_load_counter:        DS      1
var_room_load_parity:         DS      1
var_room_load_orientation:    DS      1
var_room_load_joypad_cache:   DS      1

var_room_load_slab:           DS      32
var_room_load_colors:         DS      32
        NEXTU
;;; Inventory vars
var_inventory_scene_selected_row:       DS      1
var_inventory_scene_page:               DS      1

CRAFTABLE_ITEMS_COUNT   EQU     32

;;; FIXME: This currently just stores item ids, but it needs to instead store
;;; pointers into the recipe table, for items that can be crafted in different
;;; ways (different sets of dependencies).
var_inventory_scene_craftable_items_list:   DS  2 * CRAFTABLE_ITEMS_COUNT

var_crafting_dependency_set:  DS      ITEM_SIZE * 3
var_crafting_dependency_set_end:

var_inventory_submenu_selection:        DS      1
var_inventory_add_stamina_amount:       DS      1

        NEXTU
var_scavenge_selection:         DS      1
        NEXTU
var_blizzard_color_pulse_counter:       DS      1
var_blizzard_fade_amount:               DS      1
var_blizzard_last_fade_amount:          DS      1
var_blizzard_fadein_counter:            DS      1

var_blizzard_snowflakes:   DS BLIZZARD_SNOWFLAKE_SIZE * BLIZZARD_SNOWFLAKE_COUNT

        NEXTU
var_shell_cursor_x:     DS      1
var_shell_cursor_y:     DS      1

var_shell_command_buffer: DS      32
var_shell_parse_buffer:   DS      32
var_shell_argstring:      DS      2
var_command_buffer_size:  DS      1

var_shell_completion_count:     DS      1

var_shell_completion_select:    DS      1

var_shell_parse_argument:       DS      32

        NEXTU
var_dialog_string:              DS      2
var_dialog_current_word:        DS      18
var_dialog_current_char:        DS      1
var_dialog_counter:             DS      1
var_dialog_finished:            DS      1
var_dialog_cursor_x:            DS      1
var_dialog_cursor_y:            DS      1
var_dialog_scroll_in_y:         DS      1
var_dialog_a_released:          DS      1
var_dialog_next_scene:          DS      2
var_dialog_option_selected:     DS      1
        NEXTU
        ENDU
var_scene_union_end:


;;; Cutscene control variables
var_cutscene_tile_offset:       DS      1
var_cutscene_tile_start_bank:   DS      1
var_cutscene_tile_current_bank: DS      1
var_cutscene_map_bank:          DS      1
var_cutscene_offsets_array:     DS      2


var_water_anim:
var_water_anim_timer:   DS      1
var_water_anim_idx:     DS      1
var_water_anim_changed: DS      1



INVENTORY_TAB_ITEMS     EQU     0
INVENTORY_TAB_CRAFT     EQU     1
INVENTORY_TAB_COOK      EQU     2
INVENTORY_TAB_COUNT     EQU     3

var_inventory_scene_tab:                DS      1
var_inventory_scene_cooking_tab_avail:  DS      1


;;; ############################################################################

        SECTION "MISC", WRAM0

;;; TODO: reserve some scratch space for random calculations in one of the less
;;; important ram banks.

var_misc_data_union:
        UNION
;;; Vars for bounding box testing. Otherwise, I would need to put this stuff on
;;; the stack, which is possible but inconvenient.
var_temp_hitbox1:       DS      4
var_temp_hitbox2:       DS      4
	NEXTU
;;; Intended to be used for integer->string conversions
var_temp_str1:          DS      6 ; Max 16 bit value needs 5 places, plus null
var_temp_str2:          DS      6
var_temp_str3:          DS      10
        NEXTU
        ENDU
var_misc_data_union_end:

var_blizzard_active:    DS      1

var_scavenge_slot_0:    DS      1
var_scavenge_slot_1:    DS      1
var_scavenge_target:    DS      2


var_entity_slab_weight: DS      1

var_bonfire_dialog_played:      DS      1


;;; ############################################################################

        SECTION "FADE", WRAM0

var_last_fade_amount:   DS      1


;;; ############################################################################

        SECTION "COLOR_PROFILE", WRAM0

var_fade_bank:          DS      1
var_fade_to_black_spr_lut:      DS      2
var_fade_to_black_bkg_lut:      DS      2
var_fade_to_tan_spr_lut:        DS      2
var_fade_to_tan_bkg_lut:        DS      2


;;; ############################################################################

STACK_SIZE EQU 200
STACK_BEGIN EQU $CFFF
STACK_END EQU (STACK_BEGIN - STACK_SIZE) + 1

        SECTION "STACK", WRAM0[STACK_END]

__stack:   DS      STACK_SIZE

STATIC_ASSERT(STACK_SIZE % 2 == 0)


;;; ############################################################################
