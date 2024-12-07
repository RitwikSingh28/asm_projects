.include "linux.s"
.include "record_def.s"

  # PURPOSE: This function writes a record to the given fd
  # INPUT: The fd and the buffer
  # OUTPUT: This function produces a status code and stores in %eax 

  .equ ST_WRITE_BUFFER, 8
  .equ ST_FILE_DES, 12

  .section .text

  .globl write_record
  .type write_record,@function
write_record:
  pushl %ebp
  movl %esp, %ebp

  pushl %ebx

  movl $SYS_WRITE, %eax
  movl ST_FILE_DES(%ebp), %ebx
  movl ST_WRITE_BUFFER(%ebp), %ecx
  movl $RECORD_SIZE, %edx
  int $LINUX_SYSCALL

  popl %ebx

  movl %ebp, %esp
  popl %ebp
  ret
