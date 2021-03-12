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
.test:
        ld      a, 1
        ldh     [agb_detected], a
        jr      .test

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
        call    DebugInit

        call    LoadOverworldPalettes

        ld      hl, OverlayTiles
        ld      bc, OverlayTilesEnd - OverlayTiles
        ld      de, $8800
        call    Memcpy

        ld      hl, BackgroundTiles
        ld      bc, BackgroundTilesEnd - BackgroundTiles
        ld      de, $8B00
        call    Memcpy

        ld      hl, SpriteDropShadow
        ld      bc, SpriteDropShadowEnd - SpriteDropShadow
        ld      de, $8500
        call    Memcpy

        call    TestOverlay

        call    MapInit
        call    MapLoad

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


;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;;  Animation (struct)
;;;
;;; first byte: timer
;;; second byte: keyframe
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


AnimationAdvance:
;;; hl - animation
;;; c - frame time
;;; d - length
;;; return a (true if keyframe changed)
        ld      a, [hl]         ; load timer from animation struct
        inc     a
        ld      [hl], a         ; writeback
        cp      c               ; compare timer to frame visible length
        jr      NZ, .unchanged

.advance:
        ld      a, 0
        ld      [hl+], a        ; now points to keyframe
        ld      a, [hl]         ; load keyframe from animation struct
        inc     a
        cp      d
        jr      Z, .animLoop
        ld      [hl], a         ; writeback incremented keyframe
        jr      .done

.animLoop:
        ld      a, 0            ; set keyframe to animation beginning
        ld      [hl], a

.done:
        ld      a, 1
        ret

.unchanged:
        ld      a, 0
        ret




;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;;  Entity
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


EntityBufferReset:
        ld      a, 0
        ld      [var_entity_buffer_size], a
        ret


;;; ----------------------------------------------------------------------------


EntityBufferErase:
;;; TODO...
        ret


;;; ----------------------------------------------------------------------------


EntityBufferEnqueue:
;;; de - entity ptr
;;; trashes bc
        ld      a, [var_entity_buffer_size]
        cp      ENTITY_BUFFER_CAPACITY
        jr      Z, .failed

        inc     a
        ld      [var_entity_buffer_size], a
        dec     a

        ld      b, 0
        sla     a

	ld      c, a

        ld      hl, var_entity_buffer
        add     hl, bc

        ld      [hl], d
        inc     hl
        ld      [hl], e

.failed:
        ret


;;; ----------------------------------------------------------------------------


EntitySetUpdateFn:
;;; hl - entity
;;; de - update fn address
        push    de
        ld      d, 0
        ld      e, 13
        add     hl, de
        pop     de

        ld      [hl], d
        inc     hl
        ld      [hl], e

        ret


;;; ----------------------------------------------------------------------------


;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;;  Player
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



PlayerCheckWallCollisions:
        ld      hl, var_player_coord_x
        ld      b, [hl]

        ld      hl, var_player_coord_y
        ld      c, [hl]

        ret


DebugUpdate:
        ld      hl, var_debug_animation
        ld      c, 6
        ld      d, 5
        call    AnimationAdvance
        or      a
        jr      Z, .done
        ld      a, 1
        ld      [var_debug_swap_spr], a

.done:
        jp      EntityUpdateLoopResume



DebugInit:
        ld      hl, var_debug_struct
        ld      de, DebugUpdate
        call    EntitySetUpdateFn

        ld      de, var_debug_struct
        call    EntityBufferEnqueue

        ld      a, 1
        ld      [var_debug_texture], a
        ld      [var_debug_swap_spr], a
        ld      [var_debug_timer], a
        ld      a, 0
        ld      [var_debug_display_flag], a
	ld      [var_debug_kf], a

        ld      hl, var_debug_coord_x
        ld      bc, 96
        call    FixnumInit

        ld      hl, var_debug_coord_y
        ld      bc, 95
        call    FixnumInit

        ld      a, SPRID_BONFIRE
        ld      [var_debug_fb], a

        ld      a, 1
        ld      [var_debug_palette], a

;;; NOTE: this needs to be done in vblank!
        ld      a, 10
        ld      d, 10
        ld      e, $B0
        ld      c, 1
        call    SetBackgroundTile32x32

        ret



PlayerInit:
        ld      hl, var_player_struct
        ld      bc, var_player_struct_end - var_player_struct
        ld      a, 0
        call    Memset

        ld      hl, var_player_coord_x
        ld      bc, 64
        call    FixnumInit

        ld      hl, var_player_coord_y
        ld      bc, 60
        call    FixnumInit

        ld      a, SPRID_PLAYER_SD
        ld      [var_player_fb], a

        ld      a, 1
        ld      [var_player_swap_spr], a

        or      SPRITE_SHAPE_T
        ld      [var_player_display_flag], a

        ld      hl, var_player_struct
        ld      de, PlayerUpdate
        call    EntitySetUpdateFn

        ld      de, var_player_struct
        call    EntityBufferEnqueue

        ld      hl, var_player_stamina
        ld      bc, $ffff
        ld      a, $ff
        call    FixnumInit

        ret



;;; ----------------------------------------------------------------------------

PlayerAnimate:
        ld      a, [var_player_fb]

        ld      c, SPRID_PLAYER_WR
        cp      c
        jr      Z, .animateWalkLR
        ld      c, SPRID_PLAYER_WL
        cp      c
        jr      Z, .animateWalkLR
        ld      c, SPRID_PLAYER_WD
        cp      c
        jr      Z, .animateWalkUD
        ld      c, SPRID_PLAYER_WU
        cp      c
        jr      Z, .animateWalkUD

        jr      .done

.animateWalkLR:
        ld      hl, var_player_animation
        ld      c, 6
        ld      d, 5
        call    AnimationAdvance
        or      a
        jr      NZ, .frameChangedLR
        jr      .done

.animateWalkUD:
        ld      hl, var_player_animation
        ld      c, 6
        ld      d, 10

        call    AnimationAdvance
        or      a
        jr      NZ, .frameChangedUD
.done:
        ret

.frameChangedLR:
        ld      a, 1 | SPRITE_SHAPE_T
        ld      [var_player_display_flag], a
        jr      .frameChanged

.frameChangedUD:
        ld      a, 1 | SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a

.frameChanged:
        ld      a, 1
        ld      [var_player_swap_spr], a
        ret



;;; ----------------------------------------------------------------------------


PlayerJoypadResponse:
;;; a - btn 1 pressed
;;; c - btn 3 or button 4 pressed
;;; e - desired frame
;;; hl - position ptr
;;; b - add/sub position
;;; trashes a
        or      a
        jr      Z, .done

        ld      a, c
        or      a
        jr      Z, .n2
        jr      .setSpeed

.n2:
        ld      a, [var_player_fb]
        cp      e
        jr      Z, .setSpeed    ; the base frame is unchanged

        ld      a, 1
        ld      [var_player_swap_spr], a

        ld      a, e
        ld      [var_player_fb], a

        ld      a, [var_player_kf]
        ld      e, a
        ld      a, 4
        cp      e
        jr      C, .maybeFixFrames
        jr      .setSpeed

;;; The l/r walk cycle is five frames long, the U/D walk cycle is ten frames.
.maybeFixFrames:
        ld      a, [var_player_fb]
        ld      e, SPRID_PLAYER_WL
        cp      e
        jr      Z, .subtrFrames
        ld      e, SPRID_PLAYER_WR
        cp      e
        jr      Z, .subtrFrames
        jr      .setSpeed

.subtrFrames:
        ld      a, [var_player_kf]
        sub     5
        ld      [var_player_kf], a
        ld      a, 1
        ld      [var_player_swap_spr], a

.setSpeed:
        push    bc
        ld      a, b
        or      a
        jr      Z, .subPosition

        ld      a, c
        or      a

;;; We want to add less to each axis-aligned movement vector when moving
;;; diagonally, otherwise, we will move faster in the diagonal direction.
        jr      NZ, .moveDiagonalFwd
        ld      b, 1
        ld      c, 25
        jr      .moveFwd
.moveDiagonalFwd:
        ld      b, 0
        ld      c, 198
.moveFwd:

        call    FixnumAdd
        pop     bc
        jr      .done
.subPosition:

        ld      a, c
        or      a

        jr      NZ, .moveDiagonalRev
        ld      b, 1
        ld      c, 25
        jr      .moveRev
.moveDiagonalRev:
        ld      b, 0
        ld      c, 198
.moveRev:

        ld      b, 1
        ld      c, 25
        call    FixnumSub
        pop     bc
	jr      .done

.else1:
        nop

.done:
        ret



;;; ----------------------------------------------------------------------------



PlayerUpdateMovement:
        ld      hl, var_player_coord_x
        ld      b, 0

        ldh     a, [var_joypad_raw]
        and     PADF_DOWN | PADF_UP
        ld      c, a

        ldh     a, [var_joypad_raw]
        and     PADF_LEFT
        ld      e, SPRID_PLAYER_WL
        call    PlayerJoypadResponse


        ld      hl, var_player_coord_x
        ld      b, 1

        ;; c param is unchanged for this next call
        ldh     a, [var_joypad_raw]
        and     PADF_RIGHT
        ld      e, SPRID_PLAYER_WR
        call    PlayerJoypadResponse


	ld      hl, var_player_coord_y
        ld      b, 1

        ldh     a, [var_joypad_raw]
        and     PADF_LEFT | PADF_RIGHT
        ld      c, a

        ldh     a, [var_joypad_raw]
	and     PADF_DOWN
        ld      e, SPRID_PLAYER_WD
        call    PlayerJoypadResponse

	ld      hl, var_player_coord_y
        ld      b, 0

        ldh     a, [var_joypad_raw]
	and     PADF_UP
        ld      e, SPRID_PLAYER_WU
        call    PlayerJoypadResponse

        ret


PlayerUpdate:
        call    PlayerUpdateMovement

        ldh     a, [var_joypad_released]
        and     PADF_DOWN
        jr      Z, .checkUpReleased

        ldh     a, [var_joypad_raw]
        and     PADF_LEFT | PADF_RIGHT | PADF_UP
        jr      NZ, .checkUpReleased

        ld      a, SPRID_PLAYER_SD
        ld      [var_player_fb], a
        ld      a, 1 | SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a
        ld      a, 0
        ld      [var_player_kf], a
        ld      a, 1
        ld      [var_player_swap_spr], a

