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
DB      ITEM_RAW_MEAT,  ITEM_MORSEL,    ITEM_MORSEL,    ITEM_MORSEL
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


r8_InventoryImageBoxTopRow::
DB $30, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $31, $30, $34, $34,
DB $34, $34, $34, $34, $31
r8_InventoryImageBoxTopRowEnd::


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


scavenge_text::
DB      "gather   items   /  ", 0


;;; ----------------------------------------------------------------------------

r8_ScavengeUpdate:
        ld      a, [hvar_joypad_current]
        bit     PADB_B, a
        jp      NZ, .exit

        bit     PADB_A, a
        jr      NZ, .takeItem

        bit     PADB_UP, a
        jr      Z, .checkDown

        ld      a, 0
        ld      [var_scavenge_selection], a

        call    VBlankIntrWait
        ld      de, $9c20       ; \
        ld      a, $31          ; | selector icon
        ld      [de], a         ; /
        ld      de, $9c40       ; \
        ld      a, $32          ; | selector icon
        ld      [de], a         ; /

        ret

.checkDown:
        bit     PADB_DOWN, a
        ret     Z

        call    VBlankIntrWait
        ld      de, $9c20       ; \
        ld      a, $32          ; | selector icon
        ld      [de], a         ; /
        ld      de, $9c40       ; \
        ld      a, $31          ; | selector icon
        ld      [de], a         ; /

        ld      a, 1
        ld      [var_scavenge_selection], a

        ret

.takeItem:
        ld      hl, var_scavenge_slot_0     ; \
        ld      a, [var_scavenge_selection] ; |
        ld      c, a                        ; | Pick slot
        ld      b, 0                        ; |
        add     hl, bc                      ; /

        ld      a, [hl]         ; Load item
        or      a
        ret     Z               ; empty item slot

        push    hl
        ld      b, a
        fcall   InventoryAddItem
        pop     hl

        ld      a, ITEM_NONE    ; \ Remove contents of item slot
        ld      [hl], a         ; /

        ld      a, [var_scavenge_target]     ; \
        ld      h, a                         ; | Load pointer to entity that's
        ld      a, [var_scavenge_target + 1] ; | holding the items.
        ld      l, a                         ; /

	ld      a, [var_scavenge_selection] ; \
        add     a, 1                        ; | Because there are only two
        cpl                                 ; | scavenge slots, compute mask by
        and     $03                         ; / flipping bits.

        push    af

        fcall   EntityGetFullType         ; \
        and     ENTITY_TYPE_MODIFIER_MASK ; | Retrieve existing entity type modifier
        swap    a                         ; | flags.
        srl     a                         ; |
        srl     a                         ; /

        pop     bc
        and     b
        fcall   EntitySetTypeModifier

        fcall   InventorySize     ; \
        ld      h, 0              ; | We added an item, redraw the inventory
        ld      l, c              ; | used count. First convert the number
        ld      de, var_temp_str1 ; | to a string...
        fcall   IntegerToString   ; /

        ;; Now, we'll need to re-draw the text for the item that we just took.
        fcall   VBlankIntrWait

        ld      hl, var_temp_str1 + 3 ; \
        ld      b, $88                ; | Draw the inventory-used count.
        ld      de, $9c6f             ; |
        call    PutText               ; /

        ld      a, [var_scavenge_selection]
	ld      de, $9c41
        or      a
        jr      NZ, .row1
        ld      de, $9c21
.row1:
        ld      hl, r8_InventoryItemTextTable.null
        ld      b, $88
        fcall   PutText
        ret

.exit:
        ld      a, 0
        ld      [var_scene_counter], a

        ld      de, ScavengeSceneAnimateOut0
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

r8_ScavengeShowOptions:
        fcall   InventorySize
        ld      h, 0
        ld      l, c
        ld      de, var_temp_str1
        fcall   IntegerToString

        ld      h, 0
        ld      l, INVENTORY_COUNT
        ld      de, var_temp_str2
        fcall   IntegerToString

        fcall   VBlankIntrWait

        ld      a, [var_scavenge_slot_0]
        ld      b, a
        fcall   r8_InventoryItemText
        ld      de, $9c21
        ld      b, $88
        fcall   PutText

        ld      a, [var_scavenge_slot_1]
        ld      b, a
        fcall   r8_InventoryItemText
        ld      de, $9c41
        ld      b, $88
        fcall   PutText

        fcall   VBlankIntrWait
	ld      hl, scavenge_text
        ld      de, $9c60
        ld      b, $88
        fcall   PutText

        ld      hl, var_temp_str1 + 3
        ld      b, $88
        ld      de, $9c6f
        call    PutText

        ld      hl, var_temp_str2 + 3
        ld      b, $88
        ld      de, $9c72
        call    PutText

	ld      de, $9c20       ; \
        ld      a, $31          ; | selector icon
        ld      [de], a         ; /
        ld      de, $9c40       ; \
        ld      a, $32          ; | selector icon
        ld      [de], a         ; /

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
        ret     Z

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


