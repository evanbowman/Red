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


r9_GreywolfResetCounter:
        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, 0
        ld      [bc], a
        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfIdleTryAttack:
        fcall   EntityGetPos
	ld      a, [var_player_coord_x]
        fcall   r9_absdiff
        ld      b, a
        ld      a, 24
        cp      b
        jr      C, .skip

        fcall   EntityGetPos
        ld      a, [var_player_coord_y]
        ld      b, c
        fcall   r9_absdiff
        ld      b, a
        ld      a, 24
        cp      b
        jr      C, .skip

        fcall   EntityAnimationResetKeyframe

        fcall   r9_GreywolfResetCounter

        ld      de, GreywolfUpdateAttacking
        fcall   EntitySetUpdateFn

        fcall   EntityGetPos
        ld      a, [var_player_coord_x]
        cp      b
        jr      C, .faceLeft

.faceRight:
        ld      a, SPRID_GREYWOLF_ATTACK_R
        fcall   EntitySetFrameBase
        ret

.faceLeft:
        ld      a, SPRID_GREYWOLF_ATTACK_L
        fcall   EntitySetFrameBase


.skip:
	ret


;;; ----------------------------------------------------------------------------


r9_GreywolfIdleSetFacing:
        fcall   EntityGetPos
        ld      a, [var_player_coord_x]
        cp      b
        jr      C, .faceLeft

        ld      a, SPRID_GREYWOLF_R

        fcall   EntityGetFrameBase
        cp      b
        jr      Z, .skip

        fcall   EntitySetFrameBase

        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [hl], a

        ret

.faceLeft:
        fcall   EntityGetFrameBase
        cp      b
        jr      Z, .skip

        ld      a, SPRID_GREYWOLF_L
        fcall   EntitySetFrameBase

        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [hl], a

.skip:
        ret


;;; ----------------------------------------------------------------------------


r9_EnemyUpdateColor:
        ld      bc, GREYWOLF_VAR_COLOR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        cp      a, 0
        jr      NZ, .decColorCounter

	ld      a, 3
        fcall   EntitySetPalette

        ret

.decColorCounter:
        dec     a
        ld      [bc], a
        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfUpdateIdleImpl:
;;; bc - self
        ld      h, b                    ; \ Update functions are invoked through
        ld      l, c                    ; / hl, so it can't be a param :/

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        inc     a
        ld      [bc], a
        cp      64
        jr      Z, .run

        fcall   r9_GreywolfIdleSetFacing

        fcall   r9_GreywolfIdleTryAttack

        fcall   r9_EnemyUpdateColor
        fcall   r9_GreywolfMessageLoop

        ret

.run:
        ld      a, 0
        ld      [bc], a

        ld      de, GreywolfUpdateRunSeekX
        fcall   EntitySetUpdateFn

        ld      a, [hl]
        or      ENTITY_TEXTURE_SWAP_FLAG
        ld      [hl], a

        fcall   EntityGetFrameBase
        ld      a, SPRID_GREYWOLF_L
        cp      b
        jr      Z, .left

        ld      a, SPRID_GREYWOLF_RUN_R
        fcall   EntitySetFrameBase

        ret

.left:

        ld      a, SPRID_GREYWOLF_RUN_L
        fcall   EntitySetFrameBase

        ret


;;; ----------------------------------------------------------------------------


;;; Due to overlapping and the number of sprites allowed per line, we only
;;; support L/R knockback, not U/D. As nice as it would be to have knockback
;;; in all four directions, we would risk creating display issues, but we could
;;; try adding it and see whether it's an issue in practice...

r9_GreywolfApplyKnockback:
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


        ld      bc, GREYWOLF_VAR_KNOCKBACK_DIR
        fcall   EntityGetSlack
        ld      a, [bc]
        or      a
        jr      Z, .knockbackRight

.knockbackLeft:

        ld      a, [hvar_wall_collision_result]
        and     COLLISION_LEFT
        jr      NZ, .skip


        push    hl
        ld      bc, GREYWOLF_VAR_KNOCKBACK
        fcall   EntityGetSlack
	ld      a, [bc]
        ld      d, a
        srl     d               ; Subtract off some each time, sort of
        srl     d               ; like a friction effect...
        srl     d
        srl     d
        sub     d
        ld      [bc], a
        ld      c, a
        ld      b, 0
        push    bc

        fcall   EntityGetXPos
        pop     bc
        fcall   FixnumSub
        pop     hl
.skip:
        ret