.checkUpReleased:
        ldh     a, [var_joypad_released]
        and     PADF_UP
        jr      Z, .checkLeftReleased

        ldh     a, [var_joypad_raw]
        and     PADF_LEFT | PADF_RIGHT | PADF_DOWN
        jr      NZ, .checkLeftReleased

        ld      a, SPRID_PLAYER_SU
        ld      [var_player_fb], a
        ld      a, 1 | SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a
        ld      a, 0
        ld      [var_player_kf], a
        ld      a, 1
        ld      [var_player_swap_spr], a

.checkLeftReleased:
        ldh     a, [var_joypad_released]
        and     PADF_LEFT
        jr      Z, .checkRightReleased

        ldh     a, [var_joypad_raw]
        and     PADF_UP | PADF_DOWN | PADF_RIGHT
        jr      NZ, .checkRightReleased

        ld      a, SPRID_PLAYER_SL
        ld      [var_player_fb], a
        ld      a, 1 | SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a
        ld      a, 0
        ld      [var_player_kf], a
        ld      a, 1
        ld      [var_player_swap_spr], a

.checkRightReleased:
        ldh     a, [var_joypad_released]
        and     PADF_RIGHT
        jr      Z, .animate

        ldh     a, [var_joypad_raw]
        and     PADF_UP | PADF_DOWN | PADF_RIGHT
        jr      NZ, .animate

        ld      a, SPRID_PLAYER_SR
        ld      [var_player_fb], a
        ld      a, 1 | SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a
        ld      a, 0
        ld      [var_player_kf], a
        ld      a, 1
        ld      [var_player_swap_spr], a

.animate:
        ld      a, [var_joypad_raw]
        or      a
        jr      Z, .done

        ld      hl, var_player_stamina
        ld      b, 0
        ld      c, 8
        call    FixnumSub

	call    PlayerAnimate
        jr      .done

.done:
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;;  Scene Engine
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


SetSceneFunction:

        ret



UpdateView:
        ld      a, [var_player_coord_x]
        ld      d, a
        ld      a, 175                  ; 255 - (screen_width / 2)
        cp      d
        jr      C, .xFixedRight
        ld      a, d
        ld      d, 80
	sub     d
        jr      C, .xFixedLeft
        ld      [var_view_x], a

        jr      .setY

.xFixedLeft:
        ld      a, 0
        ld      [var_view_x], a
        jr      .setY

.xFixedRight:
        ld      a, 95                   ; 255 - screen_width
        ld      [var_view_x], a

.setY:
        ld      a, [var_player_coord_y]
        add     a, 8                    ; Menu bar takes up one row, add offset
        ld      d, a
        ld      a, (183 + 19)           ; FIXME: why does this val work?
        cp      d
        jr      C, .yFixedBottom
        ld      a, d
        ld      d, 80
        sub     d
        jr      C, .yFixedTop
        ld      [var_view_y], a

        jr      .done

.yFixedTop:
        ld      a, 0
        ld      [var_view_y], a
        jr      .done

.yFixedBottom:
        ld      a, 121                  ; FIXME: how'd I decide on this number?
        ld      [var_view_y], a

.done:
        ret


;;; ----------------------------------------------------------------------------


UpdateScene:
        ld      de, var_entity_buffer
        ld      a, [var_entity_buffer_size]

;;; intentional fallthrough
EntityUpdateLoop:
        cp      0               ; compare loop counter in a
        jr      Z, EntityUpdateLoopDone
        dec     a
        push    af

        ld      a, [de]         ; fetch entity pointer from buffer
        ld      h, a
        inc     de
        ld      a, [de]
        ld      l, a            ; entity pointer now in hl
        inc     de

	push    de              ; save entity buffer pointer on stack

        ld      e, 13
        ld      d, 0
        add     hl, de          ; jump to position of update routine in entity

        ld      d, [hl]
        inc     hl
        ld      e, [hl]         ; load entity update function ptr

        ld      h, d
        ld      l, e
        jp      hl              ; Jump to entity update address

;;; Now, we could push the stack pointer, thus allowing entity update functions
;;; to be actual functions. For now, entity update functions need to jump back
;;; to this address.
EntityUpdateLoopResume:

        pop     de              ; restore entity buffer pointer
        pop     af              ; restore loop counter
        jr      EntityUpdateLoop

;;; intentional fallthrough
EntityUpdateLoopDone:

;;; If it wasn't for view scrolling, the update and draw stuff could be done in
;;; the same loop.
        call    UpdateView

        ld      a, 255
        ld      [var_last_entity_y], a
        ld      [var_last_entity_idx], a

        ld      a, 0
        ld      [var_oam_top_counter], a
        ld      a, 38
        ld      [var_oam_bottom_counter], a
        ld      de, var_entity_buffer
        ld      a, [var_entity_buffer_size] ; loop counter
EntityDrawLoop:
        cp      0               ; compare loop counter in a
        jp      Z, EntityDrawLoopDone
        dec     a
        push    af

        ld      a, [de]         ; fetch entity pointer from buffer
        ld      h, a
        inc     de
        ld      a, [de]
        ld      l, a            ; entity pointer now in hl
        inc     de

	push    de              ; save entity buffer pointer on stack


	inc     hl              ; hl now points to y coord in entity struct

        ld      a, [var_view_y]
        ld      d, a
        ld      a, [hl+]         ; this is fine, due to layout of fixnum
        sub     d
        ld      c, a

;;; This is a bit delicate. We should really be adding the size of the fixnum
;;; field. But that would be a bunch of loads and an add instruction, so it
;;; wouldn't necessarily be faster.
        inc     hl                      ; jump to location of x coord in entity
        inc     hl                      ; fixnum occupies 3 bytes (see hl+ above)

        ld      a, [var_view_x]
        ld      d, a
        ld      a, [hl]
        sub     d
        ld      b, a

;;; Now, we want to jump to the location of the texture offset in the entity
;;; struct.
;;; See entity struct docs at top of file.
;;; ptr + sizeof(Fixnum) + sizeof(Animation) + 1

        ld      d, 0
        ld      e, FIXNUM_SIZE + 2 + 1
        add     hl, de

        ld      e, [hl]                 ; Load texture index from struct
        inc     hl
        ld      d, [hl]                 ; Load palette index from struct
        inc     hl
;;; Each Sprite is 32x32, and our tile sizes are 8x16. So, to go from
;;; A sprite texture index to a starting tile index, we simply need to move
;;; the lower four bits of the index to the upper four bits (i.e. n x 16).
        swap    e                       ; ShowSprite... uses e as a start tile.

        ld      a, [hl]                 ; Load flags
        push    hl                      ; Store entity pointer

        and     $f0
        ld      h, SPRITE_SHAPE_TALL_16_32
        cp      h
        jr      Z, .putTall16x32Sprite

        ld      h, SPRITE_SHAPE_T
        cp      h
        jr      Z, .putTSprite

        ld      h, SPRITE_SHAPE_SQUARE_32
        cp      h
        jr      Z, .putSquare32Sprite

        jr      .putSpriteFinished

.putTSprite:
	ld      a, [var_oam_top_counter]
        ld      l, a                    ; Oam offset
        add     6                       ; top row uses 2 oam, bottom row uses 4
        ld      [var_oam_top_counter], a
        push    bc
        call    ShowSpriteT
        pop     bc
        jr      .putSpriteFinished

.putSquare32Sprite:
        ld      a, [var_oam_top_counter]
        ld      l, a                    ; Oam offset
        add     8                       ; 32x32 sprite uses 8 oam
        ld      [var_oam_top_counter], a
        push    bc
        call    ShowSpriteSquare32
        pop     bc
        jr      .putSpriteFinished

.putTall16x32Sprite:
        ld      a, [var_oam_top_counter]
        ld      l, a                    ; Oam offset
        add     4                       ; 16x32 sprite uses 4 oam
        ld      [var_oam_top_counter], a
        push    bc
        call    ShowSpriteTall16x32
        pop     bc


.putSpriteFinished:
        pop     hl                      ; Restore entity pointer

;;; Now, check whether the current entity's y value is greater than the previous
;;; entity's y value. If so, swap their entries in the entity buffer. Not as
;;; precise as a real sorting algorithm, but uses less cpu, and at 60fps, the
;;; entity buffer converges to a point where it's sorted by y value pretty
;;; quickly.
	ld      a, [var_last_entity_y]
	cp      c
        jr      C, EntitySwap
EntitySwapResume:

;;; Drop shadow
        ld      a, c
        ld      [var_last_entity_y], a

        ld      a, [hl]
        and     $0f
        or      a
        jr      Z, .skipShadow

        ld      a, c
        add     17
        ld      c, a

	ld      a, [var_oam_bottom_counter]
        ld      l, a
        sub     2                       ; Shadows are 16x16, grow from oam end
        ld      [var_oam_bottom_counter], a
        ld      e, $50
        ld      d, 2
        call    ShowSpriteSquare16

.skipShadow:

        pop     de              ; restore entity buffer pointer
        pop     af              ; restore loop counter
        ld      [var_last_entity_idx], a
        jp      EntityDrawLoop

EntityDrawLoopDone:

        ld      a, [var_oam_top_counter]
        ld      b, a
        ld      l, b
        call    OamLoad

	ld      c, 0

.unusedOAMZeroLoop:
        ld      a, [var_oam_bottom_counter]
        cp      b
        jr      Z, .done

;;; Move unused object to (0,0), effectively hiding it
        ld      [hl], c
        inc     hl
        ld      [hl], c
        inc     hl
        inc     hl
        inc     hl

        inc     b
        jr      .unusedOAMZeroLoop

.done:
        ret


EntitySwap:
;;; This entity swap code may not be very efficient, but it should happen
;;; infrequently.
        ld      a, [var_last_entity_idx]
        ld      d, 255                  ; Using 255 as a null index (before array beginning)
        cp      d
        jr      Z, EntitySwapResume
        push    hl
        ld      d, a
        inc     d
        ld      a, [var_entity_buffer_size]
        sub     d
        ld      hl, var_entity_buffer
        sla     a                       ; Double a, b/c a pointer is two bytes
        ld      e, a
        ld      d, 0

        add     hl, de

