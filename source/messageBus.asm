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



;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;;;
;;;
;;; Message Bus
;;;
;;; Our engine allows communication between entities via a broadcast messaging
;;; system.
;;;
;;;
;;; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



;;; ----------------------------------------------------------------------------


MessageQueueAlloc:
;;; return a - message q number
;;; trashes hl, c
        ld      a, 0

        ld      c, 0

        ld      hl, var_message_queues
.loop:
        ld      a, c
        cp      MESSAGE_QUEUE_COUNT
        jr      Z, .failed

        ld      a, [hl]
        or      a
        jr      Z, .found
        jr      .next

.found:
        ld      a, 1
        ld      [hl], a         ; set slot used

        ld      a, c
        inc     a               ; Message q slots count from one.
        ret

.next:
        inc     hl
        inc     c
        jr      .loop

.failed:
        ;; Message queue count == entity buffer size anyway. As we cannot
        ;; register more entities than we have message buffers, this code
        ;; should never run.
        jr      .failed         ; FIXME...

        ret


;;; ----------------------------------------------------------------------------


MessageQueueLoad:
;;; a - message q number
;;; trashes bc
;;; return hl - queue
        ld      hl, var_message_queue_memory
        ;; Now, four bytes per message, eight messages per queue. So, we want to
        ;; multiply our queue num by 32.
        ld      c, a
        ld      b, 0
        fcall   Mul32

        add     hl, bc
        ret


;;; ----------------------------------------------------------------------------



;;; NOTE: For each message in the message queue, invokes function pointer in bc,
;;; with a pointer to a message passed as an arg to the function in bc.
;;; This function does not affect de, so if you want to pass an additional arg
;;; to your function pointer...
MessageQueueDrain:
;;; hl - queue
;;; bc - message handler callback
;;; Promises not to touch de.

	ld      a, [hl]
        push    hl              ; Store queue header ptr on stack

        inc     hl              ; I could push, add, and pop, but that's four
        inc     hl              ; instructions anyway. Remember that we cannot
        inc     hl              ; modify de, as it's reserved by the caller for passing args.
        inc     hl              ; Now hl points to the first queue entry.
.loop:
        push    af              ; Save loop counter
        cp      0
        jr      Z, .endLoop

        ;; Lot's of stuff going on here, but most of the time, there isn't even
        ;; a single message in the queue, so it's not too bad.

	push    bc              ; Save Callback on stack
        push    hl              ; Save spot in queue on stack

        push    hl              ; \
        ld      h, b            ; | Swap hl and bc :/
        ld      l, c            ; | We want invoke hl, passing msg ptr in bc
        pop     bc              ; /

        INVOKE_HL

        pop     hl                      ; \
        ld      bc, MESSAGE_SIZE        ; | Go to next message in queue
        add     hl, bc                  ; /

        pop     bc                      ; Restore callback fn from atack

        pop     af              ; Restore loop counter
        dec     a               ; dec loop counter
        jr      .loop           ; Goto loop top.

.endLoop:
        pop     af              ; pop loop counter from stack
        pop     hl              ; Restore pointer to msg queue header

        ld      a, 0            ; \ Set the queue size to zero, we drained all
        ld      [hl], a         ; / of the messages.

        ret


;;; ----------------------------------------------------------------------------


MessageQueueAppend:
;;; hl - queue
;;; de - Message pointer
;;; trashes bc
        ld      a, [hl]         ; Load current queue size
	cp      MESSAGE_QUEUE_CAPACITY
        jr      Z, .queueFull

        push    hl
        push    de

        ld      bc, $04         ; \ Skip over queue header
        add     hl, bc          ; /

        ld      c, a            ; \
        ld      b, 0            ; | Message is four bytes, so skip over n * 4
        sla     c               ; | messages already in the queue.
        sla     c               ; |
        add     hl, bc          ; /

        ld      a, [de]         ; \
        ld      [hl+], a        ; |
        inc     de              ; |
                                ; | Copy message into queue.
        ld      a, [de]         ; |
        ld      [hl+], a        ; |
        inc     de              ; |
                                ; |
        ld      a, [de]         ; |
        ld      [hl+], a        ; |
        inc     de              ; |
                                ; |
        ld      a, [de]         ; |
        ld      [hl], a         ; /

        pop     de
        pop     hl

        ld      a, [hl]
        inc     a
        ld      [hl], a

.queueFull:
        ret


;;; ----------------------------------------------------------------------------


;;; Put message in everyone's queue
MessageBusBroadcast:
;;; hl - Message pointer
        ld      d, h
        ld      e, l

        ld      b, 0
        ld      hl, var_message_queue_memory
.loop:
        push    bc
	fcall   MessageQueueAppend
        ld      bc, MESSAGE_QUEUE_SIZE
        add     hl, bc
        pop     bc

        inc     b
        ld      a, MESSAGE_QUEUE_COUNT + 1 ; +1 for player's queue, at index 0
        cp      b
        jr      NZ, .loop

        ret


;;; ----------------------------------------------------------------------------
