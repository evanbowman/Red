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
;;;  Restore Checkpoint Scene
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


;;; ----------------------------------------------------------------------------

RestoreCheckpointSceneUpdate:
        fcall   EntityBufferReset ; Release all entity mem and message queues.

        LONG_CALL r1_PlayerNew

        xor     a
        ld      [var_player_color_counter], a

	;; Decrement lives in SRAM.
        ld      a, $0a                  ; \ Enable SRAM read/write
        ld      [rRAMG], a              ; /
        xor     a
        ld      [rRAMB], a
        ld      hl, (var_lives-PERSISTENT_STATE_DATA) + sram_var_persistent_data
        ld      a, [hl]
        dec     a
        ld      [hl], a
	xor     a                       ; \ Disable SRAM read/write
        ld      [rRAMG], a              ; /


        LONG_CALL r1_LoadGame

        ld      a, [var_lives]
        or      a
        jr      Z, .gameover


        ld      de, var_player_coord_y  ; \
        ld      hl, var_player_anchor_y ; | Restore player position from
        ld      bc, FIXNUM_SIZE * 2     ; | persistent view anchor.
        fcall   Memcpy                  ; /


        fcall   MapLoad2__rom0_only
        fcall   MapShow

        LONG_CALL r1_LoadRoomEntities

        ld      de, OverworldSceneEnter
        fcall   SceneSetUpdateFn

        ld      de, VoidVBlankFn
        fcall   SceneSetVBlankFn

        LONG_CALL r1_SaveGame
        LONG_CALL r1_InvalidateSave

        ret

.gameover:
        jp      SystemReboot    ; FIXME: of course this is just a placeholder.


;;; ----------------------------------------------------------------------------
