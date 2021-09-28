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


;;; Column 0: item, columns 1-3: dependency set.
r8_InventoryCraftingRecipes::
DB      ITEM_BUNDLE,    ITEM_STICK,     ITEM_STICK,     ITEM_STICK
DB      ITEM_FIREWOOD,  ITEM_BUNDLE,    ITEM_BUNDLE,    ITEM_BUNDLE
;;; Last row must be empty:
DB      ITEM_NONE,      ITEM_NONE,      ITEM_NONE,      ITEM_NONE
r8_InventoryCraftingRecipesEnd::


r8_InventoryCookingRecipes::
DB      ITEM_KEBAB,     ITEM_STICK,     ITEM_RAW_MEAT,  ITEM_RAW_MEAT
DB      ITEM_STEW,      ITEM_RAW_MEAT,  ITEM_RAW_MEAT,  ITEM_RAW_MEAT
DB      ITEM_SOUP,      ITEM_TURNIP,    ITEM_TURNIP,    ITEM_RAW_MEAT
DB      ITEM_SOUP,      ITEM_POTATO,    ITEM_TURNIP,    ITEM_RAW_MEAT
DB      ITEM_SOUP,      ITEM_POTATO,    ITEM_POTATO,    ITEM_RAW_MEAT
DB      ITEM_BROTH,     ITEM_TURNIP,    ITEM_TURNIP,    ITEM_TURNIP
DB      ITEM_BROTH,     ITEM_POTATO,    ITEM_POTATO,    ITEM_POTATO
DB      ITEM_BROTH,     ITEM_TURNIP,    ITEM_TURNIP,    ITEM_POTATO
DB      ITEM_BROTH,     ITEM_POTATO,    ITEM_POTATO,    ITEM_TURNIP
;;; Last row must be empty:
DB      ITEM_NONE,      ITEM_NONE,      ITEM_NONE,      ITEM_NONE
r8_InventoryCookingRecipesEnd::


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
DB $FF,$FF,$FF,$FF,$FF,$FF,$83,$83
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


r8_InventoryGetTabText:
        ld      a, [var_inventory_scene_tab]
        cp      INVENTORY_TAB_ITEMS
        jr      Z, .items
        cp      INVENTORY_TAB_CRAFT
        jr      Z, .craft
        cp      INVENTORY_TAB_COOK
        jr      Z, .cook
.items:
	ld      hl, r8_InventoryTabItemsText
        ret
.craft:
	ld      hl, r8_InventoryTabCraftText
        ret
.cook:
        ld      hl, r8_InventoryTabCookText
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryShowTabHeading:
        fcall   r8_InventoryGetTabText

        ld      de, $9c22
        ld      b, $89
        fcall   PutText
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryGetCraftableItem:
;;; b - row
;;; return b - item typeinfo
        ld      hl, var_inventory_scene_craftable_items_list
        ld      c, b
        sla     c
        ld      b, 0
        add     hl, bc

        ld      b, [hl]         ; \
        inc     hl              ; | Load recipe pointer from array
        ld      c, [hl]         ; /

        ld      a, b
        or      c
        jr      Z, .null

        ld      a, [bc]         ; \
        ld      b, a            ; | Load item typeinfo from first byte in recipe
        ld      c, 0            ; /
        ret
.null:
        ld      b, ITEM_NONE
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryTabLoadItem:
;;; b - row
        ld      a, [var_inventory_scene_tab]
        cp      a, INVENTORY_TAB_ITEMS
        jr      Z, .items
        cp      a, INVENTORY_TAB_CRAFT
        jr      Z, .craft
        cp      a, INVENTORY_TAB_COOK
        jr      Z, .craft

.items:
        fcall   InventoryGetItem
        ret

.craft:
        fcall   r8_InventoryGetCraftableItem
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryLowerBoxInitRow:
;;; de - address
        ld      hl, r8_InventoryLowerBoxMiddleRow
        ld      bc, r8_InventoryLowerBoxMiddleRowEnd - r8_InventoryLowerBoxMiddleRow
        fcall   VramSafeMemcpy
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryImageBoxInitRow:
;;; de - address
        ld      hl, r8_InventoryImageBoxMiddleRow
        ld      bc, r8_InventoryImageBoxMiddleRowEnd - r8_InventoryImageBoxMiddleRow
        fcall   VramSafeMemcpy
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

        fcall   r8_InventoryTextRowAddress

        ld      d, h
        ld      e, l

        pop     bc
        pop     hl

        fcall   PutText

        ;; Now, fill the rest of the row with spaces. PutText should leave
        ;; de in the correct position to keep on going...
        pop     hl

        fcall   r8_SmallStrlen

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
;;; b - item typeinfo
        ld      c, b
        ld      b, 0
        fcall   r8_Mul16

        ld      hl, r8_InventoryItemTextTable
        add     hl, bc

        ret


;;; ----------------------------------------------------------------------------

r8_InventoryItemRowText:
;;; a - row
        ld      b, a
        fcall   r8_InventoryTabLoadItem

        fcall   r8_InventoryItemText
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
        fcall   r8_InventoryAdjustOffset
        ret


r8_InventoryInitText:
        ld      a, 0
.loop:
        cp      7
        jr      Z, .loopDone
	push    af

        push    af
        fcall   VBlankIntrWait
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
        fcall   r8_InventoryAdjustOffset
        fcall   r8_InventoryItemRowText
        pop     bc
        pop     af

        fcall   r8_InventoryPutTextRow

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
        fcall   r8_InventoryTextRowAddress
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
        fcall   VramSafeMemcpy
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
        swap    b
        ld      a, b
        and     $f0
        ld      b, a

        ld      a, c
        swap    a
        and     $0f
        or      b
        ld      b, a

        ld      a, c
        swap    a
        and     $f0
        ld      c, a

        ret


;;; ----------------------------------------------------------------------------

