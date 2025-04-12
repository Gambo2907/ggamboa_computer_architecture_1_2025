; bilinear.asm

SECTION .data
    in_filename     db 'quadrant.img', 0
    out_filename    db 'output.img', 0
    in_size         equ 10000         ; imagen de 100x100 bytes
    out_size        equ 40000         ; imagen de 200x200 bytes
    width           equ 100           ; ancho de la imagen de entrada
    out_width       equ 200           ; ancho de la imagen de salida
    scale_factor    equ 2             ; factor de escalado

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
    mov rdi, 0             ; rdi será nuestro contador externo: j (fila de salida)
outer_loop:
    cmp rdi, out_width     ; out_height = 200 (igual que out_width en esta imagen cuadrada)
    jge interpolation_done
    ; Calcular y0 = j >> 1
    mov rax, rdi
    shr rax, 1            ; rax = j/2
    ; Multiplicar y0 por el ancho de la imagen de entrada
    imul rax, width       ; rax = y0 * 100
    mov r14, rax          ; guardar el desplazamiento de la fila para la fila superior
    ; Obtener la bandera fraccional vertical: dy = j & 1 (0 si es par, 1 si es impar)
    mov r15, rdi
    and r15, 1            ; r15 = (j mod 2)
    
    mov rsi, 0            ; rsi será nuestro contador interno: i (columna de salida)
inner_loop:
    cmp rsi, out_width
    jge next_row
    ; Calcular x0 = i >> 1
    mov rcx, rsi
    shr rcx, 1          ; rcx = i/2 (x0)
    ; Obtener la bandera fraccional horizontal: dx = i & 1 (0 si es par, 1 si es impar)
    mov r8, rsi
    and r8, 1           ; r8 = (i mod 2)

    ; Calcular la dirección del píxel superior izquierdo (input[y0][x0])
  
    movzx r9, byte [input_buf + r14 + rcx]   ; r9 = píxel en (y0, x0)

    ; Comparar dx (r8) y dy (r15) para determinar la fórmula de interpolación a usar.
    cmp r8, 0
    jne dx_nonzero
    cmp r15, 0
    je case_even_even      ; dx==0, dy==0: píxel alineado
    jmp case_even_odd      ; dx==0, dy==1: interpolación vertical

dx_nonzero:
    cmp r15, 0
    je case_odd_even       ; dx==1, dy==0: interpolación horizontal
    jmp case_odd_odd       ; dx==1, dy==1: promedio bilineal

; Caso: x par y y par (sin interpolación)
case_even_even:
    ; r9 ya contiene el píxel; se copia en r10 para almacenarlo.
    mov r10, r9
    jmp store_output

; Caso: x par y y impar (interpolación vertical)
case_even_odd:
    ; Cargar el píxel directamente debajo: input[(y0+1)*width + x0]
    movzx r11, byte [input_buf + r14 + width + rcx]
    add r9, r11           ; sumar el píxel superior e inferior
    shr r9, 1             ; dividir entre 2
    mov r10, r9
    jmp store_output

; Caso: x impar y y par (interpolación horizontal)
case_odd_even:
    ; Cargar el píxel a la derecha: input[y0*width + x0+1]
    movzx r11, byte [input_buf + r14 + rcx + 1]
    add r9, r11           ; sumar el píxel izquierdo y derecho
    shr r9, 1             ; dividir entre 2
    mov r10, r9
    jmp store_output

; Caso: x impar y y impar (promedio de 4 píxeles circundantes)
case_odd_odd:
    ; r9 contiene el píxel superior izquierdo
    ; Sumar el píxel superior derecho: input[y0*width + x0+1]
    movzx r11, byte [input_buf + r14 + rcx + 1]
    add r9, r11
    ; Sumar el píxel inferior izquierdo: input[(y0+1)*width + x0]
    movzx r11, byte [input_buf + r14 + width + rcx]
    add r9, r11
    ; Sumar el píxel inferior derecho: input[(y0+1)*width + x0+1]
    movzx r11, byte [input_buf + r14 + width + rcx + 1]
    add r9, r11
    shr r9, 2             ; dividir la suma de 4 píxeles entre 4
    mov r10, r9

store_output:
    ; Calcular el índice en la imagen de salida: índice = j*out_width + i.
    mov rax, rdi
    imul rax, out_width   ; multiplicar j por 200
    add rax, rsi          ; sumar el índice de columna i
    ; Almacenar el píxel calculado en output_buf.
    mov byte [output_buf + rax], r10b

    inc rsi             ; siguiente columna (i++)
    jmp inner_loop

next_row:
    inc rdi             ; siguiente fila (j++)
    jmp outer_loop

interpolation_done:
    ; --- Escribir output_buf en el archivo de salida ---
    ; Abrir el archivo de salida con O_WRONLY | O_CREAT | O_TRUNC (flags 65) y modo 0644.
    mov rax, 2          ; sys_open
    mov rdi, out_filename
    mov rsi, 65         ; flags (O_WRONLY|O_CREAT|O_TRUNC)
    mov rdx, 420        ; modo 0644 (en decimal)
    syscall
    mov [fd_out], rax

    ; Escribir el buffer completo de salida (40000 bytes).
    mov rax, 1          ; sys_write
    mov rdi, [fd_out]
    mov rsi, output_buf
    mov rdx, out_size
    syscall

    ; --- Salir del programa ---
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall




