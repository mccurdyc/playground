# Debugging

```
gdb ./regs
```

## `gdb`

First, it's amazing.

1. `help <command>` or `help all`
2. `show breakpoints`
3. `run`
4. `layout split`

## `apropos` "search"

From French: à propos = "to the purpose"

It's a Unix command for searching man pages and documentation.

```shell
(gdb) help apropos
(gdb) apropos memory # shows all memory-related commands
```

## `breakpoints`

```shell
(gdb) break some_function
(gdb) break file.c:42
```

## restarting

```shell
(gdb) kill
(gdb) delete # if you want to clear breakpoints
(gdb) run
(gdb) run <cli args>
```

## Current location

```shell
(gdb) backtrace
(gdb) where
(gdb) frame
(gdb) info frame
(gdb) info line
```

## `info`

```shell
(gdb) help info
(gdb) info all-registers (or just registers)
(gdb) info registers $rax
(gdb) info stack
(gdb) info breakpoints
```

## `layout`

```shell
(gdb) layout src
(gdb) layout regs
(gdb) layout next # prev; to switch between split panes
C+X a # to close; or `tui disable` if that doesnt work
```

## Disassembly `layout asm`

This takes the actual machine code and translates back into assembly representation.

The actual instructions the CPU will run, not the source code you wrote (unless you compiled without optimization, in which case they may be very similar).

```shell
% objdump -d -M intel regs
regs:     file format elf64-x86-64
Disassembly of section .text:

0000000000401000 <_start>:
  401000:	49 89 e4             	mov    r12,rsp
  401003:	49 89 ed             	mov    r13,rbp
  401006:	90                   	nop
  401007:	b8 3c 00 00 00       	mov    eax,0x3c
  40100c:	bf 00 00 00 00       	mov    edi,0x0
  401011:	0f 05                	syscall
```

```shell
# NOTE: you probably don't want thisl just use `objdump -d -M intel regs` instead
% objcopy -O binary --only-section=.text regs code.bin && \
ndisasm -b 64 code.bin | less
```

ndisasm is "dumb" - it just disassembles raw bytes from the executable file
    - Starts at offset 0 in the file
    - Doesn't understand ELF headers, data sections, etc.
    - Will try to disassemble everything (headers, data, padding) as code

ndisasm: For:
    - Raw binary blobs (bootloaders, shellcode, firmware)
    - When you need NASM syntax specifically
    - Disassembling from arbitrary offsets: ndisasm -o 0x7c00 bootloader.bin

# Manual Disassembly

## `mov r12, rsp`

- https://www.felixcloutier.com/x86/mov

I believe it's going to be one of these encodings.

```txt
88 /r	        MOV r/m8, r8	MR	Valid	Valid	Move r8 to r/m8.
REX + 88 /r	    MOV r/m81, r81	MR	Valid	N.E.	Move r8 to r/m8.
89 /r	        MOV r/m16, r16	MR	Valid	Valid	Move r16 to r/m16.
89 /r	        MOV r/m32, r32	MR	Valid	Valid	Move r32 to r/m32.
REX.W + 89 /r	MOV r/m64, r64	MR	Valid	N.E.	Move r64 to r/m64.
...
# wait it seems like it could also choose
REX.W + 8B /r	MOV r64, r/m64	RM	Valid	N.E.	Move r/m64 to r64.
```

We know `rsp` is a 64-bit register. If we were 32-bit, it'd be `esp`.

```txt
REX.W + 89 /r	MOV r/m64, r64	MR	Valid	N.E.	Move r64 to r/m64.
...
REX.W + 8B /r	MOV r64, r/m64	RM	Valid	N.E.	Move r/m64 to r64.
```

Breaking this down to learn from AI because I don't know how to interpret this.

### `REX.W`

- REX prefix byte (0x40-0x4F range)
- `W` bit set = 1 means 64-bit operand size. And the `W` here means it's required.
- Without `REX.W`, `89 /r` would be 32-bit

**REX prefix structure:** `0100 WRXB`

- **W**: 1 = 64-bit operand size. For opcode 89 here, `W=1` is required is what the docs say.
- **R**: extends ModR/M `reg` field (adds 8 to access r8-r15)
- **X**: extends SIB `index` field (adds 8)
- **B**: extends ModR/M `r/m` or SIB `base` field (adds 8 to access r8-r15)

The REX bit acts as a 4th bit to extend the 3-bit register field:

So r12 = binary 1100 = decimal 12, where the high bit comes from REX.R and the low 3 bits come from ModR/M.

```bash
0100 0000 = 0x40  (minimum REX byte)
0100 1111 = 0x4F  (maximum REX byte)
     ^^^^
     WRXB (the only bits that vary)
```

