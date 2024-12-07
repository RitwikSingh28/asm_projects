  .include "record_def.s"
  .include "linux.s"

  # PURPOSE: This function reads a record from the file descriptor
  # INPUT: The file descriptor and a buffer
  # OUTPUT: Writes the data to the buffer and returns a status code

  .equ ST_READ_BUFFER, 8
  .equ ST_FILEDES, 12

  .section .text

  .globl read_record
  .type read_record,@function
read_record:
  # Function Prologue
  pushl %ebp
  movl %esp, %ebp

  pushl %ebx
  movl ST_FILEDES(%ebp), %ebx
  movl ST_READ_BUFFER(%ebp), %ecx

  # READ Operation
  movl $RECORD_SIZE, %edx
  movl $SYS_READ, %eax
  int $LINUX_SYSCALL

  # Note: %eax has the return value, which will be given back to the calling program
  popl %ebx

  movl %ebp, %esp
  popl %ebp
  ret
