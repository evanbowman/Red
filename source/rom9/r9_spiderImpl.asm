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


SPIDER_SLAB_WEIGHT      EQU 3
SPIDER_MOVE_SPEED_DECIMAL       EQU 0
SPIDER_MOVE_SPEED_FRACTION      EQU 220

X_DEST_NULL     EQU     255


;;; ----------------------------------------------------------------------------

r9_SpiderUpdateImpl:
        ld      h, b
        ld      l, c

        ld      de, SpiderUpdateSeekY
        fcall   EntitySetUpdateFn

        fcall   r9_SpiderTryAttack

        ld      e, 6
        ld      d, 5
        fcall   EntityAnimationAdvance

        fcall   r9_SpiderUpdateColor
        fcall   r9_SpiderMessageLoop
        ret


;;; ----------------------------------------------------------------------------

r9_SpiderUpdateDeadImpl:
        ld      h, b
        ld      l, c

        push    hl

        fcall   EntityGetMessageQueue
        fcall   MessageQueueLoad

        pop     de
        ld      bc, .onMessage
        fcall   MessageQueueDrain

        ret

.onMessage:
;;; bc - message pointer
;;; de - self
        ld      a, [bc]
        cp      MESSAGE_PLAYER_INTERACT
        jr      Z, .onPlayerInteract
        ret

.onPlayerInteract:
        ld      h, d
        ld      l, e

        push    hl
        fcall   EntityGetPos
        ld      hl, var_temp_hitbox1
        fcall   r9_SpiderPopulateHitbox

        ld      hl, var_temp_hitbox2
        fcall   r9_PlayerPopulateHitbox

        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        pop     hl
        ret     NC

        push    hl
        ld      de, ScavengeSceneEnter
        fcall   SceneSetUpdateFn
        pop     hl

        call    r9_SpiderSetupScavenge

        ret


;;; ----------------------------------------------------------------------------

r9_SpiderSetupScavenge:
;;; hl - self
        ld      a, h                         ; \
        ld      [var_scavenge_target], a     ; |
        inc     bc                           ; | Store self pointer in ram.
        ld      a, l                         ; |
        ld      [var_scavenge_target + 1], a ; /

        ld      a, ITEM_NONE
        ld      [var_scavenge_slot_0], a
        ld      [var_scavenge_slot_1], a

        fcall   EntityGetFullType
        bit     6, a
        ret     Z

        ld      a, ITEM_MORSEL
        ld      [var_scavenge_slot_0], a

        ret


;;; ----------------------------------------------------------------------------

r9_SpiderGetXDest:
;;; hl - self
;;; return a
        push    bc
        ld      bc, SPIDER_VAR_X_DEST
        fcall   EntityGetSlack
        ld      a, [bc]
        pop     bc
        ret


;;; ----------------------------------------------------------------------------

r9_SpiderUpdatePrepSeekXImpl:
        ld      h, b
        ld      l, c

        push    hl
        fcall   r9_SpiderMessageLoop
        pop     hl

        ld      bc, SPIDER_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        dec     a
        ld      [bc], a
        cp      0
        jr      Z, .next
        ret
.next:
        ld      de, SpiderUpdateSeekX
        fcall   EntitySetUpdateFn

        ld      bc, SPIDER_VAR_X_DEST
        fcall   EntityGetSlack
        ld      a, [bc]
        cp      X_DEST_NULL
        jr      Z, .assign
        ret

.assign:
        ld      a, [var_player_coord_x]
        ld      [bc], a
        ret


;;; ----------------------------------------------------------------------------

r9_SpiderUpdateSeekXImpl:
        ld      h, b
        ld      l, c

        push    hl
        fcall   r9_SpiderSetupCollisionRect
        fcall   r9_WallCollisionCheckHorizontalOnly
        pop     hl

        fcall   r9_SpiderMoveX

        ld      e, 6
        ld      d, 5
        fcall   EntityAnimationAdvance

        fcall   r9_SpiderUpdateColor
        fcall   r9_SpiderMessageLoop

        ret


