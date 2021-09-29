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


;;; ----------------------------------------------------------------------------

r9_BoarUpdateImpl:
        ld      h, b
        ld      l, c

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        inc     a
        ld      [bc], a
        cp      150
        jr      Z, .next

        fcall   r9_EnemyUpdateColor
        fcall   r9_BoarMessageLoop
        ret
.next:
        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, 0
        ld      [bc], a

        ld      de, BoarUpdateSeekY
        fcall   EntitySetUpdateFn

        fcall   EntityGetPos
        ld      a, [var_player_coord_x]
        cp      b
        jr      C, .faceLeft

.faceRight:
	ld      a, SPRID_BOAR_RUN_R
        fcall   EntitySetFrameBase
        ld      a, 1            ; swap texture
        ld      [hl], a         ;
        ret

.faceLeft:
	ld      a, SPRID_BOAR_RUN_L
        fcall   EntitySetFrameBase
        ld      a, 1            ; swap texture
        ld      [hl], a         ;
	ret

;;; ----------------------------------------------------------------------------

r9_BoarUpdateChargingImpl:
        ld      h, b
        ld      l, c

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        inc     a
        ld      [bc], a
        cp      20
        jr      Z, .next

        fcall   r9_EnemyUpdateColor
        fcall   r9_BoarMessageLoop

        fcall   EntityGetPos
        ld      a, [var_player_coord_x]
        cp      b
        jr      C, .faceLeft

.faceRight:
        ld      a, SPRID_BOAR_R
        fcall   EntitySetFrameBase
        ld      a, 1            ; swap texture
        ld      [hl], a         ;
        ret

.faceLeft:
        ld      a, SPRID_BOAR_L
        fcall   EntitySetFrameBase
        ld      a, 1            ; swap texture
        ld      [hl], a         ;
        ret

.next:
        fcall   EntityGetPos
        ld      a, [var_player_coord_x]
        cp      b
        jr      C, .moveLeft

.moveRight:
	ld      a, SPRID_BOAR_RUN_R
        fcall   EntitySetFrameBase
        ld      a, 1            ; swap texture
        ld      [hl], a         ;

        ld      de, BoarUpdateDashRight
        fcall   EntitySetUpdateFn
        ret

.moveLeft:
	ld      a, SPRID_BOAR_RUN_L
        fcall   EntitySetFrameBase
        ld      a, 1            ; swap texture
        ld      [hl], a         ;

        ld      de, BoarUpdateDashLeft
        fcall   EntitySetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

r9_BoarUpdateDashLeftImpl:
        ld      h, b
        ld      l, c

        fcall   r9_BoarDashCheckPlayerCollision

        fcall   r9_EnemyUpdateColor

        ld      e, 4
        ld      d, 4
        fcall   EntityAnimationAdvance

        fcall   r9_BoarCheckCollisions

        ld      a, [hvar_wall_collision_result]
        and     COLLISION_LEFT
        jr      NZ, .collideWall


        push    hl
        fcall   EntityGetXPos
        ld      a, [hl]
        cp      20
        jr      C, .offscreenLeft
        ld      b, 2
        ld      c, 150
        fcall   FixnumSub
        pop     hl
        ret

.offscreenLeft:
        pop     hl              ; cleanup hl (above)
        ;; fallthrough

.collideWall:

        ;; TODO: screenshake
        ld      de, BoarUpdateRechargeAfterCollision
        fcall   EntitySetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

r9_BoarPopulateHitbox:
;;; b - x coord (top left)
;;; c - y coord (top left)
;;; hl - hitbox
        ld      a, b
        add     8
        ld      b, a
        ld      [hl], b
        inc     hl
        ld      a, c
        add     4
        ld      c, a
        ld      [hl], c
        inc     hl

        ld      a, 16
        add     b
        ld      [hl+], a

        ld      a, 24
        add     c
        ld      [hl], a

	ret


;;; ----------------------------------------------------------------------------

r9_BoarDashCheckPlayerCollision:

        push    hl

        ld      a, [var_player_color_counter] ; \
        or      a                             ; | Skip when player is already
        jr      NZ, .skip                     ; / injured.

        fcall   EntityGetPos
        ld      hl, var_temp_hitbox2
        fcall   r9_BoarPopulateHitbox

        ld      hl, var_temp_hitbox1
        fcall   r9_PlayerPopulateHitbox


        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection

        or      a
        jr      Z, .skip

        ld      a, 25
        ld      [var_player_color_counter], a

        push    hl
        fcall   r9_PlayerBoarAttackDepleteStamina
        pop     hl

.skip:
        pop     hl

        ret


;;; ----------------------------------------------------------------------------

