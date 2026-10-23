; mouse-ps2.asm - Microsoft Mouse 11.0 MOUSE.EXE with BIOSes that take only
; 3-byte PS/2 packets (SeaBIOS: QEMU, many newer BIOSes; patch in set.psd1,
; at 3288h of MOUSE.EXE).  The driver initializes the PS/2 mouse with INT 15h
; C205h and packet size 1 (BH=1), which SeaBIOS refuses (AH=3, CF): "mouse
; not found".  The patch at 35E1h asks for packet size 3 (BH=3); then the
; BIOS calls the callback (C207h) once per packet with status, X and Y on
; the stack.  The callback, which collected one byte per call in [0F2h],
; [0F4h], [0F6h] (count in [0F8h]), now takes the whole packet and goes on
; with the packet code; the resync on timeouts and the re-init on hot plug
; (AA 00) are left out.  nasm -o mouse-ps2.bin mouse-ps2.asm
; Copyright (C) 2026 GeosOne.  GNU General Public License version 3.
bits 16
org 0x168                       ; offset in the resident segment (file 3120h)
  mov ax,[bp+0x0c]              ; status
  mov [0xf2],ax
  mov ax,[bp+0x0a]              ; X
  mov [0xf4],ax
  mov ax,[bp+0x08]              ; Y
  mov [0xf6],ax
  mov byte [0xf8],2             ; a whole packet
  jmp 0x1a7                     ; the packet code
  times 0x1a7-0x168-($-$$) nop
