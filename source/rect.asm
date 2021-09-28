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
;;; HitRect
;;;
;;;
;;; For checking intersection between bounding boxes.
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


;;;
;;; Rect = { Point tl, Point br }
;;;
;;; Point = { u8 x, u8 y }
;;;


;;; ----------------------------------------------------------------------------


CheckXIntersection:
;;; hl - rect1
;;; de - rect2
;;; trashes b
;;; return a - true if intersection, false otherwise
	inc     de
        inc     de              ; rect2.x2 is third byte in struct

        ld      b, [hl]         ; rect1.x1
        ld      a, [de]         ; rect2.x2
        cp      b
        jr      C, .failed      ; rect2.x2 < rect1.x1, so no intersection

        inc     hl              ; move hl to rect1.x2
        inc     hl
        dec     de              ; rest de to beginning
        dec     de

        ld      a, [de]         ; rect2.x1
        ld      b, a
        ld      a, [hl]         ; rect1.x2
        cp      b
        jr      C, .failed      ; rect1.x2 < rect2.x1, so no intersection

        ld      a, 1
        ret
.failed:
        ld      a, 0
        ret


CheckIntersection:
;;; hl - rect1
;;; de - rect2
;;; trashes b
;;; return a - true if intersection, false otherwise

;;; Expected layout in struct:
;;; Rect1 { x1, y1, x2, y2 }
;;; Rect2 { x1, y1, x2, y2 }

        inc     de
        inc     de              ; rect2.x2 is third byte in struct

        ld      b, [hl]         ; rect1.x1
        ld      a, [de]         ; rect2.x2
        cp      b
        jr      C, .failed      ; rect2.x2 < rect1.x1, so no intersection

        inc     hl              ; move hl to rect1.x2
        inc     hl
        dec     de              ; rest de to beginning
        dec     de

        ld      a, [de]         ; rect2.x1
        ld      b, a
        ld      a, [hl]         ; rect1.x2
        cp      b
        jr      C, .failed      ; rect1.x2 < rect2.x1, so no intersection

        dec     hl              ; move hl to rect1.y1
        inc     de              ; move de to rect2.y2
        inc     de
        inc     de

        ld      b, [hl]         ; rect1.y1
        ld      a, [de]         ; rect2.y2

        cp      b
        jr      C, .failed      ; rect2.y2 < rect1.y1, so no intersection

        inc     hl              ; move hl to rect1.y2
        inc     hl

        dec     de              ; move de to rect2.y1
        dec     de

        ld      a, [de]         ; rect2.y1
        ld      b, a
        ld      a, [hl]         ; rect1.y2

        cp      b
        jr      C, .failed      ; rect1.y2 < rect2.y1, so no intersection

        ld      a, 1
        ret

.failed:
        ld      a, 0
        ret


;;; ----------------------------------------------------------------------------
