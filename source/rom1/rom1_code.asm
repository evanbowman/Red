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

;;;
;;; Rom bank 1 contains various functions for loading entities and dealing with
;;; map data, as well as misc utility code.
;;;

        INCLUDE "r1_miscUtilities.asm"
        INCLUDE "r1_readKeys.asm"
        INCLUDE "r1_mapFunctions.asm"
        INCLUDE "r1_inventory.asm"
        INCLUDE "r1_entityConstructors.asm"
        INCLUDE "r1_exp.asm"
        INCLUDE "r1_worldgen.asm"
        INCLUDE "r1_blizzard.asm"


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
        fcall   Memset

        ld      hl, _OAMRAM
        ld      a, 0
        ld      bc, $FE9F - $FE00
        fcall   Memset

        ld      hl, r1_GameboyColorNotDetectedText
        ld      b, $88
        ld      de, _SCRN1
        fcall   r1_DMGPutText
        fcall   LcdOn

        ld      a, 7
        ld      [rWX], a

        halt


;;; ----------------------------------------------------------------------------

r1_GameboyAdvanceDetected:
        ld      a, 1
        ldh     [hvar_agb_detected], a

	ret


;;; ----------------------------------------------------------------------------

r1_SaveMagic:
DB      $52, $45, $44, $5f


;;; ----------------------------------------------------------------------------

r1_InvalidateSave:
        ld      a, $0a                  ; \ Enable SRAM read/write
        ld      [rRAMG], a              ; /

        xor     a
        ld      [rRAMB], a

        ld      hl, sram_var_magic
        ld      a, $5f
        ld      bc, 4
        fcall   Memset

        xor     a                       ; \ Disable SRAM read/write
        ld      [rRAMG], a              ; /
        ret


;;; ----------------------------------------------------------------------------

r1_SaveExists:
;;; trashes all registers
;;; Z if save exists, NZ otherwise
        ld      a, $0a                  ; \ Enable SRAM read/write
        ld      [rRAMG], a              ; /

        ld      hl, r1_SaveMagic
        ld      de, sram_var_magic
        ld      c, 4
        fcall   Memeq

        ld      a, 0                    ; \ preserve z flag!!
        ld      [rRAMG], a              ; / Disable SRAM read/write
        ret


;;; ----------------------------------------------------------------------------


r1_SaveGame:
        ld      a, $0a                  ; \ Enable SRAM read/write
        ld      [rRAMG], a              ; /

        xor     a
        ld      [rRAMB], a

        ld      hl, r1_SaveMagic
        ld      bc, 4
        ld      de, sram_var_magic
        fcall   Memcpy


        RAM_BANK 1
        ld      hl, wram1_var_world_map_info
        ld      bc, wram1_var_world_map_info_end - wram1_var_world_map_info
        ld      de, sram_var_world_map_info
        fcall   Memcpy

        ld      hl, PERSISTENT_STATE_DATA
        ld      bc, PERSISTENT_STATE_DATA_END - PERSISTENT_STATE_DATA
        ld      de, sram_var_persistent_data
        fcall   Memcpy

        RAM_BANK 2
        ld      hl, wram2_var_collectibles
        ld      bc, wram2_var_collectibles_end - wram2_var_collectibles
        ld      de, sram_var_collectibles
        fcall   Memcpy

        xor     a                       ; \ Disable SRAM read/writes
        ld      [rRAMG], a              ; /

        ret


;;; ----------------------------------------------------------------------------

r1_LoadGame:
        ld      a, $0a                  ; \ Enable SRAM read/write
        ld      [rRAMG], a              ; /

        ld      a, 0
        ld      [rRAMB], a

	RAM_BANK 1
        ld      de, wram1_var_world_map_info
        ld      bc, wram1_var_world_map_info_end - wram1_var_world_map_info
        ld      hl, sram_var_world_map_info
        fcall   Memcpy

        ld      de, PERSISTENT_STATE_DATA
        ld      bc, PERSISTENT_STATE_DATA_END - PERSISTENT_STATE_DATA
        ld      hl, sram_var_persistent_data
        fcall   Memcpy

        RAM_BANK 2
        ld      de, wram2_var_collectibles
        ld      bc, wram2_var_collectibles_end - wram2_var_collectibles
        ld      hl, sram_var_collectibles
        fcall   Memcpy

        xor     a                       ; \ Disable SRAM read/write
        ld      [rRAMG], a              ; /

        ret


;;; ----------------------------------------------------------------------------

r1_SetCgbColorProfile:
        ld      a, 7
        ld      [var_fade_bank], a


        ld      bc, r7_BackgroundPaletteFadeToBlack
        ld      a, b
        ld      [var_fade_to_black_bkg_lut], a
        ld      a, c
        ld      [var_fade_to_black_bkg_lut + 1], a


        ld      bc, r7_SpritePaletteFadeToBlack
        ld      a, b
        ld      [var_fade_to_black_spr_lut], a
        ld      a, c
        ld      [var_fade_to_black_spr_lut + 1], a


        ld      bc, r7_BackgroundPaletteFadeToTan
        ld      a, b
        ld      [var_fade_to_tan_bkg_lut], a
        ld      a, c
        ld      [var_fade_to_tan_bkg_lut + 1], a


        ld      bc, r7_SpritePaletteFadeToTan
        ld      a, b
        ld      [var_fade_to_tan_spr_lut], a
        ld      a, c
        ld      [var_fade_to_tan_spr_lut + 1], a

        ret


;;; ----------------------------------------------------------------------------


;;; SECTION ROM1_CODE


;;; ############################################################################
