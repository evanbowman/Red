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


GREYWOLF_VAR_COLOR_COUNTER EQU 0
GREYWOLF_VAR_COUNTER       EQU 1
GREYWOLF_VAR_STAMINA       EQU 2 ; \
GREYWOLF_VAR_STAMINA2      EQU 3 ; | Fixnum
GREYWOLF_VAR_STAMINA3      EQU 4 ; /
GREYWOLF_VAR_SLAB          EQU 5
GREYWOLF_VAR_KNOCKBACK     EQU 6
GREYWOLF_VAR_KNOCKBACK_DIR EQU 7
GREYWOLF_VAR_REPEAT_STUNS  EQU 8
;;; Bytes 9 - 14 currently unused.
GREYWOLF_VAR_MAX           EQU 14



;;; Make sure vars fit within available entity slack space.
STATIC_ASSERT((GREYWOLF_VAR_MAX + 1) <= (32 - ENTITY_SIZE))


;;; ----------------------------------------------------------------------------


GreywolfUpdate:
;;; bc - self
        LONG_CALL r9_GreywolfUpdateIdleImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


GreywolfUpdateRunSeekX:
;;; bc - self
        LONG_CALL r9_GreywolfUpdateRunXImpl
        jp      EntityUpdateLoopResume


GreywolfUpdateRunSeekY:
;;; bc - self
        LONG_CALL r9_GreywolfUpdateRunYImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


GreywolfUpdateStunned:
;;; bc - self
        LONG_CALL r9_GreywolfUpdateStunnedImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


GreywolfUpdateAttacking:
;;; bc - self
        LONG_CALL r9_GreywolfUpdateAttackingImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


GreywolfUpdatePause:
;;; bc - self
        ld      h, b
        ld      l, c

        ld      bc, GREYWOLF_VAR_COUNTER
        fcall   EntityGetSlack
        ld      a, [bc]
        dec     a
        ld      [bc], a
        cp      0
        jr      Z, .idle

        jp      EntityUpdateLoopResume

.idle:
        ld      de, GreywolfUpdate
        fcall   EntitySetUpdateFn

        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


GreywolfUpdateDying:
;;; bc - self
        LONG_CALL r9_GreywolfUpdateDyingImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


GreywolfUpdateDead:
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------
