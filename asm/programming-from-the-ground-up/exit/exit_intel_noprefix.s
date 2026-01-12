# Always set noprefix with intel syntax. Otherwise, you get a weird combination intel syntax but are still
# required to use the ATT prefixs, which no one uses.
.intel_syntax noprefix

# The assembled machine code in the text section should be:
# B8 01 00 00 00 BB 00 00 00 00 CD 80
# %% readelf -x text exit.o
#
# Hex dump of section 'text':
# 0x00000000 b8010000 00bb0000 0000cd80          ............

.section .text
.globl _start
_start:
  # This is the Linux syscall for exit.
  # You must put a literal value of '1' in the eax register.
  #
  # In _Programming From the Ground Up_ they use `movl`. This is because AT&T syntax
  # uses the suffix because operand size isn't always obvious from the operands.
  # Intel syntax typically infers size from the operands e.g., eax infers 32-bit, ax would indicate 16-bit and ah or al would indicate 8-bit.
  #
  # According to https://www.felixcloutier.com/x86/mov we should expect this to be assembled as `B8+rd id` ("Move imm32 to r32.")
  #   Register Encoding (+rd)
  #     - The + means we add the register number to the base opcode
  #     - EAX is register 0 in the x86 register encoding
  #   - So the final opcode becomes: B8 + 0 = B8
  # B8 01 00 00 00
  #
  # `dword ptr` is super confusing but required for intel syntax when using the GAS assembler
  # `dword ptr` makes sense when you are referencing memory locations and it's just using that same sytanx
  # For this reason, I will probably either switch to ATT syntax or NASM.
  mov eax, 1

  # Return a 0 exit code
  # B9 00 00 00 00 - WRONG!
  # ebx is B8 + 3 (why 3 if eax is 0?)
  #   1011 1000 = B8
  # + 0000 0011 = 3 (why?)
  # ================
  #   1011 1011 = BB
  #
  # +3 because it's not alphabetical
  # x86-64 Register Encoding
  # - EAX = 0
  # - ECX = 1
  # - EDX = 2
  # - EBX = 3
  #
  # Why This Order?
  # This comes from the original 8086 register encoding:
  #  - AX (Accumulator) = 0
  #  - CX (Counter) = 1
  #  - DX (Data) = 2
  #  - BX (Base) = 3
  mov ebx, 0
  # mov ebx, 255 # just for fun and to confirm
  # 00000040: b801 0000 00bb ff00 0000 cd80 0000 0000  ................
  # ff correctly replaces 00!

  # kernel interrupt
  # https://www.felixcloutier.com/x86/intn:into:int3:int1
  # `CD ib	INT imm8	I	Valid	Valid	Generate software interrupt with vector specified by immediate byte`
  # this should be the row from the docs that the assembler ends up using
  # CD <8-bits> or one byte.
  # CD 80
  int 0x80