;;; Now, we just need to swap pointers in the array.

        push    bc
        push    hl
        ld      a, [hl+]
        ld      d, a
        ld      a, [hl+]
        ld      e, a                    ; Now we have the first value in de

        ld      a, [hl]
        ld      b, a
        ld      a, d
        ld      [hl+], a
        ld      a, [hl]
        ld      c, a
        ld      a, e
        ld      [hl], a

        pop     hl

        ld      a, b
        ld      [hl+], a
        ld      a, c
        ld      [hl], c

        pop     bc
        pop     hl
        jp      EntitySwapResume


;;; ----------------------------------------------------------------------------


;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;; Utility Routines
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


Memset:
; hl - destination
; a - byte to fill with
; bc - size

	inc	b
	inc	c
	jr	.skip
.fill:
	ld	[hl+], a
.skip:
	dec	c
	jr	nz, .fill
	dec	b
	jr	nz, .fill
	ret


;;; ----------------------------------------------------------------------------

Memcpy:
; hl - destination
; bc - size

	inc	b
	inc	c
	jr	.skip
.copy:
	ld	a, [hl+]
	ld	[de], a
	inc	de
.skip:
	dec	c
	jr	nz, .copy
	dec	b
	jr	nz, .copy
	ret


;;; ----------------------------------------------------------------------------

VBlankPoll:
; Intended for waiting on vblank while interrupts are disabled, but the screen
; is still on.
        ld      a, [rLY]
        cp      SCRN_Y
        jr      nz, VBlankPoll
        ret


;;; ----------------------------------------------------------------------------

Reset:
        ld      a, $0
        ld      b, a
        ld      a, BOOTUP_A_CGB
        jp      $0100


;;; ----------------------------------------------------------------------------

InitRam:
;;; trashes hl, bc, a
        ld      a, 0

        ld      hl, _HRAM
        ld      bc, $80
        call    Memset

        ld      hl, _RAM
        ld      bc, $CFFF - _RAM        ; size == pRamEnd - pRam
        call    Memset

        ret


;;; ----------------------------------------------------------------------------

SetCpuFast:
        ld      a, [rKEY1]
        bit     7, a
        jr      z, .impl
        ret

.impl:
        ld      a, $30
        ld      [rP1], a
        ld      a, $01
        ld      [rKEY1], a

        stop
        ret


;;; ----------------------------------------------------------------------------

ScheduleSleep:
; e - frames to sleep
        ldh     a, [var_sleep_counter]
        add     a, e
        ldh     [var_sleep_counter], a
        ret


;;; ----------------------------------------------------------------------------

VBlankIntrWait:
;;; NOTE: We reset the vbl flag before the loop, in case our game logic ran
;;; slow, and we missed the vblank.
        ld      a, 0
        ldh     [var_vbl_flag], a

.loop:
        halt
        ;; The assembler inserts a nop here to fix a hardware bug.
        ldh     a, [var_vbl_flag]
        or      a
        jr      z, .loop
        xor     a
        ldh     [var_vbl_flag], a
        ret


;;; ----------------------------------------------------------------------------


;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;; Joypad Routines
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


ReadKeys:
; b - returns raw state
; c - returns debounced state (edge-triggered)
; d - trashed
        ldh     a, [var_joypad_raw]
        ld      d, a

        ld      a, $20                  ; read P15 - returns a, b, select, start
        ldh     [rP1], a
        ldh     a, [rP1]                ; mandatory
        ldh     a, [rP1]
        cpl                             ; rP1 returns not pressed keys as 1 and pressed as 0, invert it to make result more readable
        and     $0f                     ; lower nibble has a, b, select, start state
        swap    a
        ld      b, a

        ld      a, $10                  ; read P14 - returns up, down, left, right
        ldh     [rP1], a
        ldh     a, [rP1]                ; mandatory
        ldh     a, [rP1]
        ldh     a, [rP1]
        ldh     a, [rP1]
        ldh     a, [rP1]
        ldh     a, [rP1]
        cpl                             ; rP1 returns not pressed keys as 1 and pressed as 0, invert it to make result more readable
        and     $0f                     ; lower nibble has up, down, left, right state
        or      b                       ; combine P15 and P14 states in one byte
        ld      b, a                    ; store it

        ldh     a, [var_joypad_previous]; this is when important part begins, load previous P15 & P14 state
        xor     b                       ; result will be 0 if it's the same as current read
        and     b                       ; keep buttons that were pressed during this read only
        ldh     [var_joypad_current], a ; store final result in variable and register
        ld      c, a
        ld      a, b                    ; current P15 & P14 state will be previous in next read
        ldh     [var_joypad_previous], a

        ld      a, $30                  ; reset rP1
        ldh     [rP1], a

        ld      a, b
        ldh     [var_joypad_raw], a

        cpl                             ; cpl of current == not pressed keys
        and     d                       ; and with prev keys == released
        ldh     [var_joypad_released], a
        ret


;;; ---------------------------------------------------------------------------


;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;; Fixnum
;;;
;;; I'm using a sort of fixed point numbering format, kind of. Fixnums take up
;;; three bytes in memory, consisting of:
;;; 1 upper byte
;;; 1 lower byte
;;; 1 decimal byte
;;;
;;; Combining the upper byte and the lower byte, we have a sixteen bit number.
;;; Combining the lower byte and the decimal byte, we also have a sixteen bit
;;; number.
;;;
;;; This class is potentially over-engineered, but I am not sure how large the
;;; game's rooms will ultimately be, so I am using three-byte fixnums, in case
;;; I need a larger range of coordinates.
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


;;; ---------------------------------------------------------------------------


FixnumInit:
;;; hl - address of number
;;; bc - upper bits
;;; a - decimal
;;; destroys hl
        ld      [hl], c
        inc     hl
        ld      [hl+], a
        ld      [hl], b
        ret


;;; Interprets the decimal bits and the middle bits of a fixnum as a 16 bit
;;; integer, adds them, and increments the high bits upon overflow.
FixnumAdd:
;;; hl - address of number
;;; b - small unit
;;; c - fractional unit
;;; destroys de, hl, bc, a
        push    hl                      ; Store address, for writing back later

        ld      d, [hl]                 ; Load fractional and small units
        inc     hl
        ld      e, [hl]

        ld      a, b                    ; Store small unit in a, load to h later

        inc     hl                      ; inc ptr to location of large unit
        ld      b, [hl]                 ; Load large unit

        ld      h, a                    ; store small unit argument in h

        ld      a, c                    ; load fractional unit argument into l
        ld      l, a

        add     hl, de                  ; Add small and fractional units params
        jr      NC, .writeback          ; If the addition did not overflow
.inc_large_unit:
;;; Ok, so at this point, our addition overflowed the fractional bits and the
;;; small bits, so we need to increment the large bits.
        inc     b
        ;; ld      d, 0  (should already be zeroed by overflow)
        ;; ld      e, 0  is this even necessary?

.writeback:
        ld      d, h
        ld      e, l
        pop     hl

        ld      [hl], d
        inc     hl
        ld      [hl], e
        inc     hl
        ld      [hl], b
        ret


;;; ----------------------------------------------------------------------------


FixnumSub:
;;; hl - address of number
;;; b - small unit
;;; c - fractional unit
;;; This is a bit more complicated, because there's no subtraction instruction
;;; for hl.
        push    hl
        ld      e, [hl]                      ; small units
        inc     hl
        ld      a, [hl]
        inc     hl
        ld      d, [hl]

        sub     c
        push    af
        jr      C, .decFracBits
        jr      .subSmallBits
.decFracBits:
        ld      a, e
        or      a
        jr      Z, .decCarry
        jr      .doDec
.decCarry:
        dec     d
.doDec:
        dec     e
.subSmallBits:
        ld      a, e
        sub     b
        ld      e, a
        jr      C, .decUpperBits
        jr      .done
.decUpperBits:
        dec     d
.done:
        pop     af
        pop     hl
        ld      [hl], e
        inc     hl
        ld      [hl+], a
        ld      [hl], d
        ret


FixnumUpper:
;;; hl - address of number
;;; return result in de
;;; destroys hl
        ld      e, [hl]
        inc     hl
        inc     hl
        ld      d, [hl]
        ret



;;; ---------------------------------------------------------------------------


;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;; Overworld Map
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


MapInit:

        ret

;;; ----------------------------------------------------------------------------

;;; Copy map from wram to vram
MapShow:
        ld      c, 0
        ld      hl, var_map_info

.outerLoop:
	ld      b, 0
        ld      a, 16
        cp      c
        jr      Z, .done

.innerLoop:
        ld      a, 16
        cp      b
        jr      Z, .outerLoopInc

        push    bc

        ld      a, [hl]
        or      a
        jr      Z, .skip

        ld      d, c
        sla     d

        ld      e, $C0

        ld      c, 2

        ld      a, b
	sla     a

        push    hl
        call    SetBackgroundTile16x16
        pop     hl

.skip:

        pop     bc

        inc     b
        inc     hl
	jr      .innerLoop

.outerLoopInc:
	inc     c
        jr      .outerLoop

.done:
        ret


;;; ----------------------------------------------------------------------------

MapGetTile:
;;; hl - map
;;; a - x
;;; b - y
;;; return value in b
;;; trashes hl, c
        swap    b                       ; map is 16 wide
        add     b
        ld      c, 0
        ld      b, a
        add     hl, bc
        ld      b, [hl]
        ret


;;; ----------------------------------------------------------------------------

MapPutSampleData:
        ld      hl, var_map_info

        ld      c, 0

.outer:
        ld      b, 0
.inner:
        ld      a, 0
        cp      b
        jr      Z, .write
        cp      c
        jr      Z, .write
        ld      a, 15
        cp      b
        jr      Z, .write
        cp      c
        jr      Z, .write

        jr      .incr
.write:
        ld      a, 1
        ld      [hl], a
.incr:
        inc     hl
        inc     b
.innerTest:
        ld      a, 16
        cp      b
        jr      Z, .outerTest
        jr      .inner
.outerTest:
        inc     c
        ld      a, 16
        cp      c
        jr      Z, .done
        jr      .outer
.done:
        ret


;;; ----------------------------------------------------------------------------

MapLoad:
        call    MapPutSampleData
        call    MapShow
        ret



