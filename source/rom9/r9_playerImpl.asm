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


WALL_TILES_END  EQU     56
EMPTY_TILE      EQU     58
EMPTY_TILE_ADDR EQU     $f4


;;; NOTE: We don't want the player to walk faster in the diagonal direction
;;; than along cartesian axes. Consider the cartesian number as a hypotenuse,
;;; and the diagonal constants as each x,y vector to add to the player's
;;; position when moving diagonally, assigned such that the diagonal speed
;;; equals the l/r/u/d speed.
PLAYER_WALK_SPEED_CARTESIAN_NUM         EQU     1
PLAYER_WALK_SPEED_CARTESIAN_DENOM       EQU     64

PLAYER_WALK_SPEED_DIAGONAL_NUM          EQU     0
PLAYER_WALK_SPEED_DIAGONAL_DENOM        EQU     224




r9_PlayerTileCoord:
;;; return b - y
;;; return a - x
        ld      a, [var_player_coord_y]
        swap    a               ; Tiles are 16x16, so divide player pos by 16
	and     $0f             ; swap + mask == division by 16
        ld      b, a

        ld      a, [var_player_coord_x]
        swap    a
        and     $0f
        ret



;;; ----------------------------------------------------------------------------


r9_PlayerWallCollisionCheck:
        ;; Don't ask me why these numbers work (because I do not recall). I
        ;; calibrated the hitbox size so that the player's drop-shadow wouldn't
        ;; overlap with the edge of any wall tiles. Otherwise, the size is
        ;; fairly arbitrary.
        ld      a, [var_player_coord_x]
        sub     2
        ld      [hvar_wall_collision_source_x], a
        ld      a, [var_player_coord_y]
        add     2
        ld      [hvar_wall_collision_source_y], a
        ld      a, 4
        ld      [hvar_wall_collision_size_x], a
        ld      a, 4
        ld      [hvar_wall_collision_size_y], a
        fcall   r9_WallCollisionCheck
        ret


;;; ----------------------------------------------------------------------------



r9_PlayerUpdateMovement:
        fcall   r9_PlayerWallCollisionCheck


;;; try walk left
        ld      a, [hvar_wall_collision_result] ; Load collision mask
        and     COLLISION_LEFT
        ld      [var_player_spill2], a  ; Store part of mask in temp var

        ld      hl, var_player_coord_x
        ld      b, 0

        ldh     a, [hvar_joypad_raw]
        and     PADF_DOWN | PADF_UP
        ld      c, a

        ldh     a, [hvar_joypad_raw]
        and     PADF_LEFT
        ld      e, SPRID_PLAYER_WL
        fcall   r9_PlayerJoypadResponse



;;; try walk right
        ld      a, [hvar_wall_collision_result] ; Load collision mask
        and     COLLISION_RIGHT
        ld      [var_player_spill2], a  ; Store part of mask in temp var

        ld      hl, var_player_coord_x
        ld      b, 1

        ;; c param is unchanged for this next call
        ldh     a, [hvar_joypad_raw]
        and     PADF_RIGHT
        ld      e, SPRID_PLAYER_WR
        fcall   r9_PlayerJoypadResponse



;;; try walk down
        ld      a, [hvar_wall_collision_result]  ; Load collision mask
        and     COLLISION_DOWN
        ld      [var_player_spill2], a  ; Store part of mask in temp var

	ld      hl, var_player_coord_y
        ld      b, 1

        ldh     a, [hvar_joypad_raw]
        and     PADF_LEFT | PADF_RIGHT
        ld      c, a

        ldh     a, [hvar_joypad_raw]
	and     PADF_DOWN
        ld      e, SPRID_PLAYER_WD
        fcall   r9_PlayerJoypadResponse



;;; try walk up
        ld      a, [hvar_wall_collision_result]  ; Load collision mask
        and     COLLISION_UP
        ld      [var_player_spill2], a  ; Store part of mask in temp var

	ld      hl, var_player_coord_y
        ld      b, 0

        ldh     a, [hvar_joypad_raw]
	and     PADF_UP
        ld      e, SPRID_PLAYER_WU
        fcall   r9_PlayerJoypadResponse

        ld      hl, var_player_coord_y  ; \
        ld      de, var_player_anchor_y ; | Set View Anchor
        ld      bc, FIXNUM_SIZE * 2     ; |
        fcall   Memcpy                  ; /

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAnimate:
        ld      a, [var_player_fb]

        cp      SPRID_PLAYER_WR
        jr      Z, .animateWalkLR

        cp      SPRID_PLAYER_WL
        jr      Z, .animateWalkLR

        cp      SPRID_PLAYER_WD
        jr      Z, .animateWalkUD

        cp      SPRID_PLAYER_WU
        jr      Z, .animateWalkUD

        jr      .done

.animateWalkLR:
        ld      hl, var_player_animation
        ld      c, 6
        ld      d, 5
        fcall   AnimationAdvance
        or      a
        jr      NZ, .frameChangedLR
        jr      .done

.animateWalkUD:
        ld      hl, var_player_animation
        ld      c, 6
        ld      d, 10

        fcall   AnimationAdvance
        or      a
        jr      NZ, .frameChangedUD
.done:
        ret

.frameChangedLR:
        ld      a, SPRITE_SHAPE_T
        ld      [var_player_display_flag], a
        jr      .frameChanged

.frameChangedUD:
        ld      a, SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a

.frameChanged:
        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerJoypadResponse:
;;; a - btn 1 pressed
;;; c - btn 3 or button 4 pressed
;;; e - desired frame
;;; hl - position ptr
;;; b - add/sub position
;;; trashes a
        or      a
        ret     Z

        ld      a, c
        or      a
        jr      Z, .n2

        ld      a, [var_player_fb] ; \
        cp      SPRID_PLAYER_WL    ; |
        jr      Z, .setSpeed       ; |
        cp      SPRID_PLAYER_WR    ; | Bugfix: If the player's keyframe is
        jr      Z, .setSpeed       ; | anything other than one of the walk
	cp      SPRID_PLAYER_WU    ; | keyframes, set desired frame from e.
        jr      Z, .setSpeed       ; |
        cp      SPRID_PLAYER_WD    ; |
        jr      Z, .setSpeed       ; /

.n2:
        ld      a, [var_player_fb]
        cp      e
        jr      Z, .setSpeed    ; the base frame is unchanged

        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
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
        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

