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


r8_InventoryTiles::
DB $00,$FF,$00,$FF,$00,$FF,$10,$E0
DB $00,$E0,$80,$E7,$07,$E7,$07,$E7
DB $00,$FF,$00,$FF,$00,$FF,$08,$07
DB $00,$07,$00,$E7,$E0,$E7,$E0,$E7
DB $E0,$E7,$E0,$E7,$E0,$E7,$00,$07
DB $08,$07,$00,$FF,$00,$FF,$00,$FF
DB $07,$E7,$07,$E7,$07,$E7,$00,$E0
DB $10,$E0,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$00
DB $00,$00,$00,$FF,$FF,$FF,$FF,$FF
DB $07,$E7,$07,$E7,$07,$E7,$07,$E7
DB $07,$E7,$07,$E7,$07,$E7,$07,$E7
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $E0,$E7,$E0,$E7,$E0,$E7,$E0,$E7
DB $E0,$E7,$E0,$E7,$E0,$E7,$E0,$E7
DB $FF,$FF,$FF,$FF,$FF,$FF,$00,$00
DB $00,$00,$00,$FF,$00,$FF,$00,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$DF,$DF,$9F,$9F
DB $1F,$1F,$9F,$9F,$DF,$DF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FB,$FB,$F9,$F9
DB $F8,$F8,$F9,$F9,$FB,$FB,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
r8_InventoryTilesEnd::

r8_InventoryLowerBoxTopRow::
DB $30, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34
DB $34, $34, $34, $34, $31
r8_InventoryLowerBoxTopRowEnd::

r8_InventoryLowerBoxBottomRow::
DB $33, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38
DB $38, $38, $38, $38, $32
r8_InventoryLowerBoxBottomRowEnd::

r8_InventoryLowerBoxMiddleRow::
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $00, $00, $00, $37
r8_InventoryLowerBoxMiddleRowEnd::


r8_InventoryImageBoxTopRow::
DB $30, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $31, $30, $34, $34,
DB $34, $34, $34, $34, $31
r8_InventoryImageBoxTopRowEnd::

r8_InventoryImageBoxBottomRow::
DB $33, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $32, $33, $38, $38
DB $38, $38, $38, $38, $32
r8_InventoryImageBoxBottomRowEnd::

r8_InventoryImageBoxMiddleRow::
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $37, $35, $00, $00
DB $00, $00, $00, $00, $37
r8_InventoryImageBoxMiddleRowEnd::


r8_InventoryPalettes::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $00,$00, $00,$00, $00,$00, $00,$00
DB $00,$00, $00,$00, $00,$00, $00,$00
DB $00,$00, $00,$00, $00,$00, $00,$00
DB $00,$00, $00,$00, $00,$00, $00,$00
DB $00,$00, $00,$00, $00,$00, $00,$00
DB $00,$00, $00,$00, $00,$00, $00,$00
r8_InventoryPalettesEnd::


r8_InventoryImgRow1::
DB $40, $41, $42, $43
r8_InventoryImgRow2::
DB $44, $45, $46, $47
r8_InventoryImgRow3::
DB $48, $49, $4a, $4b
r8_InventoryImgRow4::
DB $4c, $4d, $4e, $4f


;;; ----------------------------------------------------------------------------

INVENTORY_TAB_ITEMS     EQU     0
INVENTORY_TAB_CRAFT     EQU     1
INVENTORY_TAB_COUNT     EQU     2


r8_InventoryGetTabText:
        ld      a, [var_inventory_scene_tab]
        cp      INVENTORY_TAB_ITEMS
        jr      Z, .items
        cp      INVENTORY_TAB_CRAFT
        jr      Z, .craft
.items:
	ld      hl, r8_InventoryTabItemsText
        ret
.craft:
	ld      hl, r8_InventoryTabCraftText
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryShowTabHeading:
        call    r8_InventoryGetTabText

        ld      de, $9c22
        ld      b, $89
        call    PutText
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryGetCraftableItem:
        ld      hl, var_inventory_scene_craftable_items_list
        ld      c, b
        ld      b, 0
        add     hl, bc
        ld      b, [hl]
        ld      c, 0
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryTabLoadItem:
;;; b - row
        ld      a, [var_inventory_scene_tab]
        cp      a, INVENTORY_TAB_ITEMS
        jr      Z, .items
        cp      a, INVENTORY_TAB_CRAFT
        jr      Z, .craft