;;; ----------------------------------------------------------------------------


;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;; Video Routines
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


GDMABlockCopy:
; hl - sprite start address
; de - destination
; b - length
        ld      a, h
        ldh     [rHDMA1], a             ; HDMA source high
        ld      a, l
        ldh     [rHDMA2], a             ; HDMA source low

        ld      a, d
        ldh     [rHDMA3], a             ; HDMA destination high
        ld      a, e
        ldh     [rHDMA4], a             ; HDMA destination low

        ld      a, b                    ; transfer length = 5 (64 bytes)
        ldh     [rHDMA5], a             ; start DMA transfer
        ret


;;; ----------------------------------------------------------------------------

ShowSpriteSquare16:
; l - oam start
; b - x
; c - y
; d - palette
; e - start tile
        push    de
        call    OamLoad
        pop     de

        ld      a, 2
.loop:
        ld      [hl], c                 ; set y
        inc     hl
        ld      [hl], b                 ; set x
        inc     hl
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e
        inc     e

        dec     a
        or      a
        jr      z, .done

        push    hl
        ld      hl, $0800
        add     hl, bc
        ld      b, h
        pop     hl

        jr      .loop
.done:
        ret



ShowSpriteTall16x32:
;;; l - oam start
;;; b - x
;;; c - y
;;; d - palette
;;; e - start tile
;;; trashes most registers
        inc     e
        inc     e
        ld      a, b
        ld      b, 0                    ; Center stuff
        sub     b
        ld      b, a

        ld      a, c
        ld      c, 8
        sub     c
        ld      c, a

        push    de                      ; de trashed by OamLoad
        call    OamLoad                 ; OAM pointer in hl
        pop     de                      ; restore e

        push    bc                      ; for when we jump down a row

.loop_outer:
        ld      a, 1                    ; inner loop counter

.loop_inner:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e                       ; double inc b/c 8x16 tiles
        inc     e

        or      a                       ; test whether a has reached zero
        jr      z, .loop_outer_cond
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner

.loop_outer_cond:
        pop     bc                      ; see push at fn top

        push    hl

        ld      hl, $0010               ; y += 16
        add     hl, bc
        ld      c, l                    ; load upper half into y
        pop     hl

.loop_outer2:

        inc     e
        inc     e
        inc     e
        inc     e

        ld      a, 1                    ; inner loop counter

.loop_inner2:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e                       ; double inc b/c 8x16 tiles
        inc     e

        or      a                       ; test whether a has reached zero
        jr      z, .done
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner2
.done
        ret





;;; Note: 32x32 Square sprite consumes eight hardware sprites, given 8x16
;;; sprites.

