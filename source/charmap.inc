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


NEWCHARMAP RedCharset
CHARMAP " ", $32
CHARMAP "0", $33
CHARMAP "1", $34
CHARMAP "2", $35
CHARMAP "3", $36
CHARMAP "4", $37
CHARMAP "5", $38
CHARMAP "6", $39
CHARMAP "7", $3A
CHARMAP "8", $3B
CHARMAP "9", $3C
CHARMAP "a", $3D
CHARMAP "b", $3E
CHARMAP "c", $3F
CHARMAP "d", $40
CHARMAP "e", $41
CHARMAP "f", $42
CHARMAP "g", $43
CHARMAP "h", $44
CHARMAP "i", $45
CHARMAP "j", $46
CHARMAP "k", $47
CHARMAP "l", $48
CHARMAP "m", $49
CHARMAP "n", $4A
CHARMAP "o", $4B
CHARMAP "p", $4C
CHARMAP "q", $4D
CHARMAP "r", $4E
CHARMAP "s", $4F
CHARMAP "t", $50
CHARMAP "u", $51
CHARMAP "v", $52
CHARMAP "w", $53
CHARMAP "x", $54
CHARMAP "y", $55
CHARMAP "z", $56
CHARMAP ".", $57
CHARMAP ",", $58
CHARMAP "A", $59
CHARMAP "B", $5A
CHARMAP "C", $5B
CHARMAP "D", $5C
CHARMAP "E", $5D
CHARMAP "F", $5E
CHARMAP "G", $5F
CHARMAP "H", $60
CHARMAP "I", $61
CHARMAP "J", $62
CHARMAP "K", $63
CHARMAP "L", $64
CHARMAP "M", $65
CHARMAP "N", $66
CHARMAP "O", $67
CHARMAP "P", $68
CHARMAP "Q", $69
CHARMAP "R", $6A
CHARMAP "S", $6B
CHARMAP "T", $6C
CHARMAP "U", $6D
CHARMAP "V", $6E
CHARMAP "W", $6F
CHARMAP "X", $70
CHARMAP "Y", $71
CHARMAP "Z", $72
CHARMAP "\"", $73
CHARMAP "'", $74
CHARMAP "[", $75
CHARMAP "]", $76
CHARMAP "(", $77
CHARMAP ")", $78
CHARMAP ":", $79
CHARMAP "!", $7A
CHARMAP "?", $7B
CHARMAP "+", $7C
CHARMAP "-", $7D
CHARMAP "/", $7E
CHARMAP "=", $7F