.knockbackRight:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_RIGHT
        jr      NZ, .skip


        push    hl

        ld      bc, GREYWOLF_VAR_KNOCKBACK
        fcall   EntityGetSlack
	ld      a, [bc]
        ld      d, a
        srl     d               ; Subtract off some each time, sort of
        srl     d               ; like a friction effect...
        srl     d
        srl     d
        sub     d
        ld      [bc], a
        ld      c, a
        ld      b, 0
        push    bc

        fcall   EntityGetXPos
	pop     bc
        fcall   FixnumAdd
        pop     hl

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfUpdateStunnedImpl:
        ld      h, b                    ; \ Update functions are invoked through
        ld      l, c                    ; / hl, so it can't be a param :/

	fcall   r9_EnemyUpdateColor

        fcall   r9_GreywolfApplyKnockback

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        cp      0

        inc     a
        ld      [bc], a
        cp      24
        jr      Z, .idle

        fcall   r9_EnemyUpdateColor
        fcall   r9_GreywolfMessageLoop

        ret
.idle:
        ld      a, 0
        ld      [bc], a

        ld      de, GreywolfUpdate
        fcall   EntitySetUpdateFn

        ret


;;; ----------------------------------------------------------------------------

r9_absdiff:
;;; a - x1
;;; b - x2
        cp      b
        jr      C, .blah
	sub     b
        ret
.blah:
        ld      c, a
        ld      a, b
        ld      b, c
        sub     b
        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfMoveX:
        fcall   EntityGetPos
        ld      a, [var_player_coord_x]
        push    bc

        fcall   r9_absdiff      ; \
        pop     bc              ; | If our x coord is close to the player's, try
        cp      12              ; | moving in the y direction
        jr      C, .moveY       ; /

	ld      a, [var_player_coord_x]
        cp      b
        jr      C, .moveLeft

.moveRight:
        ld      a, [hvar_wall_collision_result]; \
        and     COLLISION_RIGHT                ; |
        jr      NZ, .moveY                     ; | Unless we're colliding with
                                               ; | a wall, move rightwards.
        push    hl                             ; |
        fcall   EntityGetXPos                  ; |
        ld      b, 1                           ; |
        ld      c, 136                         ; |
        fcall   FixnumAdd                      ; |
        pop     hl                             ; |
                                               ; |
        ld      a, SPRID_GREYWOLF_RUN_R        ; |
        fcall   EntitySetFrameBase             ; /

.skip:
        ret

.moveLeft:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_LEFT
        jr      NZ, .moveY

        push    hl
        fcall   EntityGetXPos
        ld      b, 1
        ld      c, 136
        fcall   FixnumSub
        pop     hl

        ld      a, SPRID_GREYWOLF_RUN_L
        fcall   EntitySetFrameBase

        ret

.moveY:
        ld      de, GreywolfUpdateRunSeekY
        fcall   EntitySetUpdateFn
        ret


;;; ----------------------------------------------------------------------------


;;; NOTE: movement is constrained to grids in the y direction. We need to ask
;;; the engine if we have enough capacity in a specific map row before
;;; occupying that map row, otherwise, we may exceed the oam-per-scanline
;;; limit. The current code already does exceed the scanline limits sometimes,
;;; but only when entities are moving from one row to another, entities will
;;; never settle in the same row for extended periods of time.
r9_GetDestSlab:
;;; FIXME: This function is used by a number of different enemy entities.
;;; Therefore, the slot number for the slab member variable needs to match.
;;; d - result
;;; trashes bc
        ASSERT GREYWOLF_VAR_SLAB == BOAR_VAR_SLAB

        push    hl

        push    hl
        ld      bc, GREYWOLF_VAR_SLAB ; \
        fcall   EntityGetSlack        ; | Fetch current slab num
        ld      a, [bc]               ; |
        ld      b, a                  ; /

        push    bc              ; \
        ld      c, b            ; |
        ld      d, 6            ; | Remove current slab from table
        fcall   SlabTableUnbind ; |
        pop     bc              ; /
        pop     hl

        ;; Now, calculate our actual current slab
        push    bc
        fcall   EntityGetPos
        ld      a, c            ; y value -> a
        fcall   GetSlabNum      ; slab num in register a
        pop     bc

	ld      d, a            ; current effective slab in d

        ld      a, [var_player_coord_y] ; \
        add     16                      ; | Slab containing player
        fcall   GetSlabNum              ; /

        ld      e, a            ; desired slab in e

        cp      d
        jr      C, .playerAbove
        jr      Z, .playerSameSlab

