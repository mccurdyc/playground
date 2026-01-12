## Getting `as` docs.

This will tell you about the valid assembler sections. It will NOT tell you the valid
code that you can write. That is the "instruction set". So for that you will need to
reference something like:

- https://www.felixcloutier.com/x86/
- https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html

```bash
pinfo -f $(nix-build '<nixpkgs>' -A binutils.info --no-out-link)/share/info/as.info

# Space         - page down (alternative)
# b             - page up (alternative)
# u             - "go up the info tree"
# Enter         - follow link
# /             - search forward
```

## Flow

```txt
Assembly Source (.s)
    ↓ [Assembler: as]

Object File (.o)
    - Contains machine code in sections
    - Sections: .text, .data, etc.
    ↓ [Linker: ld]

Executable
    - Sections combined and relocated
    - Includes metadata for loader
    ↓ [OS Loader] (TODO: read more about this)

Process Memory (TODO: read more about different pages)
    - .text → executable pages
    - .data → writable pages
    - .rodata → read-only pages
    ↓ [CPU]

Executes Instructions (Fetch; Decode; Execute loop)
    - Fetches bytes from memory
    - Decodes opcodes
    - Executes operations
```

```
# lscpu
Architecture:                x86_64
  CPU op-mode(s):            32-bit, 64-bit
  Address sizes:             39 bits physical, 48 bits virtual
  Byte Order:                Little Endian
CPU(s):                      12
  On-line CPU(s) list:       0-11
Vendor ID:                   GenuineIntel
  Model name:                Intel(R) Core(TM) i7-10710U CPU @ 1.10GHz
    CPU family:              6
    Model:                   166
...
```

as -o factorial.o factorial.s

objdump -h factorial.o

objdump -d prog.o

ld -o prog prog.o

## General

You don't "pass" state, you get the stack into the proper state and then `call` and
the syscall you make operates on the state of the stack.

## The stack is (almost always) NOT linear in physical memory (and this doesn't directly affect performance), only in virtual memory

Your stack appears as a contiguous range in virtual address space
(e.g., 0x7fff0000 - 0x7fffffff), but those virtual pages map to whatever physical
frames were available at allocation time.

The Memory Map Unit (MMU), controlled by the OS makes the stack look linear to the process.

Not having physical linear memory is generally not a performance hit because of the
Translation Lookaside Buffer (TLB) cache which is a hardware cache that stores recent
virtual->physical address translations to avoid repeatedly walking page tables.

TLB miss rate (results in ~100 clock cycles) matters more than physical contiguity.

This doesn't mean that it's not possible to have physically linear stacks. That happens
in embedded systems, etc. without OSs, or MMUs, or operations that bypass the MMU.

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
