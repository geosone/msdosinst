; format-s.asm - FORMAT /S of Windows ME (patch in set.psd1, at 83C4h of
; FORMAT.COM): runs "%COMSPEC% /C SYS x:" in place of the copy of the
; system files, which Windows ME no longer reads.  nasm -o format-s.bin format-s.asm
; Copyright (C) 2026 GeosOne.  GNU General Public License version 3.
bits 16
org 0x84c4-0x5640               ; offset of the routine in the code segment
sysa:
  pusha
  push ds
  push es
  mov al,[0x316f]               ; drive letter of the formatted disk
  mov [cs:tail+9],al
  mov es,[0x2721]               ; PSP
  mov es,[es:0x2c]              ; environment
  xor di,di
  push cs
  pop ds
.find:
  cmp byte [es:di],0
  je .done
  mov si,var
  mov cx,8
  repe cmpsb
  je .found
  dec di
  xor al,al
  mov cx,-1
  repne scasb
  jmp .find
.found:
  mov [blk+4],cs
  mov [blk+8],cs
  mov [blk+12],cs
  push es
  pop ds
  mov dx,di                     ; DS:DX = value of COMSPEC
  push cs
  pop es
  mov bx,blk
  mov ax,0x4b00
  int 0x21
.done:
  pop es
  pop ds
  popa
  clc
  ret
var db 'COMSPEC='
tail db 10,' /C SYS A:',13
blk dw 0, tail, 0, var, 0, var, 0