;;; ----------------------------------------------------------------------------

r8_InventoryItemText:
;;; b - item typeinfo
;;; trashes a bunch of registers
;;; result in hl
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
        cp      a, 1
        jr      Z, .secondPage
        cp      a, 2
        jr      Z, .thirdPage
        pop     af
        ret
.secondPage:
        pop     af
        add     7
        ret
.thirdPage:
        pop     af
        add     14
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

        ld      b, c
        WIDE_CALL r30_InventoryPutItemIcon

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


;;; Why did I dedicate three bytes per item description? I don't remember, there
;;; was probably a reason, but now it's unused, I think... aha, so for easy
;;; indexing, the size should be a power of two, and I must have thought that
;;; two bytes was not future-proof enough, so I doubled the size.

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
DB      ITEM_CATEGORY_FOOD,      220, $00, $00

.bundle:
DB      ITEM_CATEGORY_MISC,      $00, $00, $00

.firewood:
DB      ITEM_CATEGORY_MISC,      $00, $00, $00

.key:
DB      ITEM_CATEGORY_MISC,      $00, $00, $00

.morsel:
DB      ITEM_CATEGORY_FOOD,        2, $00, $00

.hammer:
DB      ITEM_CATEGORY_EQUIPMENT, $00, $00, $00

.thread:
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
        xor     a
        ld      [var_inventory_submenu_selection], a

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
        ld      a, [hl]
        ld      [var_inventory_add_stamina_amount], a

        ld      de, InventorySceneConsumeUpdate
        fcall   SceneSetUpdateFn

        ld      hl, r8_queryConsumeItemText
        fcall   r8_ShowYesNoOptionBox
        ret

.useEquipmentItem:
        ld      de, InventorySceneEquipUpdate
        fcall   SceneSetUpdateFn

        ld      hl, r8_queryEquipItemText
        fcall   r8_ShowYesNoOptionBox
        ret

.useMiscItem:
        ld      a, d
        cp      ITEM_FIREWOOD
        jr      Z, .useFirewoodItem
        cp      ITEM_NONE
        ret     Z

.discardItem:
        ld      de, InventorySceneDiscardUpdate
        fcall   SceneSetUpdateFn

        ld      hl, r8_queryDiscardItemText
        fcall   r8_ShowYesNoOptionBox
        ret

.useFirewoodItem:
        ld      de, InventorySceneUseFirewoodUpdate
        fcall   SceneSetUpdateFn

        ld      hl, r8_queryUseFirewoodText
        fcall   r8_ShowYesNoOptionBox
        ret


;;; ----------------------------------------------------------------------------

r8_ShowYesNoOptionBox:
;;; hl - heading text
        fcall   VBlankIntrWait
        ld      b, $89
        ld      a, 0
        fcall   r8_InventoryPutTextRow

        fcall   VBlankIntrWait
        ld      b, $89
        ld      a, 1
        ld      hl, r8_emptyLine
        fcall   r8_InventoryPutTextRow

        fcall   VBlankIntrWait
        ld      b, $8A
        ld      a, 2
        ld      hl, r8_optionNoText
        fcall   r8_InventoryPutTextRow

        fcall   VBlankIntrWait
        ld      b, $89
        ld      a, 3
        ld      hl, r8_optionYesText
        fcall   r8_InventoryPutTextRow

        fcall   VBlankIntrWait
        ld      b, $89
        ld      a, 4
        ld      hl, r8_emptyLine
        fcall   r8_InventoryPutTextRow

        ld      b, $89
        ld      a, 5
        ld      hl, r8_emptyLine
        fcall   r8_InventoryPutTextRow

        ld      b, $89
        ld      a, 6
        ld      hl, r8_emptyLine
        fcall   r8_InventoryPutTextRow

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
        jr      Z, .cook
