# Where the files of the MS-DOS 7.1 disk set come from

**The set no longer uses these disks.** It now takes every file from the original media itself: the MS-DOS programs of the Windows ME CD (patched: version check, FDISK/FORMAT for large disks), `SYS.COM`, `KEYB.COM`, `NLSFUNC.EXE`, `EXT.EXE`, `IO.SYS` and `COMMAND.COM` of the Windows 98 SE CD, and the rest of the MS-DOS 6.22 disks, Supplemental Disk and Windows 95 CD ([FILES.md](FILES.md), `Patches` in `sets/msdos71de/set.psd1`). The third-party files of the disks (CuteMouse, NOSHARE, PKZIP, NDD, logo, ...) are left out. The list below documents where the files of the MS-DOS 7.1 disks came from.

The MS-DOS 7.1 disks 1-4 (DISK1.EXE ... DISK4.EXE) and the system disk "W98_de" were put together by someone else. This list compares every file with the original media (German CDs/disks): **original** = byte-identical to the file on the named medium, **changed** = the file of that medium with the changes given, **other** = not on these media (other products, shareware, the author's own files).

Compared with: Windows 95C OSR 2.5 (German CD), Windows 98 SE (German CD), Windows 98 SE boot disk, Windows ME (German CD), Windows 95 (German OEM CD), MS-DOS 6.22 (German disks). Where a file is on several media, the oldest MS-DOS 7.10 one is named first.

## system disk W98_de

| File | Size | Status | Source |
|---|---:|---|---|
| `COMMAND.COM` | 96,370 | changed | Windows 98 SE COMMAND.COM, 15 changes: texts "Windows 98" -> "MS-DOS 7.1", version check removed (offset 6E79h: 3D 07 0A 74 -> 90 90 90 EB) |
| `IO.SYS` | 76,036 | changed | Windows 98 SE IO.SYS (dated 01.12.2001, 222,670 bytes - not on these CDs), truncated, boot keys/DriveSpace/logo off, Windows 3.x patch, texts "Windows 98" -> "MS-DOS 7.1", Windows ME WINBOOT.SYS header, compressed with IOPAK8 (see readme.txt of the boot disk) |
| `MSDOS.SYS` | 2 | other | empty (2 bytes CR LF) |
| `README.TXT` | 2,975 | other | notes of the disk set author on the IO.SYS changes |
| `SYS.COM` | 19,143 | original | Windows 98 SE (German CD) (`CAB: sys.com`) |

## disk 1

| File | Size | Status | Source |
|---|---:|---|---|
| `AUTOEXEC.BA_` | 82 | other | written by the disk set author |
| `COMMAND.COM` | 96,324 | changed | Windows 95C COMMAND.COM, texts "Windows 95"/"Version 4.00.1111" -> "MS-DOS 7.1"/"German Version..."; not used by the set |
| `CONFIG.SY_` | 70 | other | written by the disk set author |
| `DRVSPACE.BIN` | 65,479 | original | Windows 95C OSR 2.5 (German CD) (`CAB: drvspace.bin`) |
| `EXPAND.EXE` | 16,365 | original | Windows 95 (German OEM CD), MS-DOS 6.22 (German disks) (`img/1/EXPAND.EXE`) |
| `FDISK.EXE` | 64,108 | original | Windows 95C OSR 2.5 (German CD) (`CAB: fdisk.exe`) |
| `FORMAT.COM` | 51,111 | original | Windows 95C OSR 2.5 (German CD) (`Win95/FORMAT.COM`) |
| `IO.SYS` | 214,836 | changed | Windows 98 SE IO.SYS, modified (214,836 bytes); not used by the set |
| `KEYB.COM` | 20,023 | original | Windows 95C OSR 2.5 (German CD) (`CAB: keyb.com`) |
| `KEYBOARD.SYS` | 34,566 | original | Windows 95C OSR 2.5 (German CD), Windows 98 SE (German CD), Windows 95 (German OEM CD) (`CAB: keyboard.sys`) |
| `KEYBRD2.SYS` | 31,942 | original | Windows 95C OSR 2.5 (German CD), Windows 98 SE (German CD), Windows 95 (German OEM CD) (`CAB: keybrd2.sys`) |
| `LOGO.SY_` | 44,432 | other | boot logo "MS-DOS 7.1" (made by the disk set author) |
| `MSDOS.SYS` | 6 | other | written by the disk set author |
| `SYS.COM` | 19,143 | original | Windows 95C OSR 2.5 (German CD) (`CAB: sys.com`) |

## DISK1.EXE

| File | Size | Status | Source |
|---|---:|---|---|
| `ANSI.SYS` | 9,735 | original | Windows 95C OSR 2.5 (German CD) (`CAB: ansi.sys`) |
| `ASPI4DOS.SYS` | 14,386 | original | Windows 98 SE (German CD), Windows 98 SE boot disk, Windows ME (German CD) (`ASPI4DOS.SYS`) |
| `ASPICD.SYS` | 29,620 | original | Windows 98 SE (German CD), Windows 98 SE boot disk (`ASPICD.SYS`) |
| `ATTRIB.EXE` | 15,460 | original | Windows 95C OSR 2.5 (German CD) (`CAB: attrib.exe`) |
| `BAT2EXEC.COM` | 6,284 | other | BAT2EXEC 1.5, PC Magazine (Ziff, 1990-91) |
| `BBIE.EXE` | 20,992 | other | BBIE 1.0 (Win32 console: Bart's Boot Image Extractor) |
| `BTCDROM.SYS` | 21,971 | original | Windows 98 SE (German CD), Windows 98 SE boot disk, Windows ME (German CD) (`BTCDROM.SYS`) |
| `BTDOSM.SYS` | 30,955 | original | Windows 98 SE (German CD), Windows 98 SE boot disk, Windows ME (German CD) (`BTDOSM.SYS`) |
| `CHKDSK.EXE` | 28,976 | original | Windows 95C OSR 2.5 (German CD) (`CAB: chkdsk.exe`) |
| `CHOICE.COM` | 5,367 | original | Windows 95C OSR 2.5 (German CD), Windows 95 (German OEM CD) (`CAB: choice.com`) |
| `COMPRESS.EXE` | 15,259 | other | Microsoft COMPRESS 2.00 (SDK / Windows 3.1 DDK) |
| `CONFIG.TXT` | 297 | other | note of the disk set author (driver lines) |
| `COUNTRY.SYS` | 27,094 | original | Windows 95C OSR 2.5 (German CD), Windows 95 (German OEM CD) (`CAB: country.sys`) |
| `DEBUG.EXE` | 21,162 | original | Windows 95C OSR 2.5 (German CD) (`CAB: debug.exe`) |
| `DEFRAGR.DOC` | 16,304 | other | DEFRAGR 1.00, PC Magazine (Holmes/Flanders 1993) |
| `DELTREE.EXE` | 19,083 | original | Windows 95C OSR 2.5 (German CD), Windows 95 (German OEM CD) (`CAB: deltree.exe`) |
| `DI.EXE` | 5,668 | other | DiskImager 1.1, Port Jackson Computing (1999) |
| `DI.TXT` | 111 | other | note of the disk set author (German) |
| `DISKCOPY.COM` | 22,279 | original | Windows 95C OSR 2.5 (German CD) (`CAB: diskcopy.com`) |
| `DISPLAY.SYS` | 17,191 | original | Windows 95C OSR 2.5 (German CD) (`CAB: display.sys`) |
| `DOSKEY.COM` | 15,783 | original | Windows 95C OSR 2.5 (German CD) (`CAB: doskey.com`) |
| `DRVSPACE.SYS` | 2,151 | original | Windows 95C OSR 2.5 (German CD) (`CAB: drvspace.sys`) |
| `DUSELDR.COM` | 1,989 | other | DUSE (USB storage driver) loader |
| `EDIT.HLP` | 12,780 | original | Windows 95C OSR 2.5 (German CD), Windows 98 SE (German CD), Windows ME (German CD), Windows 95 (German OEM CD) (`CAB: edit.hlp`) |
| `EXPAND.EXE` | 16,365 | original | Windows 95 (German OEM CD), MS-DOS 6.22 (German disks) (`img/1/EXPAND.EXE`) |
| `EXT.EXE` | 13,299 | original | Windows 98 SE (German CD), Windows 98 SE boot disk, Windows ME (German CD) (`CAB: EXT.EXE`) |
| `FC.EXE` | 20,910 | original | Windows 95C OSR 2.5 (German CD) (`CAB: fc.exe`) |
| `FIND.EXE` | 6,738 | original | Windows 95C OSR 2.5 (German CD) (`CAB: find.exe`) |
| `HELP.COM` | 429 | original | Windows 95C OSR 2.5 (German CD), Windows 98 SE (German CD), Windows ME (German CD), Windows 95 (German OEM CD), MS-DOS 6.22 (German disks) (`img/2/HELP.COM`) |
| `HIMEM.SYS` | 33,447 | original | Windows 95C OSR 2.5 (German CD) (`CAB: himem.sys`) |
| `IEXTRACT.EXE` | 17,655 | original | Windows 98 SE (German CD), Windows ME (German CD) (`CAB: iextract.exe`) |
| `KEYB.COM` | 20,023 | original | Windows 95C OSR 2.5 (German CD) (`CAB: keyb.com`) |
| `KEYBOARD.SYS` | 34,566 | original | Windows 95C OSR 2.5 (German CD), Windows 98 SE (German CD), Windows 95 (German OEM CD) (`CAB: keyboard.sys`) |
| `KEYBRD2.SYS` | 31,942 | original | Windows 95C OSR 2.5 (German CD), Windows 98 SE (German CD), Windows 95 (German OEM CD) (`CAB: keybrd2.sys`) |
| `LABEL.EXE` | 9,548 | original | Windows 95C OSR 2.5 (German CD) (`CAB: label.exe`) |
| `MEM.EXE` | 32,450 | original | Windows 95C OSR 2.5 (German CD) (`CAB: mem.exe`) |
| `MODE.COM` | 29,815 | original | Windows 95C OSR 2.5 (German CD) (`CAB: mode.com`) |
| `MORE.COM` | 10,487 | original | Windows 95C OSR 2.5 (German CD) (`CAB: more.com`) |
| `MOUSE.COM` | 4,813 | other | CuteMouse 1.8 (FreeDOS, GPL) |
| `MOVE.EXE` | 27,491 | original | Windows 95C OSR 2.5 (German CD), Windows 95 (German OEM CD) (`CAB: move.exe`) |
| `MSCDEX.EXE` | 25,473 | original | Windows 95C OSR 2.5 (German CD), Windows 98 SE (German CD), Windows 98 SE boot disk, Windows ME (German CD), Windows 95 (German OEM CD), MS-DOS 6.22 (German disks) (`MSCDEX.EXE`) |
| `NLSFUNC.EXE` | 7,020 | original | Windows 95C OSR 2.5 (German CD) (`CAB: nlsfunc.exe`) |
| `NOSHARE.COM` | 2,292 | other | NOSHARE 1.00, Martin Filteau (1993) |
| `NOSHARE.TXT` | 1,227 | other | NOSHARE documentation |
| `NWCDEX.EXE` | 21,756 | other | NWCDEX 2.81, Caldera (DR-DOS / OpenDOS) |
| `OAKCDROM.TXT` | 548 | other | note of the disk set author (German) |
| `PKUNZIP.EXE` | 29,378 | other | PKZIP 2.04g shareware, PKWARE (1993) |
| `PKUNZJR.COM` | 2,916 | other | PKUNZIPjr 2.50, PKWARE (1999) |
| `PKZIPFIX.EXE` | 8,667 | other | PKZIPFIX 2.50, PKWARE (1999) |
| `RAWRITE.EXE` | 13,052 | other | RaWrite 1.2 (freeware) |
| `SCANDISK.INI` | 8,829 | original | Windows 95C OSR 2.5 (German CD) (`CAB: scandisk.ini`) |
| `SORT.EXE` | 25,978 | original | Windows 95C OSR 2.5 (German CD) (`CAB: sort.exe`) |
| `START.EXE` | 9,728 | original | Windows 95C OSR 2.5 (German CD) (`CAB: start.exe`) |
| `SUBST.EXE` | 17,968 | original | Windows 95C OSR 2.5 (German CD) (`CAB: subst.exe`) |
| `SYS.COM` | 19,143 | original | Windows 95C OSR 2.5 (German CD) (`CAB: sys.com`) |
| `XCOPY.EXE` | 3,910 | original | Windows 95C OSR 2.5 (German CD) (`CAB: xcopy.exe`) |
| `ZIP2EXE.EXE` | 30,733 | other | ZIP2EXE 2.50, PKWARE (1999) |

## DISK2.EXE

| File | Size | Status | Source |
|---|---:|---|---|
| `APACK.EXE` | 54,262 | other | aPACK 0.9x, Joergen Ibsen (PMODE/W) |
| `ASPI2DOS.SYS` | 35,330 | original | Windows 98 SE (German CD), Windows 98 SE boot disk, Windows ME (German CD) (`ASPI2DOS.SYS`) |
| `ASPI8DOS.SYS` | 37,564 | original | Windows 98 SE (German CD), Windows 98 SE boot disk, Windows ME (German CD) (`ASPI8DOS.SYS`) |
| `ASPI8U2.SYS` | 40,792 | original | Windows 98 SE (German CD), Windows 98 SE boot disk (`ASPI8U2.SYS`) |
| `CSCRIPT.EXE` | 98,304 | other | Windows Script Host (Win32, not the Windows 98 SE version) |
| `DEFRAGR.EXE` | 38,632 | other | DEFRAGR 1.00, PC Magazine (Holmes/Flanders 1993) |
| `DRVSPACE.BIN` | 65,479 | original | Windows 95C OSR 2.5 (German CD) (`CAB: drvspace.bin`) |
| `EDIT.COM` | 71,022 | original | Windows 95C OSR 2.5 (German CD), Windows 95 (German OEM CD) (`CAB: edit.com`) |
| `EGA.CPI` | 58,870 | original | Windows 95C OSR 2.5 (German CD), Windows 98 SE (German CD), Windows 95 (German OEM CD) (`CAB: ega.cpi`) |
| `EXTRACT.EXE` | 46,656 | original | Windows 95C OSR 2.5 (German CD), Windows 95 (German OEM CD) (`WIN95/EXTRACT.EXE`) |
| `FDISK.EXE` | 64,108 | original | Windows 95C OSR 2.5 (German CD) (`CAB: fdisk.exe`) |
| `FORMAT.COM` | 51,111 | original | Windows 95C OSR 2.5 (German CD) (`Win95/FORMAT.COM`) |
| `NDD.HLP` | 35,856 | other | Norton Disk Doctor help, Norton Utilities 2002 |
| `OAKCDROM.SYS` | 41,302 | original | Windows 98 SE (German CD), Windows 98 SE boot disk, Windows ME (German CD), MS-DOS 6.22 (German disks) (`OAKCDROM.SYS`) |
| `PKZIP.EXE` | 50,663 | other | PKZIP shareware, PKWARE |
| `SMARTDRV.EXE` | 45,379 | original | Windows 98 SE (German CD), MS-DOS 6.22 (German disks) (`img/4/SMARTDRV.EXE`) |
| `SULFNBK.EXE` | 45,056 | original | Windows 98 SE (German CD) (`CAB: sulfnbk.exe`) |
| `XCOPY32.EXE` | 41,984 | original | Windows 95C OSR 2.5 (German CD) (`CAB: xcopy32.exe`) |
| `XCOPY32.MOD` | 41,984 | original | Windows 98 SE (German CD) (`CAB: xcopy32.mod`) |

## DISK3.EXE

| File | Size | Status | Source |
|---|---:|---|---|
| `DEFRAGR.C` | 112,543 | other | DEFRAGR 1.00 source, PC Magazine |
| `DOS4GW.EXE` | 265,396 | other | DOS/4GW 1.97, Rational Systems (Watcom runtime) |
| `DUSE.EXE` | 107,191 | other | DUSE USB storage driver |
| `EMM386.EXE` | 126,695 | original | Windows 95C OSR 2.5 (German CD) (`CAB: emm386.exe`) |
| `MSD.EXE` | 166,023 | original | Windows 98 SE (German CD), Windows ME (German CD) (`tools/oldmsdos/msd.exe`) |
| `QBASIC.EXE` | 195,372 | original | Windows 95C OSR 2.5 (German CD), Windows 98 SE (German CD), Windows ME (German CD), Windows 95 (German OEM CD), MS-DOS 6.22 (German disks) (`img/1/QBASIC.EXE`) |
| `QBASIC.HLP` | 146,989 | original | Windows 95C OSR 2.5 (German CD), Windows 98 SE (German CD), Windows ME (German CD), Windows 95 (German OEM CD), MS-DOS 6.22 (German disks) (`x/2_QBASIC.HL_`) |
| `SCANDISK.EXE` | 144,911 | original | Windows 95C OSR 2.5 (German CD) (`Win95/scandisk.exe`) |
| `SCANREG.EXE` | 166,078 | original | Windows 98 SE (German CD) (`win98/SCANREG.EXE`) |

## DISK4.EXE

| File | Size | Status | Source |
|---|---:|---|---|
| `HELP.HLP` | 350,334 | changed | Windows 95 OTHER\OLDMSDOS\HELP.HLP, 1 byte changed (offset 4D8E6h: F6 -> FB) |
| `NDD.EXE` | 658,368 | other | Norton Disk Doctor, Norton Utilities 2002 (Symantec) |

## disk 4

| File | Size | Status | Source |
|---|---:|---|---|
| `EXPAND.EXE` | 16,365 | original | Windows 95 (German OEM CD), MS-DOS 6.22 (German disks) (`img/1/EXPAND.EXE`) |
| `POWER.EX_` | 6,397 | other | MS-DOS 6.2x POWER.EXE 8,052 bytes (not the German 6.22, 8,174 bytes) |
| `PRINT.EX_` | 11,056 | other | MS-DOS 6.2x PRINT.EXE 15,656 bytes (not the German 6.22, 15,976 bytes) |
| `SETVER.EX_` | 10,784 | changed | SETVER.EXE 19,375 bytes, modified Windows 9x SETVER (original 19,131 bytes): "DOS 7.1" texts |
| `SHARE.EX_` | 3,182 | other | Datalight SHARE 7.10 (ROM-DOS, Datalight 1989-2003), not Microsoft |
