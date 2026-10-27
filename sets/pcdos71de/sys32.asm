; Transfer PC-DOS 7.1 to FAT32 without formatting. BIOS/CSM only.
; BIOS extended I/O on the first disk; DOS volume serial verifies the target.
; Supports C: on the first primary DOS partition of the first BIOS disk.
; The IBM boot code is read from BOOT32.BIN, extracted from FORMAT32.COM.
; nasm -f bin -o SYS32.COM sys32.asm
; Copyright (C) 2026 GeosOne. GNU GPL version 3.
cpu 386
org 100h
start:
    mov sp,stacktop
    mov bx,(stacktop-$$+100h+15)/16
    mov ah,4ah
    int 21h
    jc fail
    cld
    mov si,81h
.skip:
    lodsb
    cmp al,' '
    je .skip
    and al,0dfh
    cmp al,'C'
    jb fail
    cmp al,'C'
    jne fail
    mov [target],al
    sub al,'A'-1
    mov [drive],al
    mov ah,19h             ; never overwrite system files on the source drive
    int 21h
    cmp al,2
    je fail
    mov dx,template
    mov ax,3d00h
    int 21h
    jc fail
    mov bx,ax
    mov dx,bootcode
    mov cx,512
    mov ah,3fh
    int 21h
    jc fail
    cmp ax,512
    jne fail
    mov ah,3eh
    int 21h
    cmp word [bootcode+510],0aa55h
    jne fail
    ; Use BIOS I/O for the toolkit kernel, independent of Windows FAT32 APIs.
    ; Read the MBR through BIOS, then verify the partition by DOS serial.
    xor si,si
    call diskio
    jc fail
    mov bx,sector+446
    mov cx,4
.findpart:
    mov al,[bx+4]
    cmp al,0bh
    je .foundpart
    cmp al,0ch
    je .foundpart
    cmp al,1
    je .foundpart
    cmp al,4
    je .foundpart
    cmp al,6
    je .foundpart
    cmp al,0eh
    je .foundpart
    add bx,16
    loop .findpart
    jmp fail
.foundpart:
    mov eax,[bx+8]
    mov [partition],eax
    mov [packet+8],eax
    call diskio
    jc fail
    mov ax,6900h
    mov bl,3
    mov dx,volumeinfo
    int 21h
    jc fail
    mov eax,[volumeinfo+2]
    cmp word [sector+17],0
    je .fat32serial
    cmp eax,[sector+39]
    jne fail
    jmp sys16
.fat32serial:
    cmp eax,[sector+67]
    jne fail
    cmp word [sector+11],512
    jne fail
    cmp word [sector+17],0
    jne sys16
    cmp word [sector+22],0
    jne fail
    cmp word [sector+510],0aa55h
    jne fail
    mov si,names
.nextfile:
    cmp byte [si],0
    je installboot
    mov dx,si
    mov ax,3d00h
    int 21h
    jc fail
    mov [sourcehandle],ax
    push si
    mov di,target+3
.copyname:
    lodsb
    stosb
    or al,al
    jnz .copyname
    mov dx,target
    mov ax,4301h
    xor cx,cx
    int 21h
    mov ah,3ch
    xor cx,cx
    int 21h
    jc fail
    mov [desthandle],ax
.copy:
    mov bx,[sourcehandle]
    mov dx,buffer
    mov cx,4096
    mov ah,3fh
    int 21h
    jc fail
    or ax,ax
    jz .close
    mov cx,ax
    mov bx,[desthandle]
    mov ah,40h
    int 21h
    jc fail
    cmp ax,cx
    jne fail
    jmp .copy
.close:
    mov bx,[sourcehandle]
    mov ah,3eh
    int 21h
    mov bx,[desthandle]
    mov ah,3eh
    int 21h
    mov dx,target
    mov ax,4301h
    mov cx,7
    cmp byte [target+3],'C'
    jne .attr
    mov cx,20h
.attr:
    int 21h
    jc fail
    pop si
.skipname:
    lodsb
    or al,al
    jnz .skipname
    jmp .nextfile
installboot:
    ; Keep BPB and extended BPB (11..89), use IBM jump/OEM and code.
    mov si,bootcode
    mov di,sector
    mov cx,11
    rep movsb
    mov si,bootcode+90
    mov di,sector+90
    mov cx,422
    rep movsb
    mov byte [sector+64],80h
    mov ah,0dh
    int 21h
    mov si,1
    call diskio
    jc fail
    mov ax,[sector+50]       ; FAT32 backup boot sector (0/FFFF = none)
    or ax,ax
    jz .done
    cmp ax,0ffffh
    je .done
    cmp ax,[sector+14]
    jae fail
    movzx eax,ax
    add eax,[partition]
    mov [packet+8],eax
    mov si,1
    call diskio
    jc fail
.done:
    mov dx,ok
    mov ah,9
    int 21h
    mov ax,4c00h
    int 21h
fail:
    mov dx,error
    mov ah,9
    int 21h
    mov ax,4c01h
    int 21h
sys16:
    mov eax,[partition]
    mov [abs_partition],eax
    call abs_install
    mov ax,[2ch]
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
    mov si,sysname
    mov cx,8
    rep movsb
    mov ax,ds
    mov [execblock+4],ax
    mov [execblock+8],ax
    mov [execblock+12],ax
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
    call abs_remove
    cmp byte [execfailed],0
    jne fail
    mov ah,4dh
    int 21h
    mov ah,4ch
    int 21h
sysname: db 'SYS.COM',0
execpath: times 128 db 0
execblock: dw 0,sy16tail,0,5ch,0,6ch,0
sy16tail: db 6,' A: C:',13
savedsp: dw 0
savedss: dw 0
execfailed: db 0
diskio:
    pushad
    push ds
    push es
    mov ax,ds
    mov [packet+6],ax
    mov ax,4200h
    or si,si
    jz .read
    mov ax,4300h
.read:
    mov si,packet
    mov dl,80h
    int 13h
    pop es
    pop ds
    popad
    ret
partition: dd 0
volumeinfo: times 25 db 0
packet: db 10h,0
    dw 1
    dw sector,0
    dq 0
drive: db 0
sourcehandle: dw 0
desthandle: dw 0
template: db 'BOOT32.BIN',0
names: db 'IBMBIO.COM',0,'IBMDOS.COM',0,'COMMAND.COM',0,0
target: db 'C:\',0
    times 12 db 0
ok: db 'PC-DOS-Systemdateien uebertragen.',13,10,'$'
error: db 'SYS32: Systemuebertragung fehlgeschlagen (C: auf erster DOS-Partition erforderlich).',13,10,'$'
bootcode: times 512 db 0
sector: times 512 db 0
buffer: times 4096 db 0

%include "absdisk.inc"
    times 512 db 0
stacktop:
