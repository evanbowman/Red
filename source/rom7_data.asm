;;; ############################################################################


SECTION "MISC_SPRITES", ROMX, BANK[7]


PlayerCharacterPalette::
DB $00,$00, $69,$72, $1a,$20, $03,$00
DB $00,$00, $ff,$ff, $f8,$37, $5f,$19
DB $00,$00, $54,$62, $f8,$37, $1a,$20


;;; Example of how to do the color conversion:
;;; See byte sequence $df,$24 above, the red color.
;;; We convert the actual color to hex, and then flip the order of the bytes.
;;; python> hex(((70 >> 3)) | ((141 >> 3) << 5) | ((199 >> 3) << 10))

BackgroundPalette::
DB $bf,$73, $1a,$20, $1a,$20, $00,$00
DB $bf,$73, $53,$5e, $4b,$3d, $86,$18
DB $bf,$73, $ec,$31, $54,$62, $26,$29



TEST_MAP::
DB $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0e, $00, $00, $00, $00, $00, $0e, $0e, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $08, $0f, $0f, $0f, $0f, $0f, $02, $0e, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $00, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $02, $00, $0e, $0e, $0e
DB $0e, $0e, $08, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $02, $0e, $0e
DB $0e, $0c, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $06, $0e
DB $0e, $0c, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $0f, $0f, $06, $0e
DB $0e, $0c, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $06, $0e
DB $0e, $0c, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $06, $0e
DB $0e, $0e, $0b, $0f, $0f, $10, $0f, $0f, $0f, $0f, $10, $0f, $0f, $05, $0e, $0e
DB $0e, $0e, $0e, $0b, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $05, $0e, $0e, $0e
DB $0e, $0e, $0e, $0c, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $05, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0c, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $06, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0b, $0f, $0f, $0f, $0f, $0f, $0f, $06, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0e, $0b, $0f, $0f, $0f, $0f, $05, $0e, $0e, $0e, $0e, $0e
TEST_MAP_END::


TEST_MAP_2::
DB $0e, $0e, $0e, $0e, $0e, $08, $0f, $0f, $0f, $0f, $02, $0e, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0c, $0f, $0f, $0f, $0f, $0f, $0f, $06, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $08, $0f, $0f, $0f, $0f, $0f, $0f, $06, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0c, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $06, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $08, $0f, $0f, $10, $0f, $0f, $0f, $0f, $06, $0e, $0e, $0e, $0e
DB $0a, $0a, $08, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $02, $0a, $0a, $0a, $0a
DB $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f, $0f
DB $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $0f
DB $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $10, $10, $0f
DB $0f, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
DB $0d, $0d, $0d, $0d, $0b, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $05, $0d, $0d, $0d
DB $0e, $0e, $0e, $0e, $0c, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $06, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0c, $0f, $0f, $0f, $0f, $0f, $0f, $05, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0c, $0f, $0f, $0f, $10, $0f, $0f, $06, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0c, $0f, $0f, $0f, $0f, $0f, $0f, $06, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0e, $0b, $0f, $0f, $0f, $0f, $05, $0e, $0e, $0e, $0e, $0e
TEST_MAP_2_END::


TEST_MAP_3::
DB $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0e, $0a, $0a, $0a, $0a, $0a, $0a, $0e, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $08, $0f, $0f, $0f, $0f, $0f, $0f, $02, $0e, $0e, $0e, $0e
DB $0a, $0a, $0a, $08, $0f, $0f, $0f, $0f, $10, $0f, $0f, $0f, $02, $0e, $0e, $0e
DB $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $06, $0e, $0e
DB $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $10, $0f, $02, $0e, $0e
DB $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $0f, $0e, $0e
DB $0f, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f, $0f, $05, $0e, $0e
DB $0d, $0b, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $06, $0e, $0e
DB $0e, $0e, $0d, $0b, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $05, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0d, $0d, $0b, $0f, $0f, $0f, $05, $0d, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0d, $0d, $0d, $0e, $0e, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
DB $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
TEST_MAP_3_END::


FontTiles::
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
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
FontTilesEnd::



OverlayTiles::
;;; Empty tile
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
;;;
DB $FF,$FF,$FF,$FF,$EF,$FE,$EF,$FE
DB $83,$FE,$EF,$FE,$EF,$FE,$FF,$FF
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
;;; debug
OverlayTilesEnd::

BackgroundTiles::
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
BackgroundTilesEnd::


SpriteDropShadow::
DB $00,$00,$00,$00,$00,$00,$0F,$00
DB $3F,$00,$7F,$00,$7F,$00,$7F,$00
DB $7F,$00,$3F,$00,$0F,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$F0,$00
DB $FC,$00,$FE,$00,$FE,$00,$FE,$00
DB $FE,$00,$FC,$00,$F0,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
SpriteDropShadowEnd::


;;; ############################################################################
