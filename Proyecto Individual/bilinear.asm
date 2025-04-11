; bilinear.asm
; Ejemplo de interpolación bilineal en x86-64 Assembly para Linux
; Lee un archivo "quadrant.img" de 100x100 (1 byte/píxel en escala de grises)
; y escribe un archivo "output.img" de 200x200 usando interpolación bilineal.
; Se usa openat (syscall 257) para abrir archivos.


SECTION .data
    in_filename     db 'quadrant.img', 0
    out_filename    db 'output.img', 0

    width_in        equ 100
    height_in       equ 100
    width_out       equ 200
    height_out      equ 200

    ; Factores de escala: (width_in-1)/(width_out-1) y lo mismo para Y.
    factor_x        dd 0.497487    ; en punto flotante
    factor_y        dd 0.497487

SECTION .bss
    in_buffer   resb width_in*height_in   ; 10000 bytes
    out_buffer  resb width_out*height_out ; 40000 bytes

SECTION .text
global _start

_start:
    ; ----------------------------------
    ; Abrir archivo de entrada (quadrant.img)
    ; Usamos openat (syscall 257)
    ; Argumentos:
    ;   rdi = AT_FDCWD (-100)
    ;   rsi = dirección del nombre del archivo
    ;   rdx = flags (0: O_RDONLY)
    ;   r10 = mode (0, no se usa en lectura)
    ; ----------------------------------
    mov     rax, 257         ; sys_openat
    mov     rdi, -100        ; AT_FDCWD
    lea     rsi, [rel in_filename]
    mov     rdx, 0           ; O_RDONLY
    mov     r10, 0
    syscall
    cmp     rax, 0
    js      error_exit
    mov     r12, rax         ; guardar fd de entrada en r12

    ; ----------------------------------
    ; Leer el archivo en in_buffer
    ; Sys_read: syscall 0
    ; rdi = fd, rsi = buffer, rdx = cantidad de bytes
    ; ----------------------------------
    mov     rax, 0           ; sys_read
    mov     rdi, r12
    lea     rsi, [rel in_buffer]
    mov     rdx, width_in * height_in  ; 100 * 100 = 10000 bytes
    syscall

    ; Cerrar archivo de entrada (sys_close: syscall 3)
    mov     rax, 3
    mov     rdi, r12
    syscall

    ; ----------------------------------
    ; Interpolación bilineal: recorrer cada píxel de la imagen de salida.
    ; Usamos:
    ;   rcx = y_out
    ;   rdx = x_out
    ; Se calcula para cada píxel:
    ;   src_x = x_out * factor_x
    ;   src_y = y_out * factor_y
    ; Y se deben extraer:
    ;   x0 = floor(src_x), dx = src_x - x0
    ;   y0 = floor(src_y), dy = src_y - y0
    ;
    ; Se utilizarán los 4 píxeles vecinos (p00, p10, p01, p11) para calcular:
    ;   pixel = p00*(1-dx)*(1-dy) + p10*(dx)*(1-dy) +
    ;           p01*(1-dx)*(dy)   + p11*(dx)*(dy)
    ;
    ; En este ejemplo se llama a la subrutina 'bilinear_pixel' (stub) que
    ; debería implementar estas operaciones con la FPU.
    ; Se pasa como parámetros (por la pila) x_out, y_out, in_buffer y out_buffer.
    ; ----------------------------------
    xor     rcx, rcx        ; y_out = 0

interp_y_loop:
    cmp     rcx, height_out
    jge     write_output

    xor     rdx, rdx        ; x_out = 0

interp_x_loop:
    cmp     rdx, width_out
    jge     next_line

    ; Guardar x_out (rdx) y y_out (rcx) en r8 y r9 para calcular el offset después
    mov     r8, rdx         ; r8 = x_out
    mov     r9, rcx         ; r9 = y_out

    ; -----------------------------
    ; Llamar a la subrutina bilinear_pixel (stub)
    ; Se pasan 4 parámetros (cada uno de 8 bytes):
    ;   [rsp+0] : x_out
    ;   [rsp+8] : y_out
    ;   [rsp+16]: in_buffer (puntero)
    ;   [rsp+24]: out_buffer (puntero)
    ; -----------------------------
    push    r8              ; x_out
    push    r9              ; y_out
    push    qword in_buffer
    push    qword out_buffer

    call    bilinear_pixel
    ; Se espera que bilinear_pixel devuelva el pixel resultante en al

    ; Limpiar la pila (se empujaron 4 qwords = 32 bytes)
    add     rsp, 32

    ; Calcular el offset en el buffer de salida:
    ; offset = y_out * width_out + x_out
    mov     rax, r9
    imul    rax, width_out  ; rax = r9 * width_out
    add     rax, r8         ; rax = offset

    ; Escribir el pixel (almacenado en al) en el out_buffer
    lea     rbx, [rel out_buffer]
    mov     byte [rbx + rax], al

    inc     rdx
    jmp     interp_x_loop

next_line:
    inc     rcx
    jmp     interp_y_loop

    ; ----------------------------------
    ; Escribir el buffer de salida en el archivo de salida.
    ; Usamos openat para crear/abrir el archivo en modo escritura:
    ;   rdi = AT_FDCWD (-100)
    ;   rsi = dirección del nombre del archivo
    ;   rdx = flags (O_WRONLY|O_CREAT|O_TRUNC = 1+64+512 = 577)
    ;   r10 = mode (0644 = 420 decimal)
    ; ----------------------------------
write_output:
    mov     rax, 257
    mov     rdi, -100
    lea     rsi, [rel out_filename]
    mov     rdx, 577         ; 577 = 1 | 64 | 512
    mov     r10, 420         ; permisos 0644
    syscall
    cmp     rax, 0
    js      error_exit
    mov     r12, rax         ; guardar fd de salida en r12

    ; Escribir el buffer (40000 bytes)
    mov     rax, 1           ; sys_write
    mov     rdi, r12         ; fd de salida
    lea     rsi, [rel out_buffer]
    mov     rdx, width_out * height_out  ; 200 * 200 = 40000
    syscall

    ; Cerrar archivo de salida
    mov     rax, 3           ; sys_close
    mov     rdi, r12
    syscall

    ; Salir del programa (sys_exit: syscall 60)
    mov     rax, 60
    xor     rdi, rdi
    syscall

error_exit:
    mov     rax, 60
    mov     rdi, 1
    syscall

; -----------------------------------------------------------
; Subrutina: bilinear_pixel (Stub)
; Recibe los siguientes parámetros en la pila (cada uno de 8 bytes):
;   [rsp + 0]  : x_out (coordenada de salida, entero)
;   [rsp + 8]  : y_out (coordenada de salida, entero)
;   [rsp + 16] : in_buffer (puntero a la imagen original)
;   [rsp + 24] : out_buffer (puntero a la imagen de salida, no usado en esta rutina)
;
; Objetivo: Convertir (x_out, y_out) a coordenadas en la imagen de entrada y
; aplicar interpolación bilineal.
; En este ejemplo la implementación se omite y se retorna siempre 0.
;
; Se espera que el resultado (byte interpolado) se retorne en AL.
; -----------------------------------------------------------
bilinear_pixel:
    ; Aquí debería implementarse la conversión a punto flotante y el uso
    ; de las instrucciones de la FPU (FLD, FMUL, FSUB, FISTP/FISTTP, etc.) para
    ; realizar el cálculo bilineal.
    ;
    ; Por ahora se devuelve un valor cero (negro).
    mov     al, 0
    ret

