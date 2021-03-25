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
;;; tl;dr: Do whatever you want with the code, just don't blame me if something
;;; goes wrong.
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



SPRITE_SHAPE_SQUARE_32 EQU $f0
SPRITE_SHAPE_T EQU $e0
SPRITE_SHAPE_TALL_16_32 EQU $00


        INCLUDE "hardware.inc"
        INCLUDE "defs.inc"
        INCLUDE "sprid.inc"
        INCLUDE "entityType.inc"
        INCLUDE "item.inc"



;;; NOTE: LONG_CALL does not restore the current rom bank
LONG_CALL: MACRO
        ld      a, \2
        ld      hl, \1
        rst     $08
ENDM


INVOKE_HL: MACRO
        rst     $10
ENDM


SET_BANK: MACRO
        ld      a, \1
        ld      [rROMB0], a
ENDM


        INCLUDE "hram.asm"
        INCLUDE "wram0.asm"
        INCLUDE "wram1.asm"
        INCLUDE "wram2.asm"
        INCLUDE "wram3.asm"
        INCLUDE "wram4.asm"
        INCLUDE "wram5.asm"
        INCLUDE "wram6.asm"
        INCLUDE "wram7.asm"


;; ############################################################################

        SECTION "RESTART_VECTOR_08",ROM0[$0008]
        ld      [rROMB0], a
        jp      hl


;; ############################################################################

        SECTION "RESTART_VECTOR_10",ROM0[$0010]
        jp      hl


;; ############################################################################

        SECTION "VBL", ROM0[$0040]
	jp	Vbl_isr

;;; ----------------------------------------------------------------------------

Vbl_isr:
        push    af
        ld      a, 1
        ldh     [var_vbl_flag], a
        pop     af
        reti


;;; ----------------------------------------------------------------------------


;;; SECTION VBL


;;; ############################################################################

        SECTION "BOOT", ROM0[$100]

;;; ----------------------------------------------------------------------------

EntryPoint:
        nop
        jp      Start


;;; ----------------------------------------------------------------------------


;;; SECTION BOOT


;;; ############################################################################

        SECTION "START", ROM0[$150]

;;; ----------------------------------------------------------------------------


;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;; Boot Code and main loop
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


Start:
        di                              ; Turn off interrupts during startup.
        ld      sp, STACK_BEGIN         ; Setup stack (end of wram0).

.checkGameboyColor:
        cp      a, BOOTUP_A_CGB         ; Boot leaves value in reg-a
        jr      z, .gbcDetected         ; if a == 0, then we have gbc

        di
        call    LcdOff
        call    LoadFont
	LONG_CALL r1_GameboyColorNotDetected, 1

;;; TODO: Display some text to indicate that the game requires a gbc. There's no
;;; need to waste space in bank zero for this stuff, though.


.gbcDetected:
        ld      a, 0
        ldh     [agb_detected], a
        ld      a, b
        cp      a, BOOTUP_B_AGB
        jr      NZ, .configure

;;; TODO: I need to add the corrected color palettes for gba. Until then, the
;;; game will not be playable on the gba, as the color palettes would not
;;; look too good anyway.
.agbDetected:
        LONG_CALL r1_GameboyAdvanceDetected, 1


.configure:
        LONG_CALL r1_SetCpuFast, 1
        LONG_CALL r1_VBlankPoll, 1         ; Wait for vbl before disabling lcd.

        call    LcdOff

	ld	a, 0
	ld	[rIF], a
	ld	[rSTAT], a
	ld	[rSCX], a
	ld	[rSCY], a
	ld	[rLYC], a
	ld	[rIE], a
	ld	[rVBK], a
	ld	[rSVBK], a
	ld	[rRP], a

        LONG_CALL r1_InitRam, 1

        jr      Main


;;; ----------------------------------------------------------------------------


Main:
        ld	a, IEF_VBLANK	        ; vblank interrupt
	ld	[rIE], a	        ; setup

        LONG_CALL r1_SetCgbColorProfile, 1

        ld      b, ITEM_DAGGER
        call    InventoryAddItem

        ld      b, ITEM_RAW_MEAT
        call    InventoryAddItem

        ld      b, ITEM_RAW_MEAT
        call    InventoryAddItem

        ld      b, ITEM_STICK
        call    InventoryAddItem

        ld      b, ITEM_TURNIP
        call    InventoryAddItem

        ld      b, ITEM_TURNIP
        call    InventoryAddItem

        SET_BANK 10
        ld      a, 1
        ld      [rSVBK], a
        ld      hl, r10_DefaultMap1
        ld      bc, wram1_var_world_map_info_end - wram1_var_world_map_info
        ld      de, wram1_var_world_map_info
        call    Memcpy

        LONG_CALL r1_CopyDMARoutine, 1
	LONG_CALL r1_SetRoomVisited, 1

	ld      b, 5
        ld      c, 6
        LONG_CALL r1_LoadRoom, 1

        ld      de, IntroCreditsSceneEnter
        call    SceneSetUpdateFn

        ld      de, VoidVBlankFn
        call    SceneSetVBlankFn

        LONG_CALL r1_PlayerNew, 1

        call    LoadFont

        call    MapInit
        call    MapLoad

        ld      hl, test_string
        ld      b, $88
        ld      de, _SCRN1
        call    PutText

        call    LcdOn

        ld      b, 96
        ld      c, 96
        LONG_CALL r1_BonfireNew, 1

        ei