.items:
        call    InventoryGetItem
        ret

.craft:
        call    r8_InventoryGetCraftableItem
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryLowerBoxInitRow:
;;; de - address
        ld      hl, r8_InventoryLowerBoxMiddleRow
        ld      bc, r8_InventoryLowerBoxMiddleRowEnd - r8_InventoryLowerBoxMiddleRow
        call    VramSafeMemcpy
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryImageBoxInitRow:
;;; de - address
        ld      hl, r8_InventoryImageBoxMiddleRow
        ld      bc, r8_InventoryImageBoxMiddleRowEnd - r8_InventoryImageBoxMiddleRow
        call    VramSafeMemcpy
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryTextRowAddress:
;;; a - row
;;; return address in hl
;;; trashes bc

;;; We only have seven rows onscreen, so we can multiply by 32 without
;;; much trouble
        swap    a
        and     $f0
        sla     a
        ld      c, a
        ld      b, 0

        ld      hl, $9d21
        add     hl, bc

        ret


;;; ----------------------------------------------------------------------------

r8_SmallStrlen:
;;; hl - text
;;; return c - len
        ld      c, 0
.loop:
        ld      a, [hl]
        cp      0
        ret     Z

        inc     c
        inc     hl
        jr      .loop


;;; ----------------------------------------------------------------------------

r8_InventoryPutTextRow:
;;; a - row
;;; b - attributes
;;; hl - text

        push    hl
        push    hl
        push    bc

        call    r8_InventoryTextRowAddress

        ld      d, h
        ld      e, l

        pop     bc
        pop     hl

        call    PutText

        ;; Now, fill the rest of the row with spaces. PutText should leave
        ;; de in the correct position to keep on going...
        pop     hl

        call    r8_SmallStrlen

        ld      a, 18
        sub     c
        ld      c, a

.loop:
        ld      a, 0
        cp      c
        jr      Z, .done

        ld      a, $32
	ld      [de], a

        ld      a, 1
        ld      [rVBK], a
        ld      a, b
        ld      [de], a
        ld      a, 0
	ld      [rVBK], a

        dec     c
        inc     de
        jr      .loop
.done:
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryItemText:
;;; a - row
        ld      b, a
        call    r8_InventoryTabLoadItem

        ld      c, b
        ld      b, 0
        call    r8_Mul16

        ld      hl, r8_InventoryItemTextTable
        add     hl, bc

        ret


;;; ----------------------------------------------------------------------------


r8_InventoryAdjustOffset:
;;; a - input
        push    af
	ld      a, [var_inventory_scene_page]
        or      a
        jr      NZ, .secondPage
        pop     af
        ret
.secondPage:
        pop     af
        add     7
        ret


r8_InventoryGetSelectedIndex:
        ld      a, [var_inventory_scene_selected_row]
        call    r8_InventoryAdjustOffset
        ret


r8_InventoryInitText:
        ld      a, 0
.loop:
        cp      7
        jr      Z, .loopDone
	push    af

        push    af
        call    VBlankIntrWait
        pop     af
	push    af
        ld      b, a
        ld      a, [var_inventory_scene_selected_row]
        cp      b
        ld      b, $89
        jr      NZ, .skipHighlight
        ld      b, $8A
.skipHighlight:
        pop     af

	push    af
        push    bc
        call    r8_InventoryAdjustOffset
        call    r8_InventoryItemText
        pop     bc
        pop     af

        call    r8_InventoryPutTextRow

	pop     af
        inc     a
        jr      .loop

.loopDone:

        ret


;;; ----------------------------------------------------------------------------

r8_InventoryTextRowSetAttr:
;;; a - row num
;;; b - attribute
        push    bc
        call    r8_InventoryTextRowAddress
        pop     bc

        ld      d, 0
