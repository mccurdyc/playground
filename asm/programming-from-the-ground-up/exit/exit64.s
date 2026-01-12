section .text
global _start

_start:
    mov rax, 60     ; sys_exit system call number for x86_64
    mov rdi, 0      ; exit status
    syscall         ; invoke system call