r9_BoarUpdateDashRightImpl:
        ld      h, b
        ld      l, c

        fcall   r9_BoarDashCheckPlayerCollision

        fcall   r9_EnemyUpdateColor

        ld      e, 4
        ld      d, 4
        fcall   EntityAnimationAdvance

        fcall   r9_BoarCheckCollisions

        ld      a, [hvar_wall_collision_result]
        and     COLLISION_RIGHT
        jr      NZ, .collideWall

        push    hl
        fcall   EntityGetXPos
        ld      b, [hl]
        ld      a, 220
        cp      b
        jr      C, .offscreenRight
        ld      b, 2
        ld      c, 150
        fcall   FixnumAdd
        pop     hl
        ret

.offscreenRight:
        pop     hl              ; cleanup hl (above)
        ;; fallthrough

.collideWall:

        ;; TODO: screenshake
        ld      de, BoarUpdateRechargeAfterCollision
        fcall   EntitySetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

r9_BoarCheckCollisions:
;;; hl - self
        push    hl
        fcall   EntityGetPos
        ld      a, b
        ld      [hvar_wall_collision_source_x], a
        ld      a, c
        ld      [hvar_wall_collision_source_y], a
        ld      a, 4
        ld      [hvar_wall_collision_size_x], a
        ld      a, 2
        ld      [hvar_wall_collision_size_y], a
        fcall   r9_WallCollisionCheck
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

r9_BoarUpdateRechargeAfterCollisionImpl:
        ld      h, b
        ld      l, c

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        inc     a
        ld      [bc], a
        cp      50
        jr      Z, .next

        fcall   r9_EnemyUpdateColor
        fcall   r9_BoarMessageLoop
        ret
.next:
        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, 0
        ld      [bc], a

        fcall   EntityAnimationResetKeyframe

        ld      de, BoarUpdate
        fcall   EntitySetUpdateFn

	fcall   EntityGetFrameBase
        ld      a, b
        cp      SPRID_BOAR_RUN_L
        jr      .idleL
.idleR:
        ld      a, SPRID_BOAR_R
        fcall   EntitySetFrameBase
        ld      a, 1            ; swap texture
        ld      [hl], a         ;
        ret
.idleL:
        ld      a, SPRID_BOAR_L
        fcall   EntitySetFrameBase
        ld      a, 1            ; swap texture
        ld      [hl], a         ;

        ret


;;; ----------------------------------------------------------------------------

r9_BoarDepleteStamina:
;;; b - amount
;;; c - fraction
        fcall   r9_EnemyDepleteStamina
        or      a
        jr      Z, .staminaExhausted

	push    hl
        push    af              ; heh, yeah I know
        push    de

        ld      bc, GREYWOLF_VAR_STAMINA
        fcall   EntityGetSlack
        ld      a, [bc]
        fcall   OverlayShowEnemyHealth

        pop     de
        pop     af
        pop     hl

        ret
.staminaExhausted:

        ld      de, BoarUpdateDying
        fcall   EntitySetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

r9_BoarUpdateDyingImpl:
        ld      h, b
        ld      l, c

	fcall   EntityGetFrameBase
        ld      a, b
        cp      SPRID_BOAR_DYING_L
        jr      Z, .skipAssignFrame
        cp      SPRID_BOAR_DYING_R
        jr      Z, .skipAssignFrame

        push    af

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, 0
        ld      [bc], a

        fcall   EntityAnimationResetKeyframe
        pop     af

.right:
        cp      SPRID_BOAR_L
        jr      Z, .left
        cp      SPRID_BOAR_RUN_L
        jr      Z, .left

        ld      a, SPRID_BOAR_DYING_R
        fcall   EntitySetFrameBase
        ld      a, 1            ; swap texture
        ld      [hl], a         ;

        jr      .afterAssignFrame
.left:
	ld      a, SPRID_BOAR_DYING_L
        fcall   EntitySetFrameBase
        ld      a, 1            ; swap texture
        ld      [hl], a         ;


.skipAssignFrame:
.afterAssignFrame:

        fcall   r9_EnemyUpdateColor

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        inc     a
        ld      [bc], a
        cp      50
        jr      Z, .next
	ret

.next:
        ld      de, BoarUpdateDead
        fcall   EntitySetUpdateFn

        ld      a, ENTITY_TYPE_BOAR_DEAD
        fcall   EntitySetType

        ld      a, 0 | SPRITE_SHAPE_T
        fcall   EntitySetDisplayFlags

        ld      a, $03          ; Has two items
        fcall   EntitySetTypeModifier

        ld      a, 4
        fcall   EntitySetPalette

        ld      a, 1            ; swap texture
        ld      [hl], a         ;

        fcall   EntityGetFrameBase
        ld      a, b
        cp      SPRID_BOAR_DYING_L
        jr      Z, .deadLeft

