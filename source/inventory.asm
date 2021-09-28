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


InventoryGetItem:
;;; b - slot
;;; trashes hl
;;; return b - item type
;;; return c - count
        ld      hl, var_inventory
        ld      c, b
        sla     c
        ld      b, 0
        add     hl, bc
        ld      b, [hl]
        inc     hl
        ld      c, [hl]
        ret


;;; ----------------------------------------------------------------------------

InventoryRemoveItem:
;;; c - slot
;;; trashes hl
        ld      hl, var_inventory

        ld      b, 0
        sla     c               ; two bytes per item

        add     hl, bc

        ld      a, (INVENTORY_COUNT - 1) * ITEM_SIZE
        sub     c
	ld      c, a

        or      a
        jr      Z, .removeLastEntry

	ld      d, h
        ld      e, l

        inc     hl              ; memmove source at next item index
        inc     hl

        fcall   MemmoveLeft

.removeLastEntry:
        ld      hl, var_inventory_last_item
        ld      a, 0
        ld      [hl], a

        ret


;;; ----------------------------------------------------------------------------

InventoryAddItem:
;;; b - item
;;; trashes hl, c

;;; TODO: coallesce identical items, using second "count" byte?
        ld      hl, var_inventory
        ld      c, 0
.loop:
        ld      a, INVENTORY_COUNT
        cp      c
        jr      Z, .done

        ld      a, [hl]
        or      a
        jr      NZ, .next

        ld      [hl], b
        jr      .done
.next:
        inc     hl
        inc     hl
        inc     c
        jr      .loop
.done:
        ret


;;; ----------------------------------------------------------------------------

InventoryCountOccurrences:
;;; b - item
;;; trashes hl, c
;;; d - result
        ld      hl, var_inventory
        ld      c, 0
        ld      d, 0
.loop:
        ld      a, INVENTORY_COUNT
        cp      c
        jr      Z, .done

        ld      a, [hl]
        cp      b
        jr      Z, .inc
        jr      .next
.inc:
        inc     d

.next:
        inc     hl
        inc     hl
        inc     c
        jr      .loop
.done:
        ret


;;; ----------------------------------------------------------------------------

InventoryConsumeItem:
;;; b - item
;;; trashes hl, c
        ld      hl, var_inventory
        ld      c, 0
.loop:
        ld      a, INVENTORY_COUNT
        cp      c
        ret     Z

        ld      a, [hl]
        cp      b
        jr      NZ, .next

        fcall   InventoryRemoveItem
        ret

.next:
        inc     hl
        inc     hl
        inc     c
        jr      .loop


;;; ----------------------------------------------------------------------------

InventoryIsFull:
;;; trashes hl, c
;;; return a - true / false
        ld      hl, var_inventory
        ld      c, 0
.loop:
        ld      a, INVENTORY_COUNT
        cp      c
        jr      Z, .full

        ld      a, [hl]
        or      a
        jr      NZ, .next

        jr      .hasSlots
.next:
        inc     hl
        inc     hl
        inc     c
        jr      .loop

.hasSlots:
        ld      a, 0
        ret

.full:
        ld      a, 1
        ret


;;; ----------------------------------------------------------------------------
