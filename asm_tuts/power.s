  .section .data

  .section .text

  .globl _start
_start:
  pushl $0        #Push the second argument (exp)
  pushl $2        #Push the first argument (base)
  call power

  addl $8, %esp

  # %eax stores the result
  movl %eax, %ebx
  movl $1, %eax     # Exit
  int $0x80

  .type power,@function
power:
  #Function Prologue
  pushl %ebp
  movl %esp, %ebp
  subl $4, %esp       #Make space for local variables

  #Shifting arguments to registers now
  movl 8(%ebp), %ebx   #ebx => base
  movl 12(%ebp), %ecx  #ecx => power

  cmpl $0, %ecx
  je zero_case
  movl %ebx, -4(%ebp)   #Store current result

zero_case:
  movl $1, -4(%ebp)
  jmp loop_exit

loop_start:
  cmpl $1, %ecx
  je loop_exit
  movl -4(%ebp), %eax
  imull %ebx, %eax
  movl %eax, -4(%ebp)
  decl %ecx
  jmp loop_start

loop_exit:
  movl -4(%ebp), %eax
  #Function Epilogue
  movl %ebp, %esp
  popl %ebp
  ret
