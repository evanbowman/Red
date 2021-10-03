;;; ############################################################################


SECTION "MISC_SPRITES", ROMX, BANK[7]


        INCLUDE "r7_fadeLut.asm"


r7_FontTiles::
.circle:
DB $FF,$FF,$C3,$C3,$81,$81,$81,$81
DB $81,$81,$81,$81,$C3,$C3,$FF,$FF
.font:
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$E7,$E7,$DB,$DB
DB $DB,$DB,$DB,$DB,$E7,$E7,$FF,$FF
DB $FF,$FF,$FF,$FF,$E7,$E7,$F7,$F7
DB $F7,$F7,$F7,$F7,$F7,$F7,$FF,$FF
DB $FF,$FF,$FF,$FF,$C7,$C7,$FB,$FB
DB $C3,$C3,$DF,$DF,$C3,$C3,$FF,$FF
DB $FF,$FF,$FF,$FF,$C7,$C7,$FB,$FB
DB $E7,$E7,$FB,$FB,$C7,$C7,$FF,$FF
DB $FF,$FF,$FF,$FF,$DB,$DB,$DB,$DB
DB $E3,$E3,$FB,$FB,$FB,$FB,$FF,$FF
DB $FF,$FF,$FF,$FF,$C3,$C3,$DF,$DF
DB $C3,$C3,$FB,$FB,$C7,$C7,$FF,$FF
DB $FF,$FF,$FF,$FF,$E7,$E7,$DF,$DF
DB $C7,$C7,$DB,$DB,$E7,$E7,$FF,$FF
DB $FF,$FF,$FF,$FF,$C3,$C3,$FB,$FB
DB $F7,$F7,$EF,$EF,$EF,$EF,$FF,$FF
DB $FF,$FF,$FF,$FF,$E7,$E7,$DB,$DB
DB $E7,$E7,$DB,$DB,$E7,$E7,$FF,$FF
DB $FF,$FF,$FF,$FF,$E7,$E7,$DB,$DB
DB $E3,$E3,$FB,$FB,$E7,$E7,$FF,$FF
DB $FF,$FF,$FF,$FF,$C3,$C3,$BB,$BB
DB $BB,$BB,$B3,$B3,$CB,$CB,$FF,$FF
DB $BF,$BF,$BF,$BF,$87,$87,$BB,$BB
DB $BB,$BB,$BB,$BB,$87,$87,$FF,$FF
DB $FF,$FF,$FF,$FF,$C7,$C7,$BB,$BB
DB $BF,$BF,$BF,$BF,$C3,$C3,$FF,$FF
DB $FB,$FB,$FB,$FB,$C3,$C3,$BB,$BB
DB $BB,$BB,$BB,$BB,$C3,$C3,$FF,$FF
DB $FF,$FF,$FF,$FF,$C7,$C7,$BB,$BB
DB $83,$83,$BF,$BF,$C3,$C3,$FF,$FF
DB $F3,$F3,$EF,$EF,$C7,$C7,$EF,$EF
DB $EF,$EF,$EF,$EF,$EF,$EF,$FF,$FF
DB $FF,$FF,$FF,$FF,$C3,$C3,$BB,$BB
DB $BB,$BB,$C3,$C3,$FB,$FB,$C7,$C7
DB $BF,$BF,$BF,$BF,$87,$87,$BB,$BB
DB $BB,$BB,$BB,$BB,$BB,$BB,$FF,$FF
DB $EF,$EF,$FF,$FF,$EF,$EF,$EF,$EF
DB $EF,$EF,$EF,$EF,$EF,$EF,$FF,$FF
DB $EF,$EF,$FF,$FF,$EF,$EF,$EF,$EF
DB $EF,$EF,$EF,$EF,$EF,$EF,$9F,$9F
DB $BF,$BF,$BF,$BF,$B7,$B7,$AF,$AF
DB $8F,$8F,$B7,$B7,$BB,$BB,$FF,$FF
DB $EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF
DB $EF,$EF,$EF,$EF,$E7,$E7,$FF,$FF
DB $FF,$FF,$FF,$FF,$87,$87,$AB,$AB
DB $AB,$AB,$AB,$AB,$AB,$AB,$FF,$FF
DB $FF,$FF,$FF,$FF,$A7,$A7,$9B,$9B
DB $BB,$BB,$BB,$BB,$BB,$BB,$FF,$FF
DB $FF,$FF,$FF,$FF,$C7,$C7,$BB,$BB
DB $BB,$BB,$BB,$BB,$C7,$C7,$FF,$FF
DB $FF,$FF,$FF,$FF,$87,$87,$BB,$BB
DB $BB,$BB,$87,$87,$BF,$BF,$BF,$BF
DB $FF,$FF,$FF,$FF,$C3,$C3,$BB,$BB
DB $BB,$BB,$C3,$C3,$FB,$FB,$FB,$FB
DB $FF,$FF,$FF,$FF,$A7,$A7,$9B,$9B
DB $BF,$BF,$BF,$BF,$BF,$BF,$FF,$FF
DB $FF,$FF,$FF,$FF,$C3,$C3,$BF,$BF
DB $C7,$C7,$FB,$FB,$87,$87,$FF,$FF
DB $DF,$DF,$DF,$DF,$87,$87,$DF,$DF
DB $DF,$DF,$DF,$DF,$E7,$E7,$FF,$FF
DB $FF,$FF,$FF,$FF,$BB,$BB,$BB,$BB
DB $BB,$BB,$B3,$B3,$CB,$CB,$FF,$FF
DB $FF,$FF,$FF,$FF,$BB,$BB,$BB,$BB
DB $D7,$D7,$D7,$D7,$EF,$EF,$FF,$FF
DB $FF,$FF,$FF,$FF,$AB,$AB,$AB,$AB
DB $AB,$AB,$AB,$AB,$D7,$D7,$FF,$FF
DB $FF,$FF,$FF,$FF,$BB,$BB,$D7,$D7
DB $EF,$EF,$D7,$D7,$BB,$BB,$FF,$FF
DB $FF,$FF,$FF,$FF,$BB,$BB,$BB,$BB
DB $BB,$BB,$C3,$C3,$FB,$FB,$C7,$C7
DB $FF,$FF,$FF,$FF,$83,$83,$F7,$F7
DB $EF,$EF,$DF,$DF,$83,$83,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$BF,$BF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$DF,$DF,$DF,$DF,$BF,$BF
DB $C7,$C7,$BB,$BB,$BB,$BB,$83,$83
DB $BB,$BB,$BB,$BB,$BB,$BB,$FF,$FF
DB $87,$87,$BB,$BB,$BB,$BB,$87,$87
DB $BB,$BB,$BB,$BB,$87,$87,$FF,$FF
DB $C7,$C7,$BB,$BB,$BF,$BF,$BF,$BF
DB $BF,$BF,$BB,$BB,$C7,$C7,$FF,$FF
DB $87,$87,$BB,$BB,$BB,$BB,$BB,$BB
DB $BB,$BB,$BB,$BB,$87,$87,$FF,$FF
DB $83,$83,$BF,$BF,$BF,$BF,$87,$87
DB $BF,$BF,$BF,$BF,$83,$83,$FF,$FF
DB $83,$83,$BF,$BF,$BF,$BF,$87,$87
DB $BF,$BF,$BF,$BF,$BF,$BF,$FF,$FF
DB $C7,$C7,$BB,$BB,$BF,$BF,$B3,$B3
DB $BB,$BB,$BB,$BB,$C7,$C7,$FF,$FF
DB $BB,$BB,$BB,$BB,$BB,$BB,$83,$83
DB $BB,$BB,$BB,$BB,$BB,$BB,$FF,$FF
DB $EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF
DB $EF,$EF,$EF,$EF,$EF,$EF,$FF,$FF
DB $FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB
DB $BB,$BB,$BB,$BB,$C7,$C7,$FF,$FF
DB $BB,$BB,$B7,$B7,$AF,$AF,$9F,$9F
DB $AF,$AF,$B7,$B7,$BB,$BB,$FF,$FF
DB $BF,$BF,$BF,$BF,$BF,$BF,$BF,$BF
DB $BF,$BF,$BF,$BF,$83,$83,$FF,$FF
DB $BB,$BB,$93,$93,$AB,$AB,$BB,$BB
DB $BB,$BB,$BB,$BB,$BB,$BB,$FF,$FF
DB $BB,$BB,$9B,$9B,$AB,$AB,$B3,$B3
DB $BB,$BB,$BB,$BB,$BB,$BB,$FF,$FF
DB $C7,$C7,$BB,$BB,$BB,$BB,$BB,$BB
DB $BB,$BB,$BB,$BB,$C7,$C7,$FF,$FF
DB $87,$87,$BB,$BB,$BB,$BB,$87,$87
DB $BF,$BF,$BF,$BF,$BF,$BF,$FF,$FF
DB $C7,$C7,$BB,$BB,$BB,$BB,$BB,$BB
DB $BB,$BB,$BB,$BB,$C7,$C7,$FB,$FB
DB $87,$87,$BB,$BB,$BB,$BB,$87,$87
DB $BB,$BB,$BB,$BB,$BB,$BB,$FF,$FF
DB $C7,$C7,$BB,$BB,$BF,$BF,$C7,$C7
DB $FB,$FB,$BB,$BB,$C7,$C7,$FF,$FF
DB $83,$83,$EF,$EF,$EF,$EF,$EF,$EF
DB $EF,$EF,$EF,$EF,$EF,$EF,$FF,$FF
DB $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB
DB $BB,$BB,$BB,$BB,$C7,$C7,$FF,$FF
DB $BB,$BB,$BB,$BB,$BB,$BB,$D7,$D7
DB $D7,$D7,$EF,$EF,$EF,$EF,$FF,$FF
DB $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB
DB $AB,$AB,$93,$93,$BB,$BB,$FF,$FF
DB $BB,$BB,$D7,$D7,$EF,$EF,$EF,$EF
DB $EF,$EF,$D7,$D7,$BB,$BB,$FF,$FF
DB $BB,$BB,$BB,$BB,$BB,$BB,$D7,$D7
DB $EF,$EF,$EF,$EF,$EF,$EF,$FF,$FF
DB $83,$83,$FB,$FB,$F7,$F7,$EF,$EF
DB $DF,$DF,$BF,$BF,$83,$83,$FF,$FF
DB $FF,$FF,$D7,$D7,$D7,$D7,$D7,$D7
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $EF,$EF,$EF,$EF,$EF,$EF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $E7,$E7,$EF,$EF,$EF,$EF,$EF,$EF
DB $EF,$EF,$EF,$EF,$EF,$EF,$E7,$E7
DB $E7,$E7,$F7,$F7,$F7,$F7,$F7,$F7
DB $F7,$F7,$F7,$F7,$F7,$F7,$E7,$E7
DB $E7,$E7,$DF,$DF,$BF,$BF,$BF,$BF
DB $BF,$BF,$BF,$BF,$DF,$DF,$E7,$E7
DB $E7,$E7,$FB,$FB,$FD,$FD,$FD,$FD
DB $FD,$FD,$FD,$FD,$FB,$FB,$E7,$E7
DB $FF,$FF,$CF,$CF,$CF,$CF,$FF,$FF
DB $FF,$FF,$CF,$CF,$CF,$CF,$FF,$FF
DB $EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF
DB $EF,$EF,$FF,$FF,$EF,$EF,$FF,$FF
DB $C7,$C7,$BB,$BB,$FB,$FB,$F7,$F7
DB $EF,$EF,$FF,$FF,$EF,$EF,$FF,$FF
DB $FF,$FF,$FF,$FF,$EF,$EF,$EF,$EF
DB $83,$83,$EF,$EF,$EF,$EF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $83,$83,$FF,$FF,$FF,$FF,$FF,$FF
DB $FB,$FB,$F7,$F7,$F7,$F7,$EF,$EF
DB $EF,$EF,$DF,$DF,$DF,$DF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$83,$83
DB $FF,$FF,$83,$83,$FF,$FF,$FF,$FF
r7_FontTilesEnd::


