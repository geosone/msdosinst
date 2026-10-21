# Files needed for the MS-DOS 7.1 disk set (msdos71de)

 https://winworldpc.com/product/windows-me/final
 https://winworldpc.com/product/windows-98/98-second-edition
 https://winworldpc.com/product/windows-95/osr-3
 https://winworldpc.com/product/ms-dos/622

Put **your own** media into one folder (subfolders are fine): the CD images (`*.iso`), the disk images (`*.img`) or 7-Zip archives of them (`*.7z`) as they are - the script unpacks them with 7-Zip - or copies of the CDs (or the folders named below) and the files of your disks. Then run `.\mkdosset.ps1 -Source <folder>`. `.\mkdosset.ps1 -List -Source <folder>` shows which of them are still missing.

- Files of a CD are found by their place on the CD (keep its folders); `X.CAB > NAME` = the file NAME in that CAB, the script extracts it (the other CABs of the CD must be in the same folder, a file can continue in the next CAB). The size is that of the extracted file.
- Files of the disks are found by name: compressed files (`*.??_`) are taken as they are, the script expands them.
- `IO.SYS` is built from `WINBOOT.SYS` in `WIN98\PRECOPY1.CAB` and `PRECOPY2.CAB` of the Windows 98 SE CD, `COMMAND.COM` is taken from them, `MSDOS.SYS` is written by the script; patched programs: see `Patches` in `sets\msdos71de\set.psd1`.
- Optional groups may be missing; the setup then leaves out that part.
- The sizes are those of the German media the project was tested with; other versions may work but are untested.

## CDs

| Name | Found by |
|---|---|
| MS-DOS 6.22 disk 1 (German) | `DOSSETUP.INI` |
| Windows 95 CD (German) | `OTHER\OLDMSDOS\MEMMAKER.EXE` |
| Windows 98 SE CD (German) | `WIN98\WIN98_25.CAB` |
| Windows ME CD (German) | `WIN9X\WIN_19.CAB` |

## System files

From: Windows 98 SE CD

| File | On the CD | Size (bytes) |
|---|---|---:|
| `SYS.COM` | `WIN98\EBD.CAB > SYS.COM` | 19,143 |

## IO.SYS and COMMAND.COM

From: Windows 98 SE CD

| File | On the CD | Size (bytes) |
|---|---|---:|
| `PRECOPY1.CAB` | `WIN98\PRECOPY1.CAB` | 1,331,200 |
| `PRECOPY2.CAB` | `WIN98\PRECOPY2.CAB` | 1,325,423 |

## Setup programs

From: Windows ME CD, Windows 98 SE CD

| File | On the CD | Size (bytes) |
|---|---|---:|
| `FDISK.EXE` | `WIN9X\BASE2.CAB > FDISK.EXE` | 67,116 |
| `FORMAT.COM` | `WIN9X\WIN_9.CAB > FORMAT.COM` | 51,031 |
| `KEYB.COM` | `WIN98\WIN98_25.CAB > KEYB.COM` | 20,023 |
| `KEYBOARD.SYS` | `WIN9X\WIN_19.CAB > KEYBOARD.SYS` | 34,566 |
| `KEYBRD2.SYS` | `WIN9X\WIN_19.CAB > KEYBRD2.SYS` | 31,942 |

## MS-DOS 7.1 programs (Windows ME)

From: Windows ME CD, folders WIN9X and TOOLS\OLDMSDOS

