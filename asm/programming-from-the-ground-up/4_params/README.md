# Understanding the stack

Chapter 4 (p56) talks about function parameters. `rbp` is an address that can be used to relatively
refer to function parameters that is "out of the way" of the stack pointer.

For parameters, we "reserve space" --- relative to `rbp` --- on the stack. Then, within
the function we can use locations relative to `rbp` for accessing the paramters as well
as local variables.

## Stack growth

Stack growth isn't consistent i.e., it doesn't always grow by 1-byte or 1-word. In other
words, stack elements are not uniformly-sized.

Stack alignment is specified by the ABI. System V AMD64 ABI requires 16-byte stack alignment before call instructions

Stack alignments affects performance because you have to remember that the stack is just
an abstraction on top of memory which has layers of caching. So if you have values that
often lead to misalignment or where data is going to span multiple cache-lines, you
are doing more work to get data than should be necessary. It's a performance-memory tradeoff.
If you care more about memory than performance, maybe you allow misalignment to avoid
wasted space and vice versa. Additionally, misalignment makes atomic operations impossible,
so it's also a reliability(or consistency)-memory tradeoff.

Expect a 10-30% performance hit (or worse) for a misaligned stack.

Stack growth is based on the operand size. So if you are using 64-bit registers, the
stack will grow accordingly.

`rax` - grows by 8-bytes (qword)
`eax` - grows by 4-bytes (dword)
`ax` - grows by 2-bytes (word)

What about for immediate values like `1`? It's based on the mode e.g., 64-bit, 32-bit, 16-bit, etc.

The assembler determines the operand size from the current operating mode, not from the immediate value itself.

64-bit - grows by 8-bytes (qword)
32-bit - grows by 4-bytes (dword)
16-bit - grows by 2-bytes (word)

Wow that feels like quite a waste to grow by 8-bytes just to store essentially a single bit.

00000000 00000000  00000000 00000000  00000000 00000000  00000000 00000001

But also, you don't always have a choice. If you are in 64-bit mode (for reasons), the CPU is
going to use 64-bit registers for things like the stack pointer (`rsp`). Therefore, you
wouldn't want to use a 32-bit `ebp` base pointer for memory addressing. I mean there's
nothing preventing you, but it's not going to work how you want.

By default in 64-bit mode is to grow and shrink the stack by 8-bytes. This kind of makes sense because registers are 64-bit (8-bytes),
instruction operands are 8-bytes and virtual memory address pointers are 8-bytes so when you are pushing the references on the stack it's 8-bytes. The stack is
an abstraction on top of single-byte memory locations.

## Function Parameters

System V ABI (Linux/macOS):
- First 6 parameters go in registers: RDI, RSI, RDX, RCX, R8, R9
- Additional parameters (7th+) go on stack at 16(RBP), 24(RBP), etc.

Then parameters >6 get pushed to the stack by the caller and are referenced as offset from `rbp`.

```txt
+-----------+  <-- higher addresses
|  param 9  | 32(RBP)  (7th+ params pushed by caller)
|  param 8  | 24(RBP)  (7th+ params pushed by caller)
|  param 7  | 16(RBP)  (7th+ params pushed by caller)
|  ret addr | 8(RBP)   (pushed by CALL instruction)
|  old RBP  | 0(RBP)   (pushed by function prologue)
|  local 1  | -8(RBP)  (allocated by callee)
|  local 2  | -16(RBP) (allocated by callee)
+-----------+  <-- RSP (after locals allocation)
```
