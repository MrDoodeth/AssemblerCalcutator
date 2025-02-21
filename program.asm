global _start

section .rodata
    startMessage db "===== +-*/Calculator/*-+ =====", 10
    startMessageLength equ $ - startMessage

    firstVarMessage db "Enter first variable: "
    firstVarMessageLength equ $ - firstVarMessage

    operationSignMessage db "Enter operation (+ - * /): "
    operationSignMessageLength equ $ - operationSignMessage

    secondVarMessage db "Enter second variable: "
    secondVarMessageLength equ $ - secondVarMessage

    resultMessage db "Result: "
    resultMessageLength equ $ - resultMessage

    invalidInputMessage db "Invalid input", 10
    invalidInputMessageLength equ $ - invalidInputMessage

    newLine db 10

section .bss
    bufferSize equ 64
    var1 resb bufferSize
    var2 resb bufferSize
    num1 resq 1
    num2 resq 1
    operationSign resb bufferSize
    answer resb bufferSize
    answerNum resq 1

section .text
_start:
    mov rsi, startMessage
    mov rdx, startMessageLength
    call print

    mov rsi, firstVarMessage
    mov rdx, firstVarMessageLength
    call print

    mov rsi, var1
    mov rdx, bufferSize
    call read

    mov rsi, operationSignMessage
    mov rdx, operationSignMessageLength
    call print

    mov rsi, operationSign
    mov rdx, bufferSize
    call read

    mov rsi, secondVarMessage
    mov rdx, secondVarMessageLength
    call print

    mov rsi, var2
    mov rdx, bufferSize
    call read

    mov rbx, var1
    xor rcx, rcx
    xor rax, rax
    mov r8, 1
    call validateAndConvert
    mov qword [num1], rax

    mov rbx, var2
    xor rcx, rcx
    xor rax, rax
    mov r8, 1
    call validateAndConvert
    mov qword [num2], rax

    movzx rax, byte [operationSign]
    call validateOperation

done:
    mov rsi, resultMessage
    mov rdx, resultMessageLength
    call print

    mov rax, qword [answerNum]
    call intToString

    mov rbx, rax
    mov rdi, rax
    call strlen

    mov rdx, rax
    mov rsi, rbx
    call print

    mov rsi, newLine
    mov rdx, 1
    call print

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

print:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

read:
    mov rax, 0
    mov rdi, 0
    syscall
    ret

validateAndConvert:
    movzx rdx, byte [rbx + rcx]

    cmp rdx, 10
    je localExit

    cmp rdx, '-'
    je handleNegative

    cmp rdx, '0'
    jl invalidInput

    cmp rdx, '9'
    jg invalidInput

    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rcx
    jmp validateAndConvert

localExit:
    cmp rcx, 0
    je handleNull

    imul rax, r8
    ret

handleNegative:
    cmp rcx, 0
    jne invalidInput
    mov r8, -1
    inc rcx
    jmp validateAndConvert

handleNull:
    xor rax, rax
    ret

invalidInput:
    mov rsi, invalidInputMessage
    mov rdx, invalidInputMessageLength
    call print
    jmp exit

validateOperation:
    cmp rax, '+'
    je sum

    cmp rax, '-'
    je subtract

    cmp rax, '*'
    je multiply

    cmp rax, '/'
    je divide

    jmp invalidInput

sum:
    mov rax, qword [num1]
    add rax, qword [num2]
    mov qword [answerNum], rax
    jmp done

subtract:
    mov rax, qword [num1]
    sub rax, qword [num2]
    mov qword [answerNum], rax
    jmp done

multiply:
    mov rax, qword [num1]
    imul rax, qword [num2]
    mov qword [answerNum], rax
    jmp done

divide:
    mov rax, qword [num1]
    xor rdx, rdx
    mov rcx, qword [num2]
    cmp rcx, 0
    je invalidInput
    idiv rcx
    mov qword [answerNum], rax
    jmp done

intToString:
    mov rbx, answer + bufferSize - 1
    mov byte [rbx], 0
    mov rcx, 10
    mov r8, 0
    cmp rax, 0
    jge .convert
    mov r8, 1
    neg rax
.convert:
    cmp rax, 0
    jne .loop
    dec rbx
    mov byte [rbx], '0'
    jmp .done
.loop:
    dec rbx
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rbx], dl
    cmp rax, 0
    jne .loop
.done:
    cmp r8, 1
    jne .finish
    dec rbx
    mov byte [rbx], '-'
.finish:
    mov rax, rbx
    ret

strlen:
    xor rax, rax
.str_loop:
    cmp byte [rdi+rax], 0
    je .done
    inc rax
    jmp .str_loop
.done:
    ret