.playerBelow:
        inc     d
.startBelow:
        push    de
        ld      c, d
        ld      d, 6
        fcall   SlabTableBind
        pop     de
        or      a
        jr      Z, .retryBelow
        jr      .assign
.retryBelow:
        dec     d
        jr      .startBelow


.playerAbove:
        dec     d
.startAbove:
        push    de
        ld      c, d
        ld      d, 6
        fcall   SlabTableBind
        pop     de
        or      a
        jr      Z, .retryAbove
        jr      .assign
.retryAbove:
        inc     d
        jr      .startAbove


.assign:
        pop     hl
        ld      bc, GREYWOLF_VAR_SLAB ; \
        fcall   EntityGetSlack        ; | Set slab number in entity
        ld      a, d                  ; |
        ld      [bc], a               ; /
        ret


.playerSameSlab:
        push    de
        ld      c, e
        ld      d, 6
        fcall   SlabTableBind
        ld      d, e            ; result in d
        or      a
        jr      Z, .foo
        pop     de

        pop     hl              ; see push at function top
        ld      bc, GREYWOLF_VAR_SLAB ; \
        fcall   EntityGetSlack        ; | set slab number in entity
        ld      a, d                  ; |
        ld      [bc], a               ; /
        ret
.foo:
        pop     de
        ;; How'd we end up in this situation? TODO above or below based on player y.
        jr      .playerBelow

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfMoveY:
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
        ld      b, 1
        ld      c, 136
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
        ld      bc, GREYWOLF_VAR_SLAB ; \
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

        ld      de, GreywolfUpdateRunSeekX
        fcall   EntitySetUpdateFn

        ret

.idle:
        ld      de, GreywolfUpdate
        fcall   EntitySetUpdateFn
        fcall   EntityAnimationResetKeyframe

        ret


.moveUp:
        ld      a, [hvar_wall_collision_result]
        and     COLLISION_UP
        jr      NZ, .tryMoveHorizontally

        push    hl
        fcall   EntityGetYPos
        ld      b, 1
        ld      c, 136
        fcall   FixnumSub
        pop     hl
        ret

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfUpdateRunXImpl:
;;; bc - self
        ld      h, b
        ld      l, c

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

        ld      e, 5
        ld      d, 5
        fcall   EntityAnimationAdvance

        fcall   r9_GreywolfMoveX

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        inc     a
        ld      [bc], a
        cp      255
        jr      Z, .idle

        ld      a, [var_player_coord_x]



        fcall   r9_EnemyUpdateColor
        fcall   r9_GreywolfMessageLoop

        ret
.idle:
        ld      a, 0
        ld      [bc], a

        ld      de, GreywolfUpdate
        fcall   EntitySetUpdateFn

        fcall   EntityAnimationResetKeyframe

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfUpdateRunYImpl:
;;; bc - self
        ld      h, b                    ; \ Update functions are invoked through
        ld      l, c                    ; / hl, so it can't be a param :/

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

        ld      e, 5
        ld      d, 5
        fcall   EntityAnimationAdvance

        fcall   r9_GreywolfMoveY

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        inc     a
        ld      [bc], a
        cp      255
        jr      Z, .idle


        fcall   r9_EnemyUpdateColor
        fcall   r9_GreywolfMessageLoop

        ret
.idle:
        ld      a, 0
        ld      [bc], a

        ld      de, GreywolfUpdate
        fcall   EntitySetUpdateFn

        fcall   EntityAnimationResetKeyframe

        ret



;;; ----------------------------------------------------------------------------


r9_GreywolfMessageLoop:
;;; trashes hl, should probably be called last
        push    hl                      ; Store entity pointer on stack

        fcall   EntityGetMessageQueue
        fcall   MessageQueueLoad

        pop     de                      ; Pass entity pointer in de
        ld      bc, r9_GreywolfOnMessage
	fcall   MessageQueueDrain

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfSetKnockback:
;;; d - amount
        ld      bc, GREYWOLF_VAR_KNOCKBACK
        fcall   EntityGetSlack
        ld      a, d
        ld      [bc], a


        fcall   EntityGetPos
        ld      a, [var_player_coord_x]

        cp      b
        jr      C, .knockbackRight

.knockbackLeft:
        ld      bc, GREYWOLF_VAR_KNOCKBACK_DIR
        fcall   EntityGetSlack
        ld      a, 1
        ld      [bc], a
        ret