.setSpeed:
        ld      a, [var_player_spill2]
        or      a
        jr      NZ, .noMove

        push    bc
        ld      a, b
        or      a
        jr      Z, .subPosition

        ld      a, c
        or      a

;;; We want to add less to each axis-aligned movement vector when moving
;;; diagonally, otherwise, we will move faster in the diagonal direction.
        jr      NZ, .moveDiagonalFwd
        ld      b, PLAYER_WALK_SPEED_CARTESIAN_NUM
        ld      c, PLAYER_WALK_SPEED_CARTESIAN_DENOM
        jr      .moveFwd
.moveDiagonalFwd:
        ld      b, PLAYER_WALK_SPEED_DIAGONAL_NUM
        ld      c, PLAYER_WALK_SPEED_DIAGONAL_DENOM
.moveFwd:

        fcall   FixnumAdd
        pop     bc
        jr      .done
.subPosition:

        ld      a, c
        or      a

        jr      NZ, .moveDiagonalRev
        ld      b, PLAYER_WALK_SPEED_CARTESIAN_NUM
        ld      c, PLAYER_WALK_SPEED_CARTESIAN_DENOM
        jr      .moveRev
.moveDiagonalRev:
        ld      b, PLAYER_WALK_SPEED_DIAGONAL_NUM
        ld      c, PLAYER_WALK_SPEED_DIAGONAL_DENOM
.moveRev:

        ld      b, 1
        ld      c, 64
        fcall   FixnumSub
        pop     bc
	jr      .done

.noMove:

.done:
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerOnMessage:
;;; bc - message pointer
        ld      a, [bc]                 ; Load message type
        cp      MESSAGE_WOLF_ATTACK
        jr      Z, .onWolfAttack
        cp      MESSAGE_DIALOG_BOX_OPENED
        jr      Z, .onDialogOpened
	cp      MESSAGE_DIALOG_BOX_CLOSED
        jr      Z, .onDialogClosed

        ;; TODO... currently, we're ignoring all messages.
        ret

.onDialogOpened:
        ld      hl, var_player_struct
        ld      de, PlayerDialogIdle
        fcall   EntitySetUpdateFn

        fcall   r9_PlayerSetIdleSprite
        ret

.onDialogClosed:
        ld      hl, var_player_struct
        ld      de, PlayerUpdate
        fcall   EntitySetUpdateFn
        ret

.onWolfAttack:
        push    bc
        pop     hl

        inc     hl
        inc     hl
        ld      c, [hl]         ; Load enemy y from message
        inc     hl
        ld      b, [hl]         ; Load enemy x from message

        ld      hl, var_temp_hitbox2
        fcall   r9_GreywolfPopulateHitbox

        ld      hl, var_temp_hitbox1
        fcall   r9_PlayerPopulateHitbox


        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        jr      NC, .skip

        fcall   r9_PlayerWolfAttackDepleteStamina

        ld      a, 25
        ld      [var_player_color_counter], a

        ld      b, 3
        WIDE_CALL r1_StartScreenshake
.skip:
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerMessageLoop:
        ;; NOTE: This is fine, because the player will always use message queue
        ;; id zero, so we don't need to add any offsets, we can just load the
        ;; beginning of the message queue memory in ram.
        ld      hl, var_message_queue_memory

        ld      bc, r9_PlayerOnMessage
	fcall   MessageQueueDrain
        ret


;;; ----------------------------------------------------------------------------

r9_PlayerUpdateImpl:
        fcall   r9_PlayerUpdateInjuredColor

        fcall   r9_PlayerUpdateMovement

        ldh     a, [hvar_joypad_released]
        and     PADF_DOWN
        jr      Z, .checkUpReleased

.checkDownReleased:
        ldh     a, [hvar_joypad_raw]
        and     PADF_LEFT | PADF_RIGHT | PADF_UP
        jr      NZ, .checkUpReleased

        ld      a, SPRID_PLAYER_SD
        ld      [var_player_fb], a
        ld      a, SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a
        ld      a, 0
        ld      [var_player_kf], a
        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

.checkUpReleased:
        ldh     a, [hvar_joypad_released]
        and     PADF_UP
        jr      Z, .checkLeftReleased

        ldh     a, [hvar_joypad_raw]
        and     PADF_LEFT | PADF_RIGHT | PADF_DOWN
        jr      NZ, .checkLeftReleased

        ld      a, SPRID_PLAYER_SU
        ld      [var_player_fb], a
        ld      a, SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a
        ld      a, 0
        ld      [var_player_kf], a
        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

.checkLeftReleased:
        ldh     a, [hvar_joypad_released]
        and     PADF_LEFT
        jr      Z, .checkRightReleased

        ldh     a, [hvar_joypad_raw]
        and     PADF_UP | PADF_DOWN | PADF_RIGHT
        jr      NZ, .checkRightReleased

        ld      a, SPRID_PLAYER_SL
        ld      [var_player_fb], a
        ld      a, SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a
        ld      a, 0
        ld      [var_player_kf], a
        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

.checkRightReleased:
        ldh     a, [hvar_joypad_released]
        and     PADF_RIGHT
        jr      Z, .animate

        ldh     a, [hvar_joypad_raw]
        and     PADF_UP | PADF_DOWN | PADF_RIGHT
        jr      NZ, .animate

        ld      a, SPRID_PLAYER_SR
        ld      [var_player_fb], a
        ld      a, SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a
        ld      a, 0
        ld      [var_player_kf], a
        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

.animate:
        ld      a, [hvar_joypad_raw]
        or      a
        jr      Z, .done

	fcall   r9_PlayerWalkDepleteStamina

	fcall   r9_PlayerAnimate

        ldh     a, [hvar_joypad_current]
        bit     PADB_A, a
        jr      Z, .checkB
        ld      a, [hvar_wall_collision_result]
        or      a
        jr      Z, .tryInteractEntities
        fcall   r9_PlayerTryInteract
        jr      .return

.checkB:
        bit     PADB_B, a
        jr      Z, .done
        fcall   r9_PlayerAttackInit
        ret

.done:
        ldh     a, [hvar_joypad_raw]
        and     PADF_LEFT | PADF_RIGHT | PADF_UP | PADF_DOWN
        fcallc  Z, r9_PlayerSetIdleSprite
.return:
        fcall   r9_PlayerMessageLoop
        ret

