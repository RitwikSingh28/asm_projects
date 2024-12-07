.include "linux.s"
.include "record_def.s"

  .section .data

  # Each text data item is padded to the proper length
  # with null bytes

  #.rept is used to pad each item. .rept tells the assembler
  #to repeat the section between .rept and .endr the number of times
  #specified. This is used in this program to add extra null chars
  #at the end of each field to fill it up

record1:
  .ascii "Ritwik\0"
  .rept 33 #Padding to 40B
  .byte 0
  .endr

  .ascii "Singh\0"
  .rept 34 #Padding to 40B
  .byte 0
  .endr

  .ascii "DSA is overhyped. ASM x86_64 is where the future is\0" 
  .rept 188
  .byte 0
  .endr

  .long 65

file_name:
  .ascii "test.dat\0"

  .equ ST_FILE_DESCRIPTOR, -4
  .globl _start
_start:
  #Copy the stack pointer to %ebp
  movl %esp, %ebp
  # Allocate space to hold the file descriptor
  subl $4, %esp

  # Open the file
  mov $SYS_OPEN, %eax
  mov $file_name, %ebx
  movl $0101, %ecx      # Create file if it doesn't exist, and open for writing
  movl $0666, %edx
  int $LINUX_SYSCALL

  # Store the file descriptor away
  movl %eax, ST_FILE_DESCRIPTOR(%ebp)

  pushl ST_FILE_DESCRIPTOR(%ebp)
  pushl $record1
  call write_record
  addl $8, %esp

  # Close the file descriptor
  movl $SYS_CLOSE, %eax
  movl ST_FILE_DESCRIPTOR(%ebp), %ebx
  int $LINUX_SYSCALL

  # Exit the program
  movl $SYS_EXIT, %eax
  movl $0, %ebx
  int $LINUX_SYSCALL
