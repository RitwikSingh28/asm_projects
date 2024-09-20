format ELF64 executable

;; ==============================================================
;; Up next -> add routing by parsing the incoming request's route
;; ==============================================================

; Defining the constants for the SYS_calls
SYS_write equ 1
SYS_exit equ 60

SYS_socket equ 41
SYS_bind equ 49
SYS_listen equ 50
SYS_accept equ 43
SYS_close equ 3

AF_INET equ 2
SOCK_STREAM equ 1
INADDR_ANY equ 0
MAX_CONN equ 20

STDOUT equ 1
STDERR equ 2

EXIT_SUCCESS equ 1
EXIT_FAILURE equ 0

; writing the `write` syscall in C style using Macro Substitutions
macro write fd, buf, count
{
  ;; Make a syscall for write, corresponding to int 1
  ;; Provide the first argument in rdi, 1 -> stdout
  ;; Provide the buffer contents in rsi
  ;; Provide the size of the buffer in rdx
  ;; The above configuration is equivalent to the UNIX call
  ;; write(1, "Hello World!", 13)
  syscall3 SYS_write, fd, buf, count
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
  syscall3 SYS_socket, domain, type, protocol
  ; After the syscall, the fd of the socket is kept in rax
}

macro bind sockfd, addr, addr_len 
{
  syscall3 SYS_bind, sockfd, addr, addr_len
}

macro listen sockfd, backlog
{
  mov rax, SYS_listen
  mov rdi, sockfd
  mov rsi, backlog
  syscall
}

macro accept sockfd, addr, addr_len
{
  syscall3 SYS_accept, sockfd, addr, addr_len
}

macro close sockfd 
{
  mov rax, SYS_close
  mov rdi, sockfd
  syscall
}

macro print_ok
{
  write STDOUT, ok_msg, ok_msg_len
}

macro syscall3 number, a, b, c
{
  mov rax, number
  mov rdi, a
  mov rsi, b
  mov rdx, c
  syscall
}

;; Using fasm macro to generate structs
struc servaddr_in 
{
  .sin_family dw 0
  .port       dw 0 
  .sin_addr   dd 0 
  .sin_zero   dq 0 
}

segment readable writable executable
entry main
main:
  write STDOUT, start_msg, start_msg_len

  ; Let's create a TCP web socket
  write STDOUT, socket_trace_msg, socket_trace_msg_len
  socket AF_INET, SOCK_STREAM, 0
  cmp rax, 0 
  jl error
  mov qword [sockfd], rax ;; do the 32-bit write
  print_ok

  ;; Let's now bind a name to the socket
  ;; int bind(int sockfd, const struct sockaddr* addr, socklen_t addrlen)
  ;; Need to allocate memory for a struct and pass the ptr to the function

  mov word [servaddr.sin_family], AF_INET  ;; [] -> dereferences an address
  mov word [servaddr.port], 14619
  mov dword [servaddr.sin_addr], INADDR_ANY

  write STDOUT, bind_trace_msg, bind_trace_msg_len
  bind [sockfd], servaddr.sin_family, sizeof_servaddr_in
  cmp rax, 0
  jl error
  print_ok

  ;; Time to listen to the socket
  write STDOUT, listen_trace_msg, listen_trace_msg_len
  listen [sockfd], MAX_CONN
  cmp rax, 0
  jl error

next_req:
  ;; Accepting any connections to the server
  write STDOUT, accept_trace_msg, accept_trace_msg_len
  accept [sockfd], cliaddr.sin_family, cliaddr_len
  cmp rax, 0
  jl error

  mov qword [connfd], rax
  write [connfd], response, response_len
  jmp next_req

  close [connfd]
  close [sockfd]

  exit EXIT_SUCCESS
  
error:
  write STDERR, error_msg, error_msg_len 
  close [sockfd]
  exit EXIT_FAILURE

;; db - 1 byte
;; dw - 2 bytes
;; dd - 4 bytes
;; dq - 8 bytes

segment readable writable

;; Required structure for bind
;; struct sockaddr_in {
;;   sa_family_t sin_family; -> 16 bits
;;   in_port_t sin_port; -> 16 bits
;;   struct in_addr sin_addr; -> 32 bits int
;;   uint8_t sin_zero[8]; -> 64 bits

sockfd dq -1 
connfd dq -1 
servaddr servaddr_in
sizeof_servaddr_in = $ - servaddr.sin_family
cliaddr servaddr_in
cliaddr_len dd sizeof_servaddr_in

hello_msg db "Hello There!!", 10
hello_msg_len = $ - hello_msg 

response db "HTTP/1.1 200 OK", 13, 10
         db "Content-Type: text/html; charset=utf-8", 13, 10
         db "Connection: close", 13, 10
         db 13, 10 
         db "<h1>Hello there, LinkedIn! Greetings from Flat Assembler!</h1>", 10
response_len = $ - response 
  
start_msg db "INFO: Starting web server!", 10
start_msg_len = $ - start_msg 
socket_trace_msg db "INFO: Creating a socket...", 10
socket_trace_msg_len = $ - socket_trace_msg
bind_trace_msg db "INFO: Binding the socket...", 10
bind_trace_msg_len = $ - bind_trace_msg
listen_trace_msg db "INFO: Listening at the port...", 10
listen_trace_msg_len = $ - listen_trace_msg
accept_trace_msg db "INFO: Waiting for connections...", 10
accept_trace_msg_len = $ - accept_trace_msg 
ok_msg db "INFO: OK!!", 10
ok_msg_len = $ - ok_msg
error_msg db "Error starting the server!", 10
error_msg_len = $ - error_msg