;;; ----------------------------------------------------------------------------

r9_SpiderUpdateSeekYImpl:
        ld      h, b
        ld      l, c

        push    hl
        fcall   r9_SpiderSetupCollisionRect
        fcall   r9_WallCollisionCheckVerticalOnly
        pop     hl

        fcall   r9_SpiderMoveY

        ld      e, 6
        ld      d, 5
        fcall   EntityAnimationAdvance

	fcall   r9_SpiderUpdateColor
        fcall   r9_SpiderMessageLoop

        ret


;;; ----------------------------------------------------------------------------

r9_SpiderUpdateAttackingImpl:
        ld      h, b
        ld      l, c

        fcall   r9_SpiderUpdateAttack

	fcall   r9_SpiderUpdateColor
        fcall   r9_SpiderMessageLoop
        ret

r9_SpiderUpdateAttack:
        ld      e, 6
        ld      d, 5
        fcall   EntityAnimationAdvance
	ld      a, d
        or      a
        ret     Z

        fcall   EntityAnimationGetKeyframe
        cp      0
        jr      Z, .idle
	cp      4
        jr      Z, .sendAttack
        ret

.idle:
        ld      de, SpiderUpdateAfterAttack
        fcall   EntitySetUpdateFn

        ld      bc, SPIDER_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, 10
        ld      [bc], a

        fcall   EntitySetTextureSwapFlag

        fcall   EntityGetFrameBase
        ld      a, b
        cp      SPRID_SPIDER_ATTACK_L
        jr      Z, .faceLeft

.faceRight:
        ld      a, SPRID_SPIDER_R
        fcall   EntitySetFrameBase
        ret

.faceLeft:
        ld      a, SPRID_SPIDER_L
        fcall   EntitySetFrameBase
        ret

.sendAttack:
        fcall   EntityGetPos
        ld      hl, var_temp_hitbox2
        fcall   r9_SpiderPopulateHitbox

        ld      hl, var_temp_hitbox1
        fcall   r9_PlayerPopulateHitbox

        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        ret     NC

        ld      a, 25
        ld      [var_player_color_counter], a

        fcall   r9_PlayerSpiderBiteAttackDepleteStamina

        ld      b, 1
        WIDE_CALL r1_StartScreenshake

        ret


;;; ----------------------------------------------------------------------------

r9_SpiderUpdateAfterAttackImpl:
        ld      h, b
        ld      l, c

        ld      bc, SPIDER_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        dec     a
        ld      [bc], a
        cp      0
        jr      Z, .idle
        ret
.idle:
        ld      de, SpiderUpdate
        fcall   EntitySetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

r9_SpiderMoveX:
        fcall   EntityGetPos
        fcall   r9_SpiderGetXDest
        push    bc

        fcall   r9_absdiff      ; \
        pop     bc              ; | If our x coord is close to the player's, try
        cp      12              ; | moving in the y direction
        jr      C, .moveY       ; /

	fcall   r9_SpiderGetXDest
        cp      b
        jr      C, .moveLeft

.moveRight:
        ld      a, [hvar_wall_collision_result]; \
        and     COLLISION_RIGHT                ; |
        jr      NZ, .moveY                     ; | Unless we're colliding with
                                               ; | a wall, move rightwards.
        push    hl                             ; |
        fcall   EntityGetXPos                  ; |
        ld      b, SPIDER_MOVE_SPEED_DECIMAL   ; |
        ld      c, SPIDER_MOVE_SPEED_FRACTION  ; |
        fcall   FixnumAdd                      ; |
        pop     hl                             ; |
                                               ; |
        ld      a, SPRID_SPIDER_R              ; |
        fcall   EntitySetFrameBase             ; /

.skip:
        ret

.moveLeft:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_LEFT
        jr      NZ, .moveY

        push    hl
        fcall   EntityGetXPos
        ld      b, SPIDER_MOVE_SPEED_DECIMAL
        ld      c, SPIDER_MOVE_SPEED_FRACTION
        fcall   FixnumSub
        pop     hl

        ld      a, SPRID_SPIDER_L
        fcall   EntitySetFrameBase
        ret