.tryInteractEntities:
        fcall   r9_PlayerInteractBroadcast
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerTryInteract:

        ;; Yeah, this is lazy, but it only runs when we press a button and we're
        ;; colliding with something, so it's not worth optimizing this part of
        ;; the code, especially when we have tons of slack space in this rom
        ;; bank.
        ld      a, [var_player_fb]
        cp      SPRID_PLAYER_WL
        jr      Z, .tryInteractLeft
        cp      SPRID_PLAYER_SL
        jr      Z, .tryInteractLeft
        cp      SPRID_PLAYER_WR
        jr      Z, .tryInteractRight
        cp      SPRID_PLAYER_SR
        jr      Z, .tryInteractRight
        cp      SPRID_PLAYER_WU
        jr      Z, .tryInteractUp
        cp      SPRID_PLAYER_SU
        jr      Z, .tryInteractUp
        cp      SPRID_PLAYER_WD
        jr      Z, .tryInteractDown
        cp      SPRID_PLAYER_SD
        jr      Z, .tryInteractDown
        ret

.tryInteractEntities:
        fcall   r9_PlayerInteractBroadcast
        ret

.tryInteractLeft:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_LEFT
        jr      Z, .tryInteractEntities

	fcall   r9_PlayerTileCoord
        dec     a
        ld      d, SPRID_PLAYER_PL
        fcall   r9_PlayerInteractTile

        ret

.tryInteractRight:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_RIGHT
        jr      Z, .tryInteractEntities

	fcall   r9_PlayerTileCoord
        inc     a
        ld      d, SPRID_PLAYER_PR
        fcall   r9_PlayerInteractTile

        ret

.tryInteractUp:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_UP
        jr      Z, .tryInteractEntities

	fcall   r9_PlayerTileCoord
        dec     b
        ld      d, SPRID_PLAYER_PU
        fcall   r9_PlayerInteractTile

        ret

.tryInteractDown:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_DOWN
        jr      Z, .tryInteractEntities

	fcall   r9_PlayerTileCoord
        inc     b
        ld      d, SPRID_PLAYER_PD
        fcall   r9_PlayerInteractTile

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerInteractTile:
;;; a - x
;;; b - y
;;; d - pickup animation frame base
        push    de


        push    af                      ; \
        push    bc                      ; |
        swap    a                       ; | Store x,y coords of tile, for later
        and     $f0                     ; | use, when we want to erase the tile
        ld      c, a                    ; | from the world map.
        ld      a, b                    ; |
        and     $0f                     ; |
        or      c                       ; |
        ld      [var_collect_item_xy], a; |
        pop     bc                      ; |
        pop     af                      ; /


        ld      hl, var_map_info
        fcall   MapGetTile

        ld      a, b

        fcall   IsTileLockedDoor
        jr      Z, .tryOpenDoor

        fcall   IsTileCollectible
        jr      NZ, .tryInteractEntities

        ld      hl, var_player_struct
        ld      de, PlayerUpdatePickupItem
        fcall   EntitySetUpdateFn

        pop     de

        fcall   r9_PlayerPickupAnimationInit
        ret

.tryInteractEntities:
        fcall   r9_PlayerInteractBroadcast

        pop     de
        ret

.tryOpenDoor:
        ld      hl, var_player_struct
        ld      de, PlayerUpdateUnlockDoor
        fcall   EntitySetUpdateFn

        fcall   r9_PlayerSetIdleSprite

        pop     de
        ret


;;; ----------------------------------------------------------------------------

r9_PlayerPickupAnimationInit:
;;; d - pickup animation frame base
        ld      a, d
        ld      [var_player_fb], a

        ld      a, 0
        ld      [var_player_kf], a

        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

        ret


;;; ----------------------------------------------------------------------------

no_keys_str::
DB      "key required", 0

used_key_str::
DB      "used key", 0


r9_PlayerUpdateUnlockDoorImpl:
        ld      b, ITEM_KEY
        fcall   InventoryCountOccurrences
        ld      a, d
        or      a
        jr      Z, .noKeys

        ld      hl, used_key_str
        fcall   OverlayPutText

        ld      b, ITEM_KEY
        fcall   InventoryConsumeItem

        fcall   r9_RemoveMapItem

        jr      .return

.noKeys:
        ld      hl, no_keys_str
        fcall   OverlayPutText


.return:
        ld      hl, var_player_struct
        ld      de, PlayerUpdate
        fcall   EntitySetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

r9_PlayerUpdatePickupItemImpl:
        ld      hl, var_player_animation
        ld      c, 7
        ld      d, 5
        fcall   AnimationAdvance
        or      a
        jr      NZ, .frameChanged
        ret

.frameChanged:
        ld      a, SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a

        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

        ld      a, [var_player_kf]
        cp      0                       ; Animation complete if we've looped
        jr      Z, .animationComplete

        cp      4
        jr      NZ, .skip

        fcall   r9_CollectMapItem

.skip:
        ret

.animationComplete:
        ld      hl, var_player_struct
        ld      de, PlayerUpdate
        fcall   EntitySetUpdateFn

        ld      a, [var_player_fb]
        cp      SPRID_PLAYER_PD
        jr      Z, .resumeDown
        cp      SPRID_PLAYER_PU
        jr      Z, .resumeUp
        cp      SPRID_PLAYER_PR
        jr      Z, .resumeRight
        cp      SPRID_PLAYER_PL
        jr      Z, .resumeLeft

.resumeDown:
        ld      a, SPRID_PLAYER_SD
        jr      .setFb

.resumeUp:
        ld      a, SPRID_PLAYER_SU
        jr      .setFb

.resumeRight:
        ld      a, SPRID_PLAYER_SR
        jr      .setFb

.resumeLeft:
        ld      a, SPRID_PLAYER_SL
        jr      .setFb

.setFb:
        ld      [var_player_fb], a

        ret


;;; ----------------------------------------------------------------------------


got_potato_str::
DB      "got potato", 0
got_stick_str::
DB      "got stick", 0
got_key_str::
DB      "got key", 0
got_hammer_str::
DB      "got hammer!", 0


r9_PlayerAddItemToInventory:
        ld      a, b
        cp      COLLECTIBLE_TILE_POTATO
        jr      Z, .potato
        cp      COLLECTIBLE_TILE_STICK
        jr      Z, .stick
        cp      COLLECTIBLE_TILE_KEY
        jr      Z, .key
        cp      COLLECTIBLE_TILE_HAMMER
        jr      Z, .hammer
        ret

