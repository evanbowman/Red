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
;;;  Cutscene Code
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



CutsceneInit:
;;; d - map starting bank
;;; e - texture starting bank
;;; bc - location of texture offsets array
        ld      a, b                                ; \
        ld      [var_cutscene_offsets_array], a     ; | Store pointer to texture
        ld      a, c                                ; | offsets array.
        ld      [var_cutscene_offsets_array + 1], a ; /

        ld      a, d
        ld      [var_cutscene_map_bank], a
        ld      a, e
        ld      [var_cutscene_tile_start_bank], a
        ld      [var_cutscene_tile_current_bank], a
        xor     a
        ld      [rWY], a
        ld      [var_cutscene_tile_offset], a
        ret



;;; ----------------------------------------------------------------------------



;;; NOTE: this code must be placed in ROM0
CutscenePlay:
;;; c - framerate (# of frames to pause before rendering the next frame)
;;; d - number of frames
;;; e - rom bank to jump back to upon exit

;;; NOTE: Displaying a cutscene is a delicate operation, needs to be carfully
;;; calibrated to fit within the VBlank window. Therefore, we do not return control
;;; to the game's main loop while we render the cutscene.

        push    de              ; Store exit rom bank number

        ld      e, 0            ; frame number
.outerloop:

        ld      b, c            ; reload frame timer with framerate param

        ld      a, e
        cp      d               ; \ We've reached the desired frame count,
        jr      Z, .end         ; / return.

.innerloop:
        push    de
	push    bc
        LONG_CALL r1_ReadKeys
        ld      a, [hvar_joypad_raw]
        pop     bc
        pop     de
        and     PADF_B
        or      a
        jr      NZ, .skipped

        fcall   VBlankIntrWait

        dec     b
        xor     a
        cp      b
        jr      NZ, .innerloop

        inc     e               ; inc frame number
        push    bc              ; preserve framerate param on stack
        push    de
        fcall   CutsceneWriteFrame
        pop     de
        pop     bc

        jr      .outerloop

.end:
        pop     de              ; Restore exit rom bank number in e
        ld      d, 0
.return:
        ld      a, e            ; \ Set the result ROM bank. Allows the function
        SET_BANK_FROM_A         ; / to be called safely from anywhere.
        ret

.skipped:
        pop     de              ; Restore exit rom bank number in e
        ld      d, 1
        jr      .return


;;; ----------------------------------------------------------------------------


;; As per my own testing, we seem to be able to copy about 2kb at most
;; with a dma transfer. I successfully copied 128 tiles in a DMA
;; transfer with double-speed mode. Obviously, not enough to fill the
;; whole screen with stuff. Instead, we copy both tiles and textures,
;; where only a certain number of tiles in a frame are allowed to be
;; unique.
;;
;; The visible area of the GBC screen consists of 20x18 tiles. For the
;; sake of efficiency, we will need to copy a bunch of wasted tiles at
;; the end of each row (32 tiles per row). 32*18 = 576 bytes. GDMA
;; copies in 16 byte blocks, i.e. 576 / 16 = 36 DMA iterations to copy
;; the tile data, which leaves us under 92 unique tiles per frame, while
;; the full visible frame consists of 360 tiles (so at most, only one
;; quarter of a frame's tiles can be unique). By definition, then, our
;; cutscene animations must use large planes of relatively flat color,
;; allowing us to recycle tiles.

;;; NOTE: this code must be placed in ROM0
CutsceneWriteFrame:
;;; e - frame number (TODO)
;;; trashes pretty much all registers

;;; calculating frame number...
;;; Each Frame consists of map data and textures.
;;; 576 bytes per chunk of map data, so frame * 576 gives offset to load from.

        push    de              ; Store e (frame number) for later

        ld      a, [var_cutscene_map_bank] ; \ Switch to bank with cutscene
	SET_BANK_FROM_A                    ; / map data.


        ;; n * 512 + n * 64
        ld      a, e
        ld      b, a            ; \ Moving the lower byte to the upper byte and
        ld      c, 0            ; | left-shifting by 1 achieves a 512
        sla     b               ; / multiplication.

        push    bc              ; store bc for later

        ld      b, 0            ; \
        ld      c, a            ; |
        fcall   Mul32           ; |
        sla     b               ; | n * 64
        sla     c               ; |
        ld      a, b            ; |
        adc     0               ; |
        ld      b, a            ; /

        pop     hl              ; restore previous bc into hl
        add     hl, bc          ; (n * 64) + (n * 512)

        ld      b, h                           ; \
        ld      c, l                           ; | Add offset n * 576 to ROM
        ld      hl, r12_cutscene_test_map_data ; | data pointer.
        add     hl, bc                         ; /

        ld      de, $9C00       ; \ Copy tilemap data to VRAM.
        ld      b, 35           ; | 36 - 1, DMA copies n+1 blocks
        fcall   GDMABlockCopy   ; /


	;; Ok, now that we got that out of the way, we want to copy the actual
        ;; texture data.

	ld	a, 1
	ld	[rVBK], a


	ld      a, [var_cutscene_tile_current_bank] ; \ Switch to bank with cutscene
	SET_BANK_FROM_A                             ; / texture data.

        pop     de              ; See fn top, where we store frame num on stack
        xor     a               ; \
        sla     e               ; | Multiply frame number by two, because each
        adc     0               ; | texture offset occupies two bytes.
        ld      d, a            ; /

        ld      a, [var_cutscene_offsets_array]     ; \
        ld      h, a                                ; | Load pointer to texture
        ld      a, [var_cutscene_offsets_array + 1] ; | offsets array.
        ld      l, a                                ; /

        add     hl, de          ; Seek offset into tile counts array
        ld      e, [hl]         ; \
        inc     hl              ; | Load offset into de
        ld      d, [hl]         ; /


        ld      hl, r20_cutscene_test_tile_textures
	add     hl, de          ; Add previously calculated offset to texture array

        ld      de, $8800
        ld      b, 85           ; FIXME: could copy 89, except for palette swap in cutscene
        fcall   GDMABlockCopy

        xor     a
	ld	[rVBK], a

        ret


;;; ----------------------------------------------------------------------------
