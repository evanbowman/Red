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


r9_GreywolfIdleSetFacing:
        call    EntityGetPos
        ld      a, [var_player_coord_x]
        cp      b
        jr      C, .faceLeft

        ld      a, SPRID_GREYWOLF_R

        call    EntityGetFrameBase
        cp      b
        jr      Z, .skip

        call    EntitySetFrameBase

        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [hl], a

        ret

.faceLeft:
        call    EntityGetFrameBase
        cp      b
        jr      Z, .skip

        ld      a, SPRID_GREYWOLF_L
        call    EntitySetFrameBase

        ld      a, ENTITY_TEXTURE_SWAP_FLAG
        ld      [hl], a

.skip:
        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfUpdateColor:
        ld      bc, GREYWOLF_VAR_COLOR_COUNTER
        call    EntityGetSlack
        ld      a, [bc]
        cp      a, 0
        jr      NZ, .decColorCounter

	ld      a, 3
        call    EntitySetPalette

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
        call    EntityGetSlack
        ld      a, [bc]
        inc     a
        ld      [bc], a
        cp      64
        jr      Z, .run

        call    r9_GreywolfIdleSetFacing

        call    r9_GreywolfUpdateColor
        call    r9_GreywolfMessageLoop

        ret

.run:
        ld      a, 0
        ld      [bc], a

        ld      de, GreywolfUpdateRunSeekX
        call    EntitySetUpdateFn

        ld      a, [hl]
        or      ENTITY_TEXTURE_SWAP_FLAG
        ld      [hl], a

        call    EntityGetFrameBase
        ld      a, SPRID_GREYWOLF_L
        cp      b
        jr      Z, .left

        ld      a, SPRID_GREYWOLF_RUN_R
        call    EntitySetFrameBase

        ret

.left:

        ld      a, SPRID_GREYWOLF_RUN_L
        call    EntitySetFrameBase

        ret


;;; ----------------------------------------------------------------------------


;;; Due to overlapping and the number of sprites allowed per line, we only
;;; support L/R knockback, not U/D. As nice as it would be to have knockback
;;; in all four directions, we would risk creating display issues, but we could
;;; try adding it and see whether it's an issue in practice...

r9_GreywolfApplyKnockback:
        push    hl
        call    EntityGetPos
        ld      a, b
        ld      [var_wall_collision_source_x], a
        ld      a, c
        ld      [var_wall_collision_source_y], a
        call    r9_WallCollisionCheck
        pop     hl


        ld      bc, GREYWOLF_VAR_KNOCKBACK_DIR
        call    EntityGetSlack
        ld      a, [bc]
        or      a
        jr      Z, .knockbackRight

.knockbackLeft:

        ld      a, [var_wall_collision_result]
        and     COLLISION_LEFT
        jr      NZ, .skip


        push    hl
        ld      bc, GREYWOLF_VAR_KNOCKBACK
        call    EntityGetSlack
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

        call    EntityGetXPos
        pop     bc
        call    FixnumSub
        pop     hl
.skip:
        ret

.knockbackRight:
        ld      a, [var_wall_collision_result]
        and     COLLISION_RIGHT
        jr      NZ, .skip


        push    hl

        ld      bc, GREYWOLF_VAR_KNOCKBACK
        call    EntityGetSlack
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

        call    EntityGetXPos
	pop     bc
        call    FixnumAdd
        pop     hl

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfUpdateStunnedImpl:
        ld      h, b                    ; \ Update functions are invoked through
        ld      l, c                    ; / hl, so it can't be a param :/

	call    r9_GreywolfUpdateColor

        call    r9_GreywolfApplyKnockback

        ld      bc, GREYWOLF_VAR_COUNTER
        call    EntityGetSlack
        ld      a, [bc]
        cp      0

        inc     a
        ld      [bc], a
        cp      24
        jr      Z, .idle

        call    r9_GreywolfUpdateColor
        call    r9_GreywolfMessageLoop

        ret