.potato:
        ld      b, ITEM_POTATO
        fcall   InventoryAddItem
        ld      hl, got_potato_str
        fcall   OverlayPutText
        ret

.stick:
        ld      b, ITEM_STICK
        fcall   InventoryAddItem
        ld      hl, got_stick_str
        fcall   OverlayPutText
        ret

.key:
        ld      b, ITEM_KEY
        fcall   InventoryAddItem
        ld      hl, got_key_str
        fcall   OverlayPutText
        ret

.hammer:
        ld      b, ITEM_HAMMER
        fcall   InventoryAddItem
        ld      hl, got_hammer_str
        fcall   OverlayPutText
        ret


;;; ----------------------------------------------------------------------------

r9_RemoveMapItem:
        push    de
        ld      e, 7
        fcall   ForceSleepOverworld
        pop     de

        ld      a, [var_collect_item_xy]
        and     $0f
        ld      d, a
        ld      a, [var_collect_item_xy]
        and     $f0
        swap    a

        push    af                      ; \ Store coordinate
        push    de                      ; /

        sla     a                       ; 2x2 background meta tiles
        sla     d                       ;

        ld      e, EMPTY_TILE_ADDR
        ld      c, $0a

        fcall   SetBackgroundTile16x16

	pop     de                      ; \ Restore coordinate
        pop     af                      ; /

        ld      b, d                    ; Pass y in reg b

        ld      hl, var_map_info
        ld      d, EMPTY_TILE
        fcall   MapSetTile

        fcall   CollectibleItemErase

        ret


;;; ----------------------------------------------------------------------------

r9_CollectMapItem:

        push    de
        ld      e, 7
        fcall   ForceSleepOverworld
        pop     de


        fcall   InventoryIsFull
        or      a
        jr      NZ, .failed


        ld      a, [var_collect_item_xy]
        and     $0f
        ld      d, a
        ld      a, [var_collect_item_xy]
        and     $f0
        swap    a

        push    af                      ; \ Store coordinate
        push    de                      ; /

        sla     a                       ; 2x2 background meta tiles
        sla     d                       ;

        ld      e, EMPTY_TILE_ADDR
        ld      c, $0a

        fcall   SetBackgroundTile16x16

	pop     de                      ; \ Restore coordinate
        pop     af                      ; /

        ld      b, d                    ; Pass y in reg b

        push    af
        push    bc
        ld      hl, var_map_info
        fcall   MapGetTile

        fcall   r9_PlayerAddItemToInventory

        pop     bc
        pop     af

        ld      hl, var_map_info
        ld      d, EMPTY_TILE
        fcall   MapSetTile

        fcall   CollectibleItemErase

        ret

.failed:
        ld      hl, inventory_full_str
        fcall   OverlayPutText
        ret


inventory_full_str::
DB      "inventory full", 0


;;; ----------------------------------------------------------------------------

r9_HammerAttackSetFacing:
        ld      a, [var_player_fb]
        cp      SPRID_PLAYER_WL
        jr      Z, .left
        cp      SPRID_PLAYER_SL
        jr      Z, .left
        cp      SPRID_PLAYER_WR
        jr      Z, .right
        cp      SPRID_PLAYER_SR
        jr      Z, .right
        cp      SPRID_PLAYER_WD
        jr      Z, .down
        cp      SPRID_PLAYER_SD
        jr      Z, .down
        cp      SPRID_PLAYER_WU
        jr      Z, .up
        cp      SPRID_PLAYER_SU
        jr      Z, .up
        ret

.left:
        ld      a, SPRID_PLAYER_HAMMER_L
        ld      [var_player_fb], a
        ret

.right:
        ld      a, SPRID_PLAYER_HAMMER_R
        ld      [var_player_fb], a
        ret

.down:
        ld      a, SPRID_PLAYER_HAMMER_D
        ld      [var_player_fb], a
        ret

.up:
        ld      a, SPRID_PLAYER_HAMMER_U
        ld      [var_player_fb], a
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttackInit:
        ld      a, [var_equipped_item]
        cp      ITEM_DAGGER
        jr      Z, .initDagger
	cp      ITEM_HAMMER
        jr      Z, .initHammer
        ret

.initHammer:
        ld      hl, var_player_struct
        ld      de, PlayerRaiseHammer
        fcall   EntitySetUpdateFn

        ld      hl, var_player_coord_y  ; \ Cache x,y coords. We will be
        ld      de, var_player_anchor_y ; | shifting the player's origin
        ld      bc, FIXNUM_SIZE * 2     ; / around.
        fcall   Memcpy

        xor     a
        ld      [var_player_kf], a

        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

        ld      a, SPRITE_SHAPE_SQUARE_32
        ld      [var_player_display_flag], a

        fcall   r9_HammerAttackSetFacing

        ld      b, 1
        ld      c, 10
        fcall   r9_PlayerDepleteStamina
        ret

.initDagger:
	fcall   r9_PlayerKnifeAttackDepleteStamina

        ld      hl, var_player_struct
        ld      de, PlayerUpdateAttack1
        fcall   EntitySetUpdateFn

        ld      a, 0
        ld      [var_player_kf], a

        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

        ld      a, SPRITE_SHAPE_SQUARE_32
        ld      [var_player_display_flag], a


        ld      a, [var_player_fb]
        cp      a, SPRID_PLAYER_WR
        jr      Z, .right
        cp      a, SPRID_PLAYER_SR
        jr      Z, .right
        cp      a, SPRID_PLAYER_WL
        jr      Z, .left
        cp      a, SPRID_PLAYER_SL
        jr      Z, .left
        cp      a, SPRID_PLAYER_WD
        jr      Z, .down
        cp      a, SPRID_PLAYER_SD
        jr      Z, .down
        cp      a, SPRID_PLAYER_WU
        jr      Z, .up
        cp      a, SPRID_PLAYER_SU
        jr      Z, .up

.right:
        ld      a, SPRID_PLAYER_KNIFE_ATK_R
        jr      .set

.left:
        ld      a, SPRID_PLAYER_KNIFE_ATK_L
	jr      .set

.down:
        ld      a, SPRID_PLAYER_KNIFE_ATK_D
	jr      .set

.up:
        ld      a, SPRID_PLAYER_KNIFE_ATK_U
        jr      .set


.set:
        ld      [var_player_fb], a

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttackSetFacing:
        ld      a, [hvar_joypad_current]
        bit     PADB_UP, a
        jr      NZ, .faceUp
        bit     PADB_DOWN, a
        jr      NZ, .faceDown
        bit     PADB_LEFT, a
        jr      NZ, .faceLeft
        bit     PADB_RIGHT, a
        jr      NZ, .faceRight
        ret

.faceLeft:
        ld      a, SPRID_PLAYER_KNIFE_ATK_L
        ld      [var_player_fb], a
        ret

.faceRight:
        ld      a, SPRID_PLAYER_KNIFE_ATK_R
        ld      [var_player_fb], a
        ret

.faceUp:
        ld      a, SPRID_PLAYER_KNIFE_ATK_U
        ld      [var_player_fb], a
        ret

.faceDown:
        ld      a, SPRID_PLAYER_KNIFE_ATK_D
        ld      [var_player_fb], a
        ret


;;; ----------------------------------------------------------------------------


;;; Now, the player could scan through the entity list, ask all of the entities
;;; what type they are, check overlap accordingly, etc... but we already have a
;;; message bus. So instead, we broadcast an interact message to all entities,
;;; and interactible entities will check overlap with the player, and initiate
;;; the appropriate state change. This way, the player doesn't need to know
;;; about each individual entity implementation.
r9_PlayerInteractBroadcast:
        ld      c, MESSAGE_PLAYER_INTERACT
        push    bc
        push    bc
        ld      hl, sp+0

        fcall   MessageBusBroadcast

        pop     bc
        pop     bc

        ret


;;; ----------------------------------------------------------------------------

r9_PlayerHammerAttackBroadcast:
        ld      a, [var_player_anchor_x] ; \
        ld      b, a                     ; | Second argument: player x, y
        ld      a, [var_player_anchor_y] ; |
        ld      c, a                     ; |
        push    bc                       ; /

        ld      c, MESSAGE_PLAYER_HAMMER_ATTACK ; \ First argument: message type
        ld      a, [var_player_fb]              ; | and player sprite id.
        ld      b, a                            ; |
        push    bc                              ; /

        ld      hl, sp+0        ; Load pointer to the message on the stack

        fcall   MessageBusBroadcast

        pop     bc
        pop     bc

        ret


;;; ----------------------------------------------------------------------------

r9_PlayerKnifeAttackBroadcast:
        ld      c, MESSAGE_PLAYER_KNIFE_ATTACK ; \
        ld      b, 0                           ; |
        push    bc                             ; | Setup message arg on stack.
        push    bc                             ; |
        ld      hl, sp+0                       ; /

        fcall   MessageBusBroadcast

        pop     bc              ; \ Pop message arg from stack
        pop     bc              ; /

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttackMovement:

        fcall   r9_PlayerWallCollisionCheck

        ld      a, [var_player_fb]
        cp      SPRID_PLAYER_KNIFE_ATK_D
        jr      Z, .checkMoveDown
        cp      SPRID_PLAYER_KNIFE_ATK_U
        jr      Z, .checkMoveUp
        cp      SPRID_PLAYER_KNIFE_ATK_R
        jr      Z, .checkMoveRight
        cp      SPRID_PLAYER_KNIFE_ATK_L
        jr      Z, .checkMoveLeft

        ret

.checkMoveDown:
        ldh     a, [hvar_joypad_raw]
        bit     PADB_DOWN, a
        jr      Z, .skipMoveDown
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_DOWN
        jr      NZ, .skipMoveDown

        ld      hl, var_player_coord_y
        ld      b, 0
        ld      c, 30
        fcall   FixnumAdd
	jr      .done

.skipMoveDown:
        ret


.checkMoveUp:
	ld      a, [hvar_joypad_raw]
        bit     PADB_UP, a
        jr      Z, .skipMoveUp
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_UP
        jr      NZ, .skipMoveUp

        ld      hl, var_player_coord_y
        ld      b, 0
        ld      c, 30
        fcall   FixnumSub
        jr      .done

.skipMoveUp:
        ret


.checkMoveRight:
	ld      a, [hvar_joypad_raw]
        bit     PADB_RIGHT, a
        jr      Z, .skipMoveRight
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_RIGHT
        jr      NZ, .skipMoveRight

        ld      hl, var_player_coord_x
        ld      b, 0
        ld      c, 30
        fcall   FixnumAdd
        jr      .done

.skipMoveRight:
        ret


.checkMoveLeft:
	ld      a, [hvar_joypad_raw]
        bit     PADB_LEFT, a
        jr      Z, .skipMoveLeft
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_LEFT
        jr      NZ, .skipMoveLeft

        ld      hl, var_player_coord_x
        ld      b, 0
        ld      c, 30
        fcall   FixnumSub
        jr      .done

.skipMoveLeft:
        ret

.done:
        ld      hl, var_player_coord_y  ; \
        ld      de, var_player_anchor_y ; | Set View Anchor
        ld      bc, FIXNUM_SIZE * 2     ; |
        fcall   Memcpy                  ; /
        ret


;;; ----------------------------------------------------------------------------


;;; Used for setting the origin while playing the hammer attack animation.
;;; e.g.: Anchor_x + table[keyframe] == centered_sprite_x.
r9_PlayerHammerLOriginXTable:
DB      0, 0, 1, 0, -5, -6, -6, -5, -3, 5, 5
r9_PlayerHammerROriginXTable:
DB      0, 0, -1, 0, 5, 6, 6, 5, 3, -5, -5
r9_PlayerHammerDOriginYTable:
DB      -2, -1, 0, 0, 0, 0, 0, 0, 0, -8, -8
r9_PlayerHammerUOriginYTable:
DB      0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0



r9_PlayerHammerFrameTimes:
DB      6, 6, 6, 6, 6, 12, 15, 12, 6, 6, 40


r9_PlayerRaiseHammerImpl:
        fcall   r9_PlayerUpdateInjuredColor
        fcall   r9_PlayerMessageLoop

	ld      a, [var_player_kf]
        ld      c, a
        ld      b, 0
        ld      hl, r9_PlayerHammerFrameTimes
        add     hl, bc
        ld      c, [hl]

        ld      hl, var_player_animation
        ld      d, 11
        fcall   AnimationAdvance
        or      a
        jr      NZ, .frameChanged
        ret