.knockbackRight:
        ld      bc, GREYWOLF_VAR_KNOCKBACK_DIR
        fcall   EntityGetSlack
        ld      a, 0
        ld      [bc], a
        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfCheckKnifeAttackCollision:
;;; bc - message pointer
;;; return a - true if attack hit, false if missed
	push    hl

        fcall   EntityGetPos
        ld      hl, var_temp_hitbox1
        fcall   r9_GreywolfPopulateHitbox

        ;; TODO: use message to populate hitbox, rather than player's current
        ;; state.
        ld      hl, var_temp_hitbox2
        fcall   r9_PlayerKnifeAttackPopulateHitbox

        ld      hl, var_temp_hitbox1
        ld      de, var_temp_hitbox2
        fcall   CheckIntersection ; leaves result in a

        pop     hl
        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfOnMessage:
;;; bc - message pointer
;;; de - self
        ld      a, [bc]
        cp      a, MESSAGE_PLAYER_KNIFE_ATTACK
        jr      Z, .onPlayerKnifeAttack

        ret

.onPlayerKnifeAttack:
        ld      h, d
        ld      l, e

        fcall   r9_GreywolfCheckKnifeAttackCollision
        or      a
        jr      Z, .skip

        ld      a, 7
        fcall   EntitySetPalette


        ld      bc, GREYWOLF_VAR_COLOR_COUNTER
        fcall   EntityGetSlack
        ld      a, 20
        ld      [bc], a


	ld      de, GreywolfUpdateStunned
        fcall   EntitySetUpdateFn

	ld      d, 50
        fcall   r9_GreywolfSetKnockback


        push    hl
        ld      hl, DAGGER_BASE_DAMAGE
        ld      a, [var_level]
        ld      b, a
        ld      c, GREYWOLF_DEFENSE_LEVEL
        fcall   CalculateDamage
        fcall   FormatDamage
        pop     hl
        fcall   r9_GreywolfDepleteStamina


        fcall   r9_GreywolfResetCounter

        fcall   EntityAnimationResetKeyframe


        fcall   EntityGetFrameBase
        ld      a, SPRID_GREYWOLF_L
        cp      b
        jr      Z, .left
        ld      a, SPRID_GREYWOLF_RUN_L
        cp      b
        jr      Z, .left
        ld      a, SPRID_GREYWOLF_ATTACK_L
        cp      b
        jr      Z, .left
        ld      a, SPRID_GREYWOLF_R
        cp      b
        jr      Z, .right
        ld      a, SPRID_GREYWOLF_RUN_R
        cp      b
        jr      Z, .right
        ld      a, SPRID_GREYWOLF_ATTACK_R
        cp      b
        jr      Z, .right

        ret

.right:
	ld      a, SPRID_GREYWOLF_STUN_R
        fcall   EntitySetFrameBase

        ld      a, [hl]
        or      ENTITY_TEXTURE_SWAP_FLAG
        ld      [hl], a

        ret

.left:
	ld      a, SPRID_GREYWOLF_STUN_L
        fcall   EntitySetFrameBase

        ld      a, [hl]
        or      ENTITY_TEXTURE_SWAP_FLAG
        ld      [hl], a

        ret
.skip:
        ret



;;; ----------------------------------------------------------------------------


r9_GreywolfUpdateAttackingImpl:
;;; bc - self
        ld      h, b
        ld      l, c

        ld      e, 5
        ld      d, 5
        fcall   EntityAnimationAdvance
        ld      a, d
        or      a
        jr      Z, .frameUnchanged

        fcall   EntityAnimationGetKeyframe
        cp      0
        jr      Z, .idle
        cp      3
        jr      Z, .sendAttack

        fcall   r9_GreywolfMessageLoop

        ret

.sendAttack:
        fcall   r9_GreywolfAttackBroadcast
        ret

.idle:
        fcall   EntityAnimationResetKeyframe

GREYWOLF_KNIFE_ATTACK_STUN_DURATION EQU 16

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, GREYWOLF_KNIFE_ATTACK_STUN_DURATION
        ld      [bc], a

        ld      de, GreywolfUpdatePause
        fcall   EntitySetUpdateFn

