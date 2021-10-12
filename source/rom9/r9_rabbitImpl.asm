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

r9_RabbitUpdateImpl:
        ld      h, b
        ld      l, c

        fcall   EntityGetPos
        ld      a, [var_player_coord_x]
        fcall   r9_absdiff
        ld      b, a
        ld      a, 48
        cp      b
        ret     C

        fcall   EntityGetPos
        ld      a, [var_player_coord_y]
        ld      b, c
        fcall   r9_absdiff
        ld      b, a
        ld      a, 48
        cp      b
        ret     C

        ld      bc, RABBIT_VAR_COUNTER
        fcall   EntityGetSlack
        xor     a
        ld      [bc], a

        ld      a, SPRID_RABBIT_RUN_R
        fcall   EntitySetFrameBase

        ld      de, RabbitUpdateRun
        fcall   EntitySetUpdateFn

        push    hl
        fcall   GetRandom
        ld      d, h
        ld      e, l
        pop     hl

        ld      bc, RABBIT_VAR_RUN_X_DIR
        fcall   EntityGetSlack
        ld      a, d
        and     1
        ld      [bc], a

        ld      bc, RABBIT_VAR_RUN_Y_DIR
        fcall   EntityGetSlack
        ld      a, e
        and     1
        ld      [bc], a

        ret


;;; ----------------------------------------------------------------------------

r9_RabbitUpdateRunImpl:
        ld      h, b
        ld      l, c
        ld      e, 5
        ld      d, 4
        fcall   EntityAnimationAdvance

        fcall   .update

        fcall   r9_RabbitMessageLoop

	ret

.update:
        ld      bc, RABBIT_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        inc     a
        ld      [bc], a
        cp      160
        jr      Z, .stop


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

.horizontal:
        ld      bc, RABBIT_VAR_RUN_X_DIR
        fcall   EntityGetSlack
        ld      a, [bc]
        or      a
        jr      Z, .runLeft

.runRight:
        ld      a, SPRID_RABBIT_RUN_R
        fcall   EntitySetFrameBase
        fcall   r9_RabbitRunRight
	jr      .vertical

.runLeft:
        ld      a, SPRID_RABBIT_RUN_L
        fcall   EntitySetFrameBase
        fcall   r9_RabbitRunLeft

.vertical:
        ld      bc, RABBIT_VAR_RUN_Y_DIR
        fcall   EntityGetSlack
        ld      a, [bc]
        or      a
        jr      Z, .runUp

.runDown:
	fcall   r9_RabbitRunDown
        ret

.runUp:
        fcall   r9_RabbitRunUp
        ret

.stop:
        fcall   EntityGetFrameBase
        ld      a, b
        cp      SPRID_RABBIT_RUN_L
        jr      Z, .faceLeft

.faceRight:
        ld      a, SPRID_RABBIT_R
        fcall   EntitySetFrameBase
        jr      .next

.faceLeft:
	ld      a, SPRID_RABBIT_L
        fcall   EntitySetFrameBase

.next:
        ld      de, RabbitUpdate
        fcall   EntitySetUpdateFn

        fcall   EntityAnimationResetKeyframe
        fcall   EntitySetTextureSwapFlag
        ret


;;; ----------------------------------------------------------------------------

r9_RabbitRunUp:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_UP
        ret     NZ

        fcall   EntityGetPos
        ld      a, c
        cp      32
        ret     C

        push    hl
        fcall   EntityGetYPos
        ld      b, 1
        ld      c, 20
        fcall   FixnumSub
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

r9_RabbitRunDown:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_DOWN
        ret     NZ

        fcall   EntityGetPos
        ld      a, 204
        cp      c
        ret     C

        push    hl
        fcall   EntityGetYPos
        ld      b, 1
        ld      c, 20
        fcall   FixnumAdd
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

r9_RabbitRunRight:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_RIGHT
        ret     NZ

        fcall   EntityGetPos
        ld      a, 224
        cp      b
        ret     C

        push    hl
        fcall   EntityGetXPos
        ld      b, 1
        ld      c, 20
        fcall   FixnumAdd
        pop     hl

        ret


;;; ----------------------------------------------------------------------------

r9_RabbitRunLeft:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_LEFT
        ret     NZ

        fcall   EntityGetPos
        ld      a, b
        cp      32
        ret     C

        push    hl
        fcall   EntityGetXPos
        ld      b, 1
        ld      c, 20
        fcall   FixnumSub
        pop     hl

        ret


;;; ----------------------------------------------------------------------------

r9_RabbitMessageLoop:
;;; trashes hl
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
        cp      a, MESSAGE_PLAYER_KNIFE_ATTACK
        jr      Z, .onAttacked
        cp      a, MESSAGE_PLAYER_HAMMER_ATTACK
        jr      Z, .onAttacked
        ret

.onAttacked:
;;; de - self
        ld      h, d
        ld      l, e

        push    hl
        fcall   EntityGetPos
        ld      hl, var_temp_hitbox1
        fcall   r9_SpiderPopulateHitbox ; FIXME

        ld      hl, var_temp_hitbox2
        fcall   r9_PlayerPopulateHitbox

        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection
        pop     hl
        ret     NC


        ld      bc, GREYWOLF_VAR_COLOR_COUNTER ; FIXME
        fcall   EntityGetSlack
        ld      a, 20
        ld      [bc], a

        ld      a, 7
        fcall   EntitySetHWGraphicsAttributes


        push    hl
        ld      b, 1
        WIDE_CALL r1_StartScreenshake
        pop     hl

        ld      de, RabbitUpdateDead
        fcall   EntitySetUpdateFn

        ld      a, $03          ; Drops two items
        fcall   EntitySetTypeModifier

        ld      a, ENTITY_TYPE_RABBIT_DEAD
        fcall   EntitySetType

	ld      a, SPRITE_SHAPE_SQUARE_16
        fcall   EntitySetDisplayFlags

        fcall   EntityAnimationResetKeyframe
        fcall   EntitySetTextureSwapFlag


        fcall   EntityGetFrameBase
        ld      a, b
        cp      SPRID_RABBIT_RUN_L
        jr      Z, .L
        cp      SPRID_RABBIT_L
        jr      Z, .L

.R:
	ld      a, SPRID_RABBIT_DEAD_R
        fcall   EntitySetFrameBase
        ret
.L:
        ld      a, SPRID_RABBIT_DEAD_L
        fcall   EntitySetFrameBase
        ret


;;; ----------------------------------------------------------------------------

r9_RabbitUpdateDeadImpl:
        ld      h, b
        ld      l, c

        fcall   r9_EnemyUpdateColor

        push    hl

        fcall   EntityGetMessageQueue
        fcall   MessageQueueLoad

        pop     de
        ld      bc, .onMessage
        fcall   MessageQueueDrain

        ret

.onMessage:
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

        fcall   r9_RabbitSetupScavenge

        ld      de, ScavengeSceneEnter
        jp      EntityMessageLoopJumpToScene


;;; ----------------------------------------------------------------------------

r9_RabbitSetupScavenge:
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
        jr      Z, .nextBit

        ld      a, ITEM_MORSEL
        ld      [var_scavenge_slot_0], a

.nextBit:
        bit     7, b
        ret     Z

        ld      a, ITEM_MORSEL
        ld      [var_scavenge_slot_1], a
        ret


;;; ----------------------------------------------------------------------------