r8_InventoryUpdateImage:
        fcall   VBlankIntrWait

        fcall   r8_InventoryGetSelectedIndex
        ld      b, a
        fcall   r8_InventoryTabLoadItem
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
        fcall   GDMABlockCopy

        pop     bc
        push    bc

	ld      hl, r8_InventoryItemAttributes

        fcall   r8_Mul16                ; 16 bytes per attribute block

        add     hl, bc

        ;; Now, copy over the attributes
        ld      a, 1
        ld	[rVBK], a

        ld      de, $9c4e

        fcall   r8_InventoryUpdateImageCopyAttributeRow
        fcall   r8_InventoryUpdateImageCopyAttributeRow
        fcall   r8_InventoryUpdateImageCopyAttributeRow
        fcall   r8_InventoryUpdateImageCopyAttributeRow

        ld      a, 0
        ld	[rVBK], a

        pop     bc

        ld      hl, r8_InventoryItemPalettes
        fcall   r8_Mul64                ; 64 bytes per palette
        add     hl, bc

        ld      a, [rLY]
        cp      145
        jr      C, .vsync
        jr      .copyColors
.vsync:
;;; We should never reach here, the code is fast enough to run within the blank
;;; window. But just in case...
        fcall   VBlankIntrWait
.copyColors:
        ld      b, 64
        fcall   LoadBackgroundColors

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


ITEM_CATEGORY_EQUIPMENT EQU 0
ITEM_CATEGORY_FOOD      EQU 1
ITEM_CATEGORY_MISC      EQU 2


r8_ItemDescs::
.none:
DB      ITEM_CATEGORY_MISC,      $00, $00, $00

.wolfPelt:
DB      ITEM_CATEGORY_MISC,      $00, $00, $00

.dagger:
DB      ITEM_CATEGORY_EQUIPMENT, $00, $00, $00

.rawMeat:
DB      ITEM_CATEGORY_FOOD,        6, $00, $00

.stick:
DB      ITEM_CATEGORY_MISC,      $00, $00, $00

.kebab:
DB      ITEM_CATEGORY_FOOD,      180, $00, $00

.turnip:
DB      ITEM_CATEGORY_FOOD,        2, $00, $00

.potato:
DB      ITEM_CATEGORY_FOOD,        6, $00, $00

.broth:
DB      ITEM_CATEGORY_FOOD,       90, $00, $00

.soup:
DB      ITEM_CATEGORY_FOOD,      120, $00, $00

.stew:
DB      ITEM_CATEGORY_FOOD,      $00, $00, $00

.bundle:
DB      ITEM_CATEGORY_MISC,      $00, $00, $00

.firewood:
DB      ITEM_CATEGORY_MISC,      $00, $00, $00


r8_ItemDescsEnd::
STATIC_ASSERT((r8_ItemDescsEnd - r8_ItemDescs) / 4 == ITEM_COUNT)


;;; ----------------------------------------------------------------------------


r8_GetItemDesc:
;;; c - item type
;;; trashes bc, hl
        ld      b, 0
        sla     c
        sla     c

        ld      hl, r8_ItemDescs
        add     hl, bc
        ret


;;; ----------------------------------------------------------------------------


r8_InventoryUseItem:
        ld      a, [var_inventory_scene_selected_row]
        fcall   r8_InventoryAdjustOffset

        ld      b, a
        fcall   InventoryGetItem

        ld      d, b            ; Store item id in d

        ld      c, b
	fcall   r8_GetItemDesc

        ld      a, [hl]
        cp      ITEM_CATEGORY_EQUIPMENT
        jr      Z, .useEquipmentItem
        cp      ITEM_CATEGORY_FOOD
        jr      Z, .useFoodItem
	jr      .useMiscItem

.useFoodItem:
        inc     hl
        ld      b, [hl]         ; Amount of health to restore
        ld      c, 0

        ld      hl, var_player_stamina
        fcall   FixnumAddClamped

        fcall   UpdateStaminaBar
        fcall   VBlankIntrWait  ; FIXME...
        fcall   ShowOverlay

        fcall   r8_RemoveSelectedItem

        fcall   r8_InventoryInitText
        fcall   r8_InventoryUpdateImage
        ret

.useEquipmentItem:
        ;; TODO... probably just equip the item...
        ret

.useMiscItem:
        ;; item id in d. Now, for misc items, we want to perform some specific operation
        ;; based on which item we have
        ld      a, d
        cp      ITEM_FIREWOOD
        jr      Z, .useFirewoodItem

        ret

.useFirewoodItem:

        ld      de, ConstructBonfireSceneEnter
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------


r8_RemoveSelectedItem:
        ld      a, [var_inventory_scene_selected_row]
        fcall   r8_InventoryAdjustOffset
        ld      c, a
	fcall   InventoryRemoveItem
        ret


;;; ----------------------------------------------------------------------------


r8_InventoryAPressed:
        ld      a, [var_inventory_scene_tab]
        cp      INVENTORY_TAB_ITEMS
        jr      Z, .items
        cp      INVENTORY_TAB_CRAFT
        jr      Z, .craft
        cp      INVENTORY_TAB_COOK
        jr      Z, .craft
.items:
        fcall   r8_InventoryUseItem
        ret
.craft:
        fcall   r8_InventoryCraftItem
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryCraftItem:
        fcall   r8_InventoryGetSelectedIndex
        ld      b, a

        fcall   r8_GetCraftableItemRecipe

        ld      a, h                    ; \
        or      l                       ; | Null pointer check.
        jr      Z, .skip                ; /

        push    hl

        inc     hl                      ; Skip result item for now

        ;; Consume the three dependencies
        ld      b, [hl]
        push    hl
        fcall   InventoryConsumeItem
        pop     hl
        inc     hl

        ld      b, [hl]
        push    hl
        fcall   InventoryConsumeItem
        pop     hl
        inc     hl

        ld      b, [hl]
        fcall   InventoryConsumeItem

        pop     hl

        ld      b, [hl]                 ; Load result
        fcall   InventoryAddItem        ; Store result

        ;; Redisplay everything. We consumed items from the inventory, so the
        ;; subset of things that we can craft may have changed.
        fcall   r8_InventoryLoadCraftableItems
        fcall   r8_InventoryInitText
        fcall   r8_InventoryUpdateImage
        fcall   r8_InventoryDescribeItem

.skip:
        ret


;;; ----------------------------------------------------------------------------

r8_GetCraftableItemRecipe:
;;; b - row
;;; return hl - pointer to recipe
        ld      hl, var_inventory_scene_craftable_items_list
        ld      c, b
        sla     c
        ld      b, 0
        add     hl, bc
        ld      b, [hl]
        inc     hl
        ld      c, [hl]
        ld      h, b
        ld      l, c
        ret


;;; ----------------------------------------------------------------------------