.loop:
        ld      [hl], b

        inc     hl
        inc     d
        ld      a, 18
        cp      d
        jr      NZ, .loop

        ret


;;; ----------------------------------------------------------------------------

r8_InventoryUpdateImageCopyAttributeRow:
;;; de - current attribute pointer
;;; hl - attributes pointer

        ld      bc, 4
        push    hl
        push    de
        call    VramSafeMemcpy
        pop     de
        pop     hl

        ld      bc, 4
        add     hl, bc

        push    hl
        ld      h, d
        ld      l, e

        ld      bc, 32
        add     hl, bc          ; jump a row in screen ram

        ld      d, h
        ld      e, l
        pop     hl
        ret


;;; ----------------------------------------------------------------------------

r8_Mul16:
;;; bc - number
;;; trashes d
;;; result in bc
        ld      a, c
        and     $f0
        swap    a
        ld      d, a

        ld      a, b
        swap    a
        and     $f0
        or      d
        ld      a, b

        ld      a, c
        swap    a
        and     $f0
        ld      c, a

        ret


;;; ----------------------------------------------------------------------------

r8_InventoryUpdateImage:
        call    VBlankIntrWait

        call    r8_InventoryGetSelectedIndex
        ld      b, a
        call    r8_InventoryTabLoadItem
	ld      c, b
	ld      b, 0

        ;; Dma copy the image to vram.
        push    bc

        ld      hl, r8_InventoryItemIcons

        ld      b, c            ; Swap byte order, fast mul x 256 (32x32p image)
        ld      c, 0
        add     hl, bc

        ld      de, $9400
        ld      b, 15
        call    GDMABlockCopy

        pop     bc
        push    bc

	ld      hl, r8_InventoryItemAttributes

        call    r8_Mul16                ; 16 bytes per attribute block

        add     hl, bc

        ;; Now, copy over the attributes
        ld      a, 1
        ld	[rVBK], a

        ld      de, $9c4e

        call    r8_InventoryUpdateImageCopyAttributeRow
        call    r8_InventoryUpdateImageCopyAttributeRow
        call    r8_InventoryUpdateImageCopyAttributeRow
        call    r8_InventoryUpdateImageCopyAttributeRow

        ld      a, 0
        ld	[rVBK], a

        pop     bc

        ld      hl, r8_InventoryItemPalettes
        call    r8_Mul64                ; 64 bytes per palette
        add     hl, bc

        ld      a, [rLY]
        cp      145
        jr      C, .vsync
        jr      .copyColors
.vsync:
;;; We should never reach here, the code is fast enough to run within the blank
;;; window. But just in case...
        call    VBlankIntrWait
.copyColors:
        ld      b, 64
        call    LoadBackgroundColors

        ret



;;; ----------------------------------------------------------------------------


r8_Mul64:
;;; bc - number to shift by six
        ld      d, c
        ;; Right-shift contents of c by two, so upper six bits are now lsb
        srl     d
        srl     d

        ;; swap upper and lower nibbles in b, then shift left, and mask off upper two
        swap    b
        sla     b
        sla     b
        ld      a, b
        and     $c0

        ;; combine with the six bits from lower byte
        or      d
        ld      b, a

        ld      a, c
        swap    a
        sla     a
        sla     a
        and     $c0
        ld      c, a

        ret


;;; ----------------------------------------------------------------------------

r8_InventoryLoadCraftableItems:
        ld      hl, var_inventory_scene_craftable_items_list
        ld      bc, CRAFTABLE_ITEMS_COUNT
        ld      a, 0
        call    Memset

        ;; TODO...

        ret


;;; ----------------------------------------------------------------------------

r8_InventorySetTab:
        call    VBlankIntrWait

        call    r8_InventoryShowTabHeading

        ld      a, 0
        ld      [var_inventory_scene_selected_row], a
        ld      [var_inventory_scene_page], a

        ld      a, [var_inventory_scene_tab]
        cp      INVENTORY_TAB_ITEMS
        jr      .loadItemsTab
        cp      INVENTORY_TAB_CRAFT
        jr      .loadCraftTab

