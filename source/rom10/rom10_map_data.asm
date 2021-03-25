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


;;; ############################################################################


SECTION "ROM10_CODE", ROMX, BANK[10]


r10_DefaultMap1::
        INCLUDE "default_map.asm"
r10_DefaultMap1End::


r10_TEST_MAP::
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
r10_TEST_MAP_END::


r10_TEST_MAP_2::
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
r10_TEST_MAP_2_END::


r10_TEST_MAP_3::
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
r10_TEST_MAP_3_END::
