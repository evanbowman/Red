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


SPRITE_SHAPE_SQUARE_32 EQU $f0
SPRITE_SHAPE_T EQU $e0
SPRITE_SHAPE_SQUARE_16 EQU $d0
SPRITE_SHAPE_INVISIBLE EQU $c0
SPRITE_SHAPE_TALL_16_32 EQU $00



        INCLUDE "hardware.inc"
        INCLUDE "defs.inc"
        INCLUDE "sprid.inc"
        INCLUDE "entityType.inc"
        INCLUDE "item.inc"
        INCLUDE "room.inc"
        INCLUDE "message.inc"
        INCLUDE "combat.inc"
        INCLUDE "charmap.inc"


fcall: MACRO                    ; fast call, as opposed to a long call
        ;; We can only call a function in the same bank, unless our code is in
        ;; bank zero.
        ASSERT (BANK(\1) == BANK(@) || BANK(\1) == BANK(EntryPoint))
        call   \1
ENDM


fcallc: MACRO
        ASSERT (BANK(\2) == BANK(@) || BANK(\2) == BANK(EntryPoint))
        call   \1, \2
ENDM


;;; NOTE: LONG_CALL allows you to call from bank0 into a romx bank. Does not allow
;;; a romx function to call another romx function.
;;; NOTE: trashes hl and a prior to invocation.
LONG_CALL: MACRO
        ASSERT (BANK(\1) != BANK(@)) ; pointless long call to current bank
        ASSERT (BANK(@) == BANK(EntryPoint)) ; Only works from bank0
        ld      a, BANK(\1)
        ld      hl, \1
        rst     $08
ENDM


;;; Allows you to call code anywhere in ROM. Fairly large overhead, though. If
;;; you are in bank0 already, there's no reason to use this macro instead of
;;; LONG_CALL.
;;; NOTE: trashes hl, a, d both prior to invocation, and after invocation.
WIDE_CALL: MACRO
        ASSERT (BANK(\1) != BANK(@)) ; pointless call to current bank

        ;; Wasteful to call from bank0... Or is it? I suppose I could see some
        ;; usefullness in being able to call ROMX functions without messing with
        ;; the currently-assigned ROM bank. But I think it's ultimately best to
        ;; discourage doing this, hence the assertion.
        ASSERT (BANK(@) != BANK(EntryPoint))
	ASSERT (BANK(__Widecall) == BANK(EntryPoint))

        ld      d, BANK(@)
        ld      a, BANK(\1)
        ld      hl, \1
        call    __Widecall
ENDM


INVOKE_HL: MACRO
        rst     $10
ENDM


SET_BANK_FROM_A: MACRO
        ;; Makes no sense for a ROMX bank to manually switch to another bank.
	ASSERT (BANK(@) == BANK(EntryPoint))

        ldh     [hvar_bank], a
        ld      [rROMB0], a
ENDM


SET_BANK: MACRO
        ;; Makes no sense for a ROMX bank to manually switch to another bank.
        ASSERT (BANK(@) == BANK(EntryPoint))

        ld      a, \1
        SET_BANK_FROM_A

ENDM


RAM_BANK: MACRO
        ld      a, \1
        ld      [rSVBK], a
ENDM


VIDEO_BANK: MACRO
        ld      a, \1
        ld      [rVBK], a
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
        INCLUDE "sram.asm"


;; #############################################################################

        SECTION "RESTART_VECTOR_08",ROM0[$0008]
__LongcallImpl:
        SET_BANK_FROM_A
        jp      hl


;; #############################################################################

        SECTION "RESTART_VECTOR_10",ROM0[$0010]
__InvokeHLImpl:
        jp      hl


;; #############################################################################

        SECTION "RESTART_VECTOR_18",ROM0[$0018]
        ret


;; #############################################################################

        SECTION "RESTART_VECTOR_20",ROM0[$0020]
        ret


;; #############################################################################

        SECTION "RESTART_VECTOR_28",ROM0[$0028]
        ret


;; #############################################################################

        SECTION "RESTART_VECTOR_30",ROM0[$0030]
        ret


;;; ############################################################################

        SECTION "RESTART_VECTOR_38",ROM0[$0038]
__RST_FATAL_JUMP:
        LONG_CALL r1_fatalError


;; #############################################################################

        SECTION "VBLANK", ROM0[$0040]
        jp      VBlankISR


;;; SECTION VBL


;;; ############################################################################

        SECTION "TIMER", ROM0[$0050]
	jp      TimerISR


;;; SECTION TIMER


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
        fcall   LcdOff
        fcall   LoadFont
	LONG_CALL r1_GameboyColorNotDetected

