; rsp will be consistent, rbp will be "random" based on the last process to set it.
; binary machine code
; 01001001 10001001 11100100 01001001 10001001 11101101 10010000 10111000 00111100 10111000 00111100 10111111 00000000 00001111 00000101
;
; confirmed with: objcopy -O binary --only-section=.text regs /dev/stdout | xxd -b -c1 | less
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
  ; 1011 1000 0011 1100
  ; B8        3C
  mov rax, 60

  ; https://www.felixcloutier.com/x86/mov
  ; we know 64-bit based on rax and 0 is an immediate
  ;
  ; rdi = B8+ 7 = BF
  ;
  ; 1011 1111 0000 0000
  ; BF        00
  mov rdi, 0

  ; https://www.felixcloutier.com/x86/syscall
  ; 0F 05	SYSCALL	ZO	Valid	Invalid	Fast call to privilege level 0 system procedures
  ;
  ; 0000 1111 0000 0101
  ; 0F        05
  syscall
