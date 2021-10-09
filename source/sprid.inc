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


;;; Spritesheet constants (needs to match the ordering of data in appropriate
;;; ROM banks).


;;; ROM Bank 2 Sprites:
SPRID_PLAYER_WR          EQU     0
SPRID_PLAYER_SR          EQU     5
SPRID_PLAYER_WL          EQU     6
SPRID_PLAYER_SL          EQU     11
SPRID_PLAYER_WD          EQU     12
SPRID_PLAYER_SD          EQU     22
SPRID_PLAYER_WU          EQU     23
SPRID_PLAYER_SU          EQU     33
SPRID_BONFIRE            EQU     34
SPRID_PLAYER_PD          EQU     40
SPRID_PLAYER_PU          EQU     45
SPRID_PLAYER_PR          EQU     50
SPRID_PLAYER_PL          EQU     55

SPRID_BANK2_UNUSED_1     EQU 60
SPRID_BANK2_UNUSED_2     EQU 61
SPRID_BANK2_UNUSED_3     EQU 62
SPRID_BANK2_UNUSED_4     EQU 63


;;; ROM Bank 3 Sprites:
;;; ...
SPRID_PLAYER_KNIFE_ATK_D EQU 64
SPRID_PLAYER_KNIFE_ATK_U EQU 79
SPRID_PLAYER_KNIFE_ATK_R EQU 94
SPRID_PLAYER_KNIFE_ATK_L EQU 109

SPRID_BANK3_UNUSED_1     EQU 124
SPRID_BANK3_UNUSED_2     EQU 125
SPRID_BANK3_UNUSED_3     EQU 126
SPRID_BANK3_UNUSED_4     EQU 127


;;; ROM Bank 4 Sprites:
SPRID_GREYWOLF_L         EQU 128
SPRID_GREYWOLF_R         EQU 129
SPRID_GREYWOLF_RUN_L     EQU 130
SPRID_GREYWOLF_RUN_R     EQU 135
SPRID_GREYWOLF_STUN_L    EQU 140
SPRID_GREYWOLF_STUN_R    EQU 141
SPRID_GREYWOLF_ATTACK_L  EQU 142
SPRID_GREYWOLF_ATTACK_R  EQU 147
SPRID_GREYWOLF_DEAD_L    EQU 152
SPRID_GREYWOLF_DEAD_R    EQU 153
SPRID_BOAR_L             EQU 154
SPRID_BOAR_R             EQU 155
SPRID_BOAR_RUN_L         EQU 156
SPRID_BOAR_RUN_R         EQU 160
SPRID_BOAR_DYING_L       EQU 164
SPRID_BOAR_DYING_R       EQU 165
SPRID_BOAR_DEAD_L        EQU 166
SPRID_BOAR_DEAD_R        EQU 167
SPRID_SPIDER_L           EQU 168
SPRID_SPIDER_R           EQU 173
SPRID_SPIDER_ATTACK_L    EQU 178
SPRID_SPIDER_ATTACK_R    EQU 183 ; (5 frames)


;;; ROM Bank 5 Sprites:
SPRID_PLAYER_HAMMER_L    EQU 192
SPRID_PLAYER_HAMMER_R    EQU 203
SPRID_PLAYER_HAMMER_D    EQU 214