.moveY:
        ld      de, SpiderUpdateSeekY
        fcall   EntitySetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

r9_SpiderMoveY:
        ld      a, SPIDER_SLAB_WEIGHT
        ld      [var_entity_slab_weight], a
        fcall   r9_GetDestSlab

        ld      a, d

        swap    a
        sla     a

        fcall   EntityGetPos
	push    af
	push    bc
        ld      b, c
        fcall   r9_absdiff      ; \ Because otherwise, we can flop back and
        cp      2               ; / forth if we teeter on a fractional pixel.
        pop     bc
        jr      C, .alignSlabAndTryMoveHorizontally
        pop     af

        cp      c

        jr      C, .moveUp

        ld      a, [hvar_wall_collision_result]
        and     COLLISION_DOWN
        jr      NZ, .tryMoveHorizontally

        push    hl
        fcall   EntityGetYPos
        ld      b, SPIDER_MOVE_SPEED_DECIMAL
        ld      c, SPIDER_MOVE_SPEED_FRACTION
        fcall   FixnumAdd
        pop     hl
	ret

.alignSlabAndTryMoveHorizontally:
        ;; We've detected that we moved into a new slab. Pin our y-position to
        ;; the slab boundary, just in case it isn't exactly aligned.
        ;; (Entity movement uses fixnums, we could be not exactly aligned to the
        ;; beginning/end of a slab, and the overlapping pixels could create
        ;; graphical artifacts, besides breaking the program logic).
        fcall   EntityGetPos

        push    bc
        ld      bc, SPIDER_VAR_SLAB   ; \
        fcall   EntityGetSlack        ; | Fetch current slab num
        ld      a, [bc]               ; |
        pop     bc

        swap    a               ; \ slab_num * 32 == slab_y
        sla     a               ; /

        ld      c, a            ; adjusted y back into y coord
        fcall   EntitySetPos    ; b still holds result of EntityGetPos

.tryMoveHorizontally:
        pop     af
        fcall   EntityGetPos
        ld      a, [var_player_coord_x]
        fcall   r9_absdiff
        cp      13
        jr      C, .idle

        ld      de, SpiderUpdatePrepSeekX
        fcall   EntitySetUpdateFn

        ld      bc, SPIDER_VAR_X_DEST
        fcall   EntityGetSlack
        ld      a, X_DEST_NULL
        ld      [bc], a

        fcall   r9_EnemySendSlabPositionsQuery

        ld      bc, SPIDER_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, 2
        ld      [bc], a
        ret

.idle:
        ld      de, SpiderUpdate
        fcall   EntitySetUpdateFn
        fcall   EntityAnimationResetKeyframe

        ret

.moveUp:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_UP
        jr      NZ, .tryMoveHorizontally

        push    hl
        fcall   EntityGetYPos
        ld      b, SPIDER_MOVE_SPEED_DECIMAL
        ld      c, SPIDER_MOVE_SPEED_FRACTION
        fcall   FixnumSub
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

r9_SpiderSetupCollisionRect:
        fcall   EntityGetPos
        ld      a, b
        ld      [hvar_wall_collision_source_x], a
        ld      a, c
        ld      [hvar_wall_collision_source_y], a
        ld      a, 4
        ld      [hvar_wall_collision_size_x], a
        ld      a, 2
        ld      [hvar_wall_collision_size_y], a
        ret


;;; ----------------------------------------------------------------------------

r9_SpiderMessageLoop:
;;; trashes hl
        push    hl                      ; Store entity pointer on stack

        fcall   EntityGetMessageQueue
        fcall   MessageQueueLoad

        pop     de                      ; Pass entity pointer in de
        ld      bc, r9_SpiderOnMessage
	fcall   MessageQueueDrain

        ret


;;; ----------------------------------------------------------------------------

r9_SpiderOnMessage:
;;; bc - message pointer
;;; de - self
        ld      a, [bc]
        cp      a, MESSAGE_PLAYER_KNIFE_ATTACK
        jr      Z, .onPlayerKnifeAttack
        cp      a, MESSAGE_SLAB_ENEMY_QUERY
        jr      Z, .onMessageSlabQuery
        ret