r8_CraftingDependencyInsert:
;;; b - dependency
;;; trashes de, c
        ld      de, var_crafting_dependency_set

        ;; Collapse with one item if it already exists
        ld      a, [de]
        cp      b
        jr      Z, .collapse

	inc     de
        inc     de

        ld      a, [de]
        cp      b
        jr      Z, .collapse

        inc     de
        inc     de

        ld      a, [de]
        cp      b
        jr      Z, .collapse


        ld      de, var_crafting_dependency_set

        ld      a, [de]
	or      a
        jr      Z, .set

        inc     de
        inc     de

        ld      a, [de]
        or      a
        jr      Z, .set

        inc     de
        inc     de

        ld      a, [de]
        or      a
        jr      Z, .set

        ret

.collapse:
        inc     de
        ld      a, [de]
        inc     a
        ld      [de], a
        ret

.set:
        ld      a, b
        ld      [de], a
        inc     de
        ld      a, 1
        ld      [de], a
        ret


;;; ----------------------------------------------------------------------------

r8_CraftableItemDependencyCheckAvailable:
;;; hl - current dependency
;;; return a - true if sufficient quantity in inventory meets dependency
;;; return hl - next dependency in the dependency set
;;; trashes b, c, d
        ld      a, [hl+]

        ld      b, ITEM_NONE    ; \ The dependency set will have empty slots, if
        cp      b               ; | two or three of the dependencies are
        jr      Z, .true        ; / identical.

        ld      b, a                    ; Pass item type parameter in b
        push    hl
        fcall   InventoryCountOccurrences
        pop     hl

        ld      a, [hl+]
        ld      b, a
        ld      a, d
        cp      b                       ; Result from InventoryCountOccurrences
        jr      C, .false               ; required (a) < available (b)
.true:
        ld      a, 1
        ret
.false:
        ld      a, 0
        ret


;;; ----------------------------------------------------------------------------

r8_CraftableItemCheckDependencies:
;;; hl - craftable item (see table above)
;;; a - true if inventory meets dependencies
        push    hl
        ld      hl, var_crafting_dependency_set
        ld      bc, var_crafting_dependency_set_end - var_crafting_dependency_set
        ld      a, 0
        fcall   Memset
        pop     hl

        push    hl
        inc     hl

        ld      a, [hl+]
        ld      b, a
        fcall   r8_CraftingDependencyInsert

        ld      a, [hl+]
        ld      b, a
        fcall   r8_CraftingDependencyInsert

        ld      a, [hl]
        ld      b, a
        fcall   r8_CraftingDependencyInsert

        ld      hl, var_crafting_dependency_set

        fcall   r8_CraftableItemDependencyCheckAvailable
        or      a
        jr      Z, .noMatch

        fcall   r8_CraftableItemDependencyCheckAvailable
        or      a
        jr      Z, .noMatch

        fcall   r8_CraftableItemDependencyCheckAvailable
        or      a
        jr      Z, .noMatch

        pop     hl
	ld      a, 1
        ret
.noMatch:
        pop     hl
        ld      a, 0
        ret


;;; ----------------------------------------------------------------------------

r8_CraftableItemsListInsert:
;;; de - pointer into recipe table
;;; trashes hl, c
        ld      hl, var_inventory_scene_craftable_items_list
        ld      c, 0
.loop:
        ld      a, CRAFTABLE_ITEMS_COUNT
        cp      c
        jr      Z, .done

        ld      a, [hl]
        or      a
        jr      NZ, .next

        ld      [hl], d
        inc     hl
        ld      [hl], e
        jr      .done

.next:
        inc     c
        inc     hl
        inc     hl
        jr      .loop

.done:
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryGetRecipeList:
        ld      a, [var_inventory_scene_tab]
        cp      INVENTORY_TAB_COOK
        jr      Z, .cook

        ld      hl, r8_InventoryCraftingRecipes
        ret
.cook:
        ld      hl, r8_InventoryCookingRecipes
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryLoadCraftableItems:
        ld      hl, var_inventory_scene_craftable_items_list
        ld      bc, CRAFTABLE_ITEMS_COUNT * 2
        ld      a, 0
        fcall   Memset

        fcall   r8_InventoryGetRecipeList