.items:
        ld      a, [var_inventory_scene_selected_row] ; \
        fcall   r8_InventoryAdjustOffset              ; |
        ld      b, a                                  ; | Do nothing if the
        fcall   InventoryGetItem                      ; | selected row is empty.
        ld      a, b                                  ; |
        or      a                                     ; |
        ret     Z                                     ; /

        fcall   r8_InventoryUseItem
        ret

.craft:
        fcall   r8_InventoryGetSelectedIndex ; \
        ld      b, a                         ; |
        fcall   r8_GetCraftableItemRecipe    ; | Return if recipe pointer is
        ld      a, h                         ; | null.
        or      l                            ; |
        ret     Z                            ; /

        ld      hl, r8_queryCraftItemText
        fcall   r8_ShowYesNoOptionBox
        ld      de, InventorySceneCraftOptionUpdate
        fcall   SceneSetUpdateFn
        ret

.cook:
        fcall   r8_InventoryGetSelectedIndex ; \
        ld      b, a                         ; |
        fcall   r8_GetCraftableItemRecipe    ; | Return if recipe pointer is
        ld      a, h                         ; | null.
        or      l                            ; |
        ret     Z                            ; /

        ld      hl, r8_queryCookItemText
        fcall   r8_ShowYesNoOptionBox
        ld      de, InventorySceneCraftOptionUpdate
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

r8_InventoryCraftItem:
        fcall   r8_InventoryGetSelectedIndex
        ld      b, a

        fcall   r8_GetCraftableItemRecipe

        ld      a, h                    ; \
        or      l                       ; | Null pointer check.
        ret     Z                       ; /

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
        ret     Z

        ld      a, [hl]
        or      a
        jr      NZ, .next

        ld      [hl], d
        inc     hl
        ld      [hl], e
        ret

.next:
        inc     c
        inc     hl
        inc     hl
        jr      .loop


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
        ret     Z

        ld      a, [hl]
        cp      0
        ret     Z

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
        fcall   VBlankIntrWait

        ld      hl, $9c61
        ld      bc, 10
        xor     a
        fcall   Memset

        ld      hl, $9c81
        ld      bc, 10
        fcall   Memset

        ld      hl, $9ca1
        ld      bc, 10
        fcall   Memset

        ld      a, 1
        ld      [rVBK], a

        ld      hl, $9c61
        ld      bc, 10
        ld      a, $81
        fcall   Memset

        ld      hl, $9c81
        ld      bc, 10
        fcall   Memset

        ld      hl, $9ca1
        ld      bc, 10
        fcall   Memset

        ld      a, 0
        ld      [rVBK], a

        ret



;;; ----------------------------------------------------------------------------

r8_InventorySetTab:
        fcall   VBlankIntrWait

        xor     a
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
        cp      2
        jr      Z, .skip

        inc     a
        ld      [var_inventory_scene_page], a

        ld      a, 1
        ld	[rVBK], a

        ld      a, [var_inventory_scene_selected_row]
        ld      b, $89
        fcall   r8_InventoryTextRowSetAttr

        xor     a
        ld	[rVBK], a
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

r8_InventorySceneOptionBoxUpdate:
;;; hl - yes callback
        ldh     a, [hvar_joypad_current]

.checkUp:
        bit     PADB_UP, a
        jr      Z, .checkA

        xor     a
        ld      [var_inventory_submenu_selection], a

        fcall   VBlankIntrWait
        ld      b, $8a
        ld      a, 2
        ld      hl, r8_optionNoText
        fcall   r8_InventoryPutTextRow

        ld      b, $89
        ld      a, 3
        ld      hl, r8_optionYesText
        fcall   r8_InventoryPutTextRow
	ret

.checkA:
        bit     PADB_A, a
        jr      Z, .checkDown

        ld      a, [var_inventory_submenu_selection]
        or      a
        jr      Z, .cancelOut

        INVOKE_HL               ; yes option callback
        ret

.checkDown:
        bit     PADB_DOWN, a
        jr      Z, .checkB

        ld      a, 1
        ld      [var_inventory_submenu_selection], a

        fcall   VBlankIntrWait
        ld      b, $89
        ld      a, 2
        ld      hl, r8_optionNoText
        fcall   r8_InventoryPutTextRow

        ld      b, $8a
        ld      a, 3
        ld      hl, r8_optionYesText
        fcall   r8_InventoryPutTextRow
        ret

.checkB:
        bit     PADB_B, a
        ret     Z

