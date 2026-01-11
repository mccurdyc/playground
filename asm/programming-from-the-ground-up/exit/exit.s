.intel_syntax

# The assembled machine code in the text section should be:
# B8 01 00 00 00 B9 00 00 00 00 CD 80

.section text
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
  mov eax, 1

  # Return a 0 exit code
  # B9 00 00 00 00
  mov ebx, 0

  # kernel interrupt
  # https://www.felixcloutier.com/x86/intn:into:int3:int1
  # `CD ib	INT imm8	I	Valid	Valid	Generate software interrupt with vector specified by immediate byte`
  # this should be the row from the docs that the assembler ends up using
  # CD <8-bits> or one byte.
  # CD 80
  int 0x80
