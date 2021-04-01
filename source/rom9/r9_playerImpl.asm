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


WALL_TILES_END  EQU     16


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


r9_PlayerUpdateMovement:
        ld      a, [var_player_coord_x]
        ld      [var_wall_collision_source_x], a
        ld      a, [var_player_coord_y]
        ld      [var_wall_collision_source_y], a
        call    r9_WallCollisionCheck


;;; try walk left
        ld      a, [var_wall_collision_result]  ; Load collision mask
        and     COLLISION_LEFT
        ld      [var_player_spill2], a  ; Store part of mask in temp var

        ld      hl, var_player_coord_x
        ld      b, 0

        ldh     a, [var_joypad_raw]
        and     PADF_DOWN | PADF_UP
        ld      c, a

        ldh     a, [var_joypad_raw]
        and     PADF_LEFT
        ld      e, SPRID_PLAYER_WL
        call    r9_PlayerJoypadResponse



;;; try walk right
        ld      a, [var_wall_collision_result]  ; Load collision mask
        and     COLLISION_RIGHT
        ld      [var_player_spill2], a  ; Store part of mask in temp var

        ld      hl, var_player_coord_x
        ld      b, 1

        ;; c param is unchanged for this next call
        ldh     a, [var_joypad_raw]
        and     PADF_RIGHT
        ld      e, SPRID_PLAYER_WR
        call    r9_PlayerJoypadResponse



;;; try walk down
        ld      a, [var_wall_collision_result]  ; Load collision mask
        and     COLLISION_DOWN
        ld      [var_player_spill2], a  ; Store part of mask in temp var

	ld      hl, var_player_coord_y
        ld      b, 1

        ldh     a, [var_joypad_raw]
        and     PADF_LEFT | PADF_RIGHT
        ld      c, a

        ldh     a, [var_joypad_raw]
	and     PADF_DOWN
        ld      e, SPRID_PLAYER_WD
        call    r9_PlayerJoypadResponse



;;; try walk up
        ld      a, [var_wall_collision_result]  ; Load collision mask
        and     COLLISION_UP
        ld      [var_player_spill2], a  ; Store part of mask in temp var

	ld      hl, var_player_coord_y
        ld      b, 0

        ldh     a, [var_joypad_raw]
	and     PADF_UP
        ld      e, SPRID_PLAYER_WU
        call    r9_PlayerJoypadResponse

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
        ld      a, ENTITY_TEXTURE_SWAP_FLAG
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
        jr      Z, .done

        ld      a, c
        or      a
        jr      Z, .n2
        jr      .setSpeed

.n2:
        ld      a, [var_player_fb]
        cp      e
        jr      Z, .setSpeed    ; the base frame is unchanged

        ld      a, ENTITY_TEXTURE_SWAP_FLAG
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
        ld      a, ENTITY_TEXTURE_SWAP_FLAG
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
        ld      b, 1
        ld      c, 40
        jr      .moveFwd
.moveDiagonalFwd:
        ld      b, 0
        ld      c, 206
.moveFwd:

        call    FixnumAdd
        pop     bc
        jr      .done
.subPosition:

        ld      a, c
        or      a

        jr      NZ, .moveDiagonalRev
        ld      b, 1
        ld      c, 40
        jr      .moveRev
.moveDiagonalRev:
        ld      b, 0
        ld      c, 206
.moveRev:

        ld      b, 1
        ld      c, 40
        call    FixnumSub
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

        ;; TODO... currently, we're ignoring all messages.
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
        call    r9_GreywolfPopulateHitbox

        ld      hl, var_temp_hitbox1
        call    r9_PlayerPopulateHitbox


        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        call    CheckIntersection

        or      a
        jr      Z, .skip

        call    r9_PlayerWolfAttackDepleteStamina

        ld      a, 25
        ld      [var_player_color_counter], a
.skip:
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerMessageLoop:
        ;; NOTE: This is fine, because the player will always use message queue
        ;; id zero, so we don't need to add any offsets, we can just load the
        ;; beginning of the message queue memory in ram.
        ld      hl, var_message_queue_memory

        ld      bc, r9_PlayerOnMessage
	call    MessageQueueDrain
        ret


;;; ----------------------------------------------------------------------------

r9_PlayerUpdateImpl:
        call    r9_PlayerMessageLoop

        call    r9_PlayerUpdateInjuredColor

        call    r9_PlayerUpdateMovement

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
        ld      a, ENTITY_TEXTURE_SWAP_FLAG
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
        ld      a, ENTITY_TEXTURE_SWAP_FLAG
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
        ld      a, ENTITY_TEXTURE_SWAP_FLAG
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
        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [var_player_swap_spr], a

