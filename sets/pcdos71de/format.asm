; Dispatch to the original German FORMAT16 or IBM FORMAT32 by partition type.
; C: is the first primary DOS partition on BIOS disk 80h. A:/B: use FORMAT16.
; No disk writes here: the selected IBM formatter performs the operation.
; Copyright (C) 2026 GeosOne. GNU GPL version 3.
cpu 386
org 100h
start:
    mov sp,stacktop
    mov bx,(stacktop-$$+100h+15)/16
    mov ah,4ah
    int 21h
    jc error
    mov si,81h
.spaces:
    lodsb
    cmp al,' '
    je .spaces
    and al,0dfh
    mov bx,format16
    cmp al,'/'
    je selected
    cmp al,13
    je selected
    cmp al,'A'
    je selected
    cmp al,'B'
    je selected
    cmp al,'C'
    jne error
    mov ax,ds
    mov [packet+6],ax
    mov si,packet
    mov dl,80h
    mov ax,4200h
    int 13h
    jc error
    mov si,sector+446
    mov cx,4
.find:
    mov al,[si+4]
    cmp al,0bh
    je fat32
    cmp al,0ch
    je fat32
    cmp al,1
    je fat16
    cmp al,4
    je fat16
    cmp al,6
    je fat16
    cmp al,0eh
    je fat16
    add si,16
    loop .find
    jmp error
fat16:
    mov eax,[si+8]
    mov [abs_partition],eax
    mov byte [hook],1
    mov bx,format16
    jmp selected
fat32:
    mov bx,format32
    mov byte [quick],1
selected:
    mov [toolname],bx
    mov si,81h
    mov di,tail+1
    movzx cx,byte [80h]
    cmp cx,118
    ja error
    rep movsb
    cmp byte [quick],0
    je .endtail
    mov ax,2f20h
    stosw
    mov al,'Q'
    stosb
.endtail:
    mov ax,di
    sub ax,tail+1
    mov [tail],al
    mov al,13
    stosb
    ; DOS records the full executable name after the environment strings.
    mov ax,[2ch]
    or ax,ax
    jz .fallback
    push ds
    mov ds,ax
    xor si,si
.env:
    lodsb
    or al,al
    jnz .env
    cmp byte [si],0
    jne .env
    add si,3
    mov di,execpath
    mov bx,di
    mov cx,100
.path:
    lodsb
    or al,al
    jz .pathdone
    stosb
    cmp al,'\'
    jne .next
    mov bx,di
.next:
    loop .path
.pathdone:
    mov di,bx
    pop ds
    jmp .filename
.fallback:
    mov di,execpath
.filename:
    mov si,[toolname]
    mov cx,13
    rep movsb
    mov ax,ds
    mov [execblock+4],ax
    mov [execblock+8],ax
    mov [execblock+12],ax
    cmp byte [hook],0
    je .nohook
    call abs_install
.nohook:
    mov [savedsp],sp
    mov [savedss],ss
    mov dx,execpath
    mov bx,execblock
    mov ax,4b00h
    int 21h
    cli
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,[savedss]
    mov sp,[savedsp]
    sti
    setc [execfailed]
    cmp byte [hook],0
    je .noremove
    call abs_remove
.noremove:
    cmp byte [execfailed],0
    jne error
    mov ah,4dh
    int 21h
    mov ah,4ch
    int 21h
error:
    mov dx,message
    mov ah,9
    int 21h
    mov ax,4c01h
    int 21h
format16: db 'FORMAT16.COM',0
format32: db 'FORMAT32.COM',0
toolname: dw 0
quick: db 0
hook: db 0
execfailed: db 0
savedsp: dw 0
savedss: dw 0
execblock: dw 0,tail,0,5ch,0,6ch,0
execpath: times 128 db 0
tail: times 128 db 0
packet: db 10h,0
    dw 1
    dw sector,0
    dq 0
sector: times 512 db 0
message: db 'FORMAT: Aufruf fehlgeschlagen. Unterstuetzt: A:, B:, C: auf der ersten',13,10
    db 'primaeren DOS-Partition der ersten BIOS-Festplatte.',13,10,'$'
%include "absdisk.inc"
    times 512 db 0
stacktop:
