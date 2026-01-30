# Flow

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

## `as` docs.

This will tell you about the valid assembler sections. It will NOT tell you the valid
code that you can write. That is the "instruction set". So for that you will need to
reference something like:

- https://www.felixcloutier.com/x86/
    - Basically a rip of https://cdrdv2-public.intel.com/868139/325383-089-sdm-vol-2abcd.pdf
- https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html

```bash
pinfo -f $(nix-build '<nixpkgs>' -A binutils.info --no-out-link)/share/info/as.info

# Space         - page down (alternative)
# b             - page up (alternative)
# u             - "go up the info tree"
# Enter         - follow link
# /             - search forward
```

# General

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

Some sections that I found particularly useful:

_NOTE: These sections are all in Volume 1: https://cdrdv2-public.intel.com/868138/253665-089-sdm-vol-1.pdf_

This volume actually exceeded my expectations in terms of accessibility and information.

The diagrams throughout are also quite helpful and accessible.

- 3 - BASIC EXECUTION ENVIRONMENT
    - 3.2.1 - 64-BIT MODE EXECUTION ENVIRONMENT
    - 3.3 - MEMORY ORGANIZATION
    - 3.4.1 - GENERAL-PURPOSE REGISTERS
    - 3.4.1.1 - GENERAL-PURPOSE REGISTERS IN 64-BIT MODE
    - 3.4.2 - SEGMENT REGISTERS
    - 3.5 - INSTRUCTION POINTER
        
        Doesn't actually include much information and refers to section 6.2.4.2

- 4 - DATA TYPES
- 5.1 - INSTRUCTION SET SUMMARY / GENERAL-PURPOSE INSTRUCTIONS

    Not actually helpful, just lists the instructions. That's it. Not how to use them, etc.

    Refer to https://www.felixcloutier.com/x86/ instead or https://cdrdv2-public.intel.com/868139/325383-089-sdm-vol-2abcd.pdf

- 6.2 - STACKS

    Actually quite helpful

- 7.{1,2,3} - PROGRAMMING WITH GENERAL-PURPOSE INSTRUCTIONS

    Quite helpful.

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
# Learning How to Interpret https://www.felixcloutier.com/x86

I'm referencing https://www.felixcloutier.com/x86/mov but I don't know how to interpret this.

From AI:

Each row shows a different encoding of MOV. For your simple case `(mov eax, 1)`, look at:

`B8+ rd id    MOV r32, imm32    OI    Valid    Valid    Move imm32 to r32.`

These rows in the table are all encodings of the same instruction and the encoding is chosen by the assembler to be
the most efficient use of space based on the instruction.

To read the table, I found that looking at the instruction first was helpful.

We know that `eax` is a 32-bit register, so that's where we should start. And we know `1` is immediate. This narrows
our options to

```
B8+ rd id	MOV r32, imm32	OI	Valid	Valid	Move imm32 to r32.
...
C7 /0 id	MOV r/m32, imm32	MI	Valid	Valid	Move imm32 to r/m32.
```

We see that `C7 /0 id` _could_ work. But it's more generic because it also works for writing to memory and not just writing to a register.

`B8+ rd id` is specialized - it only works for immediate to register, so it's more compact.

Why the assembler chooses `B8+ rd id`:

For `mov eax, 1`, both encodings would work, but:
- B8 01 00 00 00 (5 bytes using B8+ rd id)
- C7 C0 01 00 00 00 (6 bytes using C7 /0 id)

The assembler picks the shorter, more memory efficient encoding when possible.

The ModR/M byte has this bit layout:

```
7 6 | 5 4 3 | 2 1 0
mod |  reg  | r/m
```

`/0` says that bits `5 4 3` should all be `0`, so `000` which means that the `C7` instruction in this instance is
referring to the `MOV` instruction.

11 000 000

```
 - C0 (ModR/M: mod=11, reg=000, r/m=000 for EAX)
```

And `mod=11` just means this is register mode.

Register Encoding (3 bits):
The register encoding only needs 3 bits because there are only 8 general-purpose registers in x86:
- 000 (0) = EAX
- 001 (1) = ECX
- 010 (2) = EDX
- 011 (3) = EBX
- 100 (4) = ESP
- 101 (5) = EBP
- 110 (6) = ESI

The +rd notation means we add the 3-bit register number to the base opcode B8:

B8 (base) = 10111000 in binary
+rd       = +00000xxx (where xxx is the 3-bit register number)
- 111 (7) = EDI

The _value_ stored in the register is 32-bits, but identifying one of the eight general-purpose registers only takes 3 bits.

# Choosing an Assembler

```
as exit.s -o exit.o

exit.s:22: Error: ambiguous operand size for `mov'
exit.s:26: Error: ambiguous operand size for `mov'
```

Even though you're using 32-bit registers (eax, ebx) which should indicate 32-bit operations,
GNU Assembler in Intel syntax mode is being conservative about immediate values.

So I need to either use `movl` with ATT syntax or use a less strict assembler, like NASM.

I like strict things, so I think I'd normally choose `movl`, but I want to try nasm.

# Seeing the Machine Code

## objdump (Best Option)