| File | On the CD | Size (bytes) |
|---|---|---:|
| `ANSI.SYS` | `WIN9X\WIN_19.CAB > ANSI.SYS` | 9,751 |
| `COUNTRY.SYS` | `WIN9X\WIN_19.CAB > COUNTRY.SYS` | 30,742 |
| `DISPLAY.SYS` | `WIN9X\WIN_19.CAB > DISPLAY.SYS` | 13,223 |
| `HIMEM.SYS` | `WIN9X\WIN_19.CAB > HIMEM.SYS` | 32,823 |
| `ATTRIB.EXE` | `WIN9X\WIN_16.CAB > ATTRIB.EXE` | 15,460 |
| `CHKDSK.EXE` | `WIN9X\WIN_16.CAB > CHKDSK.EXE` | 28,848 |
| `DEBUG.EXE` | `WIN9X\WIN_16.CAB > DEBUG.EXE` | 21,098 |
| `DELTREE.EXE` | `WIN9X\WIN_16.CAB > DELTREE.EXE` | 19,147 |
| `EMM386.EXE` | `WIN9X\WIN_16.CAB > EMM386.EXE` | 126,695 |
| `FC.EXE` | `WIN9X\WIN_16.CAB > FC.EXE` | 20,910 |
| `FIND.EXE` | `WIN9X\WIN_16.CAB > FIND.EXE` | 6,738 |
| `IEXTRACT.EXE` | `WIN9X\WIN_16.CAB > IEXTRACT.EXE` | 17,655 |
| `LABEL.EXE` | `WIN9X\WIN_16.CAB > LABEL.EXE` | 9,548 |
| `MEM.EXE` | `WIN9X\WIN_16.CAB > MEM.EXE` | 32,450 |
| `MOVE.EXE` | `WIN9X\WIN_16.CAB > MOVE.EXE` | 27,571 |
| `CHOICE.COM` | `WIN9X\WIN_9.CAB > CHOICE.COM` | 5,431 |
| `DISKCOPY.COM` | `WIN9X\WIN_9.CAB > DISKCOPY.COM` | 22,279 |
| `DOSKEY.COM` | `WIN9X\WIN_9.CAB > DOSKEY.COM` | 15,783 |
| `EDIT.COM` | `WIN9X\WIN_9.CAB > EDIT.COM` | 70,974 |
| `EGA.CPI` | `WIN9X\WIN_9.CAB > EGA.CPI` | 58,870 |
| `MODE.COM` | `WIN9X\WIN_9.CAB > MODE.COM` | 29,783 |
| `MORE.COM` | `WIN9X\WIN_9.CAB > MORE.COM` | 10,487 |
| `SCANDISK.EXE` | `WIN9X\WIN_17.CAB > SCANDISK.EXE` | 249,932 |
| `SETVER.EXE` | `WIN9X\WIN_17.CAB > SETVER.EXE` | 19,131 |
| `SORT.EXE` | `WIN9X\WIN_17.CAB > SORT.EXE` | 26,778 |
| `SUBST.EXE` | `WIN9X\WIN_17.CAB > SUBST.EXE` | 17,968 |
| `XCOPY.EXE` | `WIN9X\WIN_17.CAB > XCOPY.EXE` | 3,910 |
| `XCOPY32.EXE` | `WIN9X\WIN_17.CAB > XCOPY32.EXE` | 3,910 |
| `EDIT.HLP` | `WIN9X\WIN_18.CAB > EDIT.HLP` | 12,780 |
| `SCANDISK.INI` | `WIN9X\WIN_18.CAB > SCANDISK.INI` | 8,822 |
| `XCOPY32.MOD` | `WIN9X\WIN_18.CAB > XCOPY32.MOD` | 41,984 |
| `DRVSPACE.BIN` | `WIN9X\PRECOPY1.CAB > DRVSPACE.BIN` | 69,079 |
| `DRVSPACE.SYS` | `WIN9X\PRECOPY1.CAB > DRVSPACE.SYS` | 2,151 |
| `SCANREG.EXE` | `WIN9X\PRECOPY1.CAB > SCANREG.EXE` | 173,246 |
| `MSCDEX.EXE` | `WIN9X\BASE2.CAB > MSCDEX.EXE` | 25,473 |
| `ASPI2DOS.SYS` | `WIN9X\BASE2.CAB > ASPI2DOS.SYS` | 35,330 |
| `ASPI4DOS.SYS` | `WIN9X\BASE2.CAB > ASPI4DOS.SYS` | 14,386 |
| `ASPI8DOS.SYS` | `WIN9X\BASE2.CAB > ASPI8DOS.SYS` | 37,564 |
| `ASPI8U2.SYS` | `WIN9X\BASE2.CAB > ASPI8U2.SYS` | 44,828 |
| `ASPICD.SYS` | `WIN9X\BASE2.CAB > ASPICD.SYS` | 29,606 |
| `BTCDROM.SYS` | `WIN9X\BASE2.CAB > BTCDROM.SYS` | 21,971 |
| `BTDOSM.SYS` | `WIN9X\BASE2.CAB > BTDOSM.SYS` | 30,955 |
| `OAKCDROM.SYS` | `WIN9X\BASE2.CAB > OAKCDROM.SYS` | 41,302 |
| `EXTRACT.EXE` | `WIN9X\EXTRACT.EXE` | 53,767 |
| `SMARTDRV.EXE` | `WIN9X\SMARTDRV.EXE` | 45,379 |
| `HELP.COM` | `TOOLS\OLDMSDOS\HELP.COM` | 429 |
| `MSD.EXE` | `TOOLS\OLDMSDOS\MSD.EXE` | 166,023 |
| `QBASIC.EXE` | `TOOLS\OLDMSDOS\QBASIC.EXE` | 195,372 |
| `QBASIC.HLP` | `TOOLS\OLDMSDOS\QBASIC.HLP` | 146,989 |

## MS-DOS 7.1 programs (Windows 98 SE)

From: Windows 98 SE CD, folder WIN98 (not in Windows ME)

| File | On the CD | Size (bytes) |
|---|---|---:|
| `NLSFUNC.EXE` | `WIN98\WIN98_44.CAB > NLSFUNC.EXE` | 7,020 |
| `EXT.EXE` | `WIN98\EBD.CAB > EXT.EXE` | 13,299 |

## MS-DOS 6.22 (optional)

