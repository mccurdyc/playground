section .text
global _start
_start:
; explicitly DONT backup stack. Just read it.
; print rsp+20? (stack overflow?)