.frameChanged:

        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

        fcall   r9_PlayerDropHammerSetXOrigin
        fcall   r9_PlayerDropHammerSetYOrigin

        ld      a, [var_player_kf]
        cp      6
        ret     NZ
        ld      hl, var_player_struct
        ld      de, PlayerWaitHammer
        fcall   EntitySetUpdateFn
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerDropHammerRecoverImpl:
        fcall   r9_PlayerUpdateInjuredColor
        fcall   r9_PlayerMessageLoop

        ld      a, [var_player_tmr]
        inc     a
        ld      [var_player_tmr], a
        cp      2
        jr      Z, .return
        ret
.return:
        xor     a
        ld      [var_player_tmr], a

        ld      hl, var_player_struct
        ld      de, PlayerUpdate
        fcall   EntitySetUpdateFn

        ld      de, var_player_coord_y  ; \
        ld      hl, var_player_anchor_y ; | Restore position from anchor.
        ld      bc, FIXNUM_SIZE * 2     ; |
        fcall   Memcpy                  ; /
        ret

;;; ----------------------------------------------------------------------------


r9_PlayerWaitHammerImpl:
        fcall   r9_PlayerUpdateInjuredColor
        fcall   r9_PlayerMessageLoop

.checkUp:
        ldh     a, [hvar_joypad_raw]
	bit     PADB_UP, a
        jr      Z, .checkDown

        ld      a, SPRID_PLAYER_HAMMER_U
        ld      [var_player_fb], a

        ld      hl, var_player_struct
        fcall   EntitySetTextureSwapFlag

.checkDown:
        ldh     a, [hvar_joypad_raw]
	bit     PADB_DOWN, a
        jr      Z, .checkLeft

        ld      a, SPRID_PLAYER_HAMMER_D
        ld      [var_player_fb], a

        ld      hl, var_player_struct
        fcall   EntitySetTextureSwapFlag

.checkLeft:
        ldh     a, [hvar_joypad_raw]
	bit     PADB_LEFT, a
        jr      Z, .checkRight

        ld      a, SPRID_PLAYER_HAMMER_L
        ld      [var_player_fb], a

        ld      hl, var_player_struct
        fcall   EntitySetTextureSwapFlag

.checkRight:
        ldh     a, [hvar_joypad_raw]
	bit     PADB_RIGHT, a
        jr      Z, .update

        ld      a, SPRID_PLAYER_HAMMER_R
        ld      [var_player_fb], a

        ld      hl, var_player_struct
        fcall   EntitySetTextureSwapFlag

.update:
        fcall    r9_PlayerDropHammerSetXOrigin
        fcall    r9_PlayerDropHammerSetYOrigin

        ldh     a, [hvar_joypad_raw]
        bit     PADB_B, a
        jr      Z, .next

        ;; If the player is holding b, then prime the animation counter with
        ;; some frames, so that the attack will begin as soon as the player
        ;; releases the button.
        ld      a, 12
        ld      [var_player_animation], a

        ret
.next:
        ld      hl, var_player_struct
        ld      de, PlayerDropHammer
        fcall   EntitySetUpdateFn
        ret

;;; ----------------------------------------------------------------------------


r9_PlayerDropHammerSetYOrigin:
        ld      a, [var_player_fb]
        cp      SPRID_PLAYER_HAMMER_D
        jr      Z, .D
        cp      SPRID_PLAYER_HAMMER_U
        jr      Z, .U

        ld      a, [var_player_anchor_y]
        ld      [var_player_coord_y], a
        ret

.D:
        ld      hl, r9_PlayerHammerDOriginYTable
        jr      .set
.U:
        ld      hl, r9_PlayerHammerUOriginYTable

.set:
        ld      a, [var_player_kf]
        ld      c, a
        ld      b, 0

        add     hl, bc
        ld      b, [hl]
        ld      a, b
        cp      128
        jr      C, .add
.sub:
        cpl
        inc     a
        ld      b, a
        ld      a, [var_player_anchor_y]
        add     b
        ld      [var_player_coord_y], a
        ret
.add:
        ld      a, [var_player_anchor_y]
        sub     b
        ld      [var_player_coord_y], a
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerDropHammerSetXOrigin:
        ld      a, [var_player_fb]
        cp      SPRID_PLAYER_HAMMER_L
        jr      Z, .L
        cp      SPRID_PLAYER_HAMMER_R
        jr      Z, .R

        ld      a, [var_player_anchor_x]
        ld      [var_player_coord_x], a
        ret

.L:
        ld      hl, r9_PlayerHammerLOriginXTable
        jr      .set
.R:
        ld      hl, r9_PlayerHammerROriginXTable


.set:
        ld      a, [var_player_kf]
        ld      c, a
        ld      b, 0

        add     hl, bc
        ld      b, [hl]
        ld      a, b
        cp      128
        jr      C, .add
.sub:
        cpl
        inc     a
        ld      b, a
        ld      a, [var_player_anchor_x]
        add     b
        ld      [var_player_coord_x], a
        ret
.add:
        ld      a, [var_player_anchor_x]
        sub     b
        ld      [var_player_coord_x], a
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerDropHammerImpl:
        fcall   r9_PlayerUpdateInjuredColor
        fcall   r9_PlayerMessageLoop

	ld      a, [var_player_kf]
        ld      c, a
        ld      b, 0
        ld      hl, r9_PlayerHammerFrameTimes
        add     hl, bc
        ld      c, [hl]

        ld      hl, var_player_animation
        ld      d, 11
        fcall   AnimationAdvance
        or      a
        jr      NZ, .frameChanged
        ret

.frameChanged:

        ld      a, [var_player_kf]
        cp      0
        jr      Z, .return
        cp      9
        jr      NZ, .skip0

        ;; Frame 9: hammer lands on ground, broadcast
        fcall   r9_PlayerHammerAttackBroadcast

        jr      .skip
.skip0:
        cp      10
        jr      NZ, .skip

	ld      b, 3
        WIDE_CALL r1_StartScreenshake

.skip:
        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

        fcall   r9_PlayerDropHammerSetXOrigin
        fcall   r9_PlayerDropHammerSetYOrigin
        ret

.return:
        ld      hl, var_player_struct
        ld      de, PlayerDropHammerRecover
        fcall   EntitySetUpdateFn

        xor     a
        ld      [var_player_tmr], a
        ret



;;; ----------------------------------------------------------------------------


r9_PlayerDepleteStamina:
;;; b - amount
;;; c - fraction