ShowSpriteSquare32:
; l - oam start
; b - x
; c - y
; d - palette
; e - start tile
; overwrites a, b, c, d, e, h, l  :(

;;; NOTE: This used to be a nested loop. Now, the outer loop is manually
;;; unrolled, not necessarily for performance, but because I ran out of
;;; registers.

        ld      a, b
        ld      b, 8                    ; Center stuff
        sub     b
        ld      b, a

        ld      a, c
        ld      c, 8
        sub     c
        ld      c, a

        push    de                      ; de trashed by OamLoad
        call    OamLoad                 ; OAM pointer in hl
        pop     de                      ; restore e

        push    bc                      ; for when we jump down a row

.loop_outer:
        ld      a, 3                    ; inner loop counter

.loop_inner:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e                       ; double inc b/c 8x16 tiles
        inc     e

        or      a                       ; test whether a has reached zero
        jr      z, .loop_outer_cond
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner

.loop_outer_cond:
        pop     bc                      ; see push at fn top

        push    hl

        ld      hl, $0010               ; y += 16
        add     hl, bc
        ld      c, l                    ; load upper half into y
        pop     hl

.loop_outer2:
        ld      a, 3                    ; inner loop counter

.loop_inner2:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e                       ; double inc b/c 8x16 tiles
        inc     e

        or      a                       ; test whether a has reached zero
        jr      z, .done
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner2
.done
        ret



ShowSpriteT:
; l - oam start
; b - x
; c - y
; d - palette
; e - start tile
; overwrites a, b, c, d, e, h, l  :(
        inc     e
        inc     e

        ;; ld      a, b
        ;; ld      b, 8                    ; Center stuff
        ;; sub     b
        ;; ld      b, a

        ld      a, c
        ld      c, 8
        sub     c
        ld      c, a

        push    de                      ; de trashed by OamLoad
        call    OamLoad                 ; OAM pointer in hl
        pop     de                      ; restore e

        push    bc                      ; for when we jump down a row

.loop_outer:
        ld      a, 1                    ; inner loop counter

.loop_inner:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e                       ; double inc b/c 8x16 tiles
        inc     e

        or      a                       ; test whether a has reached zero
        jr      z, .loop_outer_cond
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner

.loop_outer_cond:
        inc     e
        inc     e

        pop     bc                      ; see push at fn top

        push    hl

        ld      hl, $0010               ; y += 16
        ld      a, b
        ld      b, 8
        sub     b
        ld      b, a
        add     hl, bc
        ld      c, l                    ; load upper half into y
        pop     hl

.loop_outer2:
        ld      a, 3                    ; inner loop counter

.loop_inner2:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
        ld      [hl], d
        inc     hl
        inc     e                       ; double inc b/c 8x16 tiles
        inc     e

        or      a                       ; test whether a has reached zero
        jr      z, .done
        dec     a

        push    hl

        ld      hl, $0800
        add     hl, bc                  ; x += 8
        ld      b, h
        pop     hl
        jr      .loop_inner2
.done
        ret


;;; ----------------------------------------------------------------------------

OamLoad:
; l - oam number
; hl - return value
; de - trashed
        ld      h, $00
        add     hl, hl
        add     hl, hl
        ld      de, var_oam_back_buffer
        add     hl, de
        ret


;;; ----------------------------------------------------------------------------

OamSetPosition:
; l - oam number
; b - x
; c - y
        call    OamLoad
        ld      [hl], c
        inc     hl
        ld      [hl], b
        ret


;;; ----------------------------------------------------------------------------

OamSetTile:
; l - oam number
; a - tile
        call    OamLoad
        inc     hl
        inc     hl
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------

OamSetParams:
; l - oam number
; a - params
        call    OamLoad
        inc     hl
        inc     hl
        inc     hl
        ld      [hl],a
        ret


;;; ----------------------------------------------------------------------------

CopyDMARoutine:
        ld      hl, DMARoutine
        ld      b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
        ld      c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
        ld      a, [hli]
        ldh     [c], a
        inc     c
        dec     b
        jr      nz, .copy
        ret

DMARoutine:
        ldh     [rDMA], a

        ld      a, 40
.wait
        dec     a
        jr      nz, .wait
        ret
DMARoutineEnd:


;;; ----------------------------------------------------------------------------

LoadBackgroundColors:
;;; hl - source array
;;; b - count
        ld      a, %10000000
        ld      [rBCPS], a
.copy:
        ld      a, [hl+]
        ldh     [rBCPD], a
        dec     b
        jr      nz, .copy
        ret


;;; ----------------------------------------------------------------------------

LoadObjectColors:
;;; hl - source array
;;; b - count
        ld      a, %10000000
        ld      [rOCPS], a
.copy:
        ld      a, [hl+]
        ldh     [rOCPD], a
        dec     b
        jr      nz, .copy
        ret


;;; ----------------------------------------------------------------------------

LoadOverworldPalettes:
        ld      b, 24
        ld      hl, PlayerCharacterPalette
        call    LoadObjectColors

        ld      b, 24
        ld      hl, BackgroundPalette
        call    LoadBackgroundColors
        ret


;;; ----------------------------------------------------------------------------



SetBackgroundTile16x16:
;;; a - x index
;;; d - y index
;;; e - start tile
;;; c - palette
        ld      b, 2
.loop:
        push    bc

        push    de
        call    SetBackgroundTile
        pop     de

        inc     e
        inc     a

        push    de
        call    SetBackgroundTile
        pop     de

        inc     e
        ld      c, 1
        sub     c
        inc     d

        pop     bc

        dec     b
        push    af
        ld      a, b
        or      a
        pop     af
        jr      NZ, .loop

        ret


;;; Yeah I know, this code is not good.
SetBackgroundTile32x32:
;;; a - x index
;;; d - y index
;;; e - start tile
;;; c - palette
        ld      b, 4
.loop:
        push    bc

        push    de
        call    SetBackgroundTile
        pop     de

        inc     e
        inc     a

        push    de
        call    SetBackgroundTile
        pop     de

        inc     e
        inc     a

        push    de
        call    SetBackgroundTile
        pop     de

        inc     e
        inc     a

        push    de
        call    SetBackgroundTile
        pop     de

        inc     e
        ld      c, 3
        sub     c
        inc     d

        pop     bc

        dec     b
        push    af
        ld      a, b
        or      a
        pop     af
        jr      NZ, .loop

        ret


;;; ----------------------------------------------------------------------------


SetBackgroundTile:
;;; a - x index
;;; d - y index
;;; e - tile number
;;; c - palette
;;; FIXME: the map is vram 32 tiles wide, so we may be able to use sla
;;; instructions with the y value instead.
        push    bc
        push    af
        ld      hl, _SCRN0
        ld      b, 0
        ld      c, 32
.loop:
        ld      a, 0
        or      d
	jr      Z, .ready
        dec     d
        add     hl, bc
        jr      .loop

.ready:
        pop     af
        ld      c, a
        add     hl, bc
        ld      [hl], e

        pop     bc
        push    af
        ld	a, 1
	ld	[rVBK], a
        ld      [hl], c
        ld      a, 0
        ld      [rVBK], a
        pop     af

        ret


;;; ----------------------------------------------------------------------------


SetOverlayTile:
;;; NOTE: This writes to vram, careful!
;;; c - screen overlay x index
;;; a - tile number (overlay tiles start at $80)
;;; trashes b
        ld      hl, _SCRN1
        ld      b, 0
        add     hl, bc
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------


UpdateStaminaBar:
        ld      hl, var_player_stamina
        call    FixnumUpper
        ld      c, 1

.loopFull:
        ld      a, e
        ld      e, 16
        cp      e
        ld      e, a
        jr      C, .partial

        ld      a, e
        ld      e, 16
        sub     e
        ld      e, a
        ld      a, $82 + 8
        call    SetOverlayTile
        inc     c

        ld      a, 18
        cp      c
        jr      Z, .done
        jr      .loopFull

.partial:
        ld      a, $82
        SRL     e
        add     a, e
        call    SetOverlayTile

        inc     c
        ld      a, 18
        cp      c
        jr      Z, .done

.done:

        ret


TestOverlay:
        ld      c, 0
        ld      a, $81
        call    SetOverlayTile

        inc     c

        ld      a, $82
        call    SetOverlayTile

        inc     c

.loop1:
        ld      a, $82
        call    SetOverlayTile
        inc     c
        ld      a, 17
        cp      c
        jr      NZ, .loop1

	ld      a, $8B
        call    SetOverlayTile

        inc     c

.loop2:
        ld      a, $80
        call    SetOverlayTile
        inc     c
        ld      a, 20
        cp      c
        jr      NZ, .loop2

        ret


;;; ----------------------------------------------------------------------------


PlayerCharacterPalette::
DB $00,$00, $69,$72, $1a,$20, $03,$00
DB $00,$00, $ff,$ff, $f8,$37, $5f,$19
DB $00,$00, $54,$62, $f8,$37, $1a,$20


;;; Example of how to do the color conversion:
;;; See byte sequence $df,$24 above, the red color.
;;; We convert the actual color to hex, and then flip the order of the bytes.
;;; python> hex(((70 >> 3)) | ((141 >> 3) << 5) | ((199 >> 3) << 10))

BackgroundPalette::
DB $bf,$73, $1a,$20, $1a,$20, $00,$00
DB $bf,$73, $53,$5e, $4b,$3d, $86,$18
DB $bf,$73, $ec,$31, $54,$62, $26,$29


;;; SECTION START


;;; ----------------------------------------------------------------------------

;;; ############################################################################


        SECTION "OAM_DMA_ROUTINE", HRAM

hOAMDMA::
        ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to


;;; SECTION OAM_DMA_ROUTINE


;;; ############################################################################


SECTION "MISC_SPRITES", ROMX


OverlayTiles::
;;; Empty tile
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
;;;
DB $FF,$FF,$FF,$FF,$EF,$FE,$EF,$FE
DB $83,$FE,$EF,$FE,$EF,$FE,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$7F
DB $FF,$7F,$FF,$7F,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$3F
DB $FF,$3F,$FF,$3F,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$1F
DB $FF,$1F,$FF,$1F,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$0F
DB $FF,$0F,$FF,$0F,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$07
DB $FF,$07,$FF,$07,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$03
DB $FF,$03,$FF,$03,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$01
DB $FF,$01,$FF,$01,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F
DB $FF,$7F,$FF,$7F,$FF,$7F,$FF,$FF
;;; debug
OverlayTilesEnd::

BackgroundTiles::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$1E,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$03,$00,$07,$00
DB $07,$00,$00,$07,$1F,$07,$3F,$07
DB $0F,$00,$0F,$00,$DF,$00,$FF,$3F
DB $BF,$7F,$FF,$FF,$FF,$FF,$FF,$FF
DB $3F,$00,$EF,$70,$FF,$7F,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $00,$00,$70,$00,$F8,$80,$F8,$80
DB $DC,$E0,$EC,$F0,$FC,$FC,$FE,$F8
DB $3F,$07,$1F,$27,$3F,$3F,$3F,$3F
DB $7F,$07,$7F,$07,$3F,$47,$3F,$0F
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FE,$F0,$FE,$F0,$FE,$F0,$FE,$F0
DB $FC,$F2,$F0,$FC,$F8,$E0,$F8,$C0
DB $0F,$3F,$0F,$00,$0F,$00,$07,$08
DB $03,$04,$00,$03,$00,$00,$00,$00
DB $FF,$FF,$FF,$7F,$FF,$70,$FF,$20
DB $9F,$40,$0E,$91,$00,$0F,$00,$00
DB $FF,$FF,$FF,$FF,$FF,$70,$FF,$60
DB $FE,$61,$00,$9E,$00,$00,$00,$00
DB $F8,$80,$F0,$88,$E0,$98,$00,$60
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$80
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$03,$FF,$1F,$FF,$1F
DB $FF,$E0,$FF,$0C,$FF,$BE,$FF,$FF
DB $FF,$FF,$FF,$FF,$3F,$FF,$00,$FF
DB $FF,$1F,$FE,$1E,$FE,$7E,$FC,$FC
DB $F8,$FE,$D0,$FE,$80,$FE,$00,$FE
DB $00,$00,$01,$00,$0F,$00,$1F,$00
DB $7F,$00,$7F,$00,$FF,$00,$FF,$00
DB $1F,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$80
DB $FF,$01,$FF,$C3,$FF,$FF,$7F,$7F
DB $07,$3F,$03,$7F,$01,$7F,$00,$3F
DB $FF,$C0,$FF,$E0,$FF,$E1,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$1F,$FF
DB $FF,$80,$FF,$C0,$7F,$E0,$7F,$E0
DB $7F,$E0,$7F,$E0,$3F,$F0,$3F,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $3F,$FF,$1F,$7F,$0F,$7F,$07,$7F
DB $00,$3F,$00,$1F,$00,$07,$00,$03
DB $FF,$80,$FF,$E0,$FF,$F0,$FF,$FF
DB $3F,$FF,$3F,$FF,$07,$FF,$01,$FF
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$0F,$00,$0F,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$E0,$00,$F0,$00
DB $1F,$00,$1F,$00,$3F,$00,$3F,$00
DB $3F,$00,$7F,$00,$FF,$00,$FF,$00
DB $F8,$00,$FC,$00,$FC,$00,$FE,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $7F,$00,$7F,$00,$7F,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$7F,$00
DB $FF,$00,$FF,$00,$FF,$00,$FE,$00
DB $FE,$00,$FE,$00,$FE,$00,$FE,$00
DB $7F,$00,$7F,$00,$7F,$00,$7F,$00
DB $3F,$00,$7F,$00,$7F,$00,$FF,$00
DB $FE,$00,$FE,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FE,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$03,$00,$07,$00
DB $01,$00,$07,$00,$0F,$00,$1F,$00
DB $1F,$00,$3F,$00,$FF,$00,$FF,$00
DB $0F,$00,$0F,$00,$0F,$00,$07,$00
DB $3F,$00,$7F,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$7F,$00,$7F,$00
DB $3F,$00,$3F,$00,$7F,$00,$7F,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $7F,$00,$7F,$00,$7F,$00,$7F,$00
DB $3F,$00,$7F,$00,$7F,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $F8,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$00,$FC,$00,$FC,$00,$FE,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$71
DB $FF,$00,$FF,$01,$FF,$3F,$FF,$FF
DB $FE,$FF,$FC,$FF,$F8,$FF,$E0,$FF
DB $FF,$7F,$FE,$FE,$FC,$FE,$E0,$FC
DB $00,$FE,$00,$FE,$00,$FE,$00,$F8
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$01,$FF,$03,$FF,$03
DB $FF,$3F,$FE,$6F,$FE,$FF,$FC,$FF
DB $FF,$0E,$FF,$1F,$FF,$1F,$FF,$1F
DB $FF,$FF,$FE,$FF,$FC,$FF,$F8,$FF
DB $F8,$FF,$C0,$FF,$C0,$FE,$00,$FE
DB $00,$FC,$00,$F0,$00,$E0,$00,$C0
DB $FC,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $0F,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$0C,$FF,$1F,$FF,$FF
DB $FE,$FF,$F8,$FF,$E0,$FF,$00,$FF
DB $FF,$00,$FF,$3C,$FF,$7F,$FF,$FF
DB $FF,$FF,$3F,$FF,$00,$FF,$00,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$18
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$03
DB $FF,$3E,$FF,$FF,$FF,$FF,$F8,$FF
DB $F0,$FF,$00,$FF,$00,$FF,$00,$FF
DB $FF,$73,$FF,$FF,$7F,$FF,$3F,$FF
DB $1F,$FF,$00,$FF,$00,$FF,$00,$FF
DB $C0,$00,$E0,$00,$FB,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$00,$00,$00,$80,$00,$C0,$00
DB $C0,$00,$E0,$00,$F0,$00,$F0,$00
DB $F8,$00,$F8,$00,$F8,$00,$F8,$00
DB $FC,$00,$FE,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FE,$00,$FC,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FC,$00,$FE,$00,$FE,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FE,$00
DB $00,$00,$E0,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$00,$0F,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
BackgroundTilesEnd::


SpriteDropShadow::
DB $00,$00,$00,$00,$00,$00,$0F,$00
DB $3F,$00,$7F,$00,$7F,$00,$7F,$00
DB $7F,$00,$3F,$00,$0F,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$F0,$00
DB $FC,$00,$FE,$00,$FE,$00,$FE,$00
DB $FE,$00,$FC,$00,$F0,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
SpriteDropShadowEnd::


;;; NOTE: We're copying date from here with GDMA, so the eight byte alignment is
;;; important.
SECTION "IMAGE_DATA", ROMX, ALIGN[8], BANK[SPRITESHEET1_ROM_BANK]
;;; I'm putting this data in a separate rom bank, so that I can keep most of the
;;; code in bank 0.
SpriteSheetData::
SpritePlayerWalkCycleRight::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$01,$00,$01
DB $00,$03,$00,$03,$00,$03,$00,$07
DB $00,$07,$00,$07,$00,$07,$00,$03
DB $00,$07,$00,$0F,$00,$0F,$00,$1F
DB $00,$00,$00,$00,$00,$F0,$00,$F8
DB $00,$FC,$00,$FC,$04,$FC,$0C,$FC
DB $0E,$FA,$1E,$FE,$1C,$FC,$0C,$FC
DB $00,$FC,$00,$FC,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$3F,$00,$3F,$00,$7F
DB $00,$7F,$00,$FF,$00,$FF,$00,$7F
DB $00,$3F,$00,$1F,$00,$07,$00,$00
DB $00,$00,$01,$01,$01,$01,$00,$00
DB $00,$FC,$00,$FC,$00,$FC,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$F8,$E0,$E0
DB $C0,$C0,$80,$80,$80,$80,$C0,$C0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$01,$00,$01
DB $00,$03,$00,$03,$00,$03,$00,$07
DB $00,$07,$00,$07,$00,$07,$00,$03
DB $00,$07,$00,$0F,$00,$0F,$00,$1F
DB $00,$00,$00,$00,$00,$F0,$00,$F8
DB $00,$FC,$00,$FC,$04,$FC,$0C,$FC
DB $0E,$FA,$1E,$FE,$1C,$FC,$0C,$FC
DB $00,$FC,$00,$FC,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$1F,$00,$3F,$00,$3F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$3F,$00,$1F,$00,$07,$03,$03
DB $03,$03,$03,$03,$02,$02,$01,$01
DB $00,$FC,$00,$FC,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FC,$B8,$B8
DB $30,$30,$60,$60,$40,$40,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$01,$00,$01,$00,$03
DB $00,$03,$00,$03,$00,$03,$00,$07
DB $00,$07,$00,$07,$00,$07,$00,$07
DB $00,$0F,$00,$0F,$00,$0F,$00,$1F
DB $00,$00,$00,$F0,$00,$F8,$00,$FC
DB $00,$FC,$00,$FC,$0C,$FC,$0E,$FA
DB $1E,$FE,$1C,$FC,$0C,$FC,$00,$FC
DB $00,$FC,$00,$FC,$00,$FC,$00,$FE
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$1F,$00,$3F,$00,$3F,$00,$3F
DB $00,$3F,$00,$3F,$00,$3F,$00,$3F
DB $00,$1F,$08,$0F,$3C,$3C,$78,$78
DB $40,$40,$40,$40,$00,$00,$00,$00
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$06,$FE,$0E,$0E,$06,$06
DB $04,$04,$06,$06,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$01,$00,$01,$00,$03
DB $00,$03,$00,$03,$00,$07,$00,$07
DB $00,$07,$00,$07,$00,$03,$00,$07
DB $00,$0F,$00,$0F,$00,$1F,$00,$1F
DB $00,$00,$00,$F0,$00,$F8,$00,$FC
DB $00,$FC,$04,$FC,$0C,$FC,$0E,$FA
DB $1E,$FE,$1C,$FC,$0C,$FC,$00,$FC
DB $00,$FC,$00,$FC,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$01,$01,$01,$01,$01,$01
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$3F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$3F
DB $E0,$FF,$F8,$FF,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FC,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$06,$FE,$0E,$0E,$03,$03
DB $01,$01,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$20,$20
DB $C0,$C0,$80,$80,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$01,$00,$01
DB $00,$03,$00,$03,$00,$03,$00,$07
DB $00,$07,$00,$07,$00,$07,$00,$03
DB $00,$07,$00,$0F,$00,$0F,$00,$1F
DB $00,$00,$00,$00,$00,$F0,$00,$F8
DB $00,$FC,$00,$FC,$04,$FC,$0C,$FC
DB $0E,$FA,$1E,$FE,$1C,$FC,$0C,$FC
DB $00,$FC,$00,$FC,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$01,$00,$01,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$3F,$00,$7F,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$7F,$00,$3F,$00,$0F,$0F,$0F
DB $0C,$0C,$08,$08,$00,$00,$00,$00
DB $00,$FC,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$30,$30
DB $30,$30,$38,$38,$18,$18,$0C,$0C
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
SpritePlayerWalkCycleRightEnd::
SpritePlayerStillRight::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$07,$00,$07,$00,$0F
DB $00,$0F,$00,$0F,$00,$1F,$00,$1F
DB $00,$1F,$00,$1F,$00,$0F,$00,$1F
DB $00,$1F,$00,$1F,$00,$3F,$00,$3F
DB $00,$00,$00,$C0,$00,$E0,$00,$F0
DB $00,$F0,$10,$F0,$30,$F0,$38,$E8
DB $78,$F8,$70,$F0,$30,$F0,$00,$F0
DB $00,$F0,$00,$F8,$00,$F8,$00,$F8
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$3F,$00,$0F,$01,$01
DB $01,$01,$01,$01,$01,$01,$00,$00
DB $00,$F8,$00,$FC,$00,$FC,$00,$FC
DB $00,$FC,$00,$FC,$00,$FC,$00,$FC
DB $00,$FC,$00,$FC,$00,$F0,$80,$80
DB $80,$80,$80,$80,$80,$80,$C0,$C0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
SpritePlayerStillRightEnd::
SpritePlayerWalkCycleLeft::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$07,$00,$0F
DB $00,$1F,$00,$1F,$10,$1F,$18,$1F
DB $38,$2F,$3C,$3F,$1C,$1F,$18,$1F
DB $00,$1F,$00,$1F,$00,$1F,$00,$1F
DB $00,$00,$00,$00,$00,$C0,$00,$C0
DB $00,$E0,$00,$E0,$00,$E0,$00,$F0
DB $00,$F0,$00,$F0,$00,$F0,$00,$E0
DB $00,$F0,$00,$F8,$00,$F8,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$1F,$00,$1F,$00,$1F,$00,$3F
DB $00,$3F,$00,$3F,$00,$3F,$00,$3F
DB $00,$3F,$00,$3F,$00,$0F,$03,$03
DB $01,$01,$00,$00,$00,$00,$01,$01
DB $00,$FE,$00,$FE,$00,$FE,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FE,$00,$FC,$00,$F0,$80,$80
DB $80,$80,$C0,$C0,$C0,$C0,$80,$80
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$80,$00,$80,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$07,$00,$0F
DB $00,$1F,$00,$1F,$10,$1F,$18,$1F
DB $38,$2F,$3C,$3F,$1C,$1F,$18,$1F
DB $00,$1F,$00,$1F,$00,$1F,$00,$1F
DB $00,$00,$00,$00,$00,$C0,$00,$C0
DB $00,$E0,$00,$E0,$00,$E0,$00,$F0
DB $00,$F0,$00,$F0,$00,$F0,$00,$E0
DB $00,$F0,$00,$F8,$00,$F8,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$1F,$00,$1F,$00,$3F,$00,$3F
DB $00,$3F,$00,$3F,$00,$3F,$00,$3F
DB $00,$3F,$00,$3F,$00,$1F,$0E,$0E
DB $06,$06,$03,$03,$01,$01,$00,$00
DB $00,$FC,$00,$FE,$00,$FE,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FE,$00,$FC,$00,$F0,$E0,$E0
DB $60,$60,$60,$60,$20,$20,$40,$40
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$07,$00,$0F,$00,$1F
DB $00,$1F,$00,$1F,$18,$1F,$38,$2F
DB $3C,$3F,$1C,$1F,$18,$1F,$00,$1F
DB $00,$1F,$00,$1F,$00,$1F,$00,$3F
DB $00,$00,$00,$C0,$00,$C0,$00,$E0
DB $00,$E0,$00,$E0,$00,$E0,$00,$F0
DB $00,$F0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F8,$00,$F8,$00,$F8,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$3F,$00,$3F,$00,$3F
DB $00,$3F,$00,$3F,$00,$3F,$00,$3F
DB $00,$3F,$30,$3F,$38,$38,$30,$30
DB $10,$10,$30,$30,$00,$00,$00,$00
DB $00,$FC,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FC,$08,$F8,$1E,$1E,$0F,$0F
DB $01,$01,$01,$01,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$07,$00,$0F,$00,$1F
DB $00,$1F,$10,$1F,$18,$1F,$38,$2F
DB $3C,$3F,$1C,$1F,$18,$1F,$00,$1F
DB $00,$1F,$00,$1F,$00,$1F,$00,$1F
DB $00,$00,$00,$C0,$00,$C0,$00,$E0
DB $00,$E0,$00,$E0,$00,$F0,$00,$F0
DB $00,$F0,$00,$F0,$00,$E0,$00,$F0
DB $00,$F8,$00,$F8,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$02,$02
DB $01,$01,$00,$00,$00,$00,$00,$00
DB $00,$1F,$00,$3F,$00,$3F,$00,$3F
DB $00,$3F,$00,$3F,$00,$3F,$00,$3F
DB $00,$3F,$30,$3F,$38,$38,$60,$60
DB $C0,$C0,$80,$80,$00,$00,$00,$00
DB $00,$FE,$00,$FE,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FE
DB $03,$FF,$0F,$FF,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $80,$80,$C0,$C0,$40,$40,$40,$40
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$07,$00,$0F
DB $00,$1F,$00,$1F,$10,$1F,$18,$1F
DB $38,$2F,$3C,$3F,$1C,$1F,$18,$1F
DB $00,$1F,$00,$1F,$00,$1F,$00,$1F
DB $00,$00,$00,$00,$00,$C0,$00,$C0
DB $00,$E0,$00,$E0,$00,$E0,$00,$F0
DB $00,$F0,$00,$F0,$00,$F0,$00,$E0
DB $00,$F0,$00,$F8,$00,$F8,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$1F,$00,$3F,$00,$3F,$00,$3F
DB $00,$3F,$00,$3F,$00,$3F,$00,$3F
DB $00,$3F,$00,$3F,$00,$3F,$06,$06
DB $06,$06,$0E,$0E,$0C,$0C,$18,$18
DB $00,$FE,$00,$FE,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FE,$00,$F8,$78,$78
DB $18,$18,$08,$08,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$80
DB $00,$C0,$00,$C0,$00,$80,$00,$80
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
SpritePlayerWalkCycleLeftEnd::
SpritePlayerStillLeft::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$03,$00,$07,$00,$0F
DB $00,$0F,$08,$0F,$0C,$0F,$1C,$17
DB $1E,$1F,$0E,$0F,$0C,$0F,$00,$0F
DB $00,$0F,$00,$1F,$00,$1F,$00,$1F
DB $00,$00,$00,$E0,$00,$E0,$00,$F0
DB $00,$F0,$00,$F0,$00,$F8,$00,$F8
DB $00,$F8,$00,$F8,$00,$F0,$00,$F8
DB $00,$F8,$00,$F8,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$1F,$00,$3F,$00,$3F,$00,$3F
DB $00,$3F,$00,$3F,$00,$3F,$00,$3F
DB $00,$3F,$00,$3F,$00,$0F,$01,$01
DB $01,$01,$01,$01,$01,$01,$03,$03
DB $00,$FC,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FC,$00,$F0,$80,$80
DB $80,$80,$80,$80,$80,$80,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
SpritePlayerStillLeftEnd::
SpritePlayerWalkCycleDown::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$03,$00,$07
DB $00,$07,$00,$0F,$01,$0F,$03,$0F
DB $03,$0F,$03,$0D,$03,$0F,$03,$07
DB $00,$0F,$00,$1F,$00,$3F,$00,$3F
DB $00,$00,$00,$00,$00,$C0,$00,$E0
DB $00,$E0,$00,$F0,$80,$F0,$C0,$F0
DB $C0,$F8,$C0,$B8,$C0,$F8,$80,$F0
DB $80,$F8,$80,$F8,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$FF,$00,$FF,$00,$FF
DB $00,$7F,$01,$3F,$01,$0F,$03,$03
DB $03,$03,$03,$03,$01,$01,$03,$03
DB $00,$FE,$00,$FE,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$80,$FF
DB $80,$FE,$C0,$FC,$C0,$F0,$60,$60
DB $40,$40,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$80,$00,$80,$00,$80,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$03,$00,$07
DB $00,$07,$00,$0F,$01,$0F,$03,$0F
DB $03,$0F,$03,$0D,$03,$0F,$03,$07
DB $00,$0F,$00,$1F,$00,$3F,$00,$3F
DB $00,$00,$00,$00,$00,$C0,$00,$E0
DB $00,$E0,$00,$F0,$80,$F0,$C0,$F0
DB $C0,$F8,$C0,$B8,$C0,$F8,$80,$F0
DB $80,$F8,$80,$F8,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$3F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$FF,$00,$FF
DB $00,$7F,$00,$3F,$01,$0F,$03,$03
DB $03,$03,$01,$01,$01,$01,$00,$00
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FE,$80,$FC,$C0,$F0,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$01,$00,$07,$00,$07
DB $00,$07,$00,$0F,$03,$0F,$03,$0F
DB $03,$0D,$03,$0F,$03,$0F,$01,$0F
DB $00,$1F,$00,$3F,$00,$3F,$00,$3F
DB $00,$00,$00,$C0,$00,$E0,$00,$E0
DB $00,$F0,$80,$F0,$C0,$F0,$C0,$F0
DB $C0,$B8,$C0,$F8,$C0,$F8,$80,$F8
DB $80,$F8,$00,$FC,$00,$FC,$00,$FE
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$3F,$00,$0F,$01,$01,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FC,$00,$F0,$80,$80,$80,$80
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$01,$00,$07,$00,$07
DB $00,$0F,$00,$0F,$03,$0F,$03,$0F
DB $03,$0D,$03,$0F,$03,$07,$01,$0F
DB $00,$1F,$00,$3F,$00,$3F,$00,$3F
DB $00,$00,$00,$C0,$00,$E0,$00,$E0
DB $00,$F0,$80,$F0,$C0,$F0,$C0,$F8
DB $C0,$B8,$C0,$F8,$C0,$F0,$80,$F8
DB $80,$F8,$00,$FC,$00,$FC,$00,$FE
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$3F,$00,$0F,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FC,$80,$F0,$C0,$C0,$C0,$C0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$03,$00,$07,$00,$07
DB $00,$0F,$00,$0F,$03,$0F,$03,$0F
DB $03,$0D,$03,$0F,$03,$07,$01,$0F
DB $00,$1F,$00,$3F,$00,$3F,$00,$3F
DB $00,$00,$00,$C0,$00,$E0,$00,$E0
DB $00,$F0,$80,$F0,$C0,$F0,$C0,$F8
DB $C0,$B8,$C0,$F8,$C0,$F0,$80,$F8
DB $80,$F8,$00,$FC,$00,$FC,$00,$FE
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$FF,$00,$FF,$00,$7F
DB $00,$3F,$01,$0F,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$80,$FE
DB $80,$FC,$C0,$F0,$80,$80,$C0,$C0
DB $C0,$C0,$80,$80,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$03,$00,$07
DB $00,$07,$00,$0F,$01,$0F,$03,$0F
DB $03,$0F,$03,$0D,$03,$0F,$03,$07
DB $00,$0F,$00,$1F,$00,$3F,$00,$3F
DB $00,$00,$00,$00,$00,$C0,$00,$E0
DB $00,$E0,$00,$F0,$80,$F0,$C0,$F0
DB $C0,$F8,$C0,$B8,$C0,$F8,$80,$F0
DB $80,$F8,$80,$F8,$00,$FC,$00,$FE
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$7F,$00,$7F,$00,$7F
DB $00,$FF,$00,$FF,$00,$FF,$01,$FF
DB $01,$FF,$01,$3F,$03,$0F,$06,$06
DB $02,$02,$00,$00,$00,$00,$00,$00
DB $00,$FE,$00,$FE,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FE,$80,$FC,$80,$F0,$C0,$C0
DB $C0,$C0,$C0,$C0,$80,$80,$C0,$C0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$03,$00,$07
DB $00,$07,$00,$0F,$01,$0F,$03,$0F
DB $03,$0F,$03,$0D,$03,$0F,$03,$07
DB $00,$0F,$00,$1F,$00,$3F,$00,$3F
DB $00,$00,$00,$00,$00,$C0,$00,$E0
DB $00,$E0,$00,$F0,$80,$F0,$C0,$F0
DB $C0,$F8,$C0,$B8,$C0,$F8,$80,$F0
DB $80,$F8,$80,$F8,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$3F,$00,$7F,$00,$7F
DB $00,$7F,$00,$FF,$00,$FF,$00,$FF
DB $00,$7F,$01,$3F,$01,$0F,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FF,$00,$FF,$00,$FF,$00,$FE
DB $00,$FE,$00,$FC,$80,$F0,$C0,$C0
DB $C0,$C0,$80,$80,$80,$80,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$01,$00,$07,$00,$07
DB $00,$07,$00,$0F,$03,$0F,$03,$0F
DB $03,$0D,$03,$0F,$03,$0F,$01,$0F
DB $00,$1F,$00,$3F,$00,$3F,$00,$3F
DB $00,$00,$00,$C0,$00,$E0,$00,$E0
DB $00,$F0,$80,$F0,$C0,$F0,$C0,$F0
DB $C0,$B8,$C0,$F8,$C0,$F8,$80,$F8
DB $80,$F8,$00,$FC,$00,$FC,$00,$FE
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$3F,$00,$0F,$01,$01,$01,$01
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FC,$00,$F0,$80,$80,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$01,$00,$07,$00,$07
DB $00,$0F,$00,$0F,$03,$0F,$03,$0F
DB $03,$0D,$03,$0F,$03,$07,$01,$0F
DB $00,$1F,$00,$3F,$00,$3F,$00,$3F
DB $00,$00,$00,$C0,$00,$E0,$00,$E0
DB $00,$F0,$80,$F0,$C0,$F0,$C0,$F8
DB $C0,$B8,$C0,$F8,$C0,$F0,$80,$F8
DB $80,$F8,$00,$FC,$00,$FC,$00,$FE
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$3F,$01,$0F,$03,$03,$03,$03
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FC,$00,$F0,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$03,$00,$07,$00,$07
DB $00,$0F,$00,$0F,$03,$0F,$03,$0F
DB $03,$0D,$03,$0F,$03,$07,$01,$0F
DB $00,$1F,$00,$3F,$00,$3F,$00,$3F
DB $00,$00,$00,$C0,$00,$E0,$00,$E0
DB $00,$F0,$80,$F0,$C0,$F0,$C0,$F8
DB $C0,$B8,$C0,$F8,$C0,$F0,$80,$F8
DB $80,$F8,$00,$FC,$00,$FC,$00,$FE
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$FF,$00,$FF,$01,$7F
DB $01,$3F,$03,$0F,$01,$01,$03,$03
DB $03,$03,$01,$01,$00,$00,$00,$00
DB $00,$FE,$00,$FE,$00,$FE,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FE
DB $00,$FC,$80,$F0,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
SpritePlayerWalkCycleDownEnd::
SpritePlayerStillDown::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$03,$00,$07,$00,$07
DB $00,$0F,$01,$0F,$03,$0F,$03,$0F
DB $03,$0D,$03,$0F,$03,$07,$00,$0F
DB $00,$1F,$00,$1F,$00,$3F,$00,$3F
DB $00,$00,$00,$C0,$00,$E0,$00,$E0
DB $00,$F0,$80,$F0,$C0,$F0,$C0,$F8
DB $C0,$B8,$C0,$F8,$80,$F0,$80,$F8
DB $80,$F8,$00,$FC,$00,$FC,$00,$FE
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$3F,$00,$3F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$3F,$00,$0F,$06,$06
DB $06,$06,$06,$06,$06,$06,$04,$04
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FC,$00,$F0,$60,$60
DB $60,$60,$60,$60,$60,$60,$20,$20
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
SpritePlayerStillDownEnd::
SpritePlayerWalkCycleUp::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$03,$00,$07
DB $00,$07,$00,$0F,$00,$0F,$00,$0F
DB $00,$1F,$00,$1F,$00,$1F,$00,$0F
DB $00,$1F,$00,$1F,$00,$3F,$00,$3F
DB $00,$00,$00,$00,$00,$C0,$00,$E0
DB $00,$E0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F0,$00,$F0,$00,$F0,$00,$E0
DB $00,$F0,$00,$F8,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$01,$00,$01,$00,$01,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$7F,$00,$7F,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$7F,$00,$3F,$00,$0F,$06,$06
DB $02,$02,$00,$00,$00,$00,$00,$00
DB $00,$FC,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FF,$00,$FF,$00,$FF
DB $00,$FE,$00,$FC,$00,$F0,$C0,$C0
DB $C0,$C0,$C0,$C0,$80,$80,$40,$40
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$03,$00,$07
DB $00,$07,$00,$0F,$00,$0F,$00,$0F
DB $00,$1F,$00,$1F,$00,$1F,$00,$0F
DB $00,$1F,$00,$1F,$00,$3F,$00,$3F
DB $00,$00,$00,$00,$00,$C0,$00,$E0
DB $00,$E0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F0,$00,$F0,$00,$F0,$00,$E0
DB $00,$F0,$00,$F8,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$7F,$00,$3F,$00,$0F,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FC,$00,$FC,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FF,$00,$FF
DB $00,$FE,$00,$FC,$00,$F0,$C0,$C0
DB $C0,$C0,$80,$80,$80,$80,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$03,$00,$07,$00,$07
DB $00,$0F,$00,$0F,$00,$0F,$00,$0F
DB $00,$1F,$00,$1F,$00,$1F,$00,$1F
DB $00,$1F,$00,$3F,$00,$3F,$00,$7F
DB $00,$00,$00,$80,$00,$E0,$00,$E0
DB $00,$E0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F8,$00,$FC,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$3F,$00,$0F,$01,$01,$01,$01
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FC,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FC,$00,$F0,$80,$80,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$03,$00,$07,$00,$07
DB $00,$0F,$00,$0F,$00,$0F,$00,$1F
DB $00,$1F,$00,$1F,$00,$0F,$00,$1F
DB $00,$1F,$00,$3F,$00,$3F,$00,$7F
DB $00,$00,$00,$80,$00,$E0,$00,$E0
DB $00,$F0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F0,$00,$F0,$00,$E0,$00,$F0
DB $00,$F8,$00,$FC,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$3F,$00,$0F,$03,$03,$03,$03
DB $01,$01,$00,$00,$00,$00,$00,$00
DB $00,$FC,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FC,$00,$F0,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$03,$00,$07,$00,$07
DB $00,$0F,$00,$0F,$00,$0F,$00,$1F
DB $00,$1F,$00,$1F,$00,$0F,$00,$1F
DB $00,$1F,$00,$3F,$00,$3F,$00,$7F
DB $00,$00,$00,$C0,$00,$E0,$00,$E0
DB $00,$F0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F0,$00,$F0,$00,$E0,$00,$F0
DB $00,$F8,$00,$FC,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$3F,$00,$0F,$01,$01,$03,$03
DB $03,$03,$01,$01,$00,$00,$00,$00
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FF,$00,$FF,$00,$FE
DB $00,$FC,$00,$F0,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$03,$00,$07
DB $00,$07,$00,$0F,$00,$0F,$00,$0F
DB $00,$1F,$00,$1F,$00,$1F,$00,$0F
DB $00,$1F,$00,$1F,$00,$3F,$00,$7F
DB $00,$00,$00,$00,$00,$C0,$00,$E0
DB $00,$E0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F0,$00,$F0,$00,$F0,$00,$E0
DB $00,$F0,$00,$F8,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$7F,$00,$7F,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$7F,$00,$3F,$00,$0F,$03,$03
DB $03,$03,$03,$03,$01,$01,$02,$02
DB $00,$FC,$00,$FE,$00,$FE,$00,$FE
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FC,$00,$F0,$60,$60
DB $40,$40,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$03,$00,$07
DB $00,$07,$00,$0F,$00,$0F,$00,$0F
DB $00,$1F,$00,$1F,$00,$1F,$00,$0F
DB $00,$1F,$00,$1F,$00,$3F,$00,$3F
DB $00,$00,$00,$00,$00,$C0,$00,$E0
DB $00,$E0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F0,$00,$F0,$00,$F0,$00,$E0
DB $00,$F0,$00,$F8,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$FF,$00,$FF,$00,$FF,$00,$7F
DB $00,$7F,$00,$3F,$00,$0F,$03,$03
DB $03,$03,$01,$01,$01,$01,$00,$00
DB $00,$FC,$00,$FC,$00,$FE,$00,$FE
DB $00,$FE,$00,$FF,$00,$FF,$00,$FF
DB $00,$FE,$00,$FC,$00,$F0,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$03,$00,$07,$00,$07
DB $00,$0F,$00,$0F,$00,$0F,$00,$0F
DB $00,$1F,$00,$1F,$00,$1F,$00,$1F
DB $00,$1F,$00,$3F,$00,$3F,$00,$7F
DB $00,$00,$00,$80,$00,$E0,$00,$E0
DB $00,$E0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F8,$00,$FC,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$3F,$00,$0F,$01,$01,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FC,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FC,$00,$F0,$80,$80,$80,$80
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$03,$00,$07,$00,$07
DB $00,$0F,$00,$0F,$00,$0F,$00,$1F
DB $00,$1F,$00,$1F,$00,$0F,$00,$1F
DB $00,$1F,$00,$3F,$00,$3F,$00,$7F
DB $00,$00,$00,$80,$00,$E0,$00,$E0
DB $00,$F0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F0,$00,$F0,$00,$E0,$00,$F0
DB $00,$F8,$00,$FC,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$3F,$00,$0F,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FC,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FC,$00,$F0,$C0,$C0,$C0,$C0
DB $80,$80,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$03,$00,$07,$00,$07
DB $00,$0F,$00,$0F,$00,$0F,$00,$1F
DB $00,$1F,$00,$1F,$00,$0F,$00,$1F
DB $00,$1F,$00,$3F,$00,$3F,$00,$7F
DB $00,$00,$00,$C0,$00,$E0,$00,$E0
DB $00,$F0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F0,$00,$F0,$00,$E0,$00,$F0
DB $00,$F8,$00,$FC,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$7F,$00,$7F,$00,$7F,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$7F
DB $00,$3F,$00,$0F,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FC,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FF,$00,$FF,$00,$FE
DB $00,$FC,$00,$F0,$80,$80,$C0,$C0
DB $C0,$C0,$80,$80,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
SpritePlayerWalkCycleUpEnd::
SpritePlayerStillUp::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$03,$00,$07,$00,$07
DB $00,$0F,$00,$0F,$00,$0F,$00,$1F
DB $00,$1F,$00,$1F,$00,$0F,$00,$1F
DB $00,$1F,$00,$3F,$00,$3F,$00,$7F
DB $00,$00,$00,$C0,$00,$E0,$00,$E0
DB $00,$F0,$00,$F0,$00,$F0,$00,$F0
DB $00,$F0,$00,$F0,$00,$E0,$00,$F0
DB $00,$F8,$00,$F8,$00,$FC,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$7F,$00,$7F,$00,$7F
DB $00,$7F,$00,$3F,$00,$0F,$06,$06
DB $06,$06,$06,$06,$06,$06,$04,$04
DB $00,$FC,$00,$FC,$00,$FE,$00,$FE
DB $00,$FE,$00,$FE,$00,$FE,$00,$FE
DB $00,$FE,$00,$FC,$00,$F0,$60,$60
DB $60,$60,$60,$60,$60,$60,$20,$20
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
SpritePlayerStillUpEnd::
SpriteBonfire::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$01,$01,$03,$03
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $03,$03,$07,$07,$07,$07,$0F,$0F
DB $0F,$0F,$0F,$0F,$0F,$0F,$07,$07
DB $3F,$3F,$7F,$7F,$7F,$7F,$61,$7F
DB $40,$7F,$40,$7F,$0C,$33,$0E,$11
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $B8,$B8,$FC,$FC,$FE,$FE,$FE,$FE
DB $83,$FF,$83,$FF,$83,$FF,$C1,$FF
DB $81,$FF,$00,$FE,$0C,$F0,$00,$F0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $02,$02,$03,$03,$03,$03,$07,$07
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $06,$06,$06,$06,$04,$04,$06,$06
DB $07,$07,$07,$07,$0F,$0F,$1F,$1F
DB $3F,$3F,$3F,$3F,$31,$3F,$71,$7F
DB $70,$7F,$60,$7F,$04,$3B,$0C,$13
DB $00,$00,$08,$08,$3C,$3C,$7E,$7E
DB $FE,$FE,$FF,$FF,$E7,$FF,$87,$FF
DB $87,$FF,$CE,$FE,$EE,$FE,$E3,$FF
DB $C1,$FF,$88,$F6,$0C,$F0,$00,$F0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $02,$02,$06,$06,$06,$06,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $06,$06,$0F,$0F,$1F,$1F,$1F,$1F
DB $33,$3F,$31,$3F,$79,$7F,$7B,$7F
DB $31,$3F,$20,$3F,$00,$3F,$04,$1B
DB $1C,$1C,$1E,$1E,$3E,$3E,$7F,$7F
DB $7F,$7F,$E6,$FE,$E6,$FE,$EC,$FC
DB $FC,$FC,$FE,$FE,$FE,$FE,$E6,$FE
DB $C3,$FF,$00,$FE,$00,$FC,$10,$E0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$04,$04
DB $04,$04,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$18,$18,$1C,$1C
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $0E,$0E,$0F,$0F,$1F,$1F,$1B,$1F
DB $71,$7F,$79,$7F,$7D,$7F,$3F,$3F
DB $3B,$3F,$22,$3F,$20,$3F,$00,$1F
DB $1C,$1C,$3C,$3C,$3C,$3C,$28,$38
DB $68,$78,$78,$78,$F8,$F8,$F8,$F8
DB $FC,$FC,$FC,$FC,$FE,$FE,$C3,$FF
DB $81,$FF,$01,$FF,$00,$FC,$00,$F0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$18,$18,$1C,$1C,$18,$18
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$02,$02,$06,$06
DB $0F,$0F,$0D,$0F,$19,$1F,$39,$3F
DB $3F,$3F,$1F,$1F,$3F,$3F,$3F,$3F
DB $3B,$3F,$62,$7F,$20,$3F,$00,$1F
DB $10,$10,$00,$00,$00,$00,$10,$10
DB $30,$30,$F8,$F8,$F8,$F8,$FE,$FE
DB $FE,$FE,$FF,$FF,$F7,$FF,$C1,$FF
DB $81,$FF,$01,$FF,$00,$FC,$00,$F0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$10,$10
DB $18,$18,$18,$18,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$02,$02,$07,$07,$07,$07
DB $0F,$0F,$1D,$1F,$1D,$1F,$1F,$1F
DB $0F,$0F,$3F,$3F,$7F,$7F,$7F,$7F
DB $61,$7F,$40,$7F,$00,$3F,$0C,$13
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $80,$80,$E0,$E0,$F0,$F0,$FE,$FE
DB $FF,$FF,$FF,$FF,$F7,$FF,$C1,$FF
DB $81,$FF,$00,$FE,$00,$FC,$00,$F0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
SpriteBonfireEnd::

;;; ############################################################################