```
objdump -d exit.o

objdump -D exit.o
...
0000000000000000 <_start>:
   0:   c7 04 25 00 00 00 00    movl   $0x1,0x0
   7:   01 00 00 00
   b:   c7 04 25 00 00 00 00    movl   $0x0,0x0
  12:   00 00 00 00
  16:   cd 80                   int    $0x80
...
```

This doesn't match what I expect. Also, how is it using `movl` when I couldn't even use `movl` directly? Is GAS
"translating" to ATT syntax? If it is, I'd just write ATT syntax to avoid some confusion. But what I was reading
was that intel syntax was more commonly used.

The issue what that I had `.intel_syntax` but didn't include `noprefix` and was not using prefixes. Then I could
also remove the `dword ptr` which was a point of confusion.

```
0000000000000000 <_start>:
   0:   b8 01 00 00 00          mov    $0x1,%eax
   5:   bb 00 00 00 00          mov    $0x0,%ebx
   a:   cd 80                   int    $0x80
```

This looks a lot better!

This will show you the disassembly with both machine code bytes and assembly instructions.

## hexdump (Raw Bytes)

```
hexdump -C exit.o
```

This shows all the raw bytes, but you'll need to find the actual code section among all the ELF metadata.

## xxd (Alternative Hex Viewer)

```
xxd exit.o
```

Similar to hexdump but with a different format.

I was super confused by the `xxd` output. I wasn't seeing my machine code. Then I did find it, but wanted to know
how to know it was at offset `0x00000040`. That comes from `readelf -S exit.o`

```
  [ 1] .text             PROGBITS         0000000000000000  00000040
```

Then you can look at `0x00000040` in the `xxd` output.

```
00000040: b801 0000 00bb 0000 0000 cd80 0000 0000  ................
```


Yay!

Honestly, for this exercise, using `readelf -x .text exit.o` makes more sense

```
readelf -x .text exit.o

Hex dump of section '.text':
  0x00000000 b8010000 00bbff00 0000cd80          ............
```

Wrapping up this exercise:

```
ld exit.o -o exit
./exit
echo $?
# then change it to exit with 255 (just for fun and to confirm)
```

Then, you can even read the ELF file after compiling into a binary which will then include real virtual addresses

```
readelf -x .text exit

Hex dump of section '.text':
    0x00401000 b8010000 00bbff00 0000cd80          ............
```

Now open exit in Vim `nvim -b exit`. Then `%!xxd` to get the hex. Then make an edit. For example, let's make the exit code `254` now, so making `ff`, `fe`.

## Syscall numbers

For 32-bit:
The book assumes a 32-bit architecture. However, we are working with 64-bit.
So if you want to cross-reference what the book is using, see - https://github.com/torvalds/linux/blob/v6.16-rc1/arch/x86/entry/syscalls/syscall_32.tbl

For 64-bit:
- https://filippo.io/linux-syscall-table/
- https://github.com/torvalds/linux/blob/v6.16-rc1/arch/x86/entry/syscalls/syscall_64.tbl

# How are syscalls implemented in the Kernel?

- https://filippo.io/linux-syscall-table/ (Geeze, thanks Filippo!).

""Syscalls are implemented in functions named as in the Entry point column, generated with `DEFINE_SYSCALLx` macros.
For more information, see Documentation/process/adding-syscalls.rst.
To learn more, read the `syscall(2)` and `syscalls(2)` man pages."

# `RET` and `LEAVE`

I was trying to understand why you needed to `push rbp` at the beginning of `_start`. It boils down
to the function that you are calling expecting the stack pointer and stack to have a value to pop
off the stack.

It's the `LEAVE` or the stack frame cleanup that has this expectation on the state of the stack, not `RET`.

**Intel 64 and IA-32 Architectures Software Developer's Manual**

- `LEAVE` (stack frame cleanup) - p. Volume 2B 3-542
    - https://www.felixcloutier.com/x86/leave
    - You don't have to call if you are in a leaf function that calls no other functions. Or if you prefer doing cleanup manually.
- `RET` (returning) - p. Volume 2B 4-560
    - https://www.felixcloutier.com/x86/ret

    "Transfers program control to a return address located on the top of the stack. The address is usually placed on the stack by a CALL instruction, and the return is made to the instruction that follows the CALL instruction."

The instruction is implemented in microcode within the CPU, but open-source emulators provide software implementations for reference.

# Making the Linear Weave

Honestly how the stack was designed and the way function stacks are "chained" around physical memory is
quite beautiful. This is an OS abstraction. Memory is linear (abstraction) and it's the combination of stack and registers that go from the linear
to something "fluid".

I acknowledge it's not just the stack and registers that make this possible, but that's how I think about
this. It actually feels like maybe the MMU is where the beauty is held.

# What is a physical address?

What is a physical address in memory? Don't these refer to physical locations?
Are the physical locations linear?

No they are not linear or contiguous in hardware they are spread across chips/channels.

It's a matrix.

The linear virtual address space is created by the OS, not the MMU:
- OS sets up page tables
- OS tells each process "you have a linear address space from 0 to 2^48"
- MMU just executes the translation

# Exhaustion

The OS tries to prevent physical exhaustion of resources via many means.
