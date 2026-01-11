.intel_syntax

.section text
.globl _start
_start:
  # This is the Linux syscall for exit.
  # You must put a literal value of '1' in the eax register.
  #
  # In _Programming From the Ground Up_ they use `movl`. This is because AT&T syntax
  # uses the suffix because operand size isn't always obvious from the operands.
  #  Intel syntax typically infers size from the operands e.g., eax infers 32-bit, ax would indicate 16-bit and ah or al would indicate 8-bit.
alone.
  mov eax, 1