.animate:
        ld      a, [var_joypad_raw]
        or      a
        jr      Z, .done

	call    r9_PlayerWalkDepleteStamina

	call    r9_PlayerAnimate

        ldh     a, [var_joypad_current]
        bit     PADB_A, a
        jr      Z, .checkB
        ld      a, [var_wall_collision_result]
        or      a
        jr      Z, .tryInteractEntities
        call    r9_PlayerTryInteract
        jr      .done

.checkB:
        bit     PADB_B, a
        jr      Z, .done
        call    r9_PlayerAttackInit

.done:
        ret

.tryInteractEntities:
        call    r9_PlayerInteractBroadcast
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
        call    r9_PlayerInteractBroadcast
        ret

.tryInteractLeft:
        ld      a, [var_wall_collision_result]
        and     COLLISION_LEFT
        jr      Z, .tryInteractEntities

	call    r9_PlayerTileCoord
        dec     a
        ld      d, SPRID_PLAYER_PL
        call    r9_PlayerInteractTile

        ret

.tryInteractRight:
        ld      a, [var_wall_collision_result]
        and     COLLISION_RIGHT
        jr      Z, .tryInteractEntities

	call    r9_PlayerTileCoord
        inc     a
        ld      d, SPRID_PLAYER_PR
        call    r9_PlayerInteractTile

        ret

.tryInteractUp:
        ld      a, [var_wall_collision_result]
        and     COLLISION_UP
        jr      Z, .tryInteractEntities

	call    r9_PlayerTileCoord
        dec     b
        ld      d, SPRID_PLAYER_PU
        call    r9_PlayerInteractTile

        ret

.tryInteractDown:
        ld      a, [var_wall_collision_result]
        and     COLLISION_DOWN
        jr      Z, .tryInteractEntities

	call    r9_PlayerTileCoord
        inc     b
        ld      d, SPRID_PLAYER_PD
        call    r9_PlayerInteractTile

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
        call    MapGetTile

	ld      a, COLLECTIBLE_TILE_TEST
        cp      b               ; FIXME...
        jr      NZ, .done

        ld      hl, var_player_struct
        ld      de, PlayerUpdatePickupItem
        call    EntitySetUpdateFn

        pop     de

        call    r9_PlayerPickupAnimationInit

.done:
        ret


;;; ----------------------------------------------------------------------------

r9_PlayerPickupAnimationInit:
;;; d - pickup animation frame base
        ld      a, d
        ld      [var_player_fb], a

        ld      a, 0
        ld      [var_player_kf], a

        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [var_player_swap_spr], a

        ret


;;; ----------------------------------------------------------------------------

r9_PlayerUpdatePickupItemImpl:
        ld      hl, var_player_animation
        ld      c, 7
        ld      d, 5
        call    AnimationAdvance
        or      a
        jr      NZ, .frameChanged
        ret

.frameChanged:
        ld      a, 1 | SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a

        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [var_player_swap_spr], a

        ld      a, [var_player_kf]
        cp      0                       ; Animation complete if we've looped
        jr      Z, .animationComplete

        cp      4
        jr      NZ, .skip

        call    r9_CollectMapItem

.skip:
        ret

.animationComplete:
        ld      hl, var_player_struct
        ld      de, PlayerUpdate
        call    EntitySetUpdateFn

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

r9_SetItemCollected:
        ld      b, 0
        ld      hl, var_map_collectibles
.loop:
        ld      a, 8
        cp      b
        jr      Z, .endLoop

        ld      a, [var_collect_item_xy]
        ld      c, [hl]
        cp      c
        jr      NZ, .next

        inc     hl
        ld      a, 0
        ld      [hl], a
        jr      .endLoop

.next:
        inc     b
        inc     hl
        inc     hl
        jr      .loop
.endLoop:

        ret


;;; ----------------------------------------------------------------------------


r9_CollectMapItem:
        ld      b, 7
