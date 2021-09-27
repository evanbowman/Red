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
;;;  Intro Credits Scene
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


intro_credits_line1_str::
DB      "Evan Bowman", 0

intro_credits_line2_str::
DB      "presents", 0


intro_credits_line3_str::
DB      "winter 1792", 0


intro_credits_bkg_palette::
DB      $BF,$73, $0B,$21, $00,$04, $1A,$20,



;;; ----------------------------------------------------------------------------



IntroCreditsSceneEnter:
        call    IntroCutsceneSetup

        call    VBlankIntrWait

        ld      d, 12           ; \ bank containing map data
        ld      e, 20           ; | bank containing tile textures
        call    CutsceneInit    ; /

        ld      e, 0                    ; \ frame number
        call    CutsceneWriteFrame      ; /


        call    VBlankIntrWait
        ld      hl, intro_credits_bkg_palette
        ld      b, 8
        call    LoadBackgroundColors

        ld      a, 7
        ld      [rWX], a

        ld      a, 0
        ld      [var_scene_counter], a

        ld      de, IntroCreditsSceneUpdate
        call    SceneSetUpdateFn


        SET_BANK 7


        call    VBlankIntrWait

        ld      b, $88
        ld      de, $9cc5
        ld      hl, intro_credits_line1_str
        call    PutText

        ld      b, $88
        ld      de, $9d06
        ld      hl, intro_credits_line2_str
        call    PutText

        SET_BANK 1

        ret


;;; ----------------------------------------------------------------------------

IntroCreditsSceneUpdate:
        ld      a, [var_scene_counter]
        inc     a
        ld      [var_scene_counter], a
        cp      154
        jr      Z, .nextScene
	jr      .done

.nextScene:
        ;; call    OverworldSceneUpdateView

        ;; ld      de, OverworldSceneEnter
        ;; call    SceneSetUpdateFn

	ld      de, IntroCutsceneSceneEnter
        call    SceneSetUpdateFn

.done:
        ret


;;; ----------------------------------------------------------------------------
