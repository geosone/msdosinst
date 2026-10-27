; Adapter for the PC-DOS 2000 FAT16 tools on the 7.1 kernel. Their legacy
; absolute sector calls fail under the toolkit kernel. Translate C: only to
; BIOS extended sector I/O on the already selected primary DOS partition.
; All other drives chain to DOS. Installed only while the IBM child runs.
; Copyright (C) 2026 GeosOne. GNU GPL version 3.
abs_install:
    mov ax,3525h
    int 21h
    mov [abs_old25],bx
    mov [abs_old25+2],es
    mov ax,3526h
    int 21h
    mov [abs_old26],bx
    mov [abs_old26+2],es
    mov dx,abs_read
    mov ax,2525h
    int 21h
    mov dx,abs_write
    mov ax,2526h
    int 21h
    push ds
    pop es
    ret
abs_remove:
    push ds
    lds dx,[abs_old25]
    mov ax,2525h
    int 21h
    pop ds
    push ds
    lds dx,[abs_old26]
    mov ax,2526h
    int 21h
    pop ds
    push ds
    pop es
    ret
abs_read:
    cmp al,2
    je .ours
    jmp far [cs:abs_old25]
.ours:
    mov byte [cs:abs_function],42h
    jmp abs_io
abs_write:
    cmp al,2
    je .ours
    jmp far [cs:abs_old26]
.ours:
    mov byte [cs:abs_function],43h
abs_io:
    pushad
    push ds
    push es
    push ds
    pop es
    push cs
    pop ds
    mov [abs_dap+4],bx
    mov ax,es
    mov [abs_dap+6],ax
    movzx eax,dx
    cmp cx,0ffffh
    jne .legacy
    mov eax,[es:bx]
    mov cx,[es:bx+4]
    mov edx,[es:bx+6]
    mov [abs_dap+4],edx
.legacy:
    add eax,[abs_partition]
    mov [abs_dap+8],eax
    mov [abs_left],cx
    mov byte [abs_status],0
    sti
.next:
    cmp word [abs_left],0
    je .done
    mov si,abs_dap
    mov ah,[abs_function]
    xor al,al
    mov dl,80h
    push ds
    push es
    int 13h
    pop es
    pop ds
    jc .error
    inc dword [abs_dap+8]
    add word [abs_dap+4],512
    jnc .nowrap
    add word [abs_dap+6],1000h
.nowrap:
    dec word [abs_left]
    jmp .next
.error:
    mov byte [abs_status],1
.done:
    pop es
    pop ds
    popad
    cmp byte [cs:abs_status],0
    jne .failed
    clc
    retf                        ; INT 25/26 leave original flags on the stack
.failed:
    mov ax,0207h
    stc
    retf
abs_old25: dd 0
abs_old26: dd 0
abs_partition: dd 0
abs_left: dw 0
abs_function: db 0
abs_status: db 0
abs_dap: db 10h,0
    dw 1
    dd 0
    dq 0
