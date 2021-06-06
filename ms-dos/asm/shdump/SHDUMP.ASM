page 59,132

; Author: Dmitry V. Stefankov, 11 May'96
; Original idea from Internet peoples
; Assembler: MASM 5.1+ or compatible

.8086
.model  small
.code
ORG 100h

@Start:
;;---------- Create file ------------------------------------------------
        mov     dx, OFFSET @FileName        ;; DS:DX -> filename
        mov     ah, 3Ch                     ;; Create handle
        xor     cx, cx                      ;; Normal
        int     21h                         ;; DOS call
        jc     @Done                        ;; Check for errors
;;---------- Init variables before dump ---------------------------------
        xchg    bx, ax                      ;; Swap handle and mayve zero
        cwd                                 ;; DX:AX -> 0
        mov     si, ax                      ;; SI = starting segment number
        mov     cl, 16                      ;; CX = # of bytes to write
;;---------- Write a dump region to file --------------------------------
@DoDump:
        mov     ds, si                      ;; DS = segment number, DS:DX->buf
        mov     ah, 40h                     ;; Write handle
        int     21h                         ;; DOS call
        jc     @Done                        ;; Check for errors
;;---------- Check for termination conditions ---------------------------
        inc     si                          ;; Advance to next segment number
        jnz    @DoDump                      ;; Past 1MB boundary?
@Done:
        ret                                 ;; Return to DOS through INT 20h
;;---------- Dump filename ----------------------------------------------
@FileName   DB  'D',0                       ;; ASCIIZ filename to dump

END @Start
