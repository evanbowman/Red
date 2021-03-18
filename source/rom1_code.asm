;;; ############################################################################


SECTION "ROM1_CODE", ROMX, BANK[1]


;;; ----------------------------------------------------------------------------

VBlankPoll:
; Intended for waiting on vblank while interrupts are disabled, but the screen
; is still on.
        ld      a, [rLY]
        cp      SCRN_Y
        jr      nz, VBlankPoll
        ret


;;; ----------------------------------------------------------------------------

GameboyColorNotDetected:
        nop
        jr      GameboyColorNotDetected
        ret


;;; ----------------------------------------------------------------------------

GameboyAdvanceDetected:
        ld      a, 1
        ldh     [agb_detected], a
        jr      GameboyAdvanceDetected
	ret


;;; ----------------------------------------------------------------------------

InitWRam:
        ld      a, 0
        ld      hl, _RAM
        ;; We don't want to zero the stack, or how will we return from this fn?
        ld      bc, STACK_END - _RAM
        call    Memset

        ld      d, 1
.loop:
        ld      a, d
        cp      8
        jr      Z, .done

        ld      [rSVBK], a

        ld      hl, _RAMBANK
        ld      bc, ($DFFF - _RAMBANK) - 1
        ld      a, 0
        call    Memset

        inc     d
        jr      .loop

.done:
        ld      a, 0
        ld      [rSVBK], a


        ret


InitRam:
;;; trashes hl, bc, a
        ld      a, 0

        ld      hl, _HRAM
        ld      bc, $80
        call    Memset

        call    InitWRam

        ret


;;; ----------------------------------------------------------------------------

SetCpuFast:
        ld      a, [rKEY1]
        bit     7, a
        jr      z, .impl
        ret

.impl:
        ld      a, $30
        ld      [rP1], a
        ld      a, $01
        ld      [rKEY1], a

        stop
        ret


;;; ----------------------------------------------------------------------------

CopyDMARoutine:
        ld      hl, DMARoutine
        ld      b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
        ld      c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
        ld      a, [hli]
        ldh     [c], a
        inc     c
        dec     b
        jr      nz, .copy
        ret

DMARoutine:
        ldh     [rDMA], a

        ld      a, 40
.wait
        dec     a
        jr      nz, .wait
        ret
DMARoutineEnd:


;;; ----------------------------------------------------------------------------


;;; SECTION ROM1_CODE


;;; ############################################################################
