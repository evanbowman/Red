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
;;;
;;; Sorry for the gigantic file. I do not trust the rgbds linker one bit. If
;;; anyone wants to split the code into separate files, you're welcome to try.
;;;
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

;; ############################################################################

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

;; ############################################################################

        SECTION "SLEEP_COUNTER", HRAM

var_sleep_counter:     DS      1


;;; SECTION SLEEP_COUNTER


;; ############################################################################

        SECTION "JOYPAD_VARS", HRAM

var_joypad_current:     DS      1       ; Edge triggered
var_joypad_previous:    DS      1
var_joypad_raw:         DS      1       ; Level triggered
var_joypad_released:    DS      1       ; Edge triggered


;;; SECTION JOYPAD_VARS


;;; ############################################################################

        SECTION "IRQ_VARIABLES", HRAM

var_vbl_flag:   DS      1


;;; SECTION IRQ_VARIABLES


;;; ############################################################################

        SECTION "MISC_HRAM", HRAM

;;; TODO: use unique color palettes for Gameboy Advance
agb_detected:   DS      1


;;; SECTION IRQ_VARIABLES


;;; ############################################################################

        SECTION "OAM_BACK_BUFFER", WRAM0, ALIGN[8]

var_oam_back_buffer:
        ds OAM_SIZE * OAM_COUNT


var_oam_top_counter:     DS      1
var_oam_bottom_counter:  DS      1


;;; SECTION OAM_BACK_BUFFER


;;; ############################################################################

        SECTION "MAP_INFO", WRAM0, ALIGN[8]

MAP_TILE_WIDTH EQU 16
MAP_WIDTH EQU SCRN_VX / MAP_TILE_WIDTH
MAP_HEIGHT EQU SCRN_VY / MAP_TILE_WIDTH

var_map_info:    DS     MAP_WIDTH * MAP_HEIGHT
var_map_scratch: DS     MAP_WIDTH * MAP_HEIGHT


;;; SECTION MAP_INFO

;;; ############################################################################

        SECTION "PLAYER", WRAM0, ALIGN[8]


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

        SECTION "ENTITY_BUFFER", WRAM0, ALIGN[8]

ENTITY_BUFFER_CAPACITY EQU 8
ENTITY_POINTER_SIZE EQU 2

var_entity_buffer_size: DS      1
var_entity_buffer:      DS      ENTITY_POINTER_SIZE * ENTITY_BUFFER_CAPACITY

;;; Used as a placeholder value while sorting entities by y value.
var_last_entity_y:      DS      1
var_last_entity_idx:    DS      1


;;; ############################################################################

        SECTION "VIEW", WRAM0, ALIGN[8]

var_view_x:    DS      1
var_view_y:    DS      1


;;; ############################################################################


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

        call    PlayerInit

        call    LoadOverworldPalettes

        ld      hl, OverlayTiles
        ld      bc, OverlayTilesEnd - OverlayTiles
        ld      de, $9000
        call    Memcpy

        ld      hl, BackgroundTiles
        ld      bc, BackgroundTilesEnd - BackgroundTiles
        ld      de, $8800
        call    Memcpy

        ld      hl, SpriteDropShadow
        ld      bc, SpriteDropShadowEnd - SpriteDropShadow
        ld      de, $8500
        call    Memcpy

        call    TestOverlay

        call    MapInit
        call    MapLoad

        call    DebugInit

        ld      a, 136
        ld      [rWY], a

        ld      a, 7
        ld      [rWX], a

.activate_screen:
        ld	a, SCREEN_MODE
        ld	[rLCDC], a	        ; enable lcd
        ei

.loop:
        call    ReadKeys
        ld      a, b
        ldh     [var_joypad_raw], a
        call    UpdateScene

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

        call    UpdateStaminaBar


;;; Now, this entity buffer code looks pretty nasty. But, we are just doing a
;;; bunch of work upfront, because we do not always need to actually run the
;;; dma. Iterate through each entity, check its swap flag. If the entity
;;; requires a texture swap, map the texture into vram with GDMA.
        ld      a, SPRITESHEET1_ROM_BANK
        ld      [rROMB0], a

        ld      de, var_entity_buffer
        ld      a, [var_entity_buffer_size]

.textureCopyLoop:
        cp      0
        jr      Z, .textureCopyLoopDone
        dec     a
        push    af              ; store loop counter

;;; Even with DMA, we can only fit so many texture copies into the vblank
;;; window. If we think that we're going to exceed the vblank, defer the
;;; copies to the next iteration. The code is just checking entities for
;;; a flag which indicates that a texture copy is needed, so we can just as
;;; easily process the texture copy after the next frame.
        ld      a, [rLY]
        ld      b, a
        ld      a, 153 - 4
        cp      b
        jr      C, .textureCopyLoopTimeout


        ld      a, [de]         ; Fetch entity pointer from entity buffer
        ld      h, a
        inc     de
        ld      a, [de]
        ld      l, a            ; Now we have the entity pointer in hl
        inc     de

        ld      a, [hl]         ; load texture swap flag from entity
        or      a
        jr      Z, .noTextureCopy ; swap flag false, nothing to do
        ld      a, 0
        ld      [hl], a         ; We're swapping the texture, zero the flag

        push    de              ; store entity buffer pointer on stack

        ld      d, 0
        ld      e, 1 + FIXNUM_SIZE * 2 + 1
	add     hl, de          ; jump to offset of keyframe in entity

        ld      a, [hl+]
        ld      d, [hl]         ; load frame base
        inc     hl
        ld      b, [hl]
.test:
        add     d               ; keyframe + framebase is spritesheet index
        ld      h, a            ; pass spritesheet index in h
        call    MapSpriteBlock  ; DMA copy the sprite into vram

        pop     de              ; restore entity buffer pointer
.noTextureCopy:

        pop     af              ; restore loop counter
        jr      .textureCopyLoop


.textureCopyLoopTimeout:
        pop     af              ; Was pushed at the top of the loop

;;; intentional fallthrough

.textureCopyLoopDone:
;;; The whole point of the above loop was to copy sprites from various rom banks
;;; into vram. So we should set the rom bank back to one, which is the standard
;;; rom bank for most purposes.
        ld      a, 1
        ld      [rROMB0], a


;;; As per my own testing, I can fit about five DMA block copies for 32x32 pixel
;;; sprites in within the vblank window.
.done:
        ld      a, [rLY]
        cp      SCRN_Y
        jr      C, .vbl_window_exceeded

        jr      .loop

;;; This is just some debugging code. I'm trying to figure out how much stuff
;;; that I can copy within the vblank window.
.vbl_window_exceeded:
        stop


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



        INCLUDE "animation.asm"
        INCLUDE "entity.asm"
        INCLUDE "player.asm"
        INCLUDE "scene.asm"
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
