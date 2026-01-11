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

# Choosing and Assembler

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
