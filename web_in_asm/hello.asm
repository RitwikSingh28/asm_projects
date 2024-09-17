format ELF64 executable

segment readable writable executable
entry main
main:
  ;Make a syscall for write, corresponding to int 1
  mov rax, 1    
  ;Provide the first argument in rdi, 1 -> stdout
  mov rdi, 1
  ;Provide the buffer contents in rsi
  mov rsi, msg
  ;Provide the size of the buffer in rdx
  mov rdx, 13
  ; The above configuration is equivalent to the UNIX call
  ; write(1, "Hello World!", 13)
  syscall

  ; Syscall to exit
  mov rax, 60
  ; Put the exit code in rdi
  mov rdi, 0
  syscall

segment readable writable
msg db "Hello World!", 10