.onMessageSlabQuery:
        ld      h, d
        ld      l, e

        inc     bc              ; \ Second message byte: slab number
        ld      a, [bc]         ; /
        ld      d, a

        push    bc              ; preserve message pointer
        ld      bc, SPIDER_VAR_SLAB
        fcall   EntityGetSlack
        ld      a, [bc]
        pop     bc              ; restore message pointer

        cp      d
        jr      Z, .sameSlab
        ret

.sameSlab:
        ;; Another entity is in the same slab as we are. We need to coordinate
        ;; our positions so that we do not overlap.
        inc     bc              ; \
        ld      a, [bc]         ; |
        ld      e, a            ; | Load a pointer to the other entity from the
        inc     bc              ; | message. Now, the other entity pointer will
        ld      a, [bc]         ; | be in de, and our self pointer in hl.
        ld      d, a            ; /

        fcall   PointerEq       ; \ Ignore message from ourself.
        or      a               ; |
        ret     Z               ; /

        ld      bc, SPIDER_VAR_X_DEST
        fcall   EntityGetSlack
        ld      a, [bc]
        ld      b, a
        ld      a, [var_player_coord_x]
        cp      b
        jr      Z, .eqTaken
        ret

.eqTaken:
        ld      h, d
        ld      l, e
        ld      bc, SPIDER_VAR_X_DEST
        fcall   EntityGetSlack
        sub     8
        ld      [bc], a
        ret


.onPlayerKnifeAttack:
        fcall   r9_SpiderHandleKnifeAttackMessage
        ret


;;; ----------------------------------------------------------------------------

r9_SpiderHandleKnifeAttackMessage:
;;; de - entity pointer
;;; bc - message pointer
        ld      h, d
        ld      l, e

        push    hl
        fcall   EntityGetPos
        ld      hl, var_temp_hitbox1
        fcall   r9_SpiderPopulateHitbox

        ld      hl, var_temp_hitbox2
        fcall   r9_PlayerKnifeAttackPopulateHitbox

        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection ; sets carry flag
        pop     hl

        ret     NC

        ld      a, 7            ; Injured color
        fcall   EntitySetHWGraphicsAttributes

        push    hl
        ld      b, 1
        WIDE_CALL r1_StartScreenshake
        pop     hl

        ld      bc, SPIDER_VAR_COLOR_COUNTER
        fcall   EntityGetSlack
        ld      a, 20
        ld      [bc], a

        push    hl
        ;; NOTE: damage * 2 because I decided that the spider enemy wasn't weak
        ;; enough, but I could not easily lower its level any more.
        ld      hl, DAGGER_BASE_DAMAGE * 2
        ld      a, [var_level]
        ld      b, a
        ld      c, SPIDER_DEFENSE_LEVEL
        fcall   CalculateDamage
        fcall   FormatDamage
        pop     hl
        fcall   r9_SpiderDepleteStamina
        ret


;;; ----------------------------------------------------------------------------

r9_SpiderUpdateColor:
        ld      bc, GREYWOLF_VAR_COLOR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        cp      a, 0
        jr      NZ, .decColorCounter

	ld      a, 2
        fcall   EntitySetHWGraphicsAttributes

        ret

.decColorCounter:
        dec     a
        ld      [bc], a
        ret


;;; ----------------------------------------------------------------------------

r9_SpiderPopulateHitbox:
;;; b - x coord (top left)
;;; c - y coord (top left)
;;; hl - hitbox
        ld      a, b
        add     8
        ld      b, a
        ld      [hl], b
        inc     hl
        ld      a, c
        add     16
        ld      c, a
        ld      [hl], c
        inc     hl

        ld      a, 16
        add     b
        ld      [hl+], a

        ld      a, 16
        add     c
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------