r7_OverlayTiles::
;;; Empty tile
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
;;;
DB $FF,$FF,$FF,$FF,$93,$FF,$83,$FF
DB $83,$FF,$C7,$FF,$EF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$7F
DB $FF,$7F,$FF,$7F,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$3F
DB $FF,$3F,$FF,$3F,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$1F
DB $FF,$1F,$FF,$1F,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$0F
DB $FF,$0F,$FF,$0F,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$07
DB $FF,$07,$FF,$07,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$03
DB $FF,$03,$FF,$03,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$01
DB $FF,$01,$FF,$01,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F
DB $FF,$7F,$FF,$7F,$FF,$7F,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$E7
DB $FF,$E7,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$3F,$3F,$7F,$7F,$7F,$7F
DB $72,$72,$79,$79,$78,$78,$36,$36
DB $FF,$FF,$F3,$F3,$BB,$BB,$7B,$7B
DB $FB,$FB,$FB,$FB,$FB,$FB,$F3,$F3
DB $FF,$FF,$FF,$FF,$BB,$FF,$83,$FF
DB $AB,$FF,$83,$FF,$C7,$FF,$FF,$FF
r7_OverlayTilesEnd::

r7_BackgroundTiles::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$1E,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$03,$00,$07,$00
DB $07,$00,$00,$07,$1F,$07,$3F,$07
DB $0F,$00,$0F,$00,$DF,$00,$FF,$3F
DB $BF,$7F,$FF,$FF,$FF,$FF,$FF,$FF
DB $3F,$00,$EF,$70,$FF,$7F,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $00,$00,$70,$00,$F8,$80,$F8,$80
DB $DC,$E0,$EC,$F0,$FC,$FC,$FE,$F8
DB $3F,$07,$1F,$27,$3F,$3F,$3F,$3F
DB $7F,$07,$7F,$07,$3F,$47,$3F,$0F
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FE,$F0,$FE,$F0,$FE,$F0,$FE,$F0
DB $FC,$F2,$F0,$FC,$F8,$E0,$F8,$C0
DB $0F,$3F,$0F,$00,$0F,$00,$07,$08
DB $03,$04,$00,$03,$00,$00,$00,$00
DB $FF,$FF,$FF,$7F,$FF,$70,$FF,$20
DB $9F,$40,$0E,$91,$00,$0F,$00,$00
DB $FF,$FF,$FF,$FF,$FF,$70,$FF,$60
DB $FE,$61,$00,$9E,$00,$00,$00,$00
DB $F8,$80,$F0,$88,$E0,$98,$00,$60
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$80
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$03,$FF,$1F,$FF,$1F
DB $FF,$E0,$FF,$0C,$FF,$BE,$FF,$FF
DB $FF,$FF,$FF,$FF,$3F,$FF,$00,$FF
DB $FF,$1F,$FE,$1E,$FE,$7E,$FC,$FC
DB $F8,$FE,$D0,$FE,$80,$FE,$00,$FE
DB $00,$00,$01,$00,$0F,$00,$1F,$00
DB $7F,$00,$7F,$00,$FF,$00,$FF,$00
DB $1F,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$80
DB $FF,$01,$FF,$C3,$FF,$FF,$7F,$7F
DB $07,$3F,$03,$7F,$01,$7F,$00,$3F
DB $FF,$C0,$FF,$E0,$FF,$E1,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$1F,$FF
DB $FF,$80,$FF,$C0,$7F,$E0,$7F,$E0
DB $7F,$E0,$7F,$E0,$3F,$F0,$3F,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $3F,$FF,$1F,$7F,$0F,$7F,$07,$7F
DB $00,$3F,$00,$1F,$00,$07,$00,$03
DB $FF,$80,$FF,$E0,$FF,$F0,$FF,$FF
DB $3F,$FF,$3F,$FF,$07,$FF,$01,$FF
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$0F,$00,$0F,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$E0,$00,$F0,$00
DB $1F,$00,$1F,$00,$3F,$00,$3F,$00
DB $3F,$00,$7F,$00,$FF,$00,$FF,$00
DB $F8,$00,$FC,$00,$FC,$00,$FE,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $7F,$00,$7F,$00,$7F,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$7F,$00
DB $FF,$00,$FF,$00,$FF,$00,$FE,$00
DB $FE,$00,$FE,$00,$FE,$00,$FE,$00
DB $7F,$00,$7F,$00,$7F,$00,$7F,$00
DB $3F,$00,$7F,$00,$7F,$00,$FF,$00
DB $FE,$00,$FE,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FE,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$03,$00,$07,$00
DB $01,$00,$07,$00,$0F,$00,$1F,$00
DB $1F,$00,$3F,$00,$FF,$00,$FF,$00
DB $0F,$00,$0F,$00,$0F,$00,$07,$00
DB $3F,$00,$7F,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$7F,$00,$7F,$00
DB $3F,$00,$3F,$00,$7F,$00,$7F,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $7F,$00,$7F,$00,$7F,$00,$7F,$00
DB $3F,$00,$7F,$00,$7F,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $F8,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$00,$FC,$00,$FC,$00,$FE,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$71
DB $FF,$00,$FF,$01,$FF,$3F,$FF,$FF
DB $FE,$FF,$FC,$FF,$F8,$FF,$E0,$FF
DB $FF,$7F,$FE,$FE,$FC,$FE,$E0,$FC
DB $00,$FE,$00,$FE,$00,$FE,$00,$F8
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$01,$FF,$03,$FF,$03
DB $FF,$3F,$FE,$6F,$FE,$FF,$FC,$FF
DB $FF,$0E,$FF,$1F,$FF,$1F,$FF,$1F
DB $FF,$FF,$FE,$FF,$FC,$FF,$F8,$FF
DB $F8,$FF,$C0,$FF,$C0,$FE,$00,$FE
DB $00,$FC,$00,$F0,$00,$E0,$00,$C0
DB $FC,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $0F,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$0C,$FF,$1F,$FF,$FF
DB $FE,$FF,$F8,$FF,$E0,$FF,$00,$FF
DB $FF,$00,$FF,$3C,$FF,$7F,$FF,$FF
DB $FF,$FF,$3F,$FF,$00,$FF,$00,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$18
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$03
DB $FF,$3E,$FF,$FF,$FF,$FF,$F8,$FF
DB $F0,$FF,$00,$FF,$00,$FF,$00,$FF
DB $FF,$73,$FF,$FF,$7F,$FF,$3F,$FF
DB $1F,$FF,$00,$FF,$00,$FF,$00,$FF
DB $C0,$00,$E0,$00,$FB,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$00,$00,$00,$80,$00,$C0,$00
DB $C0,$00,$E0,$00,$F0,$00,$F0,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $F8,$00,$F8,$00,$F8,$00,$F8,$00
DB $FC,$00,$FE,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FE,$00,$FC,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FC,$00,$FE,$00,$FE,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FE,$00
DB $00,$00,$E0,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$00,$0F,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$38,$00,$3C,$00
DB $00,$00,$00,$00,$00,$00,$80,$00
DB $F0,$00,$F0,$00,$F8,$00,$80,$80
DB $3F,$03,$38,$00,$00,$01,$00,$03
DB $00,$03,$00,$01,$00,$00,$00,$00
DB $80,$00,$80,$00,$80,$60,$80,$70
DB $00,$F0,$00,$E0,$00,$00,$00,$00
DB $00,$00,$00,$00,$60,$60,$3C,$3C
DB $1E,$1E,$0F,$0F,$0F,$0F,$07,$07
DB $00,$00,$08,$08,$0C,$0C,$06,$06
DB $02,$02,$02,$02,$82,$82,$C1,$C1
DB $01,$01,$08,$08,$18,$18,$18,$18
DB $30,$30,$30,$30,$40,$40,$40,$40
DB $E0,$E0,$E0,$E0,$70,$70,$78,$78
DB $28,$28,$3C,$3C,$00,$00,$00,$00
DB $00,$00,$FF,$00,$F8,$07,$E0,$1F
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$00,$FF,$00,$3F,$C0,$1E,$E1
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$1F
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FC
DB $00,$F0,$00,$FF,$E0,$1F,$F0,$0F
DB $FF,$00,$FF,$00,$FF,$00,$E7,$18
DB $00,$0F,$01,$FE,$03,$FC,$3F,$C0
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$87,$78,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$3F,$C0,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $E7,$18,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$F0,$FF,$E0,$FF,$E0,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$0F,$FF,$07,$FF,$07,$FF
DB $C0,$FF,$C0,$FF,$C0,$DF,$00,$3F
DB $00,$FF,$E0,$1F,$FF,$00,$FF,$00
DB $03,$FF,$03,$FF,$03,$FB,$00,$FC
DB $00,$FF,$07,$F8,$FF,$00,$FF,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$1C,$1C,$3E,$3E
DB $63,$63,$63,$63,$63,$63,$3F,$3F
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $1F,$1F,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$88,$88,$54,$54,$2E,$2E
DB $1C,$1C,$08,$08,$00,$00,$00,$00
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
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
r7_BackgroundTilesEnd::


