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