.loadItemsTab:
	call    r8_InventoryInitText
        call    r8_InventoryUpdateImage
        ret

.loadCraftTab:
        call    r8_InventoryLoadCraftableItems
	call    r8_InventoryInitText
        call    r8_InventoryUpdateImage
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryTabRight:
        ld      a, [var_inventory_scene_tab]
        inc     a
        cp      INVENTORY_TAB_COUNT
        jr      NZ, .skip
        ld      a, INVENTORY_TAB_ITEMS
.skip:
        ld      [var_inventory_scene_tab], a

        call    r8_InventorySetTab

        ret


;;; ----------------------------------------------------------------------------

r8_InventoryTabLeft:
        ld      a, [var_inventory_scene_tab]
        cp      INVENTORY_TAB_ITEMS
        jr      NZ, .skip
        ld      a, INVENTORY_TAB_COUNT
.skip:
        dec     a
        ld      [var_inventory_scene_tab], a

        call    r8_InventorySetTab

        ret


;;; ----------------------------------------------------------------------------

r8_InventoryMoveCursorDown:
        ld      a, [var_inventory_scene_selected_row]

        cp      6
        jr      Z, .nextPage

        call    VBlankIntrWait

        ld      a, 1
        ld	[rVBK], a

        ld      a, [var_inventory_scene_selected_row]
        ld      b, $89
        call    r8_InventoryTextRowSetAttr

	ld      a, [var_inventory_scene_selected_row]
        inc     a
        ld      [var_inventory_scene_selected_row], a

        ld      b, $8A
        call    r8_InventoryTextRowSetAttr

        ld      a, 0
        ld	[rVBK], a

        call    r8_InventoryUpdateImage
        ret
.nextPage:
        ld      a, [var_inventory_scene_page]
        cp      1
        jr      Z, .skip

        inc     a
        ld      [var_inventory_scene_page], a

        ld      a, 1
        ld	[rVBK], a

        ld      a, [var_inventory_scene_selected_row]
        ld      b, $89
        call    r8_InventoryTextRowSetAttr

        ld      a, 0
        ld	[rVBK], a

	ld      a, 0
        ld      [var_inventory_scene_selected_row], a

	call    r8_InventoryInitText

        call    r8_InventoryUpdateImage
.skip:
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryMoveCursorUp:
        ld      a, [var_inventory_scene_selected_row]

        cp      0
        jr      Z, .prevPage

        call    VBlankIntrWait

        ld      a, 1
        ld	[rVBK], a

        ld      a, [var_inventory_scene_selected_row]
        ld      b, $89
        call    r8_InventoryTextRowSetAttr

	ld      a, [var_inventory_scene_selected_row]
        dec     a
        ld      [var_inventory_scene_selected_row], a

        ld      b, $8A
        call    r8_InventoryTextRowSetAttr

        ld      a, 0
        ld	[rVBK], a

        call    r8_InventoryUpdateImage
        ret
.prevPage:
        ld      a, [var_inventory_scene_page]
        cp      0
        jr      Z, .skip

        dec     a
        ld      [var_inventory_scene_page], a


        ld      a, 1
        ld	[rVBK], a

        ld      a, [var_inventory_scene_selected_row]
        ld      b, $89
        call    r8_InventoryTextRowSetAttr

        ld      a, 6
        ld      [var_inventory_scene_selected_row], a

        ld      b, $8A
        call    r8_InventoryTextRowSetAttr

        ld      a, 0
        ld	[rVBK], a

        call    r8_InventoryInitText

        call    r8_InventoryUpdateImage
.skip:
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryUpdate:
        ldh     a, [var_joypad_current]
        bit     PADB_UP, a
        jr      Z, .checkDown

        call    r8_InventoryMoveCursorUp

.checkDown:
        ldh     a, [var_joypad_current]
        bit     PADB_DOWN, a
        jr      Z, .checkLeft

        call    r8_InventoryMoveCursorDown

.checkLeft:
        ldh     a, [var_joypad_current]
        bit     PADB_LEFT, a
        jr      Z, .checkRight

        call    r8_InventoryTabLeft

