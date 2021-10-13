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
;;;  Overworld Scene
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


OverworldSceneFadeInVBlank:
        ld      a, [var_scene_counter]
	ld      c, a
        sub     3
        jr      C, .transition
	jr      .continue

.transition:
        ld      de, OverworldSceneOnVBlank
        fcall   SceneSetVBlankFn

.continue:
        ld      [var_scene_counter], a
        fcall   FadeToBlack

	fcall   VBlankCopySpriteTextures
        ret


;;; ----------------------------------------------------------------------------

OverworldSceneInitOverlayVRam:
	SET_BANK 7

        ld      hl, r7_OverlayTiles
        ld      bc, r7_OverlayTilesEnd - r7_OverlayTiles
        ld      de, $9000
        fcall   VramSafeMemcpy

        fcall   InitOverlay
	fcall   UpdateStaminaBar

        fcall   VBlankIntrWait
        fcall   ShowOverlay

        ret


;;; ----------------------------------------------------------------------------

OverworldSceneLoadTiles:

        fcall   OverworldSceneInitOverlayVRam ; Sets rom bank 7

        ld      hl, r7_BackgroundTiles
        ld      bc, r7_BackgroundTilesEnd - r7_BackgroundTiles
        ld      de, $8800
        fcall   VramSafeMemcpy

        VIDEO_BANK 1
        ld      hl, r7_BackgroundTiles2
        ld      bc, r7_BackgroundTiles2End - r7_BackgroundTiles2
        ld      de, $8800
        fcall   VramSafeMemcpy
        VIDEO_BANK 0

        ld      hl, r7_SpriteDropShadow
        ld      bc, r7_SpriteDropShadowEnd - r7_SpriteDropShadow
        ld      de, $87c0
        fcall   VramSafeMemcpy

        ld      hl, r7_SpriteSmallDropShadow
        ld      bc, r7_SpriteSmallDropShadowEnd - r7_SpriteSmallDropShadow
        ld      de, $87b0
        fcall   VramSafeMemcpy

        ld      hl, r7_SpriteSnowflake
        ld      bc, r7_SpriteSnowflakeEnd - r7_SpriteSnowflake
        ld      de, $8780
        fcall   VramSafeMemcpy

        ret


;;; ----------------------------------------------------------------------------

OverworldSceneEnter:
        fcall   VBlankIntrWait

        ld      c, 255
        fcall   FadeToBlack

        fcall   OverworldSceneLoadTiles

        fcall   VBlankIntrWait

        ld      a, 128
        ld      [rWY], a

        ld      a, 7
        ld      [rWX], a

;;; TODO: reload map tiles

        ld      de, OverworldSceneUpdate
        fcall   SceneSetUpdateFn

        ld      a, 255
        ld      [var_scene_counter], a

        ld      de, OverworldSceneFadeInVBlank
        fcall   SceneSetVBlankFn

        fcall   OverlayRepaintRow2

        ret


;;; ----------------------------------------------------------------------------


OverworldSceneUpdateView:
        ld      a, [var_player_anchor_x]
        ld      d, a
        ld      a, 175                  ; 255 - (screen_width / 2)
        cp      d
        jr      C, .xFixedRight
        ld      a, d
        ld      d, 80
	sub     d
        jr      C, .xFixedLeft
        ldh     [hvar_view_x], a

        jr      .setY

.xFixedLeft:
        ld      a, 0
        ldh     [hvar_view_x], a
        jr      .setY

.xFixedRight:
        ld      a, 95                   ; 255 - screen_width
        ldh     [hvar_view_x], a

.setY:
        ld      a, [var_player_anchor_y]
        add     a, 8                    ; Menu bar takes up one row, add offset
        ld      d, a
        ld      a, (183 + 19)           ; FIXME: why does this val work?
        cp      d
        jr      C, .yFixedBottom
        ld      a, d
        ld      d, 80
        sub     d
        jr      C, .yFixedTop
        ldh     [hvar_view_y], a

        jr      .done

.yFixedTop:
        ld      a, 0
        ldh     [hvar_view_y], a
        jr      .done

.yFixedBottom:
        ld      a, 121                  ; FIXME: how'd I decide on this number?
        ldh     [hvar_view_y], a

.done:
        fcall   UpdateStaminaBar

;;; !!!!FALLTHROUGH!!!!

