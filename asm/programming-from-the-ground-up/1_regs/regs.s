; rax will be consistent, rbx will be random
section .text
global _start
_start:

  ; https://www.felixcloutier.com/x86/mov
  ; 0100 1001 1000 1001 11 100 100 (just easy to see this way instead of as "nibbles")
  ;                     1110 0100
  ; 49        89        E4
  mov r12, rsp      ; Save stack pointer

  ; 0100 1001 1000 1001 11 101 101 (just easy to see this way instead of as "nibbles")
  ;                     1110 1101
  ; 49        89        ED
  mov r13, rbp      ; Save base pointer

  ; yep rbp has garbage by default.
  ; (gdb) print/x $r12
  ; $1 = 0x7fffffffa220
  ; (gdb) print/x $r13
  ; $2 = 0x0

  ; https://www.felixcloutier.com/x86/nop
  ; 1001 0000
  ; 90
  nop               ; Breakpoint here

  ; Exit
  ; https://www.felixcloutier.com/x86/mov
  ; we know 64-bit based on rax and 60 is an immediate
  ;
  ; 0100 1000 1000 1011
  ; 48        8B
  mov rax, 60

  ; https://www.felixcloutier.com/x86/mov
  ; we know 64-bit based on rax and 0 is an immediate
  mov rdi, 0

  syscall