.cancelOut:
        fcall   r8_InventoryInitText

        ld      de, InventorySceneUpdate
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------


r8_InventorySceneDiscardUpdate:
        ld      hl, .yesOptionSelectedCallback
        fcall   r8_InventorySceneOptionBoxUpdate
        ret

.yesOptionSelectedCallback:
        fcall   r8_RemoveSelectedItem
        fcall   r8_InventoryInitText
        fcall   r8_InventoryUpdateImage

        ld      de, InventorySceneUpdate
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

r8_InventorySceneUseFirewoodUpdate:
        ld      hl, .yesOptionSelectedCallback
        fcall   r8_InventorySceneOptionBoxUpdate
        ret

.yesOptionSelectedCallback:
        fcall   r8_RemoveSelectedItem

        ld      de, ConstructBonfireSceneEnter
        fcall   SceneSetUpdateFn
        ret


;;; ----------------------------------------------------------------------------

r8_InventorySceneEquipUpdate:
        ld      hl, .yesOptionSelectedCallback
        fcall   r8_InventorySceneOptionBoxUpdate
        ret

.yesOptionSelectedCallback:
        fcall   r8_InventoryGetSelectedIndex
        ld      b, a
        fcall   r8_InventoryTabLoadItem
	ld      a, b
        ld      [var_equipped_item], a
        ld      de, InventorySceneUpdate
        fcall   SceneSetUpdateFn
        fcall   r8_InventoryInitText

        ld      c, 18
        fcall   OverlayShowEquipIcon

        fcall   ShowOverlay
        ret


;;; ----------------------------------------------------------------------------

r8_InventorySceneCraftOptionUpdate:
        ld      hl, .yesOptionSelectedCallback
        fcall   r8_InventorySceneOptionBoxUpdate
        ret

.yesOptionSelectedCallback:
        fcall   r8_InventoryCraftItem
        ld      de, InventorySceneUpdate
        fcall   SceneSetUpdateFn
        ret

;;; ----------------------------------------------------------------------------

r8_InventorySceneConsumeUpdate:
        ld      hl, .yesOptionSelectedCallback
        fcall   r8_InventorySceneOptionBoxUpdate
        ret

.yesOptionSelectedCallback:
        ld      a, [var_inventory_add_stamina_amount]
        ld      b, a
        ld      c, 0
        ld      hl, var_player_stamina
        fcall   FixnumAddClamped

        fcall   UpdateStaminaBar
        fcall   VBlankIntrWait  ; FIXME...
        fcall   ShowOverlay

        fcall   r8_RemoveSelectedItem
        fcall   r8_InventoryInitText
        fcall   r8_InventoryUpdateImage

        ld      de, InventorySceneUpdate
        fcall   SceneSetUpdateFn
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
        ret     Z

        fcall   r8_InventoryTabRight

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
        ;; It's just simpler if objects are reset
        ld      hl, var_oam_back_buffer
        ld      a, 0
        ld      bc, OAM_SIZE * OAM_COUNT
        fcall   Memset

        fcall   VBlankIntrWait
        ld      hl, r8_InventoryTiles
        ld      de, $9300
        ld      b, ((r8_InventoryTilesEnd - r8_InventoryTiles) / 16) - 1
        fcall   GDMABlockCopy

        fcall   VBlankIntrWait
        ld      a, HIGH(var_oam_back_buffer)
        fcall   hOAMDMA

        ld      b, 0
        WIDE_CALL r30_InventoryPutItemIcon

        ld      a, 1
        ld	[rVBK], a

        fcall   VBlankIntrWait                     ; \
        ld      hl, (_SCRN1 + 32)                  ; |
        ld      bc, ($9e14 - (_SCRN1  + 32)) - 160 ; | Memset as much as we can
        ld      a, $81                             ; | in one blank.
        fcall   Memset                             ; /

        fcall   VBlankIntrWait
        ld      hl, (_SCRN1 + 32) + (($9e14 - (_SCRN1  + 32)) - 160)
        ld      bc, 160
        ld      a, $81
        fcall   Memset

        ld      a, 0
        ld      [rVBK], a




        fcall   VBlankIntrWait
        ld      de, $9D00
        ld      hl, r8_InventoryLowerBoxTemplate
        ld      b, 17
        fcall   GDMABlockCopy

        ld      de, $9C20
        ld      hl, r8_InventoryImageBoxTemplate
        ld      b, 13
        fcall   GDMABlockCopy

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