.waitLoop:
        call    VBlankIntrWait
        dec     b
        ld      a, 0
        cp      b
        jr      NZ, .waitLoop

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

        ld      e, $d4                  ; TODO: Define constant for this empty tile
        ld      c, 2

        call    SetBackgroundTile16x16

	pop     de                      ; \ Restore coordinate
        pop     af                      ; /

        ld      hl, var_map_info
        ld      b, d                    ; Pass y in reg b
        ld      d, 18                   ; TODO: Define constant for this empty tile
        call    MapSetTile


        ld      b, ITEM_POTATO          ; Fixme!
        call    InventoryAddItem

        call    r9_SetItemCollected

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttackInit:
	call    r9_PlayerKnifeAttackDepleteStamina

        ld      hl, var_player_struct
        ld      de, PlayerUpdateAttack1
        call    EntitySetUpdateFn

        ld      a, 0
        ld      [var_player_kf], a

        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [var_player_swap_spr], a

        ld      a, 1 | SPRITE_SHAPE_SQUARE_32
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
        ld      a, [var_joypad_current]
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

        call    MessageBusBroadcast

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

        call    MessageBusBroadcast

        pop     bc              ; \ Pop message arg from stack
        pop     bc              ; /

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttackMovement:
        ld      a, [var_player_coord_x]
        ld      [var_wall_collision_source_x], a
        ld      a, [var_player_coord_y]
        ld      [var_wall_collision_source_y], a
        call    r9_WallCollisionCheck

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
        ldh     a, [var_joypad_raw]
        bit     PADB_DOWN, a
        jr      Z, .skipMoveDown
        ld      a, [var_wall_collision_result]
        and     COLLISION_DOWN
        jr      NZ, .skipMoveDown

        ld      hl, var_player_coord_y
        ld      b, 0
        ld      c, 30
        call    FixnumAdd

.skipMoveDown:
        ret


.checkMoveUp:
	ld      a, [var_joypad_raw]
        bit     PADB_UP, a
        jr      Z, .skipMoveUp
        ld      a, [var_wall_collision_result]
        and     COLLISION_UP
        jr      NZ, .skipMoveUp

        ld      hl, var_player_coord_y
        ld      b, 0
        ld      c, 30
        call    FixnumSub

.skipMoveUp:
        ret


.checkMoveRight:
	ld      a, [var_joypad_raw]
        bit     PADB_RIGHT, a
        jr      Z, .skipMoveRight
        ld      a, [var_wall_collision_result]
        and     COLLISION_RIGHT
        jr      NZ, .skipMoveRight

        ld      hl, var_player_coord_x
        ld      b, 0
        ld      c, 30
        call    FixnumAdd

.skipMoveRight:
        ret


.checkMoveLeft:
	ld      a, [var_joypad_raw]
        bit     PADB_LEFT, a
        jr      Z, .skipMoveLeft
        ld      a, [var_wall_collision_result]
        and     COLLISION_LEFT
        jr      NZ, .skipMoveLeft

        ld      hl, var_player_coord_x
        ld      b, 0
        ld      c, 30
        call    FixnumSub

.skipMoveLeft:
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
        call    FixnumSub

        pop     af

        cp      d
        jr      NZ, .exhausted

        ret

.exhausted:
	call    SystemReboot    ; FIXME...
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerWalkDepleteStamina:
	ld      b, 0
        ld      c, 10
        call    r9_PlayerDepleteStamina
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerWolfAttackDepleteStamina:
        ld      b, 20
        ld      c, 70
        call    r9_PlayerDepleteStamina
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerKnifeAttackDepleteStamina:
        ld      b, 0
        ld      c, 48
        call    r9_PlayerDepleteStamina
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerUpdateAttack1Impl:
        call    r9_PlayerUpdateInjuredColor
        call    r9_PlayerMessageLoop

        call    r9_PlayerAttackMovement

        call    r9_PlayerAttackSetFacing
        ld      hl, var_player_animation
        ld      c, 7
        ld      d, 15
        call    AnimationAdvance
        or      a
        jr      NZ, .frameChanged
        ret

.frameChanged:
        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [var_player_swap_spr], a

        ld      a, [var_player_kf]
        cp      3
        jr      NZ, .skip

        call    r9_PlayerKnifeAttackBroadcast
.skip:

        ld      a, [var_player_kf]
        cp      4
        jr      Z, .checkBtn
        ret

.checkBtn:
        ldh     a, [var_joypad_raw]
        bit     PADB_B, a

        jr      NZ, .next

        ld      hl, var_player_struct
        ld      de, PlayerAttack1Exit
        call    EntitySetUpdateFn

        ret

.next:
        ld      hl, var_player_struct
        ld      de, PlayerUpdateAttack2
        call    EntitySetUpdateFn

        call    r9_PlayerKnifeAttackDepleteStamina

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerUpdateAttack2Impl:
        call    r9_PlayerUpdateInjuredColor
        call    r9_PlayerMessageLoop

        call    r9_PlayerAttackMovement

        call    r9_PlayerAttackSetFacing
        ld      hl, var_player_animation
        ld      c, 7
        ld      d, 15
        call    AnimationAdvance
        or      a
        jr      NZ, .frameChanged
        ret