;;; TODO: Display some text to indicate that the game requires a gbc. There's no
;;; need to waste space in bank zero for this stuff, though.


.gbcDetected:
        ld      a, 0
        ldh     [hvar_agb_detected], a
        ld      a, b
        cp      a, BOOTUP_B_AGB
        jr      NZ, .configure

.agbDetected:
        LONG_CALL r1_GameboyAdvanceDetected


.configure:
        LONG_CALL r1_SetCpuFast
        LONG_CALL r1_VBlankPoll            ; Wait for vbl before disabling lcd.

        fcall   LcdOff

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

        LONG_CALL r1_InitRam

        jr      Main


;;; ----------------------------------------------------------------------------


Main:
        ld	a, IEF_VBLANK	        ; vblank interrupt
	ld	[rIE], a	        ; setup

        ld      a, 128
        ld      [var_overlay_y_offset], a

        LONG_CALL r1_SetCgbColorProfile

        LONG_CALL r1_CopyDMARoutine

        ld      a, HIGH(var_oam_back_buffer) ; \ Zero OAM, in case we came from
        fcall   hOAMDMA                      ; / a system reboot.

        fcall   LoadFont

        fcall   LcdOn

        ei

	fcall   InitRandom              ; TODO: call this later on

        ld      de, IntroCutsceneSceneEnter
        fcall   SceneSetUpdateFn

        ld      de, VoidVBlankFn
        fcall   SceneSetVBlankFn


        fcall   CreateWorld

        ld      a, $ff
        ld      [hvar_shadow_state], a

.loop:
        fcall   GetRandom

        LONG_CALL r1_ReadKeys
        ld      a, b
        ldh     [hvar_joypad_raw], a


        ldh     a, [hvar_joypad_raw]              ; \ Soft reset for A + start +
        and     PADF_SELECT | PADF_START | PADF_A ; | select.
        cp      PADF_SELECT | PADF_START | PADF_A ; |
        fcallc  Z, SystemReboot                   ; /

        ld      de, var_scene_update_fn ; \
        ld      a, [de]                 ; |
        inc     de                      ; |
        ld      h, a                    ; | Fetch scene update fn
        ld      a, [de]                 ; |
        ld      l, a                    ; /
        INVOKE_HL                       ; Jump to scene update code

.sched_sleep:
        ld      a, [hvar_sleep_counter]
        or      a
        jr      Z, .vsync
        ld      e, a
        fcall   ForceSleepOverworld
        ld      a, 0
        ld      [hvar_sleep_counter], a

.vsync:
        fcall   VBlankIntrWait          ; vsync

        ld      a, [var_view_x]
        ld      [rSCX], a

        ld      a, [var_view_y]
        ld      [rSCY], a

        ld      a, HIGH(var_oam_back_buffer)
        fcall   hOAMDMA


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
        ld      a, [rLY]        ; \ NOTE: if current line is less than the
        cp      SCRN_Y          ; / start of the vblank, we exceeded the vblank.
        jr      C, .vbl_window_exceeded

        jr      Main.loop


;;; This is just some debugging code. I'm trying to figure out how much stuff
;;; that I can copy within the vblank window.
.vbl_window_exceeded:
        stop





;;; ----------------------------------------------------------------------------


CreateWorld:

        fcall   VBlankIntrWait

        ld      a, 1
        ld      [var_level], a

        ld      a, 3
        ld      [var_lives], a

	LONG_CALL r1_SetLevelupExp

        fcall   LoadDefaultMap

        fcall   MapLoad2__rom0_only

        fcall   MapShow

        LONG_CALL r1_PlayerNew

        LONG_CALL r1_LoadRoomEntities

	LONG_CALL r1_SetRoomVisited


        ld      a, ITEM_DAGGER
        ld      [var_equipped_item], a
        ld      b, a
        fcall   InventoryAddItem

        ret


;;; ----------------------------------------------------------------------------

LoadDefaultMap:
;;; Sets ROM Bank to ten
;;; Sets RAM bank to two
        SET_BANK 10
        RAM_BANK 1
        ld      hl, r10_DefaultMap1
        ld      bc, wram1_var_world_map_info_end - wram1_var_world_map_info
        ld      de, wram1_var_world_map_info
        fcall   Memcpy

        RAM_BANK 2
        ld      hl, r10_DefaultCollectibles
        ld      bc, r10_DefaultCollectiblesEnd - r10_DefaultCollectibles
        ld      de, wram2_var_collectibles
        fcall   Memcpy
        ret


;;; ----------------------------------------------------------------------------

VoidVBlankFn:
	ret


;;; ----------------------------------------------------------------------------

VoidUpdateFn:
        ret


