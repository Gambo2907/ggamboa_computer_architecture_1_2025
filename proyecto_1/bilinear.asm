; bilinear.asm modificado para salida 400x400
SECTION .data
    in_filename     db 'quadrant.img', 0
    out_filename    db 'output.img', 0
    in_size         equ 10000         ; imagen de 100x100 bytes
    out_size        equ 160000        ; imagen de 400x400 bytes
    width           equ 100           ; ancho de la imagen de entrada
    out_width       equ 400           ; ancho de la imagen de salida
    scale_factor    equ 4             ; factor de escalado

SECTION .bss
    input_buf       resb in_size  
    output_buf      resb out_size    
    fd_in           resq 1           
    fd_out          resq 1           

SECTION .text
global _start

_start:
    ; --- Abrir el archivo de entrada (quadrant.img) para lectura ---
    mov rax, 2                 ; sys_open
    mov rdi, in_filename
    mov rsi, 0                 ; O_RDONLY
    syscall
    mov [fd_in], rax

    ; --- Leer el archivo completo en input_buf ---
    mov rax, 0                 ; sys_read
    mov rdi, [fd_in]
    mov rsi, input_buf
    mov rdx, in_size
    syscall

    ; --- Interpolación bilineal para escalar la imagen ---
    ; Se recorre cada píxel de la imagen de salida (400x400)
    mov rdi, 0               ; rdi = j (contador de filas de salida)
outer_loop:
    cmp rdi, out_width       ; out_width = 400 (imagen cuadrada)
    jge interpolation_done
    ; Calcular la fila de la imagen de entrada: y0 = j >> 2 (división entera)
    mov rax, rdi
    shr rax, 2              ; y0 = j/4
    imul rax, width         ; rax = y0 * 100
    mov r14, rax            ; r14 = base de la fila superior (top row)
    ; Obtener la componente fraccional vertical: dy = j & 3
    mov r15, rdi
    and r15, 3              ; r15 = dy

    mov rsi, 0              ; rsi = i (contador de columnas de salida)
inner_loop:
    cmp rsi, out_width
    jge next_row
    ; Calcular la columna de la imagen de entrada: x0 = i >> 2
    mov rcx, rsi
    shr rcx, 2              ; x0 = i/4
    ; Obtener la componente fraccional horizontal: dx = i & 3
    mov r8, rsi
    and r8, 3               ; r8 = dx

    ; Cargar los 4 píxeles vecinos de la imagen de entrada:
    ; A = top-left, B = top-right, C = bottom-left, D = bottom-right
    movzx r9, byte [input_buf + r14 + rcx]          ; A
    movzx r10, byte [input_buf + r14 + rcx + 1]       ; B
    movzx r11, byte [input_buf + r14 + width + rcx]   ; C
    movzx r12, byte [input_buf + r14 + width + rcx + 1] ; D

    ; --- Interpolación horizontal en la fila superior ---
    ; top = (4 - dx)*A + dx*B
    mov rbx, 4
    sub rbx, r8             ; rbx = (4 - dx)
    mov rax, r9
    imul rax, rbx           ; A*(4-dx) en rax
    mov rbx, r8             ; rbx = dx
    mov rdx, r10
    imul rdx, rbx           ; B*dx en rdx
    add rax, rdx            ; rax = top

    ; --- Interpolación horizontal en la fila inferior ---
    ; bottom = (4 - dx)*C + dx*D
    mov rbx, 4
    sub rbx, r8             ; rbx = (4 - dx)
    mov rdx, r11
    imul rdx, rbx           ; C*(4-dx) en rdx
    mov rbx, r8             ; rbx = dx
    mov rcx, r12
    imul rcx, rbx           ; D*dx en rcx
    add rdx, rcx            ; rdx = bottom

    ; --- Interpolación vertical ---
    ; píxel = ((4 - dy)*top + dy*bottom) / 16
    mov rcx, 4
    sub rcx, r15            ; rcx = (4 - dy)
    imul rax, rcx           ; top * (4-dy) (resultado en rax)
    mov rcx, r15
    imul rdx, rcx           ; bottom * dy (resultado en rdx)
    add rax, rdx            ; suma total en rax
    shr rax, 4              ; división por 16 (resultado final en rax)

    ; --- Almacenar el píxel interpolado en output_buf ---
    mov rdx, rdi
    imul rdx, out_width     ; rdx = j * 400
    add rdx, rsi            ; rdx = j*400 + i (índice de salida)
    mov byte [output_buf + rdx], al

    inc rsi                 ; siguiente columna
    jmp inner_loop

next_row:
    inc rdi                 ; siguiente fila
    jmp outer_loop

interpolation_done:
    ; --- Escribir output_buf en el archivo de salida ---
    ; Abrir el archivo de salida con O_WRONLY|O_CREAT|O_TRUNC (flags 65) y modo 0644.
    mov rax, 2              ; sys_open
    mov rdi, out_filename
    mov rsi, 65             ; flags
    mov rdx, 420            ; modo 0644 (en decimal)
    syscall
    mov [fd_out], rax

    ; Escribir el buffer completo de salida (160000 bytes).
    mov rax, 1              ; sys_write
    mov rdi, [fd_out]
    mov rsi, output_buf
    mov rdx, out_size
    syscall

    ; --- Salir del programa ---
    mov rax, 60             ; sys_exit
    xor rdi, rdi
    syscall

