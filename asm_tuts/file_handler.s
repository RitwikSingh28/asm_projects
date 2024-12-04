  .section .data

  ########## CONSTANTS ########## 

  #syscall numbers
  .equ SYS_OPEN, 5
  .equ SYS_WRITE, 4
  .equ SYS_READ, 3
  .equ SYS_CLOSE, 6
  .equ SYS_EXIT, 1

  #options for opening files
  .equ O_RDONLY, 0
  .equ O_CREAT_WRONGLY_TRUNC, 03101

  #standard file descriptors
  .equ STDIN, 0
  .equ STDOUT, 1
  .equ STDERR, 2

  #syscall interrupt
  .equ LINUX_SYSCALL, 0x80

  .equ EOF, 0     #This is the return value of read, which means we've hit the end of file
  .equ NUM_ARGS, 2

  .section .bss
    .equ BUFFER_SIZE, 500
    .lcomm BUFFER_DATA, BUFFER_SIZE

  .section .text

  #STACK POSITIONS
  .equ ST_SIZE_RESERVE, 8
  .equ ST_FD_IN, -4
  .equ ST_FD_OUT, -8
  .equ ST_ARGC, 0       #Number of arguments
  .equ ST_ARGV_0, 4     #Name of the program
  .equ ST_ARGV_1, 8     #Input file name
  .equ ST_ARGV_2, 12    #Output file name

  .globl _start
_start:
  ### INITIALIZE THE PROGRAM ###
  # save the stack pointer
  movl %esp, %ebp

  #Allocate space for file descriptors on the stack
  subl $ST_SIZE_RESERVE, %esp

open_files:
open_fd_in:
  ## OPEN INPUT FILE ##
  # open syscall
  movl $SYS_OPEN, %eax
  # input file name first char address into %ebx
  movl ST_ARGV_1(%ebp), %ebx
  # read only flag
  movl $O_RDONLY, %ecx
  movl $0666, %edx      #not really necessary for reading
  int $LINUX_SYSCALL

store_fd_in:
  # save the given file descriptor
  movl %eax, ST_FD_IN(%ebp)

open_fd_out:
  ## OPEN OUTPUT FILE ##
  # open the file
  movl $SYS_OPEN, %eax
  # output filename into %ebx
  movl ST_ARGV_2(%ebp), %ebx
  # flags for writing to the file
  movl $O_CREAT_WRONGLY_TRUNC, %ecx
  # mode for new file (if it's created)
  movl $0666, %edx
  int $LINUX_SYSCALL

store_fd_out:
  # save the output file descriptor
  movl %eax, ST_FD_OUT(%ebp)

  ### BEGIN MAIN LOOP ###
read_loop_begin:

  ### READ IN A BLOCK FROM THE INPUT FILE ###
  movl $SYS_READ, %eax
  # get the input file descriptor
  movl ST_FD_IN(%ebp), %ebx
  # the location to read into
  movl $BUFFER_DATA, %ecx
  # the size of the buffer
  movl $BUFFER_SIZE, %edx
  int $LINUX_SYSCALL

  ### EXIT IF WE'VE REACHED EOF ###
  # check for end of file marker
  cmpl $EOF, %eax   # As size of buffer read is returned in %eax
  # if found, or on error, go to the end
  jle end_loop

continue_read_loop:
  ### CONVERT BLOCK TO UPPER CASE ###
  pushl $BUFFER_DATA      # location of the buffer
  pushl %eax              # size of the buffer
  call convert_to_upper

  popl %eax               # get the size back
  addl $4, %esp           # restore %esp

  ### WRITE THE BLOCK OUT TO THE OUTPUT FILE ###
  # size of the buffer
  movl %eax, %edx
  movl $SYS_WRITE, %eax
  # file to use
  movl ST_FD_OUT(%ebp), %ebx
  # location of the buffer
  movl $BUFFER_DATA, %ecx
  int $LINUX_SYSCALL

  ### CONTINUE THE LOOP ###
  jmp read_loop_begin

end_loop:
  ### CLOSE THE FILES ###
  # No error checking, because error conditions do not signify anything special here
  movl $SYS_CLOSE, %eax
  movl ST_FD_OUT(%ebp), %ebx
  int $LINUX_SYSCALL

  movl $SYS_CLOSE, %eax
  movl ST_FD_IN(%ebp), %ebx
  int $LINUX_SYSCALL

  ### EXIT ###
  movl $SYS_EXIT, %eax
  movl $0, %ebx
  int $LINUX_SYSCALL

  .equ LOWERCASE_A, 'a'   # The lower boundary of our search
  .equ LOWERCASE_Z, 'z'   # The upper boundary of our search
  .equ UPPER_CONVERSION, 'A' - 'a'

  ### STACK STUFF ###
  .equ ST_BUFFER_LEN, 8
  .equ ST_BUFFER, 12

convert_to_upper:
  ### FUNCTION PROLOGUE ###
  pushl %ebp
  movl %esp, %ebp

  ### SETTING UP VARS ###
  movl ST_BUFFER(%ebp), %eax
  movl ST_BUFFER_LEN(%ebp), %ebx
  movl $0, %edi

  # if buffer length == 0, just exit
  cmpl $0, %ebx
  je end_convert_loop

convert_loop:
  # get the current byte
  movb (%eax,%edi,1), %cl

  # go to next byte unless it is between 'a' and 'z'
  cmpb $LOWERCASE_A, %cl
  jl next_byte
  cmpb $LOWERCASE_Z, %cl
  jg next_byte

  # otherwise convert the byte to uppercase 
  addb $UPPER_CONVERSION, %cl
  movb %cl, (%eax,%edi,1)

next_byte:
  incl %edi
  cmpl %edi, %ebx
  jne convert_loop

end_convert_loop:
  ### FUNCTION EPILOGUE ###
  movl %ebp, %esp
  popl %ebp
  ret