;;; Test large unit in Fixnum to determine whether subtraction would drop
;;; stamina below zero.
        ld      hl, var_player_stamina
        inc     hl
        inc     hl

        ld      a, [hl]
        push    af

        ld      hl, var_player_stamina
        fcall   FixnumSub

        pop     af

        cp      d
        jr      NZ, .exhausted

        ret

.exhausted:
	ld      de, RestoreCheckpointSceneUpdate
        fcall   SceneSetUpdateFn
        ld      de, VoidVBlankFn
        fcall   SceneSetVBlankFn

        jp      SceneUnwind


;;; ----------------------------------------------------------------------------


r9_PlayerWalkDepleteStamina:
        ld      a, [var_blizzard_active]
        or      a
        jr      NZ, .blizzard

	ld      b, 0
        ld      c, 3
        fcall   r9_PlayerDepleteStamina
        ret

.blizzard:
        ld      b, 0
        ld      c, 14
        fcall   r9_PlayerDepleteStamina
        ret


;;; ----------------------------------------------------------------------------

r9_PlayerSpiderBiteAttackDepleteStamina:
        ld      hl, SPIDER_BITE_ATTACK_BASE_DAMAGE
        ld      a, [var_level]
        ld      c, a
        ld      b, SPIDER_ATTACK_LEVEL
        fcall   CalculateDamage
        fcall   FormatDamage
        fcall   r9_PlayerDepleteStamina
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerBoarAttackDepleteStamina:
        ld      hl, BOAR_ATTACK_BASE_DAMAGE
        fcall   r9_BoarAttackLevel
        ld      b, a
        ld      a, [var_level]
        ld      c, a
        fcall   CalculateDamage
        fcall   FormatDamage
        fcall   r9_PlayerDepleteStamina
        ret


;;; ----------------------------------------------------------------------------

r9_PlayerWolfAttackDepleteStamina:
        ld      hl, GREYWOLF_ATTACK_BASE_DAMAGE
        fcall   r9_GreywolfAttackLevel
        ld      b, a
        ld      a, [var_level]
        ld      c, a
        fcall   CalculateDamage
        fcall   FormatDamage
        fcall   r9_PlayerDepleteStamina
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerKnifeAttackDepleteStamina:
        ld      b, 0
        ld      c, 48
        fcall   r9_PlayerDepleteStamina
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerUpdateAttack1Impl:
        fcall   r9_PlayerUpdateInjuredColor
        fcall   r9_PlayerMessageLoop

        fcall   r9_PlayerAttackMovement

        fcall   r9_PlayerAttackSetFacing
        ld      hl, var_player_animation
        ld      c, 7
        ld      d, 15
        fcall   AnimationAdvance
        or      a
        jr      NZ, .frameChanged
        ret

.frameChanged:
        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

        ld      a, [var_player_kf]
        cp      3
        jr      NZ, .skip

        fcall   r9_PlayerKnifeAttackBroadcast
.skip:

        ld      a, [var_player_kf]
        cp      4
        jr      Z, .checkBtn
        ret

.checkBtn:
        ldh     a, [hvar_joypad_raw]
        bit     PADB_B, a

        jr      NZ, .next

        ld      hl, var_player_struct
        ld      de, PlayerAttack1Exit
        fcall   EntitySetUpdateFn

        ret

.next:
        ld      hl, var_player_struct
        ld      de, PlayerUpdateAttack2
        fcall   EntitySetUpdateFn

        fcall   r9_PlayerKnifeAttackDepleteStamina

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerUpdateAttack2Impl:
        fcall   r9_PlayerUpdateInjuredColor
        fcall   r9_PlayerMessageLoop

        fcall   r9_PlayerAttackMovement

        fcall   r9_PlayerAttackSetFacing
        ld      hl, var_player_animation
        ld      c, 7
        ld      d, 15
        fcall   AnimationAdvance
        or      a
        jr      NZ, .frameChanged
        ret

.frameChanged:
        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

        ld      a, [var_player_kf]
        cp      7
        jr      NZ, .skip

        fcall   r9_PlayerKnifeAttackBroadcast
.skip:

        ld      a, [var_player_kf]
        cp      8
        jr      Z, .checkBtn
        ret

.checkBtn:
        ldh     a, [hvar_joypad_raw]
        bit     PADB_B, a

        jr      NZ, .next

        ld      hl, var_player_struct
        ld      de, PlayerAttack2Exit
        fcall   EntitySetUpdateFn

        ret

.next:
        ld      hl, var_player_struct
        ld      de, PlayerUpdateAttack3
        fcall   EntitySetUpdateFn

	fcall   r9_PlayerKnifeAttackDepleteStamina

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerUpdateAttack3Impl:
        fcall   r9_PlayerUpdateInjuredColor
        fcall   r9_PlayerMessageLoop

        fcall   r9_PlayerAttackMovement

        fcall   r9_PlayerAttackSetFacing
        ld      hl, var_player_animation
        ld      c, 7
        ld      d, 15
        fcall   AnimationAdvance
        or      a
        jr      NZ, .frameChanged
        ret

.frameChanged:
        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

        ld      a, [var_player_kf]
        cp      12
        jr      NZ, .skip

        fcall   r9_PlayerKnifeAttackBroadcast
.skip:

        ld      a, [var_player_kf]
        cp      14
        jr      Z, .done
        ret

.done:
        ld      hl, var_player_struct
        ld      de, PlayerAttack3Exit
        fcall   EntitySetUpdateFn

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttackTryExit:
;;; de - potential resume dest
        ld      a, [hvar_joypad_raw]
        bit     PADB_B, a

        jr      NZ, .resume


        ld      a, [var_player_tmr]
        inc     a
        cp      14
        jr      Z, .next
        ld      [var_player_tmr], a

        ret

.resume:
        ld      hl, var_player_struct
        fcall   EntitySetUpdateFn

	fcall   r9_PlayerKnifeAttackDepleteStamina

        ld      a, 0
        ld      [var_player_tmr], a

        ret

.next:
        ld      a, [var_player_fb]
        cp      SPRID_PLAYER_KNIFE_ATK_U
        jr      Z, .up
        cp      SPRID_PLAYER_KNIFE_ATK_L
        jr      Z, .left
        cp      SPRID_PLAYER_KNIFE_ATK_R
        jr      Z, .right

        ld      a, SPRID_PLAYER_SD
        jr      .set