.idle:
        ld      a, 0
        ld      [bc], a

        ld      de, GreywolfUpdate
        call    EntitySetUpdateFn

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
        call    EntityGetPos
        ld      a, [var_player_coord_x]
        push    bc
        call    r9_absdiff
        pop     bc
        cp      12
        jr      C, .moveY
	ld      a, [var_player_coord_x]
        cp      b
        jr      C, .moveLeft

        ld      a, [var_wall_collision_result]
        and     COLLISION_RIGHT
        jr      NZ, .moveY

        push    hl
        call    EntityGetXPos
        ld      b, 1
        ld      c, 136
        call    FixnumAdd
        pop     hl

        ld      a, SPRID_GREYWOLF_RUN_R
        call    EntitySetFrameBase

.skip:
        ret

.moveLeft:
        ld      a, [var_wall_collision_result]
        and     COLLISION_LEFT
        jr      NZ, .moveY

        push    hl
        call    EntityGetXPos
        ld      b, 1
        ld      c, 136
        call    FixnumSub
        pop     hl

        ld      a, SPRID_GREYWOLF_RUN_L
        call    EntitySetFrameBase

        ret

.moveY:
        ld      de, GreywolfUpdateRunSeekY
        call    EntitySetUpdateFn
        ret


;;; ----------------------------------------------------------------------------


r9_GetDestSlab:
;;; d - result
;;; trashes bc
        push    hl

        ld      bc, GREYWOLF_VAR_SLAB
        call    EntityGetSlack
        ld      a, [bc]
        ld      b, a

        ld      a, [var_player_coord_y]
        add     16
        call    GetSlabNum

        ld      c, a

        ld      d, 6
        call    SlabTableRebindNearest

        ld      d, c

        pop     hl

        ld      bc, GREYWOLF_VAR_SLAB
        call    EntityGetSlack
        ld      a, d
        ld      [bc], a
        ld      d, a

        ret


;;; ----------------------------------------------------------------------------


r9_MoveYTest:
        call    r9_GetDestSlab

        ld      a, d

        swap    a
        sla     a

        call    EntityGetPos
	push    af
	push    bc
        ld      b, c
        call    r9_absdiff
        cp      2
        pop     bc
        jr      C, .skip2
        pop     af

        cp      c

        jr      C, .moveLeft2

        ld      a, [var_wall_collision_result]
        and     COLLISION_DOWN
        jr      NZ, .skip2

        push    hl
        call    EntityGetYPos
        ld      b, 1
        ld      c, 136
        call    FixnumAdd
        pop     hl
	ret

.skip2:
        pop     af
        call    EntityGetPos
        ld      a, [var_player_coord_x]
        call    r9_absdiff
        cp      13
        jr      C, .idle

        ld      de, GreywolfUpdateRunSeekX
        call    EntitySetUpdateFn

        ret

.idle:
        ld      de, GreywolfUpdate
        call    EntitySetUpdateFn
        call    EntityAnimationResetKeyframe

        ret


.moveLeft2:
        ld      a, [var_wall_collision_result]
        and     COLLISION_UP
        jr      NZ, .skip2

        push    hl
        call    EntityGetYPos
        ld      b, 1
        ld      c, 136
        call    FixnumSub
        pop     hl
        ret

        ret


r9_GreywolfUpdateRunXImpl:
;;; bc - self
        ld      h, b
        ld      l, c

        push    hl
        call    EntityGetPos
        ld      a, b
        ld      [var_wall_collision_source_x], a
        ld      a, c
        ld      [var_wall_collision_source_y], a
        call    r9_WallCollisionCheck
        pop     hl

        ld      e, 5
        ld      d, 5
        call    EntityAnimationAdvance

        call    r9_GreywolfMoveX

        ld      bc, GREYWOLF_VAR_COUNTER
        call    EntityGetSlack
        ld      a, [bc]
        inc     a
        ld      [bc], a
        cp      255
        jr      Z, .idle

        ld      a, [var_player_coord_x]



        call    r9_GreywolfUpdateColor
        call    r9_GreywolfMessageLoop

        ret
