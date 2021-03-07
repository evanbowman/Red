;;; ----------------------------------------------------------------------------
;;;
;;; Video:
;;;
;;; ----------------------------------------------------------------------------

        INCLUDE "hardware.inc"
        INCLUDE "defs.inc"


;;; ############################################################################

        SECTION "VIDEO", ROM0


CopyDMARoutine:
  ld  hl, DMARoutine
  ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
  ld  c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
  ld  a, [hli]
  ldh [c], a
  inc c
  dec b
  jr  nz, .copy
  ret

DMARoutine:
  ldh [rDMA], a

  ld  a, 40
.wait
  dec a
  jr  nz, .wait
  ret
DMARoutineEnd:

;;; ----------------------------------------------------------------------------


;;; SECTION VIDEO


;; ############################################################################

        SECTION "OAM_DMA_ROUTINE", HRAM

hOAMDMA::
        ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to


;;; SECTION OAM_DMA_ROUTINE


;;; ############################################################################

        SECTION "OAM_BACK_BUFFER", WRAM0, ALIGN[8]

var_oam_back_buffer:
        ds 4 * 40


;;; SECTION OAM_BACK_BUFFER


;;; ############################################################################