.up:
        ld      a, SPRID_PLAYER_SU
        jr      .set
.left:
        ld      a, SPRID_PLAYER_SL
        jr      .set
.right:
        ld      a, SPRID_PLAYER_SR

.set:
        ld      [var_player_fb], a
        ld      a, 0
        ld      [var_player_kf], a
        ld      [var_player_tmr], a

        ld      hl, var_player_struct
        ld      de, PlayerUpdate
        fcall   EntitySetUpdateFn

        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      [var_player_swap_spr], a

        ld      a, SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttack1ExitImpl:
        fcall   r9_PlayerAttackMovement

        ld      de, PlayerUpdateAttack2
        fcall   r9_PlayerAttackTryExit
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttack2ExitImpl:
        fcall   r9_PlayerAttackMovement

        ld      de, PlayerUpdateAttack3
        fcall   r9_PlayerAttackTryExit
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttack3ExitImpl:
        fcall   r9_PlayerAttackMovement

        ld      de, PlayerUpdateAttack1
        fcall   r9_PlayerAttackTryExit
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerUpdateInjuredColor:
        ld      a, [var_player_color_counter]
        cp      0
        jr      Z, .skip
        cp      1
        jr      Z, .done

        dec     a
        ld      [var_player_color_counter], a
        ld      a, 7
        ld      [var_player_palette], a
        ret

.done:
        ld      a, 0
        ld      [var_player_palette], a
        ld      [var_player_color_counter], a
.skip:
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerPopulateFootprint:
;;; hl - hitbox to fill with data

        ld      a, [var_player_coord_x]
        add     8
        ld      b, a
        ld      [hl+], a
        ld      a, [var_player_coord_y]
        add     12
        ld      c, a
        ld      [hl+], a

        ld      a, 8
        add     b
        ld      [hl+], a
        ld      a, 8
        add     c
        ld      [hl], a

        ret



r9_PlayerPopulateHitbox:
;;; hl - hitbox to fill with data

        ld      a, [var_player_coord_x]
        add     8
        ld      b, a
        ld      [hl+], a
        ld      a, [var_player_coord_y]
        add     4
        ld      c, a
        ld      [hl+], a

        ld      a, 16
        add     b
        ld      [hl+], a
        ld      a, 24
        add     c
        ld      [hl], a

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerKnifeAttackPopulateHitbox:
;;; hl - hitbox to fill with data
        ld      a, [var_player_coord_x]
        add     4
        ld      b, a
        ld      [hl+], a
        ld      a, [var_player_coord_y]
        add     10
        ld      c, a
        ld      [hl+], a

        ld      a, 24
        add     b
        ld      [hl+], a
        ld      a, 19
        add     c
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------

r9_PlayerHammerAttackPopulateHitbox:
;;; hl - hitbox to fill with data
;;; a - player sprite id
        cp      SPRID_PLAYER_HAMMER_L
        jr      Z, .left
        cp      SPRID_PLAYER_HAMMER_D
        jr      Z, .down
        cp      SPRID_PLAYER_HAMMER_U
        jr      Z, .up

.right:
        ld      a, [var_player_coord_x]
        add     12
        ld      b, a
        ld      [hl+], a
        ld      a, [var_player_coord_y]
        add     10
        ld      c, a
        ld      [hl+], a
        jr      .setSize
.left:
        ld      a, [var_player_coord_x]
        sub     12
        ld      b, a
        ld      [hl+], a
        ld      a, [var_player_coord_y]
        add     10
        ld      c, a
        ld      [hl+], a
        jr      .setSize
.up:
        ld      a, [var_player_coord_x]
        sub     12
        ld      b, a
        ld      [hl+], a
        ld      a, [var_player_coord_y]
        add     10
        ld      c, a
        ld      [hl+], a
        jr      .setSize
.down:
        ld      a, [var_player_coord_x]
        add     12
        ld      b, a
        ld      [hl+], a
        ld      a, [var_player_coord_y]
        add     10
        ld      c, a
        ld      [hl+], a

.setSize:
        ld      a, 24
        add     b
        ld      [hl+], a
        ld      a, 19
        add     c
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------

r9_PlayerSetIdleSprite:
;;; trashes a, bc, hl
        ld      hl, var_player_struct
        fcall   EntityGetFrameBase
        ld      a, b

        cp      SPRID_PLAYER_SR
        ret     Z
        cp      SPRID_PLAYER_SL
        ret     Z
        cp      SPRID_PLAYER_SU
        ret     Z
        cp      SPRID_PLAYER_SD
        ret     Z

        fcall   EntityAnimationResetKeyframe
        ld      a, ENTITY_FLAG0_TEXTURE_SWAP
        ld      b, [hl]
        or      b
        ld      [hl], a

        fcall   EntityGetFrameBase
        ld      a, b

        cp      SPRID_PLAYER_WR
        jr      Z, .idle_right

        cp      SPRID_PLAYER_WL
        jr      Z, .idle_left

        cp      SPRID_PLAYER_WU
        jr      Z, .idle_up

        cp      SPRID_PLAYER_KNIFE_ATK_R
        jr      Z, .idle_right

        cp      SPRID_PLAYER_KNIFE_ATK_L
        jr      Z, .idle_left

        cp      SPRID_PLAYER_KNIFE_ATK_U
        jr      Z, .idle_up

        cp      SPRID_PLAYER_HAMMER_L
        jr      Z, .idle_left

        cp      SPRID_PLAYER_HAMMER_R
        jr      Z, .idle_right

        cp      SPRID_PLAYER_HAMMER_U
        jr      Z, .idle_up

.idle_down:
        ;; NOTE: player face down as the base case, so we do not compare any of
        ;; the down-facing sprites above.
        ld      a, SPRID_PLAYER_SD
        fcall   EntitySetFrameBase
        ret

.idle_right:
        ld      a, SPRID_PLAYER_SR
        fcall   EntitySetFrameBase
        ret

.idle_left:
        ld      a, SPRID_PLAYER_SL
        fcall   EntitySetFrameBase
        ret

.idle_up:
        ld      a, SPRID_PLAYER_SU
        fcall   EntitySetFrameBase
        ret



;;; ----------------------------------------------------------------------------

r9_PlayerDialogIdleImpl:
        fcall   r9_PlayerMessageLoop
        fcall   r9_PlayerUpdateInjuredColor
        ret


;;; ----------------------------------------------------------------------------
