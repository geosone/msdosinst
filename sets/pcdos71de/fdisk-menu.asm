; German interactive front end for IBM FDISK32 (no full-screen mode of its own).
; FDISK32 performs all partition operations. No disk I/O in this program.
; nasm -f bin -o FDISK.COM fdisk-menu.asm
; Copyright (C) 2026 GeosOne. GNU GPL version 3.
cpu 386
org 100h
start:
    mov sp,stacktop
    mov bx,(stacktop-$$+100h+15)/16
    mov ah,4ah
    int 21h
    jc error
    ; Locate sibling FDISK32.COM from the DOS 3+ program path in the environment.
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
    mov si,filename
    mov cx,12
    rep movsb
    mov ax,ds
    mov [execblock+4],ax
    mov [execblock+8],ax
    mov [execblock+12],ax
menu:
    mov ax,3
    int 10h
    mov dx,title
    call print
    mov dl,[drive]
    mov ah,2
    int 21h
    mov dx,choices
    call print
    call key
    cmp al,27
    je quit
    cmp al,'0'
    je quit
    cmp al,'1'
    je primary
    cmp al,'2'
    je extended
    cmp al,'3'
    je logical
    cmp al,'4'
    je status
    cmp al,'5'
    je selectdrive
    cmp al,'6'
    je mbr
    cmp al,'7'
    je deleteall
    jmp menu
primary:
    mov si,pri
    jmp sizeprompt
extended:
    mov si,ext
    jmp sizeprompt
logical:
    mov si,log
sizeprompt:
    push si
    mov dx,sizehelp
    call print
    mov dx,input
    mov ah,0ah
    int 21h
    pop si
    xor cx,cx
    mov cl,[input+1]
    or cx,cx
    jz menu
    ; Decimal megabytes, 1..99999999, passed unchanged to IBM FDISK32.
    mov di,input+2
    xor eax,eax
.check:
    mov bl,[di]
    cmp bl,'0'
    jb badsize
    cmp bl,'9'
    ja badsize
    imul eax,10
    movzx ebx,bl
    sub ebx,'0'
    add eax,ebx
    inc di
    loop .check
    or eax,eax
    jz badsize
    call begincmd
    call append
    mov si,input+2
    movzx cx,byte [input+1]
    rep movsb
    call endcmd
    call run
    call pause
    jmp menu
badsize:
    mov dx,invalid
    call print
    call pause
    jmp menu
status:
    mov di,tail+1
    mov si,stat
    call append
    call endcmd
    call run
    call pause
    jmp menu
selectdrive:
    mov dx,drivehelp
    call print
    call key
    cmp al,'1'
    jb menu
    cmp al,'8'
    ja menu
    mov [drive],al
    jmp menu
mbr:
    mov dx,mbrhelp
    call print
    call key
    cmp al,'j'
    je .yes
    cmp al,'J'
    jne menu
.yes:
    call begincmd
    mov si,mbrarg
    call append
    call endcmd
    call run
    call pause
    jmp menu
deleteall:
    mov dx,deletehelp
    call print
    mov dx,input
    mov ah,0ah
    int 21h
    cmp byte [input+1],8
    jne menu
    mov si,input+2
    mov di,confirmation
    mov cx,8
    repe cmpsb
    jne menu
    call begincmd
    mov si,deletearg
    call append
    call endcmd
    call run
    call pause
    jmp menu
quit:
    mov dx,exithelp
    call print
    mov ax,4c00h
    int 21h
begincmd:
    mov di,tail+1
    mov al,[drive]
    stosb
    mov al,' '
    stosb
    ret
append:
    lodsb
    or al,al
    jz .done
    stosb
    jmp append
.done:
    ret
endcmd:
    mov al,13
    stosb
    mov ax,di
    sub ax,tail+2
    mov [tail],al
    ret
run:
    mov dx,newline
    call print
    mov [savedsp],sp
    mov [savedss],ss
    mov dx,execpath
    mov bx,execblock
    mov ax,4b00h
    int 21h
    ; EXEC may destroy registers on older DOS versions.
    cli
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,[savedss]
    mov sp,[savedsp]
    sti
    jc error
    mov ah,4dh
    int 21h
    or al,al
    jz .done
    mov dx,failed
    call print
.done:
    ret
error:
    mov dx,execerror
    call print
    call pause
    mov ax,4c01h
    int 21h
print:
    mov ah,9
    int 21h
    ret
key:
    mov ah,8
    int 21h
    ret
pause:
    mov dx,continue
    call print
    call key
    ret
filename: db 'FDISK32.COM',0
execpath: times 128 db 0
execblock: dw 0,tail,0,5ch,0,6ch,0
savedsp: dw 0
savedss: dw 0
drive: db '1'
input: db 9,0
    times 10 db 0
tail: times 128 db 0
pri: db '/PRI:',0
ext: db '/EXT:',0
log: db '/LOG:',0
stat: db '/STATUS',0
mbrarg: db '/MBR',0
deletearg: db '/DELETE:ALL',0
confirmation: db 'LOESCHEN'
newline: db 13,10,'$'
title: db 'PC-DOS 7.1 - Festplatte einrichten (IBM FDISK32)',13,10
    db '================================================',13,10,13,10
    db 'Ausgewaehlte Festplatte: $'
choices: db 13,10,13,10
    db '  1. Primaere DOS-Partition erstellen',13,10
    db '  2. Erweiterte DOS-Partition erstellen',13,10
    db '  3. Logisches Laufwerk erstellen',13,10
    db '  4. Partitionen und freien Platz anzeigen',13,10
    db '  5. Andere Festplatte waehlen',13,10
    db '  6. Master Boot Record erneuern',13,10
    db '  7. Alle Partitionen der ausgewaehlten Platte loeschen',13,10,13,10
    db '  0 / Esc: Zum Setup zurueckkehren',13,10,13,10
    db 'Auswahl: $'
sizehelp: db 13,10,'Groesse in MB (z. B. 8192), Eingabe leer = Abbrechen: $'
invalid: db 13,10,'Bitte eine Zahl von 1 bis 99999999 MB eingeben.',13,10,'$'
drivehelp: db 13,10,'Festplattennummer 1 bis 8 (andere Taste = Abbrechen): $'
mbrhelp: db 13,10,'Bootcode der ausgewaehlten Platte erneuern? (J/N): $'
deletehelp: db 13,10,'ACHTUNG: ALLE Partitionen der gewaehlten Platte werden geloescht!',13,10
    db 'Zum Bestaetigen LOESCHEN eingeben, sonst Eingabe leer lassen: $'
exithelp: db 13,10,'Nach Aenderungen den Computer neu starten.',13,10,'$'
failed: db 13,10,'FDISK32 meldet einen Fehler. Bitte die Meldung oben beachten.',13,10,'$'
execerror: db 13,10,'FDISK32.COM konnte nicht gestartet werden.',13,10,'$'
continue: db 13,10,'Weiter mit beliebiger Taste...$'
    times 512 db 0
stacktop:
