# Files needed for the MS-DOS 7.1 disk set (msdos71de)

Copy these files from **your own** disks into one folder (subfolders are fine) and run `.\mkdosset.ps1 -Source <folder>`. `.\mkdosset.ps1 -List -Source <folder>` shows which of them are still missing.

- File names as on the disks: compressed files (`*.??_`) are taken as they are, the script expands them.
- A file name must occur only once: take `IO.SYS`, `MSDOS.SYS`, `COMMAND.COM` and `SYS.COM` from the MS-DOS 7.1 system disk, **not** the older ones of disk 1.
- Optional groups may be missing; the setup then leaves out that part.
- `DISK1.EXE` ... `DISK4.EXE` are self-extracting ZIP archives; the script unpacks them.
- The sizes are those of the German MS-DOS 7.1 set the project was tested with; other versions may work but are untested.

## System files

From: MS-DOS 7.1 system disk "W98_de" (Win98_System_deutsch.IMG)

| File | Size (bytes) |
|---|---:|
| `IO.SYS` | 76,036 |
| `MSDOS.SYS` | 2 |
| `COMMAND.COM` | 96,370 |
| `SYS.COM` | 19,143 |

## Setup programs

From: MS-DOS 7.1 disk 1

| File | Size (bytes) |
|---|---:|
| `FDISK.EXE` | 64,108 |
| `FORMAT.COM` | 51,111 |
| `KEYB.COM` | 20,023 |
| `KEYBOARD.SYS` | 34,566 |
| `KEYBRD2.SYS` | 31,942 |

## MS-DOS 7.1 (disks 1-4)

From: MS-DOS 7.1 disks 1-4

| File | Size (bytes) |
|---|---:|
| `DISK1.EXE` | 522,866 |
| `DISK2.EXE` | 522,775 |
| `DISK3.EXE` | 977,989 |
| `DISK4.EXE` | 641,951 |

## MS-DOS 7.1 (disk 4)

From: MS-DOS 7.1 disk 4

| File | Size (bytes) |
|---|---:|
| `POWER.EX_` | 6,397 |
| `PRINT.EX_` | 11,056 |
| `SETVER.EX_` | 10,784 |
| `SHARE.EX_` | 3,182 |

## Logo (optional)

From: MS-DOS 7.1 disk 1

| File | Size (bytes) |
|---|---:|
| `LOGO.SY_` | 44,432 |

## MS-DOS Shell (optional)

From: MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)

| File | Size (bytes) |
|---|---:|
| `DOSSHELL.CO_` | 1,945 |
| `DOSSHELL.EX_` | 143,062 |
| `DOSSHELL.HL_` | 58,176 |
| `DOSSWAP.EX_` | 13,498 |
| `VGA.GR_` | 3,198 |
| `EGA.IN_` | 2,776 |
| `VGA.VI_` | 6,355 |

## MS-DOS 5.0 utilities (optional)

From: MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)

| File | Size (bytes) |
|---|---:|
| `ASSIGN.CO_` | 4,547 |
| `BACKUP.EX_` | 22,966 |
| `COMP.EX_` | 8,738 |
| `CV.COM` | 716 |
| `EDLIN.EX_` | 9,222 |
| `JOIN.EX_` | 12,237 |
| `4201.CP_` | 2,399 |
| `4208.CP_` | 359 |
| `5202.CP_` | 260 |
| `LCD.CP_` | 2,793 |
| `GORILLA.BA_` | 10,439 |
| `MONEY.BA_` | 13,049 |
| `NIBBLES.BA_` | 7,182 |
| `REMLINE.BA_` | 4,435 |
| `EXE2BIN.EX_` | 5,983 |
| `GRAFTABL.CO_` | 6,078 |
| `MIRROR.CO_` | 11,424 |
| `MSHERC.CO_` | 4,086 |
| `PRINTER.SY_` | 10,961 |
| `PRINTFIX.COM` | 234 |
| `COMMANDS.TX_` | 25,400 |

## AccessDOS (optional)

From: MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)

| File | Size (bytes) |
|---|---:|
| `ADOS.OV_` | 45,289 |
| `ADOS.CO_` | 17,911 |
| `ADOS.CFG` | 61 |
| `ADOS.TX_` | 40,535 |
| `AREADME.TX_` | 12,280 |
| `FAKEMOUS.COM` | 307 |

## Keyboard utilities (optional)

From: MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)

| File | Size (bytes) |
|---|---:|
| `DVORAK.SY_` | 1,779 |
| `DVORAK.TX_` | 3,215 |
| `KBDBUF.SYS` | 1,140 |
| `ISO.CP_` | 15,240 |
| `ISO.TXT` | 2,761 |

## DRVBOOT (optional)

From: MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)

| File | Size (bytes) |
|---|---:|
| `DRVBOOT.BA_` | 1,277 |
| `AM.EXE` | 7,825 |

## MS-DOS 6.22 network files (optional)

From: MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)

| File | Size (bytes) |
|---|---:|
| `NET.1X_` | 4,704 |
| `NET.TX_` | 2,656 |
| `SETNAME.EX_` | 3,131 |
| `NETBEUI.DO_` | 21,122 |
| `NETWKSTA.1X_` | 38,186 |
| `NETWKSTA.2X_` | 60,768 |
| `REDIR.1X_` | 19,627 |
| `REDIR.2X_` | 20,033 |

## MS-DOS utilities for Windows 95 (OLDMSDOS) (optional)

From: Windows 95 CD, folder OTHER\OLDMSDOS

| File | Size (bytes) |
|---|---:|
| `APPEND.EXE` | 10,902 |
| `CHKSTATE.SYS` | 42,432 |
| `GRAPHICS.COM` | 19,790 |
| `GRAPHICS.PRO` | 21,232 |
| `HELP.COM` | 429 |
| `HELP.HLP` | 350,334 |
| `INTERLNK.EXE` | 17,709 |
| `INTERSVR.EXE` | 38,482 |
| `LOADFIX.COM` | 1,273 |
| `MEMMAKER.EXE` | 120,407 |
| `MEMMAKER.HLP` | 19,748 |
| `MEMMAKER.INF` | 2,911 |
| `MONOUMB.386` | 8,783 |
| `PRINT.EXE` | 15,976 |
| `QBASIC.EXE` | 195,372 |
| `QBASIC.HLP` | 146,989 |
| `REPLACE.EXE` | 20,242 |
| `RESTORE.EXE` | 38,566 |
| `SIZER.EXE` | 7,329 |
| `TREE.COM` | 7,018 |
| `UNDELETE.EXE` | 26,741 |
| `MSBACKDB.OVL` | 64,250 |
| `MSBACKDR.OVL` | 68,442 |
| `MSBACKFB.OVL` | 69,866 |
| `MSBACKFR.OVL` | 74,026 |
| `MSBACKUP.EXE` | 5,615 |
| `MSBACKUP.HLP` | 366,380 |
| `MSBACKUP.OVL` | 134,432 |
| `MSBCONFG.HLP` | 54,031 |
| `MSBCONFG.OVL` | 47,338 |
