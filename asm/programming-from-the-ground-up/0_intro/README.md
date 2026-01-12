p5 - The kernel control the flow of information between programs. By itself, the kernel
won't do anything. You can't even boot a computer with just a kernel.

p7 - Von Neumann architecture divides the computer into two main parts: CPU and memory.

p9 - fetch-execute cycle

The program counter refers to the next instruction location in memory. The decoded instruction
is then passed to the arithmetic logic unit (ALU) where it is actually "executed". This is oversimplified
because real world computers are more complicated due to cache heirarchies, branch prediction and other
forms of optimizations.

Memory addresses always refer to a single byte (8-bits). The computer primarily works on 4-byte "words".

Registers are 4-bytes and are on the CPU.

Addresses are also 4-bytes.

The only way a computer knows the difference between an instruction and data in memory is due to the instruction pointer.

Linking is the process of putting object files together and including extra metadata so that the kernel
knows how to load and run the file.

Anything starting with a period is an assembler directive and is not translated directly
to machine code.

Symbols are references to memory locations that get replaced during assembly or linking.

`.global` directs the assembler to not discard this symbol after assembly because the linker will need it.

`_start` is a special symbol that denotes the start of a program.
