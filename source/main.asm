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
;;;     char state_flag_;
;;; };
;;;


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

        SECTION "OAM_BACK_BUFFER", WRAM0, ALIGN[8]

var_oam_back_buffer:
        ds OAM_SIZE * OAM_COUNT


;;; SECTION OAM_BACK_BUFFER


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

var_player_update_fn:   DS   2  ; Engine will call this fn to update player
var_player_struct_end:


;;; ############################################################################

        SECTION "ENTITY_BUFFER", WRAM0, ALIGN[8]

ENTITY_BUFFER_CAPACITY EQU 8
ENTITY_POINTER_SIZE EQU 2

var_entity_buffer_size: DS      1
var_entity_buffer:      DS      ENTITY_POINTER_SIZE * ENTITY_BUFFER_CAPACITY


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
        call    SetCpuFast
        call    VBlankPoll              ; Wait for vbl before disabling lcd.

	xor	a                       ; A now holds zero.
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

        ldh     [var_vbl_flag], a
        ldh     [var_sleep_counter], a
        ldh     [var_joypad_current], a
        ldh     [var_joypad_previous], a
        ldh     [var_joypad_raw], a
        ldh     [var_joypad_released], a

        ld      [var_entity_buffer_size], a

        ld      [var_view_x], a
        ld      [var_view_y], a

        ld      [var_player_kf], a
        ld      [var_player_tmr], a
        ld      [var_player_texture], a

        ld      hl, var_oam_back_buffer ; zero out the oam back buffer
        ld      bc, OAM_SIZE * OAM_COUNT
        call    Memset                  ; Note param a already holds 0 (above)

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

        jr      Main


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


Main:
        ld	a, IEF_VBLANK	        ; vblank interrupt
	ld	[rIE], a	        ; setup

        call    CopyDMARoutine

        call    PlayerInit

        ld      b, 8
        ld      hl, PlayerCharacterPalette
        call    LoadObjectColors

        ld      hl, OverlayTiles
        ld      bc, OverlayTilesEnd - OverlayTiles
        ld      de, $8800
        call    Memcpy

        ld      hl, SpriteDropShadow
        ld      bc, SpriteDropShadowEnd - SpriteDropShadow
        ld      de, $8500
        call    Memcpy

        call    TestOverlay

        ld      b, 8
        ld      hl, BackgroundPalette
        call    LoadBackgroundColors

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

        ld      a, [de]         ; Fetch entity pointer from entity buffer
        ld      h, a
        inc     de
        ld      a, [de]
        ld      l, a            ; Now we have the entity pointer in hl

        ld      a, [hl]         ; load texture swap flag from entity
        or      a
        jr      Z, .noTextureCopy ; swap flag false, nothing to do
        ld      a, 0
        ld      [hl], a         ; We're swapping the texture, zero the flag

        push    de              ; store entity buffer pointer on stack

        ld      d, 0
        ld      e, 1 + FIXNUM_SIZE * 2 + 1
	add     hl, de          ; jump to offset of keyframe in entity

        ld      a, [hl]
        inc     hl              ; frame base in next byte
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

        ld      b, 16
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
        ld      [hl], a
        inc     hl              ; now points to keyframe
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


EntityBufferEnqueue:
;;; de - entity ptr
;;; trashes bc
        ld      a, [var_entity_buffer_size]
        cp      ENTITY_BUFFER_CAPACITY
        jr      Z, .failed

        inc     a
        ld      [var_entity_buffer_size], a
        dec     a

        ld      c, 0
        add     a, a

	ld      b, a

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
        ld      e, 11
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


PlayerInit:
        ld      hl, var_player_struct
        ld      de, UpdatePlayer
        call    EntitySetUpdateFn

        ld      de, var_player_struct
        call    EntityBufferEnqueue
        ret



;;; ----------------------------------------------------------------------------

AnimatePlayer:
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
        jr      NZ, .frameChanged
        jr      .done

.animateWalkUD:
        ld      hl, var_player_animation
        ld      c, 6
        ld      d, 10

        call    AnimationAdvance
        or      a
        jr      NZ, .frameChanged
.done:
        ret

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



UpdatePlayerMovement:
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


UpdatePlayer:
        call UpdatePlayerMovement

        ldh     a, [var_joypad_released]
        and     PADF_DOWN
        jr      Z, .checkUpReleased

        ldh     a, [var_joypad_raw]
        and     PADF_LEFT | PADF_RIGHT | PADF_UP
        jr      NZ, .checkUpReleased

        ld      a, SPRID_PLAYER_SD
        ld      [var_player_fb], a
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
        ld      a, 0
        ld      [var_player_kf], a
        ld      a, 1
        ld      [var_player_swap_spr], a

