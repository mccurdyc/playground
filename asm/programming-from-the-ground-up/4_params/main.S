section .text

global _start
_start:
  ; First 6 parameters go in registers: RDI, RSI, RDX, RCX, R8, R9
  mov rdi, 2
  mov rsi, 3

  call power

  ; TODO - clean stack

  ; TODO - exit

; takes two parameters
; param 1 - base
; param 2 - power
;
; 2^0 * 2^1 * 2^2
; 1 * 2 * 2 * 2
power:
  push rbp
  mov rbp, rsp

  cmp rsi, 1
  jmp power

  mul rdx, rdi

  leave
  ret


