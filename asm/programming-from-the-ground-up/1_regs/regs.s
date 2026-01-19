; rax will be consistent, rbx will be random
section .text
global _start
_start:
  ; https://www.felixcloutier.com/x86/mov
  mov r12, rsp      ; Save stack pointer
  mov r13, rbp      ; Save base pointer

  ; yep rbp has garbage by default.
  ; (gdb) print/x $r12
  ; $1 = 0x7fffffffa220
  ; (gdb) print/x $r13
  ; $2 = 0x0

  nop               ; Breakpoint here

  ; Exit
  mov rax, 60
  mov rdi, 0
  syscall