.checkRight:
        ldh     a, [var_joypad_current]
        bit     PADB_RIGHT, a
        jr      Z, .done

        call    r8_InventoryTabRight

.done:
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryInitImageMargin:
        ld      hl, $9c2d
	ld      bc, 6
        ld      d, $36
        call    r8_VramSafeMemset

        ld      hl, $9c4d
	ld      bc, 6
        ld      d, $36
        call    r8_VramSafeMemset

        ld      hl, $9c6d
	ld      bc, 6
        ld      d, $36
        call    r8_VramSafeMemset

        ld      hl, $9c8d
	ld      bc, 6
        ld      d, $36
        call    r8_VramSafeMemset

        ld      hl, $9cad
	ld      bc, 6
        ld      d, $36
        call    r8_VramSafeMemset

        ld      hl, $9ccd
	ld      bc, 6
        ld      d, $36
        call    r8_VramSafeMemset


        ld      a, 1
        ld	[rVBK], a

        ld      hl, $9c2d
	ld      bc, 6
        ld      d, $83
        call    r8_VramSafeMemset

        ld      hl, $9c4d
	ld      bc, 6
        ld      d, $83
        call    r8_VramSafeMemset

        ld      hl, $9c6d
	ld      bc, 6
        ld      d, $83
        call    r8_VramSafeMemset

        ld      hl, $9c8d
	ld      bc, 6
        ld      d, $83
        call    r8_VramSafeMemset

        ld      hl, $9cad
	ld      bc, 6
        ld      d, $83
        call    r8_VramSafeMemset

        ld      hl, $9ccd
	ld      bc, 6
        ld      d, $83
        call    r8_VramSafeMemset

        ld      a, 0
        ld	[rVBK], a

        ret


;;; ----------------------------------------------------------------------------

r8_InventoryOpen:
        ld      hl, r8_InventoryTiles
        ld      bc, r8_InventoryTilesEnd - r8_InventoryTiles
        ld      de, $9300
        call    VramSafeMemcpy

        ;; It's just simpler if objects are reset
        ld      hl, var_oam_back_buffer
        ld      a, 0
        ld      bc, OAM_SIZE * OAM_COUNT
        call    Memset

        call    VBlankIntrWait
        ld      a, HIGH(var_oam_back_buffer)
        call    hOAMDMA

	ld      hl, r8_InventoryItemIcons
        ld      de, $9400
        ld      b, 15
        call    GDMABlockCopy

        ld      a, 1
        ld	[rVBK], a

        ld      hl, (_SCRN1 + 32)
        ld      bc, $9e14 - (_SCRN1  + 32)
        ld      d, $81
        call    r8_VramSafeMemset
        ld      a, 0
        ld      [rVBK], a

        ld      hl, r8_InventoryLowerBoxTopRow
        ld      bc, r8_InventoryLowerBoxTopRowEnd - r8_InventoryLowerBoxTopRow
        ld      de, $9D00
        call    VramSafeMemcpy

        ld      de, $9C20
        call    r8_InventoryImageBoxInitRow

        ld      de, $9C40
        call    r8_InventoryImageBoxInitRow

        ld      de, $9C60
        call    r8_InventoryImageBoxInitRow

        ld      de, $9C80
        call    r8_InventoryImageBoxInitRow

	ld      de, $9CA0
        call    r8_InventoryImageBoxInitRow

	ld      de, $9CC0
        call    r8_InventoryImageBoxInitRow

        ld      hl, r8_InventoryImageBoxBottomRow
        ld      bc, r8_InventoryImageBoxBottomRowEnd - r8_InventoryImageBoxBottomRow
        ld      de, $9CE0
	call    VramSafeMemcpy

        ld      de, $9D20
        call    r8_InventoryLowerBoxInitRow

        ld      de, $9D40
        call    r8_InventoryLowerBoxInitRow

        ld      de, $9D60
        call    r8_InventoryLowerBoxInitRow

        ld      de, $9D80
        call    r8_InventoryLowerBoxInitRow

        ld      de, $9DA0
        call    r8_InventoryLowerBoxInitRow

	ld      de, $9DC0
        call    r8_InventoryLowerBoxInitRow

        ld      de, $9DE0
        call    r8_InventoryLowerBoxInitRow

        ld      hl, r8_InventoryLowerBoxBottomRow
        ld      bc, r8_InventoryLowerBoxBottomRowEnd - r8_InventoryLowerBoxBottomRow
        ld      de, $9E00
        call    VramSafeMemcpy

        ld      a, 1
        ld      [var_overlay_alternate_pos], a

        call    ShowOverlay

        call    r8_InventoryInitImageMargin

        call    VBlankIntrWait
        ld      b, r8_InventoryPalettesEnd - r8_InventoryPalettes
        ld      hl, r8_InventoryPalettes
        call    LoadBackgroundColors

