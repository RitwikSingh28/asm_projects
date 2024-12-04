  .section .data

  .section .text

  .globl _start
_start:
  pushl $5
  call fact

  #%eax stores the result
  movl %eax, %ebx
  movl $1, %eax
  int $0x80

  .type fact,%function
fact:
  #Function Prologue
  pushl %ebp
  movl %esp, %ebp

  #Move the variables into registers
  movl 8(%ebp), %eax

  cmp $1, %eax
  je return

  decl %eax
  pushl %eax
  call fact     #stores the result in %eax

  popl %edx

  movl 8(%ebp), %ebx
  imull %ebx, %eax

return:
  movl %ebp, %esp
  popl %ebp
  ret
