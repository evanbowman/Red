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
;;;  Intro Cutscene Scene
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



intro_credits_line1_str::
DB      "Evan Bowman", 0


intro_credits_line2_str::
DB      "presents", 0


intro_credits_line3_str::
DB      "winter 1792", 0




intro_credits_bkg_palette_0::
DB      $BF,$73, $0B,$21, $1A,$20, $00,$04,

intro_credits_bkg_palette::
DB      $BF,$73, $0B,$21, $00,$04, $1A,$20,

intro_credits_bkg_palette_2::
DB      $BF,$73, $d3,$3d, $00,$04, $1A,$20,



;;; ----------------------------------------------------------------------------

IntroCutsceneSetup:
        ;; This function mostly just places attributes in vram, assigning
        ;; palettes/attributes to tiles before beginning the animation.
        fcall   LcdOff
        ld	a, 1
	ld	[rVBK], a
        ld      hl, $9C00
        ld      bc, 576
        ld      a, $88
        fcall   Memset
        fcall   LcdOn
        ld      a, 0
        ld	[rVBK], a
        ret


;;; ----------------------------------------------------------------------------

IntroCutsceneSceneEnter:
        fcall   IntroCutsceneSetup


        fcall   VBlankIntrWait

        ;; ...
        ld      d, 13           ; \ bank containing map data
        ld      e, 21           ; | bank containing tile textures
        ld      bc, r21_cutscene_wolf_texture_offsets
        fcall   CutsceneInit    ; /

        ld      e, 0                    ; \ frame number
        fcall   CutsceneWriteFrame      ; /


        fcall   VBlankIntrWait
        ld      hl, intro_credits_bkg_palette_0
        ld      b, 8
        fcall   LoadBackgroundColors

        ld      a, 7
        ld      [rWX], a

        ld      a, 0
        ld      [var_scene_counter], a

        fcall   VBlankIntrWait

        ld      e, 0            ; frame number
        fcall   CutsceneWriteFrame

        ld      de, IntroCutsceneSceneUpdate
        fcall   SceneSetUpdateFn

        ;; fixme: accidental fallthrough which isn't actually problematic

;;; ----------------------------------------------------------------------------

IntroCutsceneSceneUpdate:

        fcall   VBlankIntrWait
        ld      b, $88
        ld      de, $9ce4
        ld      hl, intro_credits_line3_str
        fcall   PutText


        ld      e, 154
        fcall   ForceSleep


        fcall   VBlankIntrWait
	ld      e, 0            ; frame number
        fcall   CutsceneWriteFrame


        ;; ok, so why all this weirdness (below)? Our font uses a specific color
        ;; palette, while our cutscene uses a different color palette. We play
        ;; the first frame with a couple colors swapped, in order to display a
        ;; black background. FIXME: give the text its own palette.
        fcall   VBlankIntrWait
        ld      hl, intro_credits_bkg_palette
        ld      b, 8
        fcall   LoadBackgroundColors
        ld      e, 1            ; frame number
        fcall   CutsceneWriteFrame
        ;; end weirdness

        ld      e, 2
        fcall   ForceSleep


        ;; Play the first cutscene, wolf turns to look at camera
	ld      d, 12           ; number of frames
        ld      e, BANK(@)      ; our own bank
        ld      c, 6            ; framerate
        fcall   CutscenePlay

	ld      e, 30           ; \ frames to sleep
        fcall   ForceSleep      ; /


        ;; Setup second cutscene sequence
        ld      d, 12           ; \ bank containing map data
        ld      e, 20           ; | bank containing tile textures
        ld      bc, r20_cutscene_test_texture_offsets
        fcall   CutsceneInit    ; /

        fcall   VBlankIntrWait
        ld      e, 0
        fcall   CutsceneWriteFrame


        fcall   VBlankIntrWait              ; \
        ld      b, $88                      ; |
        ld      de, $9cc5                   ; |
        ld      hl, intro_credits_line1_str ; | Show intro credits text
        fcall   PutText                     ; |
        ld      b, $88                      ; |
        ld      de, $9d06                   ; |
        ld      hl, intro_credits_line2_str ; |
        fcall   PutText                     ; /


        ld      e, 154
        fcall   ForceSleep

        ;; Play second cutscene sequence
        ld      d, 24
        ld      e, BANK(@)      ; our own bank
        ld      c, 6            ; framerate
        fcall   CutscenePlay


        ld      e, 23           ; \ frames to sleep
        fcall   ForceSleep      ; /


        ;; Third second cutscene sequence
        ld      d, 14           ; \ bank containing map data
        ld      e, 22           ; | bank containing tile textures
        ld      bc, r22_cutscene_face_texture_offsets
        fcall   CutsceneInit    ; /


	fcall   VBlankIntrWait                  ; \
        ld      hl, intro_credits_bkg_palette_2 ; |
        ld      b, 8                            ; | Swap palette and display the
        fcall   LoadBackgroundColors            ; | first frame of the next
        ld      e, 0                            ; | sequence.
        fcall   CutsceneWriteFrame              ; /


        ld      d, 11
        ld      e, BANK(@)      ; our own bank
        ld      c, 11           ; framerate
        fcall   CutscenePlay

        fcall   OverworldSceneUpdateView

        ld      de, OverworldSceneEnter
        fcall   SceneSetUpdateFn
        ret

;;; ----------------------------------------------------------------------------
