# Syscall numbers

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
