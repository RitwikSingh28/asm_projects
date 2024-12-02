  #PURPOSE: This program finds the maximum number of a
  #         set of data items.
  #

  #VARIABLES: The registers have the following uses:
  #
  # %edi - Holds the index of the data item being examined
  # %ebx - Largest data item found
  # %eax - Current data item
  #
  # The following memory locations are used:
  #
  # data_items - contains the item data. A 0 is used
  #              to terminate the data
  #

  .section .data
numbers:
  .long 3, 23, 14, 53, 23, 64, 21, 192, 255
length:
  .long 9

  .section .text

  .globl _start
_start:
  movl $0, %edi
  movl numbers(,%edi,4), %eax
  movl %eax, %ebx

loop_proc:
  cmp length, %edi
  je exit
  incl %edi
  movl numbers(,%edi,4), %eax
  cmp %ebx, %eax
  jge loop_proc
  movl %eax, %ebx
  jmp loop_proc

exit:
  movl $1, %eax
  int $0x80
