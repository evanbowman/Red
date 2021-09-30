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


;;; Red uses huge character animations, and the engine needs to prevent too many
;;; entities from ending up on the same line. We use a datastructure that we're
;;; calling a slab table, which represents subsections of the current room in
;;; the game world.
;;; At maximum size, an entity may take up as much as 32x32 pixels (eight oam),
;;; i.e. four oam wide. But entities have drop shadows too, so, really, an
;;; an entity uses six oam at its widest point. We can really only allow two
;;; entities per row in the game world. So we want to divide the game world
;;; into eight slabs, where each slab may contain a single enemy. The logic may
;;; get a bit more complicated, though:
;;; e.g. let's suppose that an entity occupies a slab, and another entity wants
;;; to cross over that row on the way to the player. Technically, we can allow
;;; this, right? As long as the entity does not linger in the same row for two
;;; long. But, what if an entity wants to cross over a row, and both the player
;;; and another entity are already in the row? Do we prevent the entity from
;;; moving, or just accept the momentary graphical abberation as it passes by?


GetSlabNum:
;;; a - absolute y position
        and     $f0             ; \
        swap    a               ; | Slab num = y / 32
        srl     a               ; /
        ret


;;; ----------------------------------------------------------------------------


GetSlabY:
;;; a - slab num
        swap    a               ; \ y = slab num * 32
        sla     a               ; /
        ret


;;; ----------------------------------------------------------------------------


SLAB_MAX_WEIGHT EQU 7           ; (six oam)


;;; Try to bind to a row in the slab table. Fails if the row currently exceeds
;;; the max allowed weight.
SlabTableBind:
;;; c - row
;;; d - add weight
;;; trashes hl, b
;;; return a - true if successful, false otherwise
        ld      hl, var_map_slabs
        ld      b, 0
        add     hl, bc

        ld      a, [hl]
        add     d
	cp      SLAB_MAX_WEIGHT
        jr      C, .bind

        ld      a, 0
        ret

.bind:
        ld      [hl], a
        ld      a, 1
        ret


;;; ----------------------------------------------------------------------------

SlabTableRowWeight:
;;; c - row
;;; a - result weight
;;; trashes b, hl
        ld      hl, var_map_slabs
        ld      b, 0
        add     hl, bc

        ld      a, [hl]
        ld      d, a
        ret


;;; ----------------------------------------------------------------------------

SlabTableIsRowFull:
;;; c - row
;;; a - bool result
;;; trashes b, hl
        fcall   SlabTableRowWeight
        cp      (SLAB_MAX_WEIGHT - 1)
        ld      a, 0            ; \ If less than max weight, ret 0
        ret     C               ; /
        ld      a, 1
        ret


;;; ----------------------------------------------------------------------------


SlabTableRebindNearest:
;;; b - current row
;;; c - desired row
;;; d - required weight
;;; trashes hl, b
;;; return c - result
        push    bc

	push    bc                      ; \
        ld      c, b                    ; | Free the row that we're currently
        fcall   SlabTableUnbind         ; | using in the table.
        pop     bc                      ; /


        fcall   SlabTableGetNearestAvail
        or      a                       ; \ If there is no row available, remain
        jr      Z, .reset               ; / in current row.

        fcall   SlabTableBind

        pop     hl                      ; pop bc into hl, we want to preserve bc

        ret

.reset:
        pop     bc
        ld      c, b                    ; \ Rebind ourself to the row that we're
        fcall   SlabTableBind           ; / currently in.
        ret


;;; ----------------------------------------------------------------------------


;;; Attemts to find a free slot in the desired row, or in the row above or below
;;; the desired row.
SlabTableGetNearestAvail:
;;; c - desired row
;;; d - required weight
;;; result a - success/failure
;;; result c - found row (if success)
;;; trashes hl, b
        ld      hl, var_map_slabs
        ld      b, 0
        add     hl, bc

.loop:
        ld      a, [hl]
        add     d
        cp      SLAB_MAX_WEIGHT
        jr      C, .found


        ld      a, 0
        cp      c
        jr      Z, .nodec

	dec     c
        dec     hl

        ld      a, [hl]
        add     d
        cp      SLAB_MAX_WEIGHT
        jr      C, .found

        inc     c
        inc     hl
.nodec:

        ld      a, 7
        cp      c
        jr      Z, .noinc

        inc     c
        inc     hl

        ld      a, [hl]
        add     d
        cp      SLAB_MAX_WEIGHT
        jr      C, .found

.noinc:

        ld      a, 0
        ret

.found:
        ld      a, 1
        ret


;;; ----------------------------------------------------------------------------


SlabTableUnbind:
;;; c - row
;;; d - remove weight
;;; trashes hl, b
        ld      hl, var_map_slabs
        ld      b, 0
        add     hl, bc

        ld      a, [hl]
        sub     d
        ld      [hl], a
        ret


;;; ----------------------------------------------------------------------------


;;; This is intended for setting the initial slab for each enemy when loading a
;;; room. When we exited the previous room, we stored each entity's coordinates
;;; in 16x16 room coords. If two entities were in the process of moving to a
;;; different slab, and were overlapping when exiting the room, we'll have
;;; trouble when reloading the room, and assigning the entities' initial slab.
;;; So, simply bind any random unused one, and allow the entity update code to
;;; reallocate a better slab later.
SlabTableFindAnyUnused:
;;; d - required weight
        ld      hl, var_map_slabs
        ld      c, 0
.loop:
        ld      a, [hl]
        add     d
        cp      SLAB_MAX_WEIGHT
        jr      C, .found       ; a < required

        inc     c
        inc     hl
        jr      .loop

        ;; FIXME: we couldn't find any free space in a single slab in the whole
        ;; table. Hmm... we should never actually have this many entities
        ;; anyway, the engine only supports eight entities per room, and there
        ;; are eight slabs, so...
.error:
        jr      .error

        ret
.found:
        ret


;;; ----------------------------------------------------------------------------