r7_BackgroundTiles2::
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
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $18,$00,$10,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$18,$00,$08,$00
DB $08,$00,$48,$00,$40,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$FF,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$FF,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$00,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$00,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $0F,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $F0,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
r7_BackgroundTiles2End::


r7_SpriteDropShadow::
DB $00,$00,$00,$00,$00,$00,$0F,$00
DB $3F,$00,$7F,$00,$7F,$00,$7F,$00
DB $7F,$00,$3F,$00,$0F,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$F0,$00
DB $FC,$00,$FE,$00,$FE,$00,$FE,$00
DB $FE,$00,$FC,$00,$F0,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
r7_SpriteDropShadowEnd::


;;; Requires 8-byte alignement for DMA copies.
align 8
r7_BackgroundTilesWaterAnim::
DB $00,$00,$FF,$00,$FC,$03,$F0,$0F
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$00,$FF,$00,$3F,$C0,$1E,$E1
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$0F
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FC

DB $00,$10,$00,$FF,$E0,$1F,$F0,$0F
DB $FF,$00,$FF,$00,$FF,$00,$E7,$18
DB $00,$1F,$01,$FE,$03,$FC,$3F,$C0
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$CF,$30,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00

DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$3F,$C0,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $E7,$18,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00

DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$F0,$FF,$E0,$FF,$E0,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$0F,$FF,$07,$FF,$07,$FF
DB $C0,$FF,$C0,$FF,$C0,$DF,$00,$3F
DB $00,$FF,$E0,$1F,$F8,$07,$FF,$00
DB $03,$FF,$03,$FB,$00,$FC,$00,$FF
DB $00,$FF,$07,$F8,$1F,$E0,$FF,$00

