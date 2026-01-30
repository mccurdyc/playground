# looping

I was extremely humbled by this learning session. When I literally tried to write a loop and was lost. It's honestly
for this purpose that I really appreciate AI. Where you don't need to be afraid of asking the dumbest possible questions.

Learning is a process of testing your humility and patience. Are you willing to ask the dumb questions or give up and go back
to the comfortable? 1% every day. Heck even 0.000001% every day. It's not about progress. It's about process.

I wanted to get to the "fun" parts of actually building something. How can I do that when I don't even know how to
create a simple loop construct.

## `LOOP` and `LOOPcc`

https://www.felixcloutier.com/x86/loop:loopcc

Performs a loop operation using the RCX, ECX or CX register as a counter (depending on whether address size is 64 bits, 32 bits, or 16 bits).

Each time the LOOP instruction is executed, the count register is decremented, then checked for 0. If the count is 0, the loop is terminated and program execution continues with the instruction following the LOOP instruction.

If the count is not zero, a near jump is performed to the destination (target) operand, which is presumably the instruction at the beginning of the loop.

Early termination:

Some forms of the loop instruction (LOOPcc) also accept the ZF flag as a condition for terminating the loop before the count reaches zero. With these forms of the instruction, a condition code (cc) is associated with each instruction to indicate the condition being tested for. Here, the LOOPcc instruction itself does not affect the state of the ZF flag; the ZF flag is changed by other instructions in the loop.

## Where are the various jump conditions? `Jcc`

https://www.felixcloutier.com/x86/jcc

The manual groups related instructions to avoid repetition. Instead of separate pages for each
jump, they document:
- `Jcc` - All conditional jumps with their condition codes
    - with the JMP instruction, the transfer is one-way; that is, a return address is not saved.
- `SETcc` - All conditional set-byte instructions
- `CMOVcc` - All conditional moves
- `LOOPcc` - All conditional moves

## `FLAGS`, `EFLAGS` and `RFLAGS` - "program status and control register"

It's `EFLAGS` because the upper 32-bits of `RFLAGS` are just reserved.

`*FLAGS` is just another register. See Figures 3-1, 3-2, 3-4 and 3-8 in the Intel x86 manual. (TODO)

## 7.3.8.2 Conditional Transfer Instructions

"The conditional transfer instructions execute jumps or loops that transfer program control to another instruction in
the instruction stream if specified conditions are met. The conditions for control transfer are specified with a set of
condition codes that define various states of the status flags (CF, ZF, OF, PF, and SF) in the EFLAGS register."

### Status Flags (arithmetic results) (Section 3.4.3.1)

- CF (bit 0) Carry flag — Set if an arithmetic operation generates a carry or a borrow out of the most-
significant bit of the result; cleared otherwise. This flag indicates an overflow condition for
unsigned-integer arithmetic. It is also used in multiple-precision arithmetic.

- PF (bit 2) Parity flag — Set if the least-significant byte of the result contains an even number of 1 bits;
cleared otherwise.

- AF (bit 4) Auxiliary Carry flag — Set if an arithmetic operation generates a carry or a borrow out of bit
3 of the result; cleared otherwise. This flag is used in binary-coded decimal (BCD) arithmetic.

- ZF (bit 6) SF (bit 7) Zero flag — Set if the result is zero; cleared otherwise.
Sign flag — Set equal to the most-significant bit of the result, which is the sign bit of a signed
integer. (0 indicates a positive value and 1 indicates a negative value.)

- OF (bit 11) Overflow flag — Set if the integer result is too large a positive number or too small a negative
number (excluding the sign-bit) to fit in the destination operand; cleared otherwise. This flag
indicates an overflow condition for signed-integer (two’s complement) arithmetic

There are also Control Flags and System Flags.

## EFLAGS Set by CMP.

After `cmp %rax, %rbx` (which computes rbx - rax):

```txt
1. ZF (Zero Flag) - Set if result is zero (operands equal)
2. SF (Sign Flag) - Set if result is negative
3. CF (Carry Flag) - Set if unsigned underflow occurred
4. OF (Overflow Flag) - Set if signed overflow occurred
```

```txt
Opcode   Mnemonic   Condition
------   --------   ---------
74       je/jz      ZF = 1
75       jne/jnz    ZF = 0
7C       jl/jnge    SF ≠ OF
7D       jge/jnl    SF = OF
7E       jle/jng    ZF = 1 OR SF ≠ OF
7F       jg/jnle    ZF = 0 AND SF = OF
72       jb/jnae    CF = 1
73       jae/jnb    CF = 0
76       jbe/jna    CF = 1 OR ZF = 1
77       ja/jnbe    CF = 0 AND ZF = 0
```