r9_SpiderDepleteStamina:
;;; b - amount
;;; c - fraction
        fcall   r9_EnemyDepleteStamina
        or      a
        jr      Z, .staminaExhausted

	push    hl
        push    af
        push    de

        ld      bc, SPIDER_VAR_STAMINA
        fcall   EntityGetSlack
        ld      a, [bc]
        fcall   OverlayShowEnemyHealth

        pop     de
        pop     af
        pop     hl

        ret

.staminaExhausted:

        push    hl
        ld      bc, SPIDER_VAR_SLAB   ; \
        fcall   EntityGetSlack        ; | Fetch current slab num
        ld      a, [bc]               ; |
        ld      b, a                  ; /
        ld      c, b                  ; \
        ld      d, SPIDER_SLAB_WEIGHT ; | Remove spider from slab table
        fcall   SlabTableUnbind       ; /
        pop     hl

        ld      a, SPRITE_SHAPE_INVISIBLE
        fcall   EntitySetDisplayFlags

        ld      e, 20
	fcall   ScheduleSleep

        ld      de, SpiderUpdateDead
        fcall   EntitySetUpdateFn

        ld      a, $01          ; Drops one item
        fcall   EntitySetTypeModifier

	ld      a, ENTITY_TYPE_SPIDER_DEAD
        fcall   EntitySetType

        ;; TODO: set a tile in the overworld representing a dead spider. No need
        ;; to waste OAM resources on small dead enemies.

	push    hl
        push    af
        push    de
        fcall   OverlayRepaintRow2
        pop     de
        pop     af
        pop     hl

        ld      hl, 6
        fcall   AddExp

        ret


;;; ----------------------------------------------------------------------------

r9_SpiderTryAttack:
        fcall   EntityGetPos
	ld      a, [var_player_coord_x]
        fcall   r9_absdiff
        ld      b, a
        ld      a, 16
        cp      b
        ret     C

        fcall   EntityGetPos
        ld      a, [var_player_coord_y]
        ld      b, c
        fcall   r9_absdiff
        ld      b, a
        ld      a, 24
        cp      b
        ret     C

	fcall   EntityAnimationResetKeyframe

        fcall   EntitySetTextureSwapFlag

        ld      de, SpiderUpdateAttacking
        fcall   EntitySetUpdateFn

        fcall   EntityGetPos
        ld      a, [var_player_coord_x]
        cp      b
        jr      C, .faceLeft

.faceRight:
        ld      a, SPRID_SPIDER_ATTACK_R
        fcall   EntitySetFrameBase
        ret

.faceLeft:
        ld      a, SPRID_SPIDER_ATTACK_L
        fcall   EntitySetFrameBase
        ret


;;; ----------------------------------------------------------------------------

r9_EnemySendSlabPositionsQuery:
;;; hl - entity
;;; trashes a bunch of registers (not hl)
        push    hl

        ld      bc, SPIDER_VAR_SLAB   ; \
        fcall   EntityGetSlack        ; | Fetch current slab num
        ld      a, [bc]               ; /

	ld      b, a
        ld      c, MESSAGE_SLAB_ENEMY_QUERY

        push    hl              ; second two message bytes, self pointer
        push    bc              ; first two message bytes, message type, slab

        ld      hl, sp+0

        fcall   MessageBusBroadcast

        pop     bc
        pop     bc

        pop     hl

        ret


;;; ----------------------------------------------------------------------------

;; r9_EnemySendSlabPositionResponse:
;;         push    hl

;;         ld      bc, SPIDER_VAR_X_DEST
;;         fcall   EntityGetSlack
;; 	;; TODO

;;         push    bc

;;         ld      bc, SPIDER_VAR_SLAB ; \
;;         fcall   EntityGetSlack      ; | Fetch current slab num
;;         ld      a, [bc]             ; /

;;         ld      b, a
;;         ld      c, MESSAGE_SLAB_ENEMY_RESPONSE

;;         push    bc

;;         ld      hl, sp+0

;;         fcall   MessageBusBroadcast

;;         pop     bc              ; \ Pop message off of the stack.
;;         pop     bc              ; /

;;         pop     hl
;;         ret


;;; ----------------------------------------------------------------------------