`REX.W` in the instruction encoding table tell you that setting the `W` bit is required.

`WRXB` vary based on registers

1. `0100` - Fixed prefix that identifies this as a REX byte
2. `W` - Controls operand size (but meaning varies by opcode)
3. `R` - Extends ModR/M.reg field (set to 1 for r8-r15 in destination)

### `89` - The opcode byte

Identifies this as MOV with direction: (source) memory/register → (destination) register.

Why didn't it choose `8B`?

Both would work, but 89 requires fewer (not really) REX extension BITS ... kinda.

`49` - `0100 1001`
`4C` - `0100 1100`

The assembler always prefers `89` for register-to-register moves.
**It puts the source in the more "flexible" position (the reg field).**
This is just an assembler convention, not a requirement. Hand-written machine code could use either.

### `/r` - ModR/M byte follows

Why is it `/r`? What does this symbolize or signify? Is it that we know `MOV` is three bytes and `/r` symbolizes something within that third byte?

`/r` = Is just documentation short-hand for "needs ModR/M byte with both `reg` and `r/m` fields used for operands"

Similar to `/0-7` shorthand.

Actually, I think first, I must understand the encoding `ModRM:reg (w)`

```
RM	    ModRM:reg (w)	ModRM:r/m (r)	N/A	N/A
```

- **ModRM:reg (w)**: destination encoded in ModR/M `reg` field, written to
- **ModRM:r/m (r)**: source encoded in ModR/M `r/m` field, read from
- **(w)** = write/destination, **(r)** = read/source

Format: `[mod:2][reg:3][r/m:3]` (2 bits, 3 bits, 3 bits)

- `mod` field = addressing mode
- `reg` field = destination register
- `r/m` field = source (register or memory depending on mod)

Okay this is the breakdown of the third byte in our instruction.

So now we have something like

```bash
<a byte to signal 64-bit registers that I still don't understand> | 89 | <2-bit mode> <3-bit destinsation register> <3-bit source register>
```

I want to fill the last byte in now.

#### ModR/M `mod` field encoding

- `00` - easy. got it.
- `01`, `10` - okay. hmm actually no. All that I understand is these deal with memory displacement. Let's come back to these.
    -  `<signify 64-bit byte> | 8B | 43 08`
     - `43` = ModR/M (01 | 000 | 011) `01` - 1-byte displacement byte follows | rax | rbx
     - `08` = 1 byte displacement from rbx in memory
- `11` - easy. no memory access.

```
mod bits | Meaning                      | Example
---------|------------------------------|---------------------------
00       | [reg] - register indirect    | mov rax, [rbx]
         | (no displacement)            |
         |                              |
01       | [reg + disp8]                | mov rax, [rbx + 0x10]
         | (1-byte signed displacement) |
         |                              |
10       | [reg + disp32]               | mov rax, [rbx + 0x1000]
         | (4-byte signed displacement) |
         |                              |
11       | reg - register direct        | mov rax, rbx
         | (no memory access)           |
```

#### Complete SIMPLE example: `mov rax, rbx`

Encoding: `48 8B C3`

- `48` = REX.W (0100 1000 binary, W=1 for 64-bit)
- `8B` = opcode (MOV r64, r/m64)
- `C3` = ModR/M (11 000 011 binary)
  - mod=11 (register direct mode)
  - reg=000 → RAX (destination)
  - r/m=011 → RBX (source)

#### Another example: `mov rax, [rbx + 8]`

Encoding: `48 8B 43 08`

- `48` = REX.W I don't get this. 0011 0000.
- `8B` = opcode. Easy. Got it.
- `43` = ModR/M (01 000 011 binary). Got it.
  - mod=01 → 8-bit displacement follows. Ohh we are saying we only need 8 bits to describe how many BYTES displacement. That's not confusing.
  - reg=000 → RAX (destination)
  - r/m=011 → RBX (base register)
- `08` = displacement (+8 bytes). Got it.

#### 64-bit register encoding (with REX prefix)

The 3-bit ModR/M fields are extended by REX prefix bits to encode all 16 64-bit
registers:

```
REX.R/B | reg/r/m | Register
--------|---------|----------
   0    |   000   | rax
   0    |   001   | rcx
   0    |   010   | rdx
   0    |   011   | rbx
   0    |   100   | rsp
   0    |   101   | rbp
   0    |   110   | rsi
   0    |   111   | rdi
---
   1    |   000   | r8
   1    |   001   | r9
   1    |   010   | r10
   1    |   011   | r11
   1    |   100   | r12
   1    |   101   | r13
   1    |   110   | r14
   1    |   111   | r15
```