.frameChanged:
        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [var_player_swap_spr], a

        ld      a, [var_player_kf]
        cp      7
        jr      NZ, .skip

        call    r9_PlayerKnifeAttackBroadcast
.skip:

        ld      a, [var_player_kf]
        cp      8
        jr      Z, .checkBtn
        ret

.checkBtn:
        ldh     a, [var_joypad_raw]
        bit     PADB_B, a

        jr      NZ, .next

        ld      hl, var_player_struct
        ld      de, PlayerAttack2Exit
        call    EntitySetUpdateFn

        ret

.next:
        ld      hl, var_player_struct
        ld      de, PlayerUpdateAttack3
        call    EntitySetUpdateFn

	call    r9_PlayerKnifeAttackDepleteStamina

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerUpdateAttack3Impl:
        call    r9_PlayerUpdateInjuredColor
        call    r9_PlayerMessageLoop

        call    r9_PlayerAttackMovement

        call    r9_PlayerAttackSetFacing
        ld      hl, var_player_animation
        ld      c, 7
        ld      d, 15
        call    AnimationAdvance
        or      a
        jr      NZ, .frameChanged
        ret

.frameChanged:
        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [var_player_swap_spr], a

        ld      a, [var_player_kf]
        cp      12
        jr      NZ, .skip

        call    r9_PlayerKnifeAttackBroadcast
.skip:

        ld      a, [var_player_kf]
        cp      14
        jr      Z, .done
        ret

.done:
        ld      hl, var_player_struct
        ld      de, PlayerAttack3Exit
        call    EntitySetUpdateFn

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttackTryExit:
;;; de - potential resume dest
        ld      a, [var_joypad_raw]
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
        call    EntitySetUpdateFn

	call    r9_PlayerKnifeAttackDepleteStamina

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
        call    EntitySetUpdateFn

        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [var_player_swap_spr], a

        ld      a, 1 | SPRITE_SHAPE_TALL_16_32
        ld      [var_player_display_flag], a

        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttack1ExitImpl:
        call    r9_PlayerAttackMovement

        ld      de, PlayerUpdateAttack2
        call    r9_PlayerAttackTryExit
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttack2ExitImpl:
        call    r9_PlayerAttackMovement

        ld      de, PlayerUpdateAttack3
        call    r9_PlayerAttackTryExit
        ret


;;; ----------------------------------------------------------------------------


r9_PlayerAttack3ExitImpl:
        call    r9_PlayerAttackMovement

        ld      de, PlayerUpdateAttack1
        call    r9_PlayerAttackTryExit
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
        ;; ld      a, [var_player_fb]
        ;; cp      SPRID_PLAYER_KNIFE_ATK_L
        ;; jr      Z, .left
        ;; cp      SPRID_PLAYER_KNIFE_ATK_R
        ;; jr      Z, .right
        ;; cp      SPRID_PLAYER_KNIFE_ATK_U
        ;; jr      Z, .up

        ld      a, [var_player_coord_x]
        ld      b, a
        ld      [hl+], a
        ld      a, [var_player_coord_y]
        ld      c, a
        ld      [hl+], a

        ld      a, 32
        add     b
        ld      [hl+], a
        ld      a, 32
        add     c
        ld      [hl], a
        ret

;; .left:
;;         ld      a, [var_player_coord_x]
;;         sub     4
;;         ld      b, a
;;         ld      [hl+], a
;;         ld      a, [var_player_coord_y]
;;         ld      c, a
;;         ld      [hl+], a

;;         ld      a, 16
;;         add     b
;;         ld      [hl+], a

;;         ld      a, 32
;;         add     c
;;         ld      [hl], a
;;         ret


;; .right:
;;         ld      a, [var_player_coord_x]
;;         add     20
;;         ld      b, a
;;         ld      [hl+], a
;;         ld      a, [var_player_coord_y]
;;         ld      c, a
;;         ld      [hl+], a

;;         ld      a, 16
;;         add     b
;;         ld      [hl+], a

;;         ld      a, 32
;;         add     c
;;         ld      [hl], a
;;         ret

;; .up:
        ;; call    r9_PlayerPopulateHitbox ;todo
;;         ret

;; .down:
;;         call    r9_PlayerPopulateHitbox ;todo
        ret


;;; ----------------------------------------------------------------------------