.deadRight:
	ld      a, SPRID_BOAR_DEAD_R
        fcall   EntitySetFrameBase
	ret

.deadLeft:
        ld      a, SPRID_BOAR_DEAD_L
        fcall   EntitySetFrameBase
        ret


;;; ----------------------------------------------------------------------------

r9_BoarOnMessage:
;;; bc - message pointer
;;; de - self
        ld      a, [bc]
        cp      a, MESSAGE_PLAYER_KNIFE_ATTACK
        jr      Z, .onPlayerKnifeAttack

        ret

.onPlayerKnifeAttack:
        ld      h, d
        ld      l, e

        fcall   r9_GreywolfCheckKnifeAttackCollision ; FIXME! :)
        or      a
        ret     Z

        ld      a, 7
        fcall   EntitySetPalette

        ld      bc, BOAR_VAR_COLOR_COUNTER
        fcall   EntityGetSlack
        ld      a, 20
        ld      [bc], a

        push    hl
        ld      hl, DAGGER_BASE_DAMAGE
        ld      a, [var_level]
        ld      b, a
        ld      c, BOAR_DEFENSE_LEVEL
        fcall   CalculateDamage
        fcall   FormatDamage
        pop     hl
        fcall   r9_BoarDepleteStamina

        ret

;;; ----------------------------------------------------------------------------

r9_BoarMessageLoop:
        push    hl
        push    hl                      ; Store entity pointer on stack

        fcall   EntityGetMessageQueue
        fcall   MessageQueueLoad

        pop     de                      ; Pass entity pointer in de
        ld      bc, r9_BoarOnMessage
	fcall   MessageQueueDrain

        pop     hl
        ret


;;; ----------------------------------------------------------------------------

r9_BoarUpdateRunYImpl:
        ld      h, b
        ld      l, c

        fcall   r9_BoarCheckCollisions

        ld      e, 5
        ld      d, 4
        fcall   EntityAnimationAdvance

        fcall   r9_BoarMoveY

        fcall   r9_EnemyUpdateColor
        fcall   r9_BoarMessageLoop
        ret


;;; ----------------------------------------------------------------------------

r9_BoarMoveY:
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
        jr      C, .tryMoveHorizontally
        pop     af

        cp      c

        jr      C, .moveUp

        ld      a, [hvar_wall_collision_result]
        and     COLLISION_DOWN
        jr      NZ, .tryMoveHorizontally

        push    hl
        fcall   EntityGetYPos
        ld      b, 1
        ld      c, 70
        fcall   FixnumAdd
        pop     hl
	ret

.tryMoveHorizontally:
        pop     af

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, 0
        ld      [bc], a

        fcall   EntityAnimationResetKeyframe

        ld      de, BoarUpdateCharging
        fcall   EntitySetUpdateFn

        ret

.idle:
        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, 0
        ld      [bc], a
        fcall   EntityAnimationResetKeyframe


        ld      de, BoarUpdate
        fcall   EntitySetUpdateFn

        ret


.moveUp:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_UP
        jr      NZ, .tryMoveHorizontally

        push    hl
        fcall   EntityGetYPos
        ld      b, 1
        ld      c, 70
        fcall   FixnumSub
        pop     hl
        ret


;;; ----------------------------------------------------------------------------



r9_BoarDeadOnMessage:
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

        fcall   EntityGetPos    ; pos -> bc
        ld      hl, var_temp_hitbox1
        fcall   r9_BoarPopulateHitbox

        ld      hl, var_temp_hitbox2
        fcall   r9_PlayerPopulateHitbox

        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection

        pop     hl

        or      a
        ret     Z

        push    hl
        ld      de, ScavengeSceneEnter
        fcall   SceneSetUpdateFn
        pop     hl

	call    r9_BoarSetupScavenge

	ret


;;; ----------------------------------------------------------------------------

r9_BoarSetupScavenge:
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
        ld      b, a
        bit     6, b
        jr      Z, .skip0

        ld      a, ITEM_RAW_MEAT
        ld      [var_scavenge_slot_0], a

.skip0:
        bit     7, b
        ret     Z

        ld      a, ITEM_RAW_MEAT
        ld      [var_scavenge_slot_1], a

        ret


;;; ----------------------------------------------------------------------------


r9_BoarUpdateDeadImpl:
;;; bc - self
        ld      h, b
        ld      l, c

        push    hl

        fcall   EntityGetMessageQueue
        fcall   MessageQueueLoad

        pop     de
        ld      bc, r9_BoarDeadOnMessage
        fcall   MessageQueueDrain
        ret


;;; ----------------------------------------------------------------------------
