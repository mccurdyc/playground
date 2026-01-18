section .data
; "taking input" is via STDIN, so we need to read from a file
;
; https://filippo.io/linux-syscall-table/
.equ SYS_READ, 0
.equ SYS_WRITE, 1
.equ SYS_OPEN, 2
.equ SYS_CLOSE, 3
.equ SYS_EXIT, 60

; standard filedescriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

section .bss
; We need a buffer for reading the list of numbers
;
; "BSS" stands for Block Started by Symbol.
;
; It's a section in assembly and compiled programs that reserves space for uninitialized static
; variables. Key characteristics:
;
; 1. Zero-initialized: The OS automatically fills the BSS section with zeros at program startup
; 2. No storage in executable: Unlike the data section, BSS doesn't increase executable size since
; it only specifies how much memory to reserve
;
; ASSUMPTIONS (for simplicity and fun):
; - assume 5 unsigned integers (for fun: we'll see what happens when you provide 6 instead of 5, provide unsigned, etc.)
; - assume values will be <255 (1 byte each)

; The book uses `.lcomm` because it's using local data that is available at compilation time.
; ref:
; - ch 4 of the Intel x86 manual

; "res" stands for "reserve". It does NOT initialize.
; resb = Reserve Bytes
; resw = Reserve words (2 bytes each)
; resd = Reserve Double-words (4 bytes each)
; ...
input_buffer resb 80 ; 8 bytes * (5 unsigned integers (remember these will be read in as ASCII) + 4 spaces between + 1 EOF or some kind of terminator(?))

section .text

global _start
_start:
; Setup stack
;
; No stack frame exists yet.
; The stack pointer (rsp) points to whatever the kernel set up, but there's no base pointer (rbp) frame.
;
; The kernel sets up:
; 1. Stack memory region - Allocates a fixed-size stack (typically 8MB on Linux) in the process's virtual address space
; 2. Initial stack pointer - Sets rsp to point to the top of this allocated region
; 3. Stack contents - Places program information on the stack before jumping to _start:              ▀
;   - Argument count (argc)
;   - Argument pointers (argv)
;   - Environment variable pointers (envp)
;   - Auxiliary vector entries (platform-specific info)

; Initially I was confused why we needed to push the "garbage" rbp value onto the stack in the _start
; function if we are calling another function. It's because leave of the function that we are calling
; will expect to be able to pop from the stack.

push rbp ; moves the stack pointer down so rbp points to a different location than rsp, preventing a circular reference.
mov rbp, rsp
call read_input

read_input:
  push rbp          ; Save caller's frame
  mov rbp, rsp      ; Set up current frame
  sub rsp, 32       ; Allocate locals
  leave
  ret

loop:
  ; setup function stack
  ; parse unsigned int from ASCII
  leave
  ret

exit:
  ; syscall for program exit
  mov rax, SYS_EXIT
  mov rdi, 0
  syscall
