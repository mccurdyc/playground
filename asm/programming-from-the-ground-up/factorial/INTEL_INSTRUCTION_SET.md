# Intel Instruction Set

Just skimming through: https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html

CRITICAL: I have no idea what I'm doing, so DONT use these notes as a reference. This is me learning from
a combination of reading the manual (RTFM) and conversing with the modern day "wiki", namely AI.

I got to this point from reading Barlett's _Programming From the Ground Up_. On page 65, I wanted to better
understand how he knew to use, for example, `eax` as the register name. And I couldn't follow the example
code because I didn't understand how the stack pointer was automatically moving "up". And how I could learn more about
what's available in my Intel x86-64 CPU. I wanted to know how to read the official documentation instead
of reading an abstraction of the official documentation.

I think after a brief skim of the official spec, I will feel comfortable referencing an easier to digest
and more straightforward abstracted documentation. (Maybe I'm wrong and I should learn the other way around).

---

The stack is managed as part of the execution environment. It is in memory.

If a 32-bit operand size is specified: EAX, EBX, ECX, EDX, EDI, ESI, EBP, ESP, R8D-R15D are available.
If a 64-bit operand size is specified: RAX, RBX, RCX, RDX, RDI, RSI, RBP, RSP, R8-R15 are available.

Architectural Nesting (The "Russian Doll" Model)

In x86-64, registers are not separate physical entities for each size;
they are overlapping views of the same 64-bit storage location.

- RAX is the full 64-bit register.
- EAX refers to the lower 32 bits of RAX.
- AX refers to the lower 16 bits.
- AL refers to the lower 8 bits.

Keep in mind that "lower" is likely relative to endianess.

32-bit execution mode (protected mode).

In 64-bit mode, the CPU has 16 general-purpose registers (RAX–R15).
In 32-bit mode, you are restricted to 8 (EAX–ESP). 

The Only Real Benefit is cache density:
A 64-bit pointer (or address) is 8 bytes;
a 32-bit pointer is 4 bytes.
Because the data is smaller in 32-bit, more of it fits into the CPU Cache (L1/L2/L3).

The "Middle Ground": The x32 ABI

Because engineers liked the speed of 64-bit registers but hated the "bloat" of 64-bit pointers, they created the x32 ABI (mostly used in Linux).
- The Best of Both Worlds: It uses the 64-bit instruction set (all 16 registers) but treats all memory addresses as 32-bit.
- The Limit: You are capped at 4GB of RAM per process, but you get a ~5-10% speed boost because of the increased cache density and 64-bit register count.

64-bit general-purpose registers (RAX, RBX, RCX, RDX, RSI, RDI, RSP, RBP, or R8-R15).
- 32-bit general-purpose registers (EAX, EBX, ECX, EDX, ESI, EDI, ESP, EBP, or R8D-R15D).
- 16-bit general-purpose registers (AX, BX, CX, DX, SI, DI, SP, BP, or R8W-R15W).
- 8-bit general-purpose registers: AL, BL, CL, DL, SIL, DIL, SPL, BPL, and R8B-R15B are available using REX
prefixes; AL, BL, CL, DL, AH, BH, CH, DH are available without using REX prefixes.

## EIP (32-bit) / RIP (64-bit)

The instruction pointer (EIP) register contains the offset in the current code segment for the next instruction to be
executed. It is advanced from one instruction boundary to the next in straight-line code

The EIP register cannot be accessed directly by software; it is controlled implicitly by control-transfer instructions
(such as JMP, JCC, CALL, and RET), interrupts, and exceptions. The only way to read the EIP register is to execute a
CALL instruction and then read the value of the return instruction pointer from the procedure stack.

## General Purpose Instructions

The general-purpose instructions perform basic data movement, arithmetic, logic, program flow, and string operations
that programmers commonly use

## How does the stack pointer "magically" move!?

I began to understand that the CPU "magically" managed it as part of managing the stack in memory as part
of this Ben Eater video at 16:30 - https://www.youtube.com/watch?v=xBjQVxVxOxc&t=1030s