ScreenShakeUpdate:
        ld      a, [var_shake_magnitude]
        or      a
        ret     Z
        ld      b, a

        ld      a, [var_shake_timer]
        cp      32
        jr      Z, .done
        ld      c, a
.run:
        LONG_CALL r1_Screenshake

        ld      a, [var_shake_timer]
        inc     a
        ld      [var_shake_timer], a

        ret

.done:
        ld      a, 0
        ld      [var_shake_magnitude], a
        ld      [var_shake_timer], a
        ret


;;; ----------------------------------------------------------------------------


OverworldSceneUpdate:

.checkLevelup:
	ldh     a, [hvar_exp_levelup_ready_flag]
        or      a
        jr      Z, .checkExpChanged

        xor     a
        ldh     [hvar_exp_levelup_ready_flag], a
        ldh     [hvar_exp_changed_flag], a

        LONG_CALL r1_ExpDoLevelup
        fcall   OverlayRepaintRow2


        ;; TODO: play a jingle, go to levelup scene

        ret

.checkExpChanged:
        ldh     a, [hvar_exp_changed_flag]
        or      a
        jr      Z, .checkSelect

        xor     a
        ldh     [hvar_exp_changed_flag], a

	fcall   OverlayRepaintRow2

        ret

.checkSelect:
        ldh     a, [hvar_joypad_current]
        bit     PADB_SELECT, a
        jr      Z, .checkStart

        ld      de, WorldmapSceneEnter
        fcall   SceneSetUpdateFn

        ld      de, VoidVBlankFn
        fcall   SceneSetVBlankFn
        ret

.checkStart:
        bit     PADB_START, a
        jr      Z, .updateEntities

	ld      a, 0
        ld      [var_inventory_scene_cooking_tab_avail], a
        ld      a, INVENTORY_TAB_ITEMS
        ld      [var_inventory_scene_tab], a

        ld      de, InventorySceneEnter
        fcall   SceneSetUpdateFn
        ret

.updateEntities:
	fcall   UpdateEntities

        fcall   OverworldSceneAnimateWater

;;; If it wasn't for view scrolling, the update and draw stuff could be done in
;;; the same loop.
        fcall   OverworldSceneUpdateView

        fcall   DrawEntitiesSimple

        fcall   OverworldSceneTryRoomTransition

        ret


;;; ----------------------------------------------------------------------------


VBlankCopySpriteTextures:
;;; Now, this entity buffer code looks pretty nasty. But, we are just doing a
;;; bunch of work upfront, because we do not always need to actually run the
;;; dma. Iterate through each entity, check its swap flag. If the entity
;;; requires a texture swap, map the texture into vram with GDMA.
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


        ld      a, [de]         ; \
        ld      h, a            ; |
        inc     de              ; |  Fetch entity pointer from entity buffer
        ld      a, [de]         ; /
        ld      l, a            ; Now we have the entity pointer in hl
        inc     de

        ld      a, [hl]         ; load texture swap flag from entity
        and     ENTITY_FLAG0_TEXTURE_SWAP
        jr      Z, .noTextureCopy ; swap flag false, nothing to do

        ld      a, [hl]
        and     LOW(~ENTITY_FLAG0_TEXTURE_SWAP) ; \ We're swapping the texture,
        ld      [hl], a                         ; / zero the flag.

        and     ENTITY_FLAG0_SPRITESHEET_MASK ; \ Bind the current spritesheet.
        ldh     [hvar_spritesheet], a         ; /

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
        fcall   MapSpriteBlock  ; DMA copy the sprite into vram

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
.done:
        SET_BANK 1

        ret


;;; ----------------------------------------------------------------------------

OverworldSceneOnVBlank:
        ld      a, [var_stamina_last_val]
        ld      b, a
        ld      a, [var_player_stamina]
        srl     b
        srl     a
        cp      b
        jr      Z, .skip
        fcall   ShowOverlay
.skip:
        ldh     a, [hvar_overlay_y_offset]
        ld      [rWY], a

        ld      a, [var_player_stamina]
        ld      [var_stamina_last_val], a

        ;; Now, technically, doing this copy here could starve sprite anims,
        ;; which need to run within the vblank window. But, the water anim runs
        ;; at a slow framerate, so the copies don't happen too often (once
        ;; every 12 frames at most).
        ld      a, [var_water_anim_changed]
        or      a
        fcallc  NZ, VBlankCopyWaterTextures

	fcall   VBlankCopySpriteTextures

        ret


