format ELF64 executable

; Defining the constants for the SYS_calls
  SYS_write = 1
  SYS_exit = 60

; writing the `write` syscall in C style using Macro Substitutions
macro write fd, buf, count
{
  ;Make a syscall for write, corresponding to int 1
  mov rax, SYS_write    
  ;Provide the first argument in rdi, 1 -> stdout
  mov rdi, fd
  ;Provide the buffer contents in rsi
  mov rsi, buf
  ;Provide the size of the buffer in rdx
  mov rdx, count
  ; The above configuration is equivalent to the UNIX call
  ; write(1, "Hello World!", 13)
  syscall
}

; writing the `exit` syscall 
macro exit code
{
  mov rax, SYS_exit
  ; Put the exit code in rdi
  mov rdi, code
  syscall
}

segment readable writable executable
entry main
main:
  write 1, msg, msg_len
  exit 0
  
segment readable writable
msg db "Hello World!", 10
msg_len = $ - msg 