r8_optionYesText:
DB      "yes            ", 0
r8_optionNoText:
DB      "no             ", 0


r8_emptyLine:
DB      "               ", 0


r8_queryDiscardItemText:
DB      "Discard item?  ", 0
r8_queryConsumeItemText:
DB      "Consume item?  ", 0
r8_queryCraftItemText:
DB      "Craft item?    ", 0
r8_queryCookItemText:
DB      "Cook item?     ", 0
r8_queryUseFirewoodText:
DB      "Start bonfire? ", 0
r8_queryEquipItemText:
DB      "Equip item?    ", 0


;;; NOTE: Only the first nine bytes of the strings are guaranteed to be shown.
;;; Using sixteen byte strings allows us to index into the string table faster,
;;; and because we pad the strings, we don't need to worry about zero-ing out
;;; stuff when writing different strings to a spot onscreen.
r8_InventoryItemTextTable::
.null:
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
DB      "key            ", 0
DB      "morsel         ", 0
DB      "hammer         ", 0
DB      "thread         ", 0
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
.key::
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $83, $83, $83, $83
.keyEnd::
.morsel::
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $84, $83, $83, $83
DB $84, $85, $85, $83
.morselEnd::
.hammer::
DB $84, $83, $83, $85           ; Placeholder, TODO...
DB $86, $87, $87, $85
DB $86, $86, $84, $87
DB $83, $85, $85, $85
.hammerEnd::
.thread::
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $83, $83, $83, $83
DB $83, $83, $83, $83
.threadEnd::

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
.key::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $ad,$4d, $ff,$7f, $81,$20,
DB $fa,$46, $ad,$4d, $d1,$21, $81,$20,
DB $fa,$46, $ad,$24, $d1,$21, $81,$20,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.keyEnd::
.morsel::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $1b,$4b, $ad,$24, $7d,$35, $9f,$63,
DB $1b,$4b, $ad,$24, $7d,$35, $81,$20,
DB $1b,$4b, $ad,$24, $9f,$63, $81,$20,
DB $00,$00, $00,$00, $00,$00, $00,$00,
DB $00,$00, $00,$00, $00,$00, $00,$00,
.morselEnd::
.hammer::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $ad,$4d, $ad,$24, $ff,$7f,
DB $fa,$46, $ad,$4d, $ff,$7f, $81,$20,
DB $fa,$46, $ad,$24, $d1,$21, $81,$20,
DB $fa,$46, $ad,$4d, $ad,$24, $81,$20,
DB $fa,$46, $ad,$4d, $ad,$24, $d1,$21,
.hammerEnd::
.thread::
DB $BF,$73, $1A,$20, $1A,$20, $00,$04,
DB $37,$73, $49,$35, $00,$04, $62,$1c,
DB $03,$00, $69,$72, $00,$00, $1A,$20,
DB $fa,$46, $d1,$21, $ff,$7f, $81,$20,
DB $fa,$46, $ad,$4d, $ff,$7f, $81,$20,
DB $fa,$46, $ad,$24, $d1,$21, $81,$20,
DB $fa,$46, $ad,$4d, $ad,$24, $81,$20,
DB $fa,$46, $ad,$4d, $ad,$24, $d1,$21,
.threadEnd::

r8_InventoryItemPalettesEnd::
STATIC_ASSERT((r8_InventoryItemPalettesEnd - r8_InventoryItemPalettes) / 64 == ITEM_COUNT)


;;; ############################################################################

SECTION "ROM8_MENU_TEMPLATE", ROMX, ALIGN[8], BANK[8]

r8_InventoryLowerBoxTemplate::
.topRow:
DB $30, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34, $34,
DB $34, $34, $34, $34, $31, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
.middleRows:
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
.bottomRow:
DB $33, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38
DB $38, $38, $38, $38, $32, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
r8_InventoryLowerBoxTemplateEnd::

r8_InventoryImageBoxTemplate::
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $37, $35, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $37, $35, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $37, $35, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $37, $35, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $37, $35, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $37, $35, $00, $00
DB $00, $00, $00, $00, $37, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
DB $33, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $32, $33, $38, $38
DB $38, $38, $38, $38, $32, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
DB $00, $00,
r8_InventoryImageBoxTemplateEnd::


;;; ############################################################################

SECTION "ROM8_INVENTORY_TILES", ROMX, ALIGN[8], BANK[8]

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
