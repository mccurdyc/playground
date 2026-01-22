[BITS 64]           ; nasm defaults to 16-bit for binary mode
  mov r12, rsp      ; Save stack pointer
  mov r13, rbp      ; Save base pointer
  nop               ; Breakpoint here
  mov rax, 60
  mov rdi, 0
  syscall
