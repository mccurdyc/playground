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