;;; ----------------------------------------------------------------------------

VBlankCopyWaterTextures:
        ld      a, 0
        ld      [var_water_anim_changed], a

        SET_BANK 7

	ld      hl, r7_BackgroundTilesWaterAnim

        ld      a, [var_water_anim_idx]
        ld      b, a
        ld      c, a
        swap    c
        sla     c               ; FIXME: this x64 will break with more than 4 keyframes
        sla     c
        add     hl, bc


        ld      de, $8D40       ; Address of water tiles in VRAM
        ld      b, 19           ; tiles-to-copy - 1
        fcall   GDMABlockCopy

        ret


;;; ----------------------------------------------------------------------------

OverworldSceneAnimateWater:
        ld      hl, var_water_anim
        ld      c, 13
        ld      d, 3
        fcall   AnimationAdvance
	ld      [var_water_anim_changed], a
        ret


;;; ----------------------------------------------------------------------------

OverworldSceneStartTransition:
;;; de - transition fn
	fcall   SceneSetUpdateFn

	fcall   EntityBufferReset

        fcall   OverlayRepaintRow2

        ld      hl, var_map_slabs
        ld      bc, MAP_HEIGHT / 2
        ld      a, 0
        fcall   Memset

        ;; The player entity is always present in every room (obviously?)
        ld      de, var_player_struct
        fcall   EntityBufferEnqueue

        ld      a, [hvar_joypad_raw]
        ld      [var_room_load_joypad_cache], a

        ld      a, 0
        ld      [var_water_anim_timer], a
        ld      [var_water_anim_idx], a
        ld      [var_water_anim_changed], a

        ret


;;; ----------------------------------------------------------------------------

OverworldSceneTryRoomTransition:
        ld      a, [var_player_coord_y]
        cp      246
        jr      C, .tryUpTransition

        LONG_CALL r1_StoreRoomEntities

	ld      a, [var_room_y]
        inc     a
        ld      [var_room_y], a

        ld      de, RoomTransitionSceneDownUpdate
        fcall   OverworldSceneStartTransition

        ld      de, RoomTransitionSceneDownVBlank
        fcall   SceneSetVBlankFn

        fcall   MapLoad2__rom0_only

        ld      a, 0
        ld      [var_room_load_counter], a
        ld      c, a
        LONG_CALL r1_MapExpandRow

        ret

.tryUpTransition:

        ld      a, [var_player_coord_y]
        ld      b, a
        ld      a, 8
        cp      b
        jr      C, .tryRightTransition

        LONG_CALL r1_StoreRoomEntities

	ld      a, [var_room_y]
        dec     a
        ld      [var_room_y], a

        ld      de, RoomTransitionSceneUpUpdate
        fcall   OverworldSceneStartTransition

        ld      de, RoomTransitionSceneUpVBlank
        fcall   SceneSetVBlankFn

        fcall   MapLoad2__rom0_only

        ld      a, 31
        ld      [var_room_load_counter], a
        ld      c, a
        LONG_CALL r1_MapExpandRow

        ret

.tryRightTransition:
        ld      a, [var_player_coord_x]
        cp      246
        jr      C, .tryLeftTransition

        LONG_CALL r1_StoreRoomEntities

	ld      a, [var_room_x]
        inc     a
        ld      [var_room_x], a

        ld      de, RoomTransitionSceneRightUpdate
        fcall   OverworldSceneStartTransition

        ld      de, RoomTransitionSceneRightVBlank
        fcall   SceneSetVBlankFn

        fcall   MapLoad2__rom0_only

        ld      a, 0
        ld      [var_room_load_counter], a
        ld      c, a
        LONG_CALL r1_MapExpandColumn

        ret

.tryLeftTransition:
        ld      a, [var_player_coord_x]
        ld      b, a
        ld      a, 8
        cp      b
        jr      C, .done

        LONG_CALL r1_StoreRoomEntities

	ld      a, [var_room_x]
        dec     a
        ld      [var_room_x], a

        ld      de, RoomTransitionSceneLeftUpdate
        fcall   OverworldSceneStartTransition

        ld      de, RoomTransitionSceneLeftVBlank
        fcall   SceneSetVBlankFn

        fcall   MapLoad2__rom0_only

        ld      a, 31
        ld      [var_room_load_counter], a
        ld      c, a
        LONG_CALL r1_MapExpandColumn

.done:
        ret
