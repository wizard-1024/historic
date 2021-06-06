        page    60, 132
        title   Sample for EXIT2DOS

; Name:     SAMPLE
; Purpose:  Emulates a hangup program
; Author:   Dmitry Stefankov
; Date:     22-Feb-1998



code    segment  'CODE'
assume cs:code,ds:code,ss:code
        org 100h                            ;; make command file
        
@start:
                REPT    8
                    jmp  SHORT @Start
                ENDM
                mov     ax, 4C00h           ;; Terminate process
                int     21h
                    
code        ends

        end @start
