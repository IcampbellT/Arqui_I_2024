section .data
    buffer_size equ 2048
    filename db 'estudiantes.txt', 0
    buffer db buffer_size dup(0)
    array_size equ 2048

section .bss
	array resq array_size

section .text
    global _start

_start:
    ; Open the file
    mov rdi, filename
    mov rsi, 0 ; O_RDONLY mode
    mov rax, 2 ; sys_open syscall number
    syscall

    ; Check for errors in opening the file
    test rax, rax
    js error_handling

    ; Read from the file into the buffer
    mov rdi, rax ; file descriptor
    mov rsi, buffer
    mov rdx, buffer_size
    mov rax, 0 ; sys_read syscall number
    syscall

    ; Check for errors in reading from the file
    test rax, rax
    js error_handling

    ; Close the file
    mov rdi, rax ; file descriptor
    mov rax, 3 ; sys_close syscall number
    syscall

    ; Parse the buffer into lines and store them in the array
    mov rcx, 0 ; array index
parse_loop:
    lea rsi, [buffer + rcx*8] ; address of current line in buffer
    mov qword [array + rcx*8], rsi ; store address in array
    
    inc rcx
    
    cmp rcx, array_size
    jge print_array
    
    jmp parse_loop

print_array:
    mov rcx, 0 ; reset array index for printing loop
    
print_loop:
    mov rsi, [array + rcx*8] ; get address of current line from array
    
        ; Print the line (example: using write syscall)
    mov rdi, 1          ; file descriptor 1 (stdout)
    mov rdx, buffer_size ; length of the line to print
    mov rax, 1          ; sys_write syscall number
    syscall

    inc rcx

    cmp rcx, array_size
    jl print_loop

exit_program:
    ; Exit the program
    mov rax, 60         ; sys_exit syscall number
    xor rdi, rdi        ; exit code 0
    syscall

error_handling:
    ; Handle error here (for example, print error message and exit)