.frameUnchanged:

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfAttackBroadcast:
        fcall   EntityGetFrameBase

        fcall   EntityGetPos            ; \ Second two message bytes: y, x
        push    bc                      ; /

        ld      c, MESSAGE_WOLF_ATTACK  ; \ First two message bytes:
        push    bc                      ; / Message type, frame base

        ld      hl, sp+0                ; Pass pointer to message on stack

        fcall   MessageBusBroadcast

        pop     bc              ; \ Pop message arg from stack
        pop     bc              ; /

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfPopulateHitbox:
;;; b - x coord (top left)
;;; c - y coord (top left)
;;; hl - hitbox
        ld      [hl], b
        inc     hl
        ld      [hl], c
        inc     hl

        ld      a, 32           ; FIXME: use something other than 32x32...
        add     b
        ld      [hl+], a

        ld      a, 32
        add     c
        ld      [hl], a

        ret


;;; ----------------------------------------------------------------------------

r9_EnemyDepleteStamina:
;;; hl - enemy
;;; b - amount
;;; c - fraction
        push    hl
        push    bc

        ld      bc, GREYWOLF_VAR_STAMINA
        fcall   EntityGetSlack

        push    bc              ; \ bc -> hl
        pop     hl              ; /

        pop     bc              ; restore fraction, amount

        push    hl
        inc     hl
        inc     hl
        ld      a, [hl]         ; load upper num
        pop     hl

        push    af              ; store upper num

        fcall   FixnumSub

        pop     af
        pop     hl

        cp      d               ; if higher bits changed, we dropped below zero
        jr      NZ, .staminaExhausted
        ld      a, 1
        ret
.staminaExhausted:
        ld      a, 0
        ret


;;; ----------------------------------------------------------------------------

r9_GreywolfDepleteStamina:
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
        ld      d, 255
        fcall   r9_GreywolfSetKnockback

        ld      de, GreywolfUpdateDying
        fcall   EntitySetUpdateFn

	push    hl
        push    af              ; heh, yeah I know
        push    de
        fcall   OverlayRepaintRow2
        pop     de
        pop     af
        pop     hl

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfUpdateDyingImpl:
;;; bc - self
        ld      h, b
        ld      l, c

	fcall   r9_EnemyUpdateColor

        fcall   r9_GreywolfApplyKnockback

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        inc     a
        ld      [bc], a
        cp      24
        jr      Z, .dead

        ret

.dead:
        push    hl
        ld      bc, GREYWOLF_VAR_SLAB ; \
        fcall   EntityGetSlack        ; | Fetch current slab num
        ld      a, [bc]               ; |
        ld      b, a                  ; /

        push    bc              ; \
        ld      c, b            ; |
        ld      d, 6            ; | Remove current slab from table
        fcall   SlabTableUnbind ; |
        pop     bc              ; /
        pop     hl

        ld      a, 0 | SPRITE_SHAPE_T
        fcall   EntitySetDisplayFlags

        fcall   EntityGetPos
        ld      a, [var_player_coord_x]
        cp      b
        jr      C, .faceLeft
.faceRight:
        ld      a, SPRID_GREYWOLF_DEAD_R
        fcall   EntitySetFrameBase
        jr      .continue
.faceLeft:
        ld      a, SPRID_GREYWOLF_DEAD_L
        fcall   EntitySetFrameBase
.continue:

        ld      de, GreywolfUpdateDead
        fcall   EntitySetUpdateFn

        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [hl], a

        ld      a, ENTITY_TYPE_GREYWOLF_DEAD
        fcall   EntitySetType

        ld      a, $03          ; Has two items
        fcall   EntitySetTypeModifier

        ld      a, 4
        fcall   EntitySetPalette

        fcall   EntityGetXPos
        ld      b, 1
        ld      c, 0
        fcall   FixnumAdd

        ld      hl, 10
        fcall   AddExp

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfDeadOnMessage:
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
        fcall   r9_GreywolfPopulateHitbox

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

	call    r9_GreywolfSetupScavenge

	ret


;;; ----------------------------------------------------------------------------

r9_GreywolfSetupScavenge:
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

        ld      a, ITEM_RAW_MEAT ; TODO: randomize based on a seed?
        ld      [var_scavenge_slot_0], a

.skip0:
        bit     7, b
        ret     Z

        ld      a, ITEM_WOLF_PELT
        ld      [var_scavenge_slot_1], a

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfUpdateDeadImpl:
;;; bc - self
        ld      h, b
        ld      l, c

        push    hl

        fcall   EntityGetMessageQueue
        fcall   MessageQueueLoad

        pop     de
        ld      bc, r9_GreywolfDeadOnMessage
        fcall   MessageQueueDrain
        ret


;;; ----------------------------------------------------------------------------
