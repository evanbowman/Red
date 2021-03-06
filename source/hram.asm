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



;; ############################################################################

        SECTION "SLEEP_COUNTER", HRAM

hvar_sleep_counter:     DS      1


;;; SECTION SLEEP_COUNTER


;;; ############################################################################

        SECTION "VIEW_VARS", HRAM

hvar_overlay_y_offset:        DS      1
hvar_view_x:   DS      1
hvar_view_y:   DS      1


;; #############################################################################

        SECTION "JOYPAD_VARS", HRAM

hvar_joypad_current:     DS      1       ; Edge triggered
hvar_joypad_previous:    DS      1
hvar_joypad_raw:         DS      1       ; Level triggered
hvar_joypad_released:    DS      1       ; Edge triggered


;;; SECTION JOYPAD_VARS


;;; ############################################################################

        SECTION "IRQ_VARIABLES", HRAM

hvar_vbl_flag:   DS      1


;;; SECTION IRQ_VARIABLES


;;; ############################################################################

        SECTION "MISC_HRAM", HRAM

;;; TODO: use unique color palettes for Gameboy Advance
hvar_agb_detected:   DS      1

hvar_rand_state:     DS      2

hvar_exp_changed_flag:          DS      1
hvar_exp_levelup_ready_flag:    DS      1


hvar_temp_loop_counter1:         DS      1
hvar_temp_loop_counter2:         DS      1


;;; Controls the shadow flicker. $ff for even, $00 for odd. Switches back and
;;; forth between even and odd. When even, even numbered entities in the display
;;; queue will have visible shadows. When odd, odd numbered entities in the
;;; display queue will have visible shadows.
hvar_shadow_parity:    DS      1
hvar_shadow_state:     DS      1
hvar_current_entity_parity:     DS      1


hvar_column_table_result:       DS      1


hvar_spritesheet:      DS       1


;;; SECTION MISC_HRAM


;;; ############################################################################


        SECTION "WALL_COLLISON_TEST_VARS", HRAM

hvar_wall_collision_source_x: DS 1
hvar_wall_collision_source_y: DS 1
hvar_wall_collision_size_x:   DS 1
hvar_wall_collision_size_y:   DS 1


hvar_wall_collision_result:   DS 1


hvar_bank:      DS      1


;;; SECTION WALL_COLLISON_TEST_VARS


;;; ############################################################################
