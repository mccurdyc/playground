# Understanding setting up a stack

`rbp` is about restoring caller state. `rbp` contains a relative location to arbitrary parameters. The processor can't manage this for you, it's "dumb". You -- the author -- know how many params functions have.
`rsp` is automatically maintained because it always references a single location.

Sometimes `rbp` is pushed to the stack by convention e.g., in `_start` where you know there is not "caller" of `_start` to be restored.

If you don't use `rbp` you will have tons of off-by-one issues and end up not being able to restore the state
of other caller parameters.

It's quite beautiful that with just two places to store state --- current and previous --- you can have
intricate call trees to navigate linear memory. I assume if memory were three-dimensional, etc. you would need
to have dimension+1 storage locations.

I still need to come back to this because my grasp is still fleeting. I want to read more of CS:APP.

```asm
_start:
    mov rbp, rsp
    call some_fn

some_fn:
    push rbp          ; Save caller's frame
```

Our goal here is to understand why the `push rbp` is necessary in `_start`.


The following is just to show that `rbp` is junk to start, but that the CPU manages `rsp`.

```asm
mov r12, rsp      ; Save stack pointer
mov r13, rbp      ; Save base pointer
```

```txt
(gdb) print/x $r12
$1 = 0x7fffffffa220 ; rsp

(gdb) print/x $r13
$2 = 0x0            ; rbp
```

Read section 6-2 "Stacks" and 6-4 "Calling procedures using CALL and RET" of the x86 instruction set.

- https://www.felixcloutier.com/x86/call

"When executing a near call, the processor pushes the value of the EIP register (which contains the offset of the instruction following the CALL instruction)
on the stack (for use later as a return-instruction pointer). The processor then branches to the address in
the current code segment specified by the target operand."

Ah, so it does a `push` which manipulates the stack pointer `rsp`.

Also, most calls are "near calls".

- https://www.felixcloutier.com/x86/ret

If we have the following:

```asm
_start:
    mov rbp, rsp
    call some_fn

some_fn:
    push rbp
    call another_fn
    pop rbp
    ret
```

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

It took me roughly 3-hours and $1.41 in Claude 4.5 Sonnet credits to understand how to manually
disassemble this line.

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

Why it prefer `89` over `8B`?

`49` - `0100 1001`
`4C` - `0100 1100`

It's likely that the assembler considers the following:

1. Always prefer opcode 89 for reg→reg moves - just a canonical form choice, no
deeper reason

2. Prefer putting the destination in `r/m` - because in real memory operations, **the
destination is more often memory (stores are common), so this creates consistency**

3. Historical convention - early assemblers picked one and everyone copied it

This is just an assembler convention, not a requirement. Hand-written machine code could use either.

I'm just going to try to remember this as, you'll likely be writing to memory more often as the destination.

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

## `mov rax, 60`

I think it would either use `REX.W + B8+ rd io` or `REX.W + C7 /0 id`.
I expect it to choose the former because the latter is more "flexible" to support writing to registers
or memory. The flexibility doesn't seem to add additional bytes though. The first could be shortened to
use 32-bit immediate by not extending via the `REX.W` byte.

I think it would be `48 B8 3C` or `0100 1000 1011 1000 0011 1100` nibbles.

The manual disassembly is taking ~10min now! This is exciting! I need to practice disassembling other instructions.

Let me checks the assembled code.

Hmm. `nasm` seems to drop the `REX.W` byte. Also, I clearly dropped the remaining bytes for the imm32 which is required
for a 64-bin register.

```shell
% objdump -d -M intel regs
...
0000000000401000 <_start>:
  ...
  401007:       b8 3c 00 00 00          mov    eax,0x3c
```

### `REX.W`

`REX.WRXB` - just noting to remember the order

```txt
0100 1000
48
```

#### Why does `nasm` drop `REX.W`?

Oh, because I've compiled for 64-bit, the default register size is 64-bit and therefore I don't need to explicitly
extend the register byte. Now, `REX.W` would exist if I had compiled for 32-bit but needed to extend this to use
a 64-bit register like `rax`. Let's confirm.

```bash
nasm -f elf32 -g -F dwarf regs.s -o regs_32.o

regs.s:10: error: instruction not supported in 32-bit mode
regs.s:15: error: instruction not supported in 32-bit mode
regs.s:34: error: instruction not supported in 32-bit mode
regs.s:38: error: instruction not supported in 32-bit mode
```

I mean this makes sense. But then why isn't `REX.W` always optional? Oh wait maybe it is for the `B8` opcode where
the second operand is `<= 32-bit`.

### `B8+ rd`

It's `+0` because it's `rax`.

```txt
1011 1000
B8
```

### `io` - "Immediate Operand"

Oh, the operand encoding table makes this clear:

```txt
OI	opcode + rd (w)	imm8/16/32/64	N/A	N/A
```

```txt
0110 0000
60
```

Ahh :facepalm: `60` is decimal, not hex.

```txt
0011 1100
0x3C # let's prefix with 0x to make it clear :smile: it's hex
```

## Seeing binary (instead of hex) .text section

This is just to check my manual hex to binary conversion. There's not much practical value in this otherwise.

```bash
objcopy -O binary --only-section=.text regs /dev/stdout | xxd -b
```

To keep the original virtual memory addresses

```bash
objdump -d -M intel regs | awk '/^ /{addr=$1; for(i=2;i<=NF&&$i~/^[0-9a-f]{2}$/;i++){print addr, $i}}' | while read addr hex; do echo "$addr $(echo $hex | xxd -r -p | xxd -b -c1 | cut -d' ' -f2)"; done
```

# General Things

## The actual code is 19-bytes

Between addresses 401000-401011 (keep in mind that these digits are hex digits) is 19 bytes.

```bash
% ls -lh regs
-rwxr-xr-x 1 mccurdyc users 5.2K Jan 21 07:36 regs

% stat -c %s regs
5256
```

But the `regs` binary is 5.2K or 5256 bytes! That's 99.997% of metadata.

But from that you get a lot! Without the ELF binary format and DWARF debugging symbols, you can't use sections in your code and you can't link.

The raw binary approach is typically used for:
- Bootloaders
- Shellcode
- Embedded systems
- Operating system kernels

```bash
bc <<< "scale=4; 19/5256"
.0036
```

```bash
% just build-bin

% ls -lh regs.bin
-rw-r--r-- 1 mccurdyc users 19 Jan 22 07:48 regs.bin

% stat -c %s regs.bin
19
```

Okay, now we can't even run our binary. We need the layer of abstraction that the ELF format provides. Maybe we
can just strip debugging symbols.

```bash
% just build-without-dwarf

% ls -lh regs_without_dwarf
-rwxr-xr-x 1 mccurdyc users 4.6K Jan 22 08:24 regs_without_dwarf

% stat -c %s regs_without_dwarf
4656
```

Oh hmm honestly, I would have expected a littly bit better. Apparently debug symbols only accounted for ~20% of the binary
size.
