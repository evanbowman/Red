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


GreywolfIdleSetFacing:
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


GreywolfUpdate:
;;; bc - self
        ld      h, b                    ; \ Update functions are invoked through
        ld      l, c                    ; / hl, so it can't be a param :/

        ;; call    GreywolfIdleSetFacing

        ld      e, 6
        ld      d, 5
        call    EntityAnimationAdvance


        call    EntityGetSlack
        ld      a, [bc]
        cp      a, 0
        jr      NZ, .decColorCounter

	ld      a, 3
        call    EntitySetPalette

        jr      .next

.decColorCounter:
        dec     a
        ld      [bc], a

.next:

;;         ld      a, [var_player_attack]
;;         cp      PLAYER_ATTACK_NONE
;;         jr      Z, .resetColor

;;         ld      a, 7
;;         call    EntitySetPalette

;;         jr      .done

;; .resetColor:
;; 	ld      a, 3
;;         call    EntitySetPalette

        push    hl                      ; Store entity pointer on stack

        call    EntityGetMessageQueue
        call    MessageQueueLoad

        pop     de                      ; Pass entity pointer in de
        ld      bc, GreywolfOnMessage
	call    MessageQueueDrain

.done:
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


GreywolfOnMessage:
;;; bc - message pointer
;;; de - self
        ld      a, [bc]
        cp      a, MESSAGE_PLAYER_KNIFE_ATTACK
        jr      Z, .onPlayerKnifeAttack

        ret

.onPlayerKnifeAttack:
        ld      h, d
        ld      l, e

        ld      a, 7
        call    EntitySetPalette

        call    EntityGetSlack
        ld      a, 20
        ld      [bc], a
        ret


;;; ----------------------------------------------------------------------------