.loop:
        LONG_CALL r1_ReadKeys, 1
        ld      a, b
        ldh     [var_joypad_raw], a


        ld      de, var_scene_update_fn ; \
        ld      a, [de]                 ; |
        inc     de                      ; |
        ld      h, a                    ; | Fetch scene update fn
        ld      a, [de]                 ; |
        ld      l, a                    ; /
        INVOKE_HL                       ; Jump to scene update code


.sched_sleep:
        ldh     a, [var_sleep_counter]
        or      a
        jr      z, .vsync
        dec     a
        ldh     [var_sleep_counter], a
        call    VBlankIntrWait
        jr      .sched_sleep


.vsync:
        call    VBlankIntrWait          ; vsync

        ld      a, [var_view_x]
        ld      [rSCX], a

        ld      a, [var_view_y]
        ld      [rSCY], a

        ld      a, HIGH(var_oam_back_buffer)
        call    hOAMDMA


        ld      de, var_scene_vblank_fn ; \
        ld      a, [de]                 ; |
        inc     de                      ; |
        ld      h, a                    ; | Fetch scene vblank fn
        ld      a, [de]                 ; |
        ld      l, a                    ; /
        INVOKE_HL                       ; Jump to scene vblank code

;;; As per my own testing, I can fit about five DMA block copies for 32x32 pixel
;;; sprites in within the vblank window.
.done:
        ld      a, [rLY]
        cp      SCRN_Y
        jr      C, .vbl_window_exceeded

        jr      Main.loop

;;; This is just some debugging code. I'm trying to figure out how much stuff
;;; that I can copy within the vblank window.
.vbl_window_exceeded:
        stop


;;; ----------------------------------------------------------------------------

VoidVBlankFn:
	ret


;;; ----------------------------------------------------------------------------

VoidUpdateFn:
        ret


;;; ----------------------------------------------------------------------------

MapSpriteBlock:
; h target sprite index
; b vram index
; overwrites de
;;; Sprite blocks are 32x32 in size. Because 32x32 sprites occupy 256 bytes,
;;; indexing is super easy.
;;; FIXME: In the future, if we want to support more than 256 sprites, what to
;;; do?
;;; TODO: parameterize vram dest
        ld      de, r2_SpriteSheetData
        ld      l, 0
        add     hl, de                  ; h is in upper bits, so x256 for free

        push    hl
        ld      hl, _VRAM
        ld      c, 0
        add     hl, bc
        ld      d, h
        ld      e, l
        pop     hl

        ld      b, 15
        call    GDMABlockCopy
        ret


;;; ----------------------------------------------------------------------------


;;; I ran into issues where the I see illegal instruction errors when separating
;;; my source code into different sections.
        INCLUDE "animation.asm"
        INCLUDE "entity.asm"
        INCLUDE "bonfire.asm"
        INCLUDE "player.asm"
        INCLUDE "scene.asm"
        INCLUDE "inventory.asm"
        INCLUDE "overworldScene.asm"
        INCLUDE "inventoryScene.asm"
        INCLUDE "introCreditsScene.asm"
        INCLUDE "roomTransitionScene.asm"
        INCLUDE "worldmapScene.asm"
        INCLUDE "utility.asm"
        INCLUDE "fixnum.asm"
        INCLUDE "map.asm"
        INCLUDE "video.asm"
        INCLUDE "data.asm"
        INCLUDE "rom1_code.asm"
        INCLUDE "rom2_data.asm"
        INCLUDE "rom7_data.asm"
        INCLUDE "rom8_code.asm"
        INCLUDE "rom9_code.asm"
        INCLUDE "rom10_map_data.asm"
        INCLUDE "rom11_data.asm"


;;; SECTION START


;;; ----------------------------------------------------------------------------

;;; ############################################################################

        SECTION "OAM_DMA_ROUTINE", HRAM

hOAMDMA::
        ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to


;;; SECTION OAM_DMA_ROUTINE


;;; ############################################################################