DB $FF,$FF,$FF,$FF,$FE,$FE,$FC,$FC
DB $F8,$F9,$F8,$FF,$F0,$F7,$F8,$FF
DB $FF,$FF,$FF,$FF,$1F,$1F,$07,$E7
DB $03,$F3,$01,$F9,$01,$F9,$01,$F9
DB $90,$97,$B2,$B3,$FE,$FE,$FF,$FF
DB $FF,$FF,$FF,$FF,$FD,$FD,$FF,$FF
DB $03,$F3,$03,$C3,$C7,$C7,$1F,$1F
DB $7F,$7F,$FF,$FF,$FF,$FF,$FF,$FF



DB $00,$00,$FF,$00,$FC,$03,$F0,$0F
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$00,$FF,$00,$3F,$C0,$1E,$E1
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$1F
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$F8

DB $00,$F0,$00,$FF,$80,$7F,$E0,$1F
DB $FF,$00,$FF,$00,$FF,$00,$C3,$3C
DB $00,$00,$00,$FF,$01,$FE,$1F,$E0
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$87,$78,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00

DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FE,$01,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$1F,$E0,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $C3,$3C,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00

DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$F0,$FF,$E0,$FF,$E0,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$0F,$FF,$07,$FF,$07,$FF
DB $C0,$FF,$C0,$DF,$80,$BF,$00,$3F
DB $00,$FF,$C0,$3F,$F0,$0F,$FF,$00
DB $03,$FF,$03,$FF,$03,$FB,$00,$FC
DB $00,$FF,$03,$FC,$0F,$F0,$FF,$00