;;; Now, we can draw the very top row! Jump the window up, and draw the top row
;;; in place of where the overlay bar used to be.
        ld      a, 0
        ld      [rWY], a

        ld      b, 0
        ld      hl, r8_InventoryImageBoxTopRow
        ld      de, _SCRN1
.loop:
        ld      a, [hl+]
        ld      [de], a

        ld      a, 1
        ld      [rVBK], a
        ld      a,  $81
        ld      [de], a
        ld      a, 0
        ld      [rVBK], a

        inc     de
        inc     b
        ld      a, 20
        cp      b
        jr      NZ, .loop
.done:

        ;; TODO: use unions for scene-specific variables
        ld      a, 0
        ld      [var_inventory_scene_selected_row], a
        ld      [var_inventory_scene_page], a
        ld      [var_inventory_scene_tab], a

        call    VBlankIntrWait

        ld      hl, $9c21       ; \
        ld      a, $3a          ; | Show left arrow
        ld      [hl], a         ; /

        ld      hl, $9c2a       ; \
        ld      a, $3b          ; | Show right arrow
        ld      [hl], a         ; /

        ld      hl, $9c41       ; \
        ld      bc, 10          ; | Show divider
        ld      a, $3c          ; /
        call    Memset

        call    r8_InventoryShowTabHeading

        ret


;;; ----------------------------------------------------------------------------

r8_SetupImageTiles:
        ld      de, $9c4e
        ld      hl, r8_InventoryImgRow1
        ld      bc, 4
        call    VramSafeMemcpy

        ld      de, $9c6e
        ld      hl, r8_InventoryImgRow2
        ld      bc, 4
        call    VramSafeMemcpy

        ld      de, $9c8e
        ld      hl, r8_InventoryImgRow3
        ld      bc, 4
        call    VramSafeMemcpy

        ld      de, $9cae
        ld      hl, r8_InventoryImgRow4
        ld      bc, 4
        call    VramSafeMemcpy

        ret


;;; ----------------------------------------------------------------------------

r8_VramSafeMemset:
; hl - destination
; d - byte to fill with
; bc - size
        ld      a, [rLY]
        cp      145
        jr      C, .needsInitialVSync
	jr      .start

.needsInitialVSync:
        call    VBlankIntrWait

.start:
	inc	b
	inc	c
	jr	.skip
.top:
        ld      a, [rLY]
        cp      152
        jr      Z, .vsync
        jr      .fill

.vsync:
	call    VBlankIntrWait
.fill:
	ld	[hl], d
        inc     hl
.skip:
	dec	c
	jr	nz, .top
	dec	b
	jr	nz, .top
.done:
	ret


;;; ----------------------------------------------------------------------------