;;; ----------------------------------------------------------------------------

DrawonlyUpdateFn:
        fcall   DrawEntitiesSimple
        ret


;;; ----------------------------------------------------------------------------


__Widecall:
;;; hl - function pointer
;;; a - target bank
;;; d - resume bank
;;; NOTE: assumes that the caller pushed its own bank onto the stack. Only
;;; intended to be invoked using the WIDE_CALL macro.
        push    de
        rst     $08
        pop     de
        ld      a, d
        SET_BANK_FROM_A
        ret


;;; ----------------------------------------------------------------------------

VBlankISR:
;;; The VBlank interrupt handler jumps here.
        push    af
        ld      a, 1
        ldh     [hvar_vbl_flag], a

        ld      a, $80                    ; \
        ld      [rTMA], a                 ; | Setup timer, should fire around
        ld      [rTIMA], a                ; | rLY == 133.
        ld      a, TACF_START | TACF_4KHZ ; |
        ld      [rTAC], a                 ; /

        ld	a, IEF_VBLANK | IEF_TIMER ; \ Prep timer interrupt
	ld	[rIE], a                  ; /

        pop     af
        reti


;;; ----------------------------------------------------------------------------

TimerISR:
;;; The Timer interrupt handler jumps here.
        push    af
        push    bc
        push    hl
        push    de

        ld      a, TACF_STOP    ; \ Stop the timer from counting.
        ld      [rTAC], a       ; /

        ld	a, IEF_VBLANK   ; \ Disable timer interrupt, set vblank irq
	ld	[rIE], a	; /

        ;; Eventually, we will be running audio code here.

        ld      a, 42           ; \ Just a test, to make sure that we restore
	ld      [rROMB0], a     ; / the correct rom bank.

        ld      a, [hvar_bank]  ; \ Restore mapped bank from before timer ISR
        ld      [rROMB0], a     ; /

        pop     de
        pop     hl
        pop     bc
        pop     af
        reti


;;; ----------------------------------------------------------------------------



;;; I ran into issues where the I see illegal instruction errors when separating
;;; my source code into different sections.
        INCLUDE "animation.asm"
        INCLUDE "cutscene.asm"
        INCLUDE "entity.asm"
        INCLUDE "boar.asm"
        INCLUDE "bonfire.asm"
        INCLUDE "player.asm"
        INCLUDE "greywolf.asm"
        INCLUDE "spider.asm"
        INCLUDE "scene.asm"
        INCLUDE "rect.asm"
        INCLUDE "inventory.asm"
        INCLUDE "blizzardScene.asm"
        INCLUDE "overworldScene.asm"
        INCLUDE "inventoryScene.asm"
        INCLUDE "introCutsceneScene.asm"
        INCLUDE "roomTransitionScene.asm"
        INCLUDE "worldmapScene.asm"
        INCLUDE "constructBonfireScene.asm"
        INCLUDE "scavengeScene.asm"
        INCLUDE "messageBus.asm"
        INCLUDE "slabTable.asm"
        INCLUDE "utility.asm"
        INCLUDE "fixnum.asm"
        INCLUDE "map.asm"
        INCLUDE "exp.asm"
        INCLUDE "video.asm"
        INCLUDE "damage.asm"
        INCLUDE "rand.asm"
        INCLUDE "overlayBar.asm"
        INCLUDE "math.asm"
        INCLUDE "collectible.asm"
        INCLUDE "sector.asm"

;;; Other ROM banks:
        INCLUDE "rom1_code.asm"
        INCLUDE "rom2_data.asm"
        INCLUDE "rom3_data.asm"
        INCLUDE "rom4_data.asm"
        INCLUDE "rom5_data.asm"
        INCLUDE "rom7_data.asm"
        INCLUDE "rom8_code.asm"
        INCLUDE "rom9_code.asm"
        INCLUDE "rom10_map_data.asm"
        INCLUDE "rom11_data.asm"
        INCLUDE "rom12_intro_cutscene_data.asm"
        INCLUDE "rom13_intro_cutscene_data.asm"
        INCLUDE "rom14_intro_cutscene_data.asm"
        INCLUDE "rom20_intro_cutscene_texture_data.asm"
        INCLUDE "rom21_intro_cutscene_texture_data.asm"
        INCLUDE "rom22_intro_cutscene_texture_data.asm"
        INCLUDE "rom30_data.asm"


;;; SECTION START


;;; ----------------------------------------------------------------------------

;;; ############################################################################

        SECTION "OAM_DMA_ROUTINE", HRAM

hOAMDMA::
        ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to


;;; SECTION OAM_DMA_ROUTINE


;;; ############################################################################