.loop:
        ld      a, [hl]
        cp      ITEM_NONE
        jr      Z, .endLoop

        fcall   r8_CraftableItemCheckDependencies
	or      a
        jr      Z, .skip

        ld      a, [hl]

        push    hl

        push    hl              ; \ Copy hl to de (I'm feeling lazy)
        pop     de              ; /

        fcall   r8_CraftableItemsListInsert
        pop     hl

.skip:
        inc     hl
        inc     hl
        inc     hl
        inc     hl

        jr      .loop

.endLoop:

        ret


;;; ----------------------------------------------------------------------------

r8_PutTruncatedItemText:
;;; hl - text
;;; de - screen ptr
;;; b - attribute
;;; c - max length to show
.loop:
        ld      a, 0
        cp      c
        jr      Z, .done

        ld      a, [hl]
        cp      0
	jr      Z, .done

        fcall   AsciiToGlyph
        ld      [de], a

        ld      a, 1
        ld      [rVBK], a
        ld      a, b
        ld      [de], a
        ld      a, 0
	ld      [rVBK], a

        dec     c
        inc     hl
        inc     de

        jr      .loop
.done:

        ret


;;; ----------------------------------------------------------------------------

r8_ShowRecipeText:
;;; de - screen pointer
;;; hl - item pointer
;;; return hl - pointer to next item
        ld      a, [hl+]
        ld      b, a
        push    hl
        push    de
        fcall   r8_InventoryItemText    ; text ptr now in hl
        pop     de
        ld      b, $89
        ld      c, 9                    ; Max chars to print
        fcall   r8_PutTruncatedItemText
        pop     hl
        ret


r8_InventoryDescribeItem:
        ld      a, [var_inventory_scene_tab]
        cp      INVENTORY_TAB_ITEMS
        jr      Z, .describeItem
        cp      INVENTORY_TAB_CRAFT
        jr      Z, .showRecipeList
        cp      INVENTORY_TAB_COOK
        jr      Z, .showRecipeList

.describeItem:
        ret

.showRecipeList:
        fcall   r8_InventoryGetSelectedIndex
        ld      b, a

        fcall   r8_GetCraftableItemRecipe
.here:
        ld      a, h                    ; \
        or      l                       ; | Null pointer check.
        jr      Z, .reset               ; /

        ld      a, [hl+]                ; \
        ld      b, a                    ; | Make sure item itself isn't the
        ld      a, ITEM_NONE            ; | null item (shouldn't happen...).
        cp      b                       ; |
        jr      Z, .reset               ; /

        fcall   VBlankIntrWait
	ld      de, $9c62
        fcall   r8_ShowRecipeText

	ld      de, $9c82
        fcall   r8_ShowRecipeText

	ld      de, $9ca2
        fcall   r8_ShowRecipeText

        ld      a, $3D
        ld      hl, $9c61
        ld      [hl], a
	ld      hl, $9c81
        ld      [hl], a
        ld      hl, $9ca1
        ld      [hl], a

	ret
.reset:
        fcall   r8_InventoryClearItemInfoBox
        ret


r8_InventoryClearItemInfoBox:
        ld      hl, $9c61
        ld      bc, 10
        ld      d, 0
        fcall   r8_VramSafeMemset

        ld      hl, $9c81
        ld      bc, 10
        ld      d, 0
        fcall   r8_VramSafeMemset

        ld      hl, $9ca1
        ld      bc, 10
        ld      d, 0
        fcall   r8_VramSafeMemset

        ld      a, 1
        ld      [rVBK], a

        ld      hl, $9c61
        ld      bc, 10
        ld      d, $81
        fcall   r8_VramSafeMemset

        ld      hl, $9c81
        ld      bc, 10
        ld      d, $81
        fcall   r8_VramSafeMemset

        ld      hl, $9ca1
        ld      bc, 10
        ld      d, $81
        fcall   r8_VramSafeMemset

        ld      a, 0
        ld      [rVBK], a

        ret



;;; ----------------------------------------------------------------------------

r8_InventorySetTab:
        fcall   VBlankIntrWait

        ld      a, 0
        ld      [var_inventory_scene_selected_row], a
        ld      [var_inventory_scene_page], a

        ld      a, [var_inventory_scene_tab]
        cp      INVENTORY_TAB_ITEMS
        jr      Z, .loadItemsTab
        cp      INVENTORY_TAB_CRAFT
        jr      Z, .loadCraftTab
        cp      INVENTORY_TAB_COOK
        jr      Z, .loadCraftTab

.loadItemsTab:
        fcall   r8_InventoryShowTabHeading
	fcall   r8_InventoryInitText
        fcall   r8_InventoryUpdateImage
        fcall   r8_InventoryDescribeItem
        ret

.loadCraftTab:
        fcall   r8_InventoryLoadCraftableItems ; FIXME: code is identical toexcept for this line
        fcall   VBlankIntrWait
        fcall   r8_InventoryShowTabHeading
	fcall   r8_InventoryInitText
        fcall   r8_InventoryUpdateImage
        fcall   r8_InventoryDescribeItem
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryTabRight:
        fcall   r8_InventoryClearItemInfoBox

        ld      a, [var_inventory_scene_tab]
.next:
        inc     a
        cp      INVENTORY_TAB_COOK
        jr      NZ, .checkEnd

        ld      b, a
        ld      a, [var_inventory_scene_cooking_tab_avail]
        or      a
        ld      a, b
        jr      Z, .next
        jr      .skip

.checkEnd:
        cp      INVENTORY_TAB_COUNT
        jr      NZ, .skip
        ld      a, INVENTORY_TAB_ITEMS
.skip:
        ld      [var_inventory_scene_tab], a

        fcall   r8_InventorySetTab



        ret


;;; ----------------------------------------------------------------------------

r8_InventoryTabLeft:
        fcall   r8_InventoryClearItemInfoBox

        ld      a, [var_inventory_scene_tab]
        cp      INVENTORY_TAB_ITEMS
        jr      NZ, .skip
        ld      a, INVENTORY_TAB_COUNT
.skip:
.next:
        dec     a
        cp      INVENTORY_TAB_COOK
        jr      NZ, .set

        ld      b, a
        ld      a, [var_inventory_scene_cooking_tab_avail]
        or      a
        ld      a, b
        jr      Z, .next

.set:
        ld      [var_inventory_scene_tab], a

        fcall   r8_InventorySetTab

        ret


;;; ----------------------------------------------------------------------------

r8_InventoryMoveCursorDown:
        ld      a, [var_inventory_scene_selected_row]

        cp      6
        jr      Z, .nextPage

        fcall   VBlankIntrWait

        ld      a, 1
        ld	[rVBK], a

        ld      a, [var_inventory_scene_selected_row]
        ld      b, $89
        fcall   r8_InventoryTextRowSetAttr

	ld      a, [var_inventory_scene_selected_row]
        inc     a
        ld      [var_inventory_scene_selected_row], a

        ld      b, $8A
        fcall   r8_InventoryTextRowSetAttr

        ld      a, 0
        ld	[rVBK], a

        fcall   r8_InventoryUpdateImage
        fcall   r8_InventoryDescribeItem
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
        fcall   r8_InventoryTextRowSetAttr

        ld      a, 0
        ld	[rVBK], a

	ld      a, 0
        ld      [var_inventory_scene_selected_row], a

	fcall   r8_InventoryInitText

        fcall   r8_InventoryUpdateImage
        fcall   r8_InventoryDescribeItem
.skip:
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryMoveCursorUp:
        ld      a, [var_inventory_scene_selected_row]

        cp      0
        jr      Z, .prevPage

        fcall   VBlankIntrWait

        ld      a, 1
        ld	[rVBK], a

        ld      a, [var_inventory_scene_selected_row]
        ld      b, $89
        fcall   r8_InventoryTextRowSetAttr

	ld      a, [var_inventory_scene_selected_row]
        dec     a
        ld      [var_inventory_scene_selected_row], a

        ld      b, $8A
        fcall   r8_InventoryTextRowSetAttr

        ld      a, 0
        ld	[rVBK], a

        fcall   r8_InventoryUpdateImage
        fcall   r8_InventoryDescribeItem
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
        fcall   r8_InventoryTextRowSetAttr

        ld      a, 6
        ld      [var_inventory_scene_selected_row], a

        ld      b, $8A
        fcall   r8_InventoryTextRowSetAttr

        ld      a, 0
        ld	[rVBK], a

        fcall   r8_InventoryInitText

        fcall   r8_InventoryUpdateImage
        fcall   r8_InventoryDescribeItem
.skip:
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryUpdate:
        ldh     a, [hvar_joypad_current]
        bit     PADB_UP, a
        jr      Z, .checkA

        fcall   r8_InventoryMoveCursorUp

.checkA:
	ldh     a, [hvar_joypad_current]
        bit     PADB_A, a
        jr      Z, .checkDown

        fcall   r8_InventoryAPressed
        ret

.checkDown:
        ldh     a, [hvar_joypad_current]
        bit     PADB_DOWN, a
        jr      Z, .checkLeft

        fcall   r8_InventoryMoveCursorDown

.checkLeft:
        ldh     a, [hvar_joypad_current]
        bit     PADB_LEFT, a
        jr      Z, .checkRight

        fcall   r8_InventoryTabLeft

.checkRight:
        ldh     a, [hvar_joypad_current]
        bit     PADB_RIGHT, a
        jr      Z, .done

        fcall   r8_InventoryTabRight

.done:
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryInitImageMargin:
        ld      hl, $9c2d
	ld      bc, 6
        ld      d, $36
        fcall   r8_VramSafeMemset

        ld      hl, $9c4d
	ld      bc, 6
        ld      d, $36
        fcall   r8_VramSafeMemset

        ld      hl, $9c6d
	ld      bc, 6
        ld      d, $36
        fcall   r8_VramSafeMemset

        ld      hl, $9c8d
	ld      bc, 6
        ld      d, $36
        fcall   r8_VramSafeMemset

        ld      hl, $9cad
	ld      bc, 6
        ld      d, $36
        fcall   r8_VramSafeMemset

        ld      hl, $9ccd
	ld      bc, 6
        ld      d, $36
        fcall   r8_VramSafeMemset


        ld      a, 1
        ld	[rVBK], a

        ld      hl, $9c2d
	ld      bc, 6
        ld      d, $83
        fcall   r8_VramSafeMemset

        ld      hl, $9c4d
	ld      bc, 6
        ld      d, $83
        fcall   r8_VramSafeMemset

        ld      hl, $9c6d
	ld      bc, 6
        ld      d, $83
        fcall   r8_VramSafeMemset

        ld      hl, $9c8d
	ld      bc, 6
        ld      d, $83
        fcall   r8_VramSafeMemset

        ld      hl, $9cad
	ld      bc, 6
        ld      d, $83
        fcall   r8_VramSafeMemset

        ld      hl, $9ccd
	ld      bc, 6
        ld      d, $83
        fcall   r8_VramSafeMemset

        ld      a, 0
        ld	[rVBK], a

        ret


;;; ----------------------------------------------------------------------------

r8_InventoryOpen:
        ld      hl, r8_InventoryTiles
        ld      bc, r8_InventoryTilesEnd - r8_InventoryTiles
        ld      de, $9300
        fcall   VramSafeMemcpy

        ;; It's just simpler if objects are reset
        ld      hl, var_oam_back_buffer
        ld      a, 0
        ld      bc, OAM_SIZE * OAM_COUNT
        fcall   Memset

        fcall   VBlankIntrWait
        ld      a, HIGH(var_oam_back_buffer)
        fcall   hOAMDMA

	ld      hl, r8_InventoryItemIcons
        ld      de, $9400
        ld      b, 15
        fcall   GDMABlockCopy

        ld      a, 1
        ld	[rVBK], a

        ld      hl, (_SCRN1 + 32)
        ld      bc, $9e14 - (_SCRN1  + 32)
        ld      d, $81
        fcall   r8_VramSafeMemset
        ld      a, 0
        ld      [rVBK], a

        ld      hl, r8_InventoryLowerBoxTopRow
        ld      bc, r8_InventoryLowerBoxTopRowEnd - r8_InventoryLowerBoxTopRow
        ld      de, $9D00
        fcall   VramSafeMemcpy

        ld      de, $9C20
        fcall   r8_InventoryImageBoxInitRow

        ld      de, $9C40
        fcall   r8_InventoryImageBoxInitRow

        ld      de, $9C60
        fcall   r8_InventoryImageBoxInitRow

        ld      de, $9C80
        fcall   r8_InventoryImageBoxInitRow

	ld      de, $9CA0
        fcall   r8_InventoryImageBoxInitRow

	ld      de, $9CC0
        fcall   r8_InventoryImageBoxInitRow

        ld      hl, r8_InventoryImageBoxBottomRow
        ld      bc, r8_InventoryImageBoxBottomRowEnd - r8_InventoryImageBoxBottomRow
        ld      de, $9CE0
	fcall   VramSafeMemcpy

        ld      de, $9D20
        fcall   r8_InventoryLowerBoxInitRow

        ld      de, $9D40
        fcall   r8_InventoryLowerBoxInitRow

        ld      de, $9D60
        fcall   r8_InventoryLowerBoxInitRow

        ld      de, $9D80
        fcall   r8_InventoryLowerBoxInitRow

        ld      de, $9DA0
        fcall   r8_InventoryLowerBoxInitRow

	ld      de, $9DC0
        fcall   r8_InventoryLowerBoxInitRow

        ld      de, $9DE0
        fcall   r8_InventoryLowerBoxInitRow

        ld      hl, r8_InventoryLowerBoxBottomRow
        ld      bc, r8_InventoryLowerBoxBottomRowEnd - r8_InventoryLowerBoxBottomRow
        ld      de, $9E00
        fcall   VramSafeMemcpy

        ld      a, 1
        ld      [var_overlay_alternate_pos], a

        fcall   ShowOverlay

        fcall   r8_InventoryInitImageMargin

        fcall   VBlankIntrWait
        ld      b, r8_InventoryPalettesEnd - r8_InventoryPalettes
        ld      hl, r8_InventoryPalettes
        fcall   LoadBackgroundColors

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
        ld      a, 0
        ld      [var_inventory_scene_selected_row], a
        ld      [var_inventory_scene_page], a

        fcall   VBlankIntrWait

        ld      hl, $9c21       ; \
        ld      a, $3a          ; | Show left arrow
        ld      [hl], a         ; /

        ld      hl, $9c2a       ; \
        ld      a, $3b          ; | Show right arrow
        ld      [hl], a         ; /

        ld      hl, $9c41       ; \
        ld      bc, 10          ; | Show divider
        ld      a, $3c          ; /
        fcall   Memset


        fcall   r8_SetupImageTiles

	fcall   r8_InventorySetTab

        fcall   VBlankIntrWait
        ret


;;; ----------------------------------------------------------------------------

r8_SetupImageTiles:
        ld      de, $9c4e
        ld      hl, r8_InventoryImgRow1
        ld      bc, 4
        fcall   VramSafeMemcpy

        ld      de, $9c6e
        ld      hl, r8_InventoryImgRow2
        ld      bc, 4
        fcall   VramSafeMemcpy

        ld      de, $9c8e
        ld      hl, r8_InventoryImgRow3
        ld      bc, 4
        fcall   VramSafeMemcpy

        ld      de, $9cae
        ld      hl, r8_InventoryImgRow4
        ld      bc, 4
        fcall   VramSafeMemcpy

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
        fcall   VBlankIntrWait

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
	fcall   VBlankIntrWait
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


;;; NOTE: Only the first nine bytes of the strings are guaranteed to be shown.
;;; Using sixteen byte strings allows us to index into the string table faster,
;;; and because we pad the strings, we don't need to worry about zero-ing out
;;; stuff when writing different strings to a spot onscreen.
r8_InventoryItemTextTable::
DB      "--             ", 0
DB      "wolf pelt      ", 0
DB      "dagger         ", 0
DB      "raw meat       ", 0
DB      "stick          ", 0
DB      "kebab          ", 0
DB      "turnip         ", 0
DB      "potato         ", 0
DB      "broth          ", 0
DB      "soup           ", 0
DB      "stew           ", 0
DB      "bundle         ", 0
DB      "firewood       ", 0
r8_InventoryItemTextTableEnd::
STATIC_ASSERT((r8_InventoryItemTextTableEnd - r8_InventoryItemTextTable) / 16 == ITEM_COUNT)


r8_InventoryTabItemsText::
DB      " items  ", 0
r8_InventoryTabItemsTextEnd::

r8_InventoryTabCraftText::
DB      " craft  ", 0
r8_InventoryTabCraftTextEnd::

r8_InventoryTabCookText::
DB      "  cook  ", 0
r8_InventoryTabCookTextEnd::


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
.kebab::
DB $83, $83, $83, $83
DB $84, $84, $84, $84
DB $83, $84, $83, $83
DB $84, $83, $83, $83
.kebabEnd::
.turnip::
DB $83, $83, $83, $83
DB $85, $84, $83, $83
DB $85, $83, $83, $83
DB $85, $85, $86, $83
.turnipEnd::
.potato::
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $83, $83, $83, $83
.potatoEnd::
.broth::
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $83, $84, $84, $83
DB $85, $85, $85, $85
.brothEnd::
.soup::
DB $83, $83, $83, $83
DB $83, $84, $84, $83
DB $83, $85, $84, $83
DB $86, $86, $86, $86
.soupEnd::
.stew::
DB $83, $83, $83, $83           ; TODO
DB $83, $84, $84, $83
DB $83, $85, $84, $83
DB $86, $86, $86, $86
.stewEnd::
.bundle::
DB $83, $84, $84, $84
DB $83, $83, $84, $84
DB $83, $83, $84, $83
DB $83, $83, $84, $83
.bundleEnd::
.firewood::
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $83, $83, $83, $83
.firewoodEnd::
r8_InventoryItemAttributesEnd::
STATIC_ASSERT((r8_InventoryItemAttributesEnd - r8_InventoryItemAttributes) / 16 == ITEM_COUNT)



;;; FIXME: the first three palette rows are the same every time, because they're
;;; used by the UI. And we only really use four palettes to display an icon. We
;;; can cut down on rom usage by optimizing this stuff a bit.
r8_InventoryItemPalettes::
.empty::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $ce,$55, $29,$31, $c2,$30,
DB $fa,$46, $ce,$55, $29,$31, $c2,$30,
DB $fa,$46, $ce,$55, $29,$31, $c2,$30,
DB $fa,$46, $ce,$55, $29,$31, $c2,$30,
DB $fa,$46, $ce,$55, $29,$31, $c2,$30,
.emptyEnd::
.wolfPelt::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $ad,$4d, $08,$2d, $81,$20,
DB $fa,$46, $ad,$4d, $ff,$7f, $81,$20,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.wolfPeltEnd::
.dagger::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $ad,$4d, $ff,$7f, $81,$20,
DB $fa,$46, $ad,$4d, $d1,$21, $81,$20,
DB $fa,$46, $ad,$24, $d1,$21, $81,$20,
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
DB $fa,$46, $d1,$21, $ad,$24, $81,$20,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.stickEnd::
.kebab::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $ad,$24, $6e,$1e, $d1,$21,
DB $fa,$46, $ad,$24, $81,$20, $d1,$21,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.kebabEnd::
.turnip::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $a9,$1d, $7d,$35, $9f,$63,
DB $fa,$46, $ff,$7f, $7d,$35, $9f,$63,
DB $fa,$46, $81,$20, $ff,$7f, $9f,$63,
DB $fa,$46, $81,$20, $d1,$21, $9f,$63,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.turnipEnd::
.potato::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $d1,$21, $ad,$24, $81,$20,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.potatoEnd::
.broth::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $c7,$40, $2d,$52, $f4,$19,
DB $86,$11, $c7,$40, $2d,$52, $f4,$19,
DB $fa,$46, $c7,$40, $2d,$52, $81,$20,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.brothEnd::
.soup::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $ad,$24, $7d,$35, $9f,$63,
DB $ad,$24, $6e,$1e, $7d,$35, $9f,$63,
DB $ad,$24, $ff,$7f, $7d,$35, $9f,$63,
DB $fa,$46, $81,$20, $ad,$24, $9f,$63,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.soupEnd::
.stew::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04, ; TODO
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $ad,$24, $7d,$35, $9f,$63,
DB $ad,$24, $6e,$1e, $7d,$35, $9f,$63,
DB $ad,$24, $ff,$7f, $7d,$35, $9f,$63,
DB $fa,$46, $81,$20, $ad,$24, $9f,$63,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.stewEnd::
.bundle::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $ad,$24, $d1,$21, $81,$20,
DB $fa,$46, $ad,$24, $ff,$ff, $81,$20,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.bundleEnd::
.firewood::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $d1,$21, $ad,$24, $81,$20,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.firewoodEnd::
r8_InventoryItemPalettesEnd::
STATIC_ASSERT((r8_InventoryItemPalettesEnd - r8_InventoryItemPalettes) / 64 == ITEM_COUNT)


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
.kebab::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$03,$00,$03,$00,$03
DB $00,$01,$00,$00,$01,$00,$07,$00
DB $00,$00,$01,$01,$03,$83,$07,$C7
DB $0F,$EF,$07,$FF,$C6,$3E,$FC,$04
DB $C0,$C0,$E0,$E0,$E0,$E0,$C0,$C0
DB $80,$80,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $0F,$00,$0E,$01,$0F,$00,$0F,$00
DB $07,$08,$07,$08,$07,$00,$03,$04
DB $BC,$40,$DC,$20,$6C,$90,$6C,$90
DB $B4,$48,$BC,$40,$DC,$20,$F8,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $01,$00,$01,$00,$01,$00,$01,$00
DB $07,$04,$0F,$0F,$7E,$02,$EE,$10
DB $B7,$48,$DB,$24,$DB,$24,$ED,$12
DB $F0,$0C,$00,$FC,$00,$7E,$00,$3E
DB $00,$3E,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $01,$00,$00,$00,$03,$03,$03,$03
DB $07,$07,$06,$0E,$0E,$1E,$00,$1C
DB $FF,$00,$FE,$00,$F8,$00,$70,$80
DB $00,$F0,$00,$F8,$00,$78,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
.kebabEnd::
.turnip::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$1F
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$03,$C0
DB $00,$00,$00,$00,$03,$00,$07,$00
DB $1F,$00,$7E,$00,$FC,$00,$F0,$00
DB $00,$00,$02,$01,$03,$03,$07,$03
DB $0B,$07,$0F,$07,$17,$0F,$17,$0F
DB $80,$7F,$E0,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$F3,$FF,$E7,$FF,$FF
DB $07,$F0,$01,$FE,$00,$FE,$01,$FE
DB $80,$FF,$E0,$FF,$E0,$FF,$E0,$FF
DB $00,$00,$0F,$00,$7F,$00,$FF,$00
DB $78,$80,$F0,$00,$7E,$80,$7F,$80
DB $1F,$0F,$1E,$0F,$3F,$0F,$3F,$1F
DB $3F,$1F,$3F,$1F,$3F,$1F,$3F,$0F
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $E0,$FF,$C0,$FF,$E0,$FF,$F0,$FF
DB $F0,$FF,$FC,$FF,$FE,$FF,$FE,$FF
DB $67,$80,$63,$80,$40,$80,$40,$80
DB $00,$80,$00,$80,$00,$80,$00,$80
DB $1C,$04,$0E,$02,$06,$00,$03,$00
DB $01,$00,$00,$00,$00,$00,$00,$00
DB $7F,$7F,$1F,$1F,$00,$00,$80,$80
DB $C0,$40,$71,$01,$0F,$00,$00,$00
DB $FE,$FF,$F0,$F1,$02,$03,$04,$06
DB $38,$38,$B0,$80,$00,$00,$00,$00
DB $00,$80,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
.turnipEnd::
.potato::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $01,$00,$01,$00,$03,$00,$07,$00
DB $00,$00,$01,$00,$7F,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$00,$FF,$00,$BF,$40,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$00,$C0,$00,$C0,$00,$E0,$00
DB $E0,$00,$F0,$00,$F0,$00,$F8,$00
DB $0F,$00,$1F,$00,$3F,$00,$3F,$00
DB $3F,$00,$7F,$40,$7F,$40,$7F,$40
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$DF,$20,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $F8,$00,$F8,$00,$F8,$00,$F8,$00
DB $F8,$00,$F8,$00,$F8,$00,$F0,$00
DB $7F,$40,$7F,$60,$7F,$60,$3F,$30
DB $1F,$18,$0F,$0E,$03,$03,$00,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FB,$FB,$00,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$20,$20,$00,$00
DB $F0,$00,$F0,$00,$E0,$00,$E0,$00
DB $C0,$00,$00,$00,$00,$00,$00,$00
.potatoEnd::
.broth::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$01
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$1F,$07,$F8
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$F8,$E0,$1F
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$80
DB $00,$0F,$07,$18,$0F,$30,$0F,$77
DB $1F,$EF,$3F,$DF,$3F,$DF,$3F,$FF
DB $FF,$00,$FE,$1E,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FC,$03,$FF,$F0,$F9,$F9,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $00,$F0,$C0,$18,$F0,$0C,$B0,$AA
DB $F8,$F5,$EC,$E9,$FC,$FB,$FC,$FF
DB $3F,$FF,$1F,$FF,$8F,$7F,$C1,$3F
DB $F0,$0F,$FC,$03,$7F,$00,$7F,$00
DB $F7,$F7,$FD,$FD,$FF,$FF,$FF,$FF
DB $1F,$FF,$00,$FF,$C0,$3F,$FF,$00
DB $EF,$EF,$FF,$FF,$FF,$FF,$FF,$FF
DB $F8,$FF,$00,$FF,$23,$DC,$DF,$20
DB $FC,$FF,$F8,$FF,$F1,$FE,$83,$FC
DB $0F,$F0,$3F,$C0,$FE,$00,$FE,$00
DB $7F,$40,$7F,$60,$3F,$30,$1F,$18
DB $0F,$0C,$03,$03,$00,$00,$00,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$7F,$70,$00,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$F0,$00,$00,$00
DB $FC,$00,$F8,$00,$F0,$00,$E0,$00
DB $C0,$00,$00,$00,$00,$00,$00,$00
.brothEnd::
.soup::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$01
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$1F,$07,$F8
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$F8,$E0,$1F
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$80
DB $00,$0F,$07,$18,$0F,$30,$0B,$73
DB $1F,$EF,$3F,$DF,$3F,$DF,$3F,$FF
DB $00,$00,$1F,$1F,$FF,$FF,$FF,$FF
DB $FF,$9D,$FF,$0F,$FF,$07,$FF,$CF
DB $00,$03,$F0,$F0,$FF,$FF,$FF,$FF
DB $FF,$F1,$FF,$E0,$FF,$E0,$FF,$C1
DB $00,$F0,$C0,$18,$F0,$0C,$D0,$CA
DB $F8,$F5,$FC,$F9,$FC,$FB,$F8,$FB
DB $3E,$FF,$1F,$FF,$8F,$7F,$C1,$3F
DB $F0,$0F,$FC,$03,$7F,$00,$7F,$00
DB $FF,$FF,$FF,$FD,$FF,$F7,$FF,$FF
DB $1F,$FF,$00,$FF,$00,$3F,$00,$00
DB $FF,$FF,$FF,$FF,$FF,$9F,$FF,$FF
DB $F8,$FF,$00,$FF,$00,$DC,$00,$20
DB $FC,$FF,$F8,$FF,$F1,$FE,$83,$FC
DB $0F,$F0,$3F,$C0,$FE,$00,$FE,$00
DB $40,$3F,$60,$1F,$30,$0F,$18,$07
DB $0C,$03,$03,$00,$00,$00,$00,$00
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$70,$0F,$00,$00
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$F0,$00,$00
DB $00,$FC,$00,$F8,$00,$F0,$00,$E0
DB $00,$C0,$00,$00,$00,$00,$00,$00
.soupEnd::
.stew::
DB $00,$00,$00,$00,$00,$00,$00,$00 ; TODO...
DB $00,$00,$00,$00,$00,$00,$00,$01
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$1F,$07,$F8
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$F8,$E0,$1F
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$80
DB $00,$0F,$07,$18,$0F,$30,$0B,$73
DB $1F,$EF,$3F,$DF,$3F,$DF,$3F,$FF
DB $00,$00,$1F,$1F,$FF,$FF,$FF,$FF
DB $FF,$9D,$FF,$0F,$FF,$07,$FF,$CF
DB $00,$03,$F0,$F0,$FF,$FF,$FF,$FF
DB $FF,$F1,$FF,$E0,$FF,$E0,$FF,$C1
DB $00,$F0,$C0,$18,$F0,$0C,$D0,$CA
DB $F8,$F5,$FC,$F9,$FC,$FB,$F8,$FB
DB $3E,$FF,$1F,$FF,$8F,$7F,$C1,$3F
DB $F0,$0F,$FC,$03,$7F,$00,$7F,$00
DB $FF,$FF,$FF,$FD,$FF,$F7,$FF,$FF
DB $1F,$FF,$00,$FF,$00,$3F,$00,$00
DB $FF,$FF,$FF,$FF,$FF,$9F,$FF,$FF
DB $F8,$FF,$00,$FF,$00,$DC,$00,$20
DB $FC,$FF,$F8,$FF,$F1,$FE,$83,$FC
DB $0F,$F0,$3F,$C0,$FE,$00,$FE,$00
DB $40,$3F,$60,$1F,$30,$0F,$18,$07
DB $0C,$03,$03,$00,$00,$00,$00,$00
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$70,$0F,$00,$00
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$F0,$00,$00
DB $00,$FC,$00,$F8,$00,$F0,$00,$E0
DB $00,$C0,$00,$00,$00,$00,$00,$00
.stewEnd::
.bundle::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$03,$00,$03,$00,$03,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$AF,$00,$FF
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$C0,$00,$C0
DB $00,$00,$00,$00,$00,$00,$00,$01
DB $00,$0F,$01,$0E,$01,$0E,$00,$03
DB $00,$00,$00,$01,$13,$00,$3F,$C0
DB $3F,$C0,$0F,$F0,$8F,$70,$0F,$F8
DB $00,$EF,$00,$F0,$87,$78,$C7,$39
DB $C7,$38,$E3,$7E,$E3,$1C,$E3,$1C
DB $00,$80,$00,$00,$E0,$00,$F8,$00
DB $FC,$00,$C0,$00,$FE,$00,$FE,$00
DB $00,$07,$00,$0F,$01,$0E,$00,$0F
DB $00,$0F,$01,$1E,$00,$1F,$00,$1F
DB $4F,$B0,$FF,$1E,$9F,$60,$1F,$E0
DB $1F,$E0,$3F,$C0,$7F,$FE,$7F,$80
DB $E3,$1C,$E3,$1C,$E3,$1C,$E3,$1C
DB $E3,$1C,$E3,$1C,$E3,$1C,$E7,$18
DB $FE,$00,$F0,$00,$FE,$00,$FE,$00
DB $FC,$80,$F0,$00,$F8,$00,$E0,$00
DB $34,$3F,$1C,$1F,$07,$06,$03,$03
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $7F,$80,$7F,$80,$FF,$7F,$C0,$C0
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $C7,$3F,$FC,$3C,$E0,$E0,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $C0,$C0,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
.bundleEnd::
.firewood::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$01,$00,$03,$00,$03,$00,$03
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$F0,$00,$F8,$00,$F8,$00,$FC
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$01,$00,$03,$00,$07,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$C0,$00,$E0,$00,$E0,$00
DB $00,$01,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$FE,$00,$FF,$00,$7F,$00,$3F
DB $00,$3F,$00,$1F,$00,$0F,$00,$07
DB $03,$0C,$00,$0F,$00,$8F,$00,$DF
DB $00,$DF,$18,$FF,$00,$FF,$00,$FF
DB $C0,$20,$00,$E0,$00,$C0,$00,$C0
DB $00,$80,$00,$80,$00,$0E,$00,$FE
DB $00,$00,$00,$00,$00,$03,$07,$00
DB $0F,$00,$0F,$10,$1F,$20,$3F,$00
DB $02,$03,$01,$3F,$01,$FF,$00,$FF
DB $80,$7F,$80,$7F,$C0,$3F,$C0,$3F
DB $00,$FF,$00,$FF,$80,$FF,$80,$FF
DB $40,$FF,$30,$FF,$38,$FF,$38,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$03,$FF,$0E,$FE
DB $3F,$00,$7F,$40,$7F,$40,$7F,$40
DB $7F,$60,$3F,$3F,$00,$00,$00,$00
DB $80,$7F,$80,$7F,$80,$7F,$80,$7F
DB $0F,$FF,$F8,$F8,$00,$00,$00,$00
DB $1C,$FF,$1E,$FF,$1E,$FF,$F3,$F3
DB $81,$81,$00,$00,$00,$00,$00,$00
DB $00,$F0,$00,$F8,$00,$FC,$00,$FC
DB $80,$F8,$F0,$F0,$00,$00,$00,$00
.firewoodEnd::
r8_InventoryItemIconsEnd::
STATIC_ASSERT((r8_InventoryItemIconsEnd - r8_InventoryItemIcons) / 256 == ITEM_COUNT)