From: MS-DOS 6.22 disks 1 and 2

| File | On the CD | Size (bytes) |
|---|---|---:|
| `EXPAND.EXE` | `EXPAND.EXE` | 16,365 |
| `POWER.EX_` |  | 5,624 |
| `SHARE.EX_` |  | 8,191 |

## MS-DOS Shell (optional)

From: MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)

| File | Size (bytes) |
|---|---:|
| `DOSSHELL.CO_` | 1,945 |
| `DOSSHELL.EX_` | 143,062 |
| `DOSSHELL.HL_` | 58,176 |
| `DOSSWAP.EX_` | 13,577 |
| `VGA.GR_` | 3,198 |
| `EGA.IN_` | 3,076 |
| `VGA.VI_` | 6,355 |

## MS-DOS 5.0 utilities (optional)

From: MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)

| File | Size (bytes) |
|---|---:|
| `ASSIGN.CO_` | 4,547 |
| `BACKUP.EX_` | 22,966 |
| `COMP.EX_` | 8,738 |
| `CV.COM` | 716 |
| `EDLIN.EXE` | 12,674 |
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

| File | On the CD | Size (bytes) |
|---|---|---:|
| `APPEND.EXE` | `OTHER\OLDMSDOS\APPEND.EXE` | 10,902 |
| `CHKSTATE.SYS` | `OTHER\OLDMSDOS\CHKSTATE.SYS` | 42,432 |
| `GRAPHICS.COM` | `OTHER\OLDMSDOS\GRAPHICS.COM` | 19,790 |
| `GRAPHICS.PRO` | `OTHER\OLDMSDOS\GRAPHICS.PRO` | 21,232 |
| `HELP.COM` | `OTHER\OLDMSDOS\HELP.COM` | 429 |
| `HELP.HLP` | `OTHER\OLDMSDOS\HELP.HLP` | 350,334 |
| `INTERLNK.EXE` | `OTHER\OLDMSDOS\INTERLNK.EXE` | 17,709 |
| `INTERSVR.EXE` | `OTHER\OLDMSDOS\INTERSVR.EXE` | 38,482 |
| `LOADFIX.COM` | `OTHER\OLDMSDOS\LOADFIX.COM` | 1,273 |
| `MEMMAKER.EXE` | `OTHER\OLDMSDOS\MEMMAKER.EXE` | 120,407 |
| `MEMMAKER.HLP` | `OTHER\OLDMSDOS\MEMMAKER.HLP` | 19,748 |
| `MEMMAKER.INF` | `OTHER\OLDMSDOS\MEMMAKER.INF` | 2,911 |
| `MONOUMB.386` | `OTHER\OLDMSDOS\MONOUMB.386` | 8,783 |
| `PRINT.EXE` | `OTHER\OLDMSDOS\PRINT.EXE` | 15,976 |
| `QBASIC.EXE` | `OTHER\OLDMSDOS\QBASIC.EXE` | 195,372 |
| `QBASIC.HLP` | `OTHER\OLDMSDOS\QBASIC.HLP` | 146,989 |
| `REPLACE.EXE` | `OTHER\OLDMSDOS\REPLACE.EXE` | 20,242 |
| `RESTORE.EXE` | `OTHER\OLDMSDOS\RESTORE.EXE` | 38,566 |
| `SIZER.EXE` | `OTHER\OLDMSDOS\SIZER.EXE` | 7,329 |
| `TREE.COM` | `OTHER\OLDMSDOS\TREE.COM` | 7,018 |
| `UNDELETE.EXE` | `OTHER\OLDMSDOS\UNDELETE.EXE` | 26,741 |
| `MSBACKDB.OVL` | `OTHER\OLDMSDOS\MSBACKUP\MSBACKDB.OVL` | 64,250 |
| `MSBACKDR.OVL` | `OTHER\OLDMSDOS\MSBACKUP\MSBACKDR.OVL` | 68,442 |
| `MSBACKFB.OVL` | `OTHER\OLDMSDOS\MSBACKUP\MSBACKFB.OVL` | 69,866 |
| `MSBACKFR.OVL` | `OTHER\OLDMSDOS\MSBACKUP\MSBACKFR.OVL` | 74,026 |
| `MSBACKUP.EXE` | `OTHER\OLDMSDOS\MSBACKUP\MSBACKUP.EXE` | 5,615 |
| `MSBACKUP.HLP` | `OTHER\OLDMSDOS\MSBACKUP\MSBACKUP.HLP` | 366,380 |
| `MSBACKUP.OVL` | `OTHER\OLDMSDOS\MSBACKUP\MSBACKUP.OVL` | 134,432 |
| `MSBCONFG.HLP` | `OTHER\OLDMSDOS\MSBACKUP\MSBCONFG.HLP` | 54,031 |
| `MSBCONFG.OVL` | `OTHER\OLDMSDOS\MSBACKUP\MSBCONFG.OVL` | 47,338 |