align 8                         ; Required alignment for dma copies
r8_InventoryItemIcons::
.empty::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
.emptyEnd::
.wolfPelt::
DB $FE,$00,$CE,$F0,$67,$78,$33,$3C
DB $99,$1E,$CC,$0F,$E7,$04,$E3,$00
DB $0E,$00,$0E,$00,$0E,$00,$7E,$00
DB $FE,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $FF,$00,$F1,$0E,$F3,$8C,$F8,$FF
DB $0E,$0D,$03,$03,$01,$01,$00,$00
DB $FF,$00,$FF,$00,$FF,$00,$7F,$80
DB $3F,$C0,$0F,$F0,$87,$F8,$C3,$FC
DB $80,$00,$80,$00,$C0,$00,$E0,$00
DB $F0,$00,$FC,$03,$FE,$01,$FF,$01
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $01,$1C,$00,$FE,$01,$FE,$FF,$FF
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $61,$7E,$30,$3F,$18,$1F,$0C,$0B
DB $07,$00,$07,$01,$0F,$09,$0E,$08
DB $FF,$00,$FE,$01,$FE,$01,$7E,$81
DB $3E,$C1,$0F,$F0,$87,$F8,$80,$FF
DB $00,$00,$80,$00,$60,$80,$70,$80
DB $70,$80,$F8,$00,$F0,$10,$F8,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $0C,$0E,$04,$07,$04,$07,$04,$07
DB $04,$07,$04,$07,$04,$07,$02,$00
DB $C0,$FF,$61,$7F,$30,$3F,$1E,$1F
DB $03,$03,$00,$00,$00,$00,$00,$00
DB $F0,$0C,$F0,$0C,$18,$E4,$0C,$F0
DB $FC,$E0,$3C,$3C,$00,$00,$00,$00
.wolfPeltEnd::
.dagger::
DB $38,$00,$3C,$00,$16,$08,$3B,$24
DB $3F,$30,$1F,$18,$0F,$08,$0F,$0C
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $80,$00,$C0,$00,$E0,$00,$70,$80
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $07,$06,$03,$02,$03,$03,$01,$01
DB $01,$01,$00,$00,$00,$00,$00,$00
DB $B8,$40,$FC,$00,$EE,$10,$FD,$02
DB $F4,$8B,$F8,$C7,$7C,$43,$7E,$61
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $80,$00,$40,$00,$E0,$03,$E1,$17
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$C0,$00,$E0,$00,$E0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $3F,$30,$1E,$11,$1E,$19,$0E,$0D
DB $06,$07,$00,$33,$01,$7F,$C0,$F8
DB $03,$FF,$14,$FC,$00,$F8,$80,$F4
DB $00,$FC,$0C,$F0,$9E,$E0,$FF,$F0
DB $80,$C0,$40,$40,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $70,$70,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $1F,$18,$0F,$0C,$07,$06,$03,$02
DB $01,$01,$00,$00,$00,$00,$00,$00
DB $00,$00,$80,$00,$C0,$00,$C0,$30
DB $C0,$28,$80,$F8,$80,$F8,$F0,$F0
.daggerEnd::
.rawMeat::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $01,$00,$03,$00,$07,$00,$07,$00
DB $00,$00,$00,$00,$03,$00,$1F,$00
DB $FF,$00,$ED,$03,$5B,$A7,$F7,$0F
DB $00,$00,$00,$00,$F8,$00,$FE,$70
DB $FF,$FE,$FF,$FF,$9D,$FF,$19,$FF
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$80,$00,$00,$80,$C0,$80
DB $0F,$00,$0F,$00,$0B,$04,$1F,$00
DB $1F,$00,$1F,$00,$1F,$00,$3F,$00
DB $BE,$4F,$FE,$0F,$FC,$0F,$EC,$1F
DB $EC,$1F,$FC,$1F,$F8,$1F,$F8,$1F
DB $18,$FF,$08,$FF,$08,$FF,$08,$FF
DB $00,$FF,$00,$FF,$00,$FF,$08,$FF
DB $80,$C0,$C0,$C0,$C0,$C0,$60,$C0
DB $60,$E0,$30,$E0,$30,$E0,$20,$F0
DB $3F,$00,$7F,$00,$7F,$00,$7F,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $D8,$3F,$F8,$3F,$F8,$7F,$F0,$7F
DB $F0,$7F,$F0,$7F,$F0,$FF,$F0,$FF
DB $08,$FF,$08,$FF,$08,$FF,$18,$FF
DB $18,$FF,$1C,$FF,$1C,$FF,$1C,$FF
DB $38,$F0,$38,$F0,$1C,$F8,$0C,$F8
DB $0C,$F8,$14,$F8,$78,$F0,$D0,$E0
DB $FF,$80,$FF,$C0,$7F,$70,$1F,$1E
DB $03,$03,$00,$00,$00,$00,$00,$00
DB $E0,$FF,$F0,$FF,$FF,$FF,$FF,$7F
DB $FF,$00,$00,$00,$00,$00,$00,$00
DB $1F,$FF,$3F,$FF,$FE,$FC,$F8,$E0
DB $E0,$00,$00,$00,$00,$00,$00,$00
DB $E0,$C0,$80,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
.rawMeatEnd::
.stick::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$01
DB $00,$03,$00,$03,$00,$07,$00,$0F
DB $00,$00,$30,$40,$78,$80,$78,$80
DB $78,$80,$00,$F8,$00,$E0,$00,$C0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$01,$00,$03,$00,$07
DB $00,$1F,$00,$3F,$00,$7E,$00,$FC
DB $00,$F8,$00,$F0,$00,$E0,$00,$C0
DB $00,$80,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$01,$00,$03,$00,$07,$00,$0F
DB $00,$07,$00,$1F,$00,$3F,$00,$7E
DB $00,$FC,$00,$F0,$00,$E0,$00,$C0
DB $00,$80,$00,$80,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$1F,$00,$3E,$40,$7C,$40,$78
DB $70,$70,$00,$00,$00,$00,$00,$00
DB $00,$80,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
.stickEnd::
r8_InventoryItemIconsEnd::


