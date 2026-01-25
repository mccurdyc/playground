section .text

global _start
_start:
  push 3
  push 2
  call power

  ; TODO - clean stack

  ; TODO - exit

; takes two parameters
; param 1 - base
; param 2 - power
power:
  ; setup stack frame ("display"?)
  push rbp
  mov rbp, rsp
