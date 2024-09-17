format ELF64 executable

; Defining the constants for the SYS_calls
SYS_write = 1
SYS_exit = 60
SYS_socket = 41

AF_INET = 2
SOCK_STREAM = 1

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

macro socket domain, type, protocol
{
  mov rax, SYS_socket
  mov rdi, domain
  mov rsi, type
  mov rdx, protocol
  syscall
  ; After the syscall, the fd of the socket is kept in rax
}

segment readable writable executable
entry main
main:
  write 1, start_msg, start_msg_len

  ; Let's create a TCP web socket
  socket AF_INET, SOCK_STREAM, 0
  mov dword [sockfd], eax ;; do the 32-bit write
  
  exit 0
  
;; db - 1 byte
;; dw - 2 bytes
;; dd - 4 bytes
;; dq - 8 bytes

segment readable writable
sockfd dd 0 
start_msg db "Starting web server!", 10
start_msg_len = $ - start_msg 