r8_InventoryItemTextTable::
DB      "- empty -      ", 0
DB      "wolf pelt      ", 0
DB      "dagger         ", 0
DB      "raw meat       ", 0
DB      "stick          ", 0
r8_InventoryItemTextTableEnd::

r8_InventoryTabItemsText::
DB      " items  ", 0
r8_InventoryTabItemsTextEnd::

r8_InventoryTabCraftText::
DB      " craft  ", 0
r8_InventoryTabCraftTextEnd::



r8_InventoryItemAttributes::
.empty::
DB $83, $83, $83, $83
DB $83, $83, $84, $84
DB $83, $83, $83, $83
DB $83, $84, $83, $84
.emptyEnd::
.wolfPelt::
DB $83, $83, $83, $83
DB $83, $83, $84, $84
DB $83, $83, $83, $83
DB $83, $84, $83, $84
.wolfPeltEnd::
.dagger::
DB $83, $83, $83, $83
DB $83, $83, $84, $84
DB $84, $84, $85, $84
DB $85, $85, $85, $85
.daggerEnd::
.rawMeat::
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $84, $85, $85, $83
.rawMeatEnd::
.stick::
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $83, $83, $83, $83
.stickEnd::
r8_InventoryItemAttributesEnd::



r8_InventoryItemPalettes::
.empty::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $1b,$4b, $ce,$55, $29,$31, $c2,$30,
DB $1b,$4b, $ce,$55, $29,$31, $c2,$30,
DB $1b,$4b, $ce,$55, $29,$31, $c2,$30,
DB $1b,$4b, $ce,$55, $29,$31, $c2,$30,
DB $1b,$4b, $ce,$55, $29,$31, $c2,$30,
.emptyEnd::
.wolfPelt::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $1b,$4b, $ad,$4d, $08,$2d, $81,$20,
DB $1b,$4b, $ad,$4d, $ff,$7f, $81,$20,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.wolfPeltEnd::
.dagger::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $1b,$4b, $ad,$4d, $ff,$7f, $81,$20,
DB $1b,$4b, $ad,$4d, $d1,$21, $81,$20,
DB $1b,$4b, $ad,$24, $d1,$21, $81,$20,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.daggerEnd::
.rawMeat::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $1b,$4b, $ad,$24, $7d,$35, $9f,$63,
DB $1b,$4b, $ad,$24, $7d,$35, $81,$20,
DB $1b,$4b, $81,$20, $7d,$35, $9f,$63,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.rawMeatEnd::
.stick::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $1b,$4b, $d1,$21, $ad,$24, $81,$20,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.stickEnd::
r8_InventoryItemPalettesEnd::
