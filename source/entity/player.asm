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
;;;  Player
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$




;;; ----------------------------------------------------------------------------


PlayerUpdate:
        ;; Moved to rom bank 9 to save space.
        LONG_CALL r9_PlayerUpdateImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


PlayerUpdatePickupItem:
        LONG_CALL r9_PlayerUpdatePickupItemImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


PlayerUpdateUnlockDoor:
        LONG_CALL r9_PlayerUpdateUnlockDoorImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


PlayerUpdateAttack1:
        LONG_CALL r9_PlayerUpdateAttack1Impl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


PlayerUpdateAttack2:
        LONG_CALL r9_PlayerUpdateAttack2Impl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


PlayerUpdateAttack3:
        LONG_CALL r9_PlayerUpdateAttack3Impl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


PlayerAttack1Exit:
        LONG_CALL r9_PlayerAttack1ExitImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


PlayerAttack2Exit:
        LONG_CALL r9_PlayerAttack2ExitImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


PlayerAttack3Exit:
        LONG_CALL r9_PlayerAttack3ExitImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


PlayerRaiseHammer:
        LONG_CALL r9_PlayerRaiseHammerImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


PlayerWaitHammer:
        LONG_CALL r9_PlayerWaitHammerImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


PlayerDropHammer:
        LONG_CALL r9_PlayerDropHammerImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------


PlayerDropHammerRecover:
        LONG_CALL r9_PlayerDropHammerRecoverImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------

PlayerDialogIdle:
        LONG_CALL r9_PlayerDialogIdleImpl
        jp      EntityUpdateLoopResume


;;; ----------------------------------------------------------------------------
