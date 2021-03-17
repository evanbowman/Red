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


;;;
;;; Various parts of the code refer to an entity. This is the approximate layout
;;; of a game entity:
;;;
;;; struct Entity {
;;;     char texture_swap_flag_;
;;;     Fixnum coord_y_; // (three bytes)
;;;     Fixnum coord_x_; // (three bytes)
;;;     Animation anim_; // (two bytes)
;;;     char base_frame_;
;;;     char vram_index_;
;;;     char display_flags_;
;;;     Pointer update_fn_;
;;; };
;;;

SPRITE_SHAPE_SQUARE_32 EQU $f0
SPRITE_SHAPE_T EQU $e0
SPRITE_SHAPE_TALL_16_32 EQU $00


        INCLUDE "hardware.inc"
        INCLUDE "defs.inc"

;;; Player spritesheet constants (needs to match the ordering of data in bank 2)
SPRID_PLAYER_WR EQU     0
SPRID_PLAYER_SR EQU     5
SPRID_PLAYER_WL EQU     6
SPRID_PLAYER_SL EQU     11
SPRID_PLAYER_WD EQU     12
SPRID_PLAYER_SD EQU     22
SPRID_PLAYER_WU EQU     23
SPRID_PLAYER_SU EQU     33
SPRID_BONFIRE   EQU     34


        INCLUDE "hram.asm"
        INCLUDE "wram0.asm"


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
        di                              ; Turn of interrupts during startup.
        ld      sp, $E000               ; Setup stack.


.checkGameboyColor:
        cp      a, BOOTUP_A_CGB         ; Boot leaves value in reg-a
        jr      z, .gbcDetected         ; if a == 0, then we have gbc
        jr      .checkGameboyColor      ; Freeze

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
        ld      a, 1
        ldh     [agb_detected], a
        jr      .agbDetected


.configure:
        call    SetCpuFast
        call    VBlankPoll              ; Wait for vbl before disabling lcd.

	ld	a, 0
	ld	[rIF], a
	ld	[rLCDC], a
	ld	[rSTAT], a
	ld	[rSCX], a
	ld	[rSCY], a
	ld	[rLYC], a
	ld	[rIE], a
	ld	[rVBK], a
	ld	[rSVBK], a
	ld	[rRP], a

        call    InitRam

        jr      Main


;;; ----------------------------------------------------------------------------


Main:
        ld	a, IEF_VBLANK	        ; vblank interrupt
	ld	[rIE], a	        ; setup

        call    CopyDMARoutine

        ld      de, OverworldSceneEnter
        call    SceneSetUpdateFn

        ld      de, VoidVBlankFn
        call    SceneSetVBlankFn

        call    PlayerInit

        call    LoadFont

        call    MapInit
        call    MapLoad

        call    DebugInit

.activate_screen:
        ld	a, SCREEN_MODE
        ld	[rLCDC], a	        ; enable lcd
        ei

.loop:
        call    ReadKeys
        ld      a, b
        ldh     [var_joypad_raw], a


        ld      de, var_scene_update_fn ; \
        ld      a, [de]                 ; |
        inc     de                      ; |
        ld      h, a                    ; | Fetch scene update fn
        ld      a, [de]                 ; |
        ld      l, a                    ; /
        jp      hl                      ; Jump to scene update code

UpdateFnResume:                         ; This label is global, so that the
                                        ; update code can jump back.

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
        ld      h, a                    ; | Fetch scene update fn
        ld      a, [de]                 ; |
        ld      l, a                    ; /
        jp      hl                      ; Jump to scene vblank code

VBlankFnResume:

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
	jr      VBlankFnResume


;;; ----------------------------------------------------------------------------

VoidUpdateFn:
        jr      UpdateFnResume


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
        ld      de, SpriteSheetData
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


;;; I ran into issues where the linker would generate incorrect code. This
;;; isn't such a terrible alternative, though. At least this way, I have some
;;; idea of the order in which my code will be laid out in the ROM.
        INCLUDE "animation.asm"
        INCLUDE "entity.asm"
        INCLUDE "player.asm"
        INCLUDE "scene.asm"
        INCLUDE "overworldScene.asm"
        INCLUDE "roomTransitionScene.asm"
        INCLUDE "utility.asm"
        INCLUDE "joypad.asm"
        INCLUDE "fixnum.asm"
        INCLUDE "map.asm"
        INCLUDE "video.asm"
        INCLUDE "data.asm"


;;; SECTION START


;;; ----------------------------------------------------------------------------

;;; ############################################################################


        SECTION "OAM_DMA_ROUTINE", HRAM

hOAMDMA::
        ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to


;;; SECTION OAM_DMA_ROUTINE


;;; ############################################################################