.idle:
        ld      a, 0
        ld      [bc], a

        ld      de, GreywolfUpdate
        call    EntitySetUpdateFn

        call    EntityAnimationResetKeyframe

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfUpdateRunYImpl:
;;; bc - self
        ld      h, b                    ; \ Update functions are invoked through
        ld      l, c                    ; / hl, so it can't be a param :/

        push    hl
        call    EntityGetPos
        ld      a, b
        ld      [var_wall_collision_source_x], a
        ld      a, c
        ld      [var_wall_collision_source_y], a
        call    r9_WallCollisionCheck
        pop     hl

        ld      e, 5
        ld      d, 5
        call    EntityAnimationAdvance

        call    r9_MoveYTest

        ld      bc, GREYWOLF_VAR_COUNTER
        call    EntityGetSlack
        ld      a, [bc]
        inc     a
        ld      [bc], a
        cp      255
        jr      Z, .idle


        call    r9_GreywolfUpdateColor
        call    r9_GreywolfMessageLoop

        ret
.idle:
        ld      a, 0
        ld      [bc], a

        ld      de, GreywolfUpdate
        call    EntitySetUpdateFn

        call    EntityAnimationResetKeyframe

        ret



;;; ----------------------------------------------------------------------------


r9_GreywolfMessageLoop:
;;; trashes hl, should probably be called last
        push    hl                      ; Store entity pointer on stack

        call    EntityGetMessageQueue
        call    MessageQueueLoad

        pop     de                      ; Pass entity pointer in de
        ld      bc, r9_GreywolfOnMessage
	call    MessageQueueDrain

        ret


;;; ----------------------------------------------------------------------------


r9_GreywolfSetKnockback:
        ld      bc, GREYWOLF_VAR_KNOCKBACK
        call    EntityGetSlack
        ld      a, 100
        ld      [bc], a


        call    EntityGetPos
        ld      a, [var_player_coord_x]

        cp      b
        jr      C, .knockbackRight

.knockbackLeft:
        ld      bc, GREYWOLF_VAR_KNOCKBACK_DIR
        call    EntityGetSlack
        ld      a, 1
        ld      [bc], a
        ret

.knockbackRight:
        ld      bc, GREYWOLF_VAR_KNOCKBACK_DIR
        call    EntityGetSlack
        ld      a, 0
        ld      [bc], a
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

        call    EntityGetPos
	ld      a, [var_player_coord_x]
        call    r9_absdiff
        ld      b, a
        ld      a, 32
        cp      b
        jr      C, .skip

        call    EntityGetPos
        ld      a, [var_player_coord_y]
        ld      b, c
        call    r9_absdiff
        ld      b, a
        ld      a, 32
        cp      b
        jr      C, .skip

        call    r9_GreywolfSetKnockback

        ld      a, 7
        call    EntitySetPalette

        ld      de, GreywolfUpdateStunned
        call    EntitySetUpdateFn

        call    EntityAnimationResetKeyframe

        ld      bc, GREYWOLF_VAR_COUNTER
        call    EntityGetSlack
        ld      a, 0
        ld      [bc], a

        ld      bc, GREYWOLF_VAR_STAMINA
        call    EntityGetSlack
        ;; TODO: subtract stamina

        ld      bc, GREYWOLF_VAR_COLOR_COUNTER
        call    EntityGetSlack
        ld      a, 20
        ld      [bc], a

        call    EntityGetFrameBase
        ld      a, SPRID_GREYWOLF_L
        cp      b
        jr      Z, .left
        ld      a, SPRID_GREYWOLF_RUN_L
        cp      b
        jr      Z, .left
        ld      a, SPRID_GREYWOLF_R
        cp      b
        jr      Z, .right
        ld      a, SPRID_GREYWOLF_RUN_R
        cp      b
        jr      Z, .right

        ret

.right:
	ld      a, SPRID_GREYWOLF_STUN_R
        call    EntitySetFrameBase

        ld      a, [hl]
        or      ENTITY_TEXTURE_SWAP_FLAG
        ld      [hl], a

        ret

.left:
	ld      a, SPRID_GREYWOLF_STUN_L
        call    EntitySetFrameBase

        ld      a, [hl]
        or      ENTITY_TEXTURE_SWAP_FLAG
        ld      [hl], a

        ret
.skip:
        ret



;;; ----------------------------------------------------------------------------