DB $FF,$FF,$FF,$FF,$FF,$FF,$FC,$FC
DB $F0,$F1,$E0,$E7,$E0,$E7,$E8,$EF
DB $FF,$FF,$FF,$FF,$8F,$8F,$07,$E7
DB $03,$F3,$03,$FB,$03,$FB,$03,$FB
DB $F0,$F7,$BA,$BB,$7E,$7E,$FF,$FF
DB $FF,$FF,$FE,$FE,$FD,$FD,$F7,$F7
DB $03,$FB,$03,$E3,$CF,$CF,$0F,$0F
DB $1F,$1F,$FF,$FF,$FF,$FF,$FF,$FF



DB $00,$00,$FF,$00,$FC,$03,$F0,$0F
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$00,$FF,$00,$3F,$C0,$1E,$E1
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$1C
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$10

DB $00,$E0,$00,$FF,$C0,$3F,$F0,$0F
DB $FF,$00,$FF,$00,$FF,$00,$E3,$1C
DB $00,$3F,$00,$FF,$01,$FE,$3F,$C0
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$8F,$70,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00

DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FE,$01,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$3F,$C0,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $E3,$1C,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00

DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$F0,$FF,$E0,$FF,$E0,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$0F,$FF,$07,$FF,$07,$FF
DB $C0,$FF,$C0,$FF,$C0,$DF,$00,$3F
DB $00,$FF,$C0,$3F,$F8,$07,$FF,$00
DB $03,$FF,$03,$FB,$01,$FD,$00,$FC
DB $00,$FF,$03,$FC,$1F,$E0,$FF,$00

DB $FF,$FF,$FF,$FF,$FF,$FF,$FE,$FE
DB $FC,$FD,$F8,$FF,$F0,$F7,$F8,$FF
DB $FF,$FF,$FF,$FF,$07,$07,$03,$E3
DB $01,$F1,$01,$F9,$01,$F9,$01,$F9
DB $F0,$F7,$F2,$F3,$FE,$FE,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $01,$F9,$03,$F3,$C7,$C7,$9F,$9F
DB $7F,$7F,$FF,$FF,$FF,$FF,$FF,$FF

r7_BackgroundTilesWaterAnimEnd::


;;; ############################################################################