.animate:
        ld      a, [var_joypad_raw]
        or      a
        jr      Z, .done
	call    AnimatePlayer
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
        ld      l, a            ; entity pinter now in hl

	push    de              ; save entity buffer pointer on stack

        ld      e, 11
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

;;; intentional fallthrough
EntityDrawLoop:
        ld      hl, var_player_coord_x
        call    FixnumUpper

        ld      a, [var_view_x]
        ld      l, a
        ld      a, e
        sub     l
        ld      b, a


        ld      hl, var_player_coord_y
        call    FixnumUpper

        ld      a, [var_view_y]
        ld      l, a
        ld      a, e
        sub     l
        ld      c, a

        ld      l, 0                    ; Oam offset
        ld      e, 0                    ; Start tile
        push    bc
        call    ShowSpriteSquare32
        pop     bc

;;; Drop shadow
        ld      a, c
        add     17
        ld      c, a
        ld      l, 8
        ld      e, $50
        call    ShowSpriteSquare16
.skip:

        ret


;;; ----------------------------------------------------------------------------


IsOnscreen:
;;; b - x
;;; c - y
;;; a - result
;;; trashes l
        ld      a, [var_view_x]
        ld      l, a
        ld      a, b                    ; TODO: make arg a instead of b?
        cp      l
        jr      C, .false

        ld      a, SCRN_X
        add     l
        ld      a, l
        cp      b
        jr      C, .false

        ld      a, [var_view_y]
        ld      l, a
        ld      a, c
        cp      l
        jr      C, .false

        ld      a, SCRN_Y
        add     l
        ld      a, l
        cp      c
        jr      C, .false

        ld      a, 1
        ret
.false:
	ld      a, 0
        ret


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
;;; TODO: explicitly set the rom bank?
        jp      $0100


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
        ld      [hl], a
        inc     hl
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
        ld      [hl], a
        inc     hl
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


;;; Note: 32x32 Square sprite consumes eight hardware sprites, given 8x16
;;; sprites.

ShowSpriteSquare32:
; l - oam start
; b - x
; c - y
; e - start tile
; overwrites a, b, c, d, e, h, l  :(

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

        ld      d, 1                    ; outer loop counter

.loop_outer:
        ld      a, 3                    ; inner loop counter

.loop_inner:

        ld      [hl], c                 ; set y
        inc     hl                      ; go to next byte
        ld      [hl], b                 ; set x
        inc     hl                      ; skip the next three bytes in oam
        ld      [hl], e
        inc     hl
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
        or      d                       ; outer loop counter is zero here
        jr      z, .done
        dec     d

        pop     bc                      ; see push at fn top

        push    hl

        ld      hl, $0010               ; y += 16
        add     hl, bc
        ld      c, l                    ; load upper half into y
        pop     hl
        jr      .loop_outer
.done:
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

TestTilemap:
        ld      hl, _SCRN0

        ld      c, 0

.outer:
        ld      b, 0
.inner:
        ld      a, 0
        cp      b
        jr      Z, .write
        cp      c
        jr      Z, .write
        ld      a, 31
        cp      b
        jr      Z, .write
        cp      c
        jr      Z, .write

        jr      .incr
.write:
        ld      a, 4
        ld      [hl], a
.incr:
        inc     hl
        inc     b
.innerTest:
        ld      a, 32
        cp      b
        jr      Z, .outerTest
        jr      .inner
.outerTest:
        inc     c
        ld      a, 32
        cp      c
        jr      Z, .done
        jr      .outer
.done:
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


TestOverlay:
        ld      c, 0
        ld      a, $81
        call    SetOverlayTile

        inc     c
.loop:
        ld      a, $80
        call    SetOverlayTile
        inc     c
        ld      a, 20
        cp      c
        jr      NZ, .loop
        ret


;;; ----------------------------------------------------------------------------


PlayerCharacterPalette::
DB $00,$00, $69,$72, $1a,$20, $03,$00

;;; Example of how to do the color conversion:
;;; See byte sequence $df,$24 above, the red color.
;;; We convert the actual color to hex, and then flip the order of the bytes.
;;; python> hex(((70 >> 3)) | ((141 >> 3) << 5) | ((199 >> 3) << 10))

BackgroundPalette::
DB $bf,$73, $bf,$73, $1a,$20, $00,$00


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
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$93,$FF,$83,$FF
DB $83,$FF,$C7,$FF,$EF,$FF,$FF,$FF
OverlayTilesEnd::


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

;;; ############################################################################
