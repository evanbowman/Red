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


;;;
;;; The game world consists of twelve sectors, where eighteen rooms comprise
;;; each sector.
;;;
;;; R - room
;;; S - sector
;;;
;;;     Sector:
;;; ===============
;;; | R R R R R R |
;;; | R R R R R R |
;;; | R R R R R R |
;;; | R R R R R R |
;;; ===============
;;;
;;;   World:
;;; =========
;;; | S S S |  Sectors numbered:  1 2 3
;;; | S S S |                     4 5 6
;;; | S S S |                     etc.
;;; | S S S |
;;; =========
;;;
;;; The world generation algorithm composes* the game world by randomly
;;; selecting from a set of pre-defined sectors, and placing them into the
;;; world.
;;;
;;; * That's the plan, anyway. I'm going to add the code for generating the
;;; world later, for now, I'm using a static world map.
;;;


;;; ----------------------------------------------------------------------------

GetSectorX:
        ;; We could divide by six... but the map is known to be 18x16, and it's
        ;; faster to simply do a few comparisons.
        ld      a, [var_room_x]
        cp      (18 / 3)
        jr      C, .one
        cp      2 * (18 / 3)
        jr      C, .two
        ld      a, 3
        ret
.one:
        ld      a, 1
        ret
.two:
        ld      a, 2
        ret


;;; ----------------------------------------------------------------------------

CurrentSector:
;;; x result in b
;;; y result in c
        fcall   GetSectorX
        ld      b, a
        ld      a, [var_room_y]
        srl     a               ; \
        srl     a               ; | Room y / 4 == sector y
        ld      c, a            ; /
        ret


;;; ----------------------------------------------------------------------------

CurrentSectorNum:
;;; trashes bc
;;; result in a
        fcall   CurrentSector
        ld      a, 0            ; \
        add     c               ; | a <- y * 3
        add     c               ; |
        add     c               ; /
        add     b               ; y * 3 + x == linear sector number
        ret


;;; ----------------------------------------------------------------------------

;;; A convenience function for indexing into a lookup table based on the current
;;; sector number.
SectorLutGet:
;;; hl - lookup table
;;; trashes hl, bc
;;; a - result
        fcall   CurrentSectorNum
        ld      c, a
        ld      b, 0
        add     hl, bc
        ld      a, [hl]
        ret


;;; ----------------------------------------------------------------------------
