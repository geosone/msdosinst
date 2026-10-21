# MS-DOS 7.1 (German) disk set: the files mkdosset.ps1 needs from your own
# CDs and disks and where they go in the archive (see INSTALL.INI).
#
# Put the CD images (*.iso), the disk images (*.img) - or 7-Zip archives of
# them - or copies of the CDs (or the folders named here) and the files of
# your disks into one folder (subfolders are fine) and give it with -Source;
# mkdosset.ps1 -List shows this list.  Entries: NAME = a file of your disks, found by
# name; Medium:PATH = a file of a CD (Media), PATH from the CD root;
# Medium:PATH\X.CAB>NAME = a file in a CAB of a CD.  Compressed files
# (*.??_, SZDD/KWAJ) are expanded.
@{
    Name   = 'MSDOS71'            # archive MSDOS71.D01, MSDOS71.D02, ...
    Label  = 'MSDOS71'            # volume labels "MSDOS71 1", ...
    Keyboard = 'GR'               # KEYB on the setup disk

    # the CDs (and disks): found in -Source by the file Find (path from the root)
    Media = @{
        WinMe   = @{ Name = 'Windows ME CD (German)'; Find = 'WIN9X\WIN_19.CAB' }
        Win98se = @{ Name = 'Windows 98 SE CD (German)'; Find = 'WIN98\WIN98_25.CAB' }
        # the first Windows 95 (1995): OTHER\OLDMSDOS of OSR 2.x has only HELP and QBASIC
        Win95   = @{ Name = 'Windows 95 CD (German, 1995, not OSR 2.x)'; Find = 'OTHER\OLDMSDOS\MEMMAKER.EXE' }
        # the Supplemental Disk has another EXPAND.EXE (English)
        Dos622  = @{ Name = 'MS-DOS 6.22 disk 1 (German)'; Find = 'DOSSETUP.INI' }
    }

    # disk 1: the MS-DOS 7.1 system files, the boot sector is written by
    # mkdosset.ps1.  IO.SYS is built by ext/small-io-sys (compile.ps1 de) from
    # winboot.sys of the Windows 98 SE CD, COMMAND.COM is the one of the same
    # CD (see Patches); both are in WIN98\PRECOPY1.CAB, continued in
    # PRECOPY2.CAB.  MSDOS.SYS is MsdosSys.  SYS.COM is the Windows 98 SE one
    # (the Windows ME SYS.COM installs only Windows ME system files).
    System     = @('IO.SYS', 'MSDOS.SYS', 'COMMAND.COM', 'Win98se:WIN98\EBD.CAB>SYS.COM')
    SystemFrom = 'Windows 98 SE CD'
    IoSysCabs  = @('Win98se:WIN98\PRECOPY1.CAB', 'Win98se:WIN98\PRECOPY2.CAB')
    IoSysFrom  = 'Windows 98 SE CD'
    # the options that the IO.SYS of the MS-DOS 7.1 system disk had built in
    MsdosSys   = @('[Options]', 'BootKeys=0', 'Logo=0', 'DblSpace=0', 'DrvSpace=0', 'SystemReg=0')
    # Windows ME FDISK and FORMAT (see Patches); Windows ME has no KEYB.COM
    BootFiles  = @('WinMe:WIN9X\BASE2.CAB>FDISK.EXE', 'WinMe:WIN9X\WIN_9.CAB>FORMAT.COM', 'Win98se:WIN98\WIN98_25.CAB>KEYB.COM',
                   'WinMe:WIN9X\WIN_19.CAB>KEYBOARD.SYS', 'WinMe:WIN9X\WIN_19.CAB>KEYBRD2.SYS')
    BootFrom   = 'Windows ME CD, Windows 98 SE CD'

    # archive: Files (as above; Medium = the CD of entries without one),
    # Zip = self-extracting ZIP archive, To = directory in the archive,
    # Optional = may be missing, KeepFirst = leave out names that are
    # already in DOS\, "A=B" = store file A (after expanding) as B
    Archive = @(
        @{ Name = 'MS-DOS 7.1 programs (Windows ME)'; From = 'Windows ME CD, folders WIN9X and TOOLS\OLDMSDOS'; Medium = 'WinMe'; To = 'DOS'
           Files = @('WIN9X\WIN_19.CAB>ANSI.SYS', 'WIN9X\WIN_19.CAB>COUNTRY.SYS', 'WIN9X\WIN_19.CAB>DISPLAY.SYS',
                     'WIN9X\WIN_19.CAB>HIMEM.SYS',
                     'WIN9X\WIN_16.CAB>ATTRIB.EXE', 'WIN9X\WIN_16.CAB>CHKDSK.EXE', 'WIN9X\WIN_16.CAB>DEBUG.EXE',
                     'WIN9X\WIN_16.CAB>DELTREE.EXE', 'WIN9X\WIN_16.CAB>EMM386.EXE', 'WIN9X\WIN_16.CAB>FC.EXE',
                     'WIN9X\WIN_16.CAB>FIND.EXE', 'WIN9X\WIN_16.CAB>IEXTRACT.EXE', 'WIN9X\WIN_16.CAB>LABEL.EXE',
                     'WIN9X\WIN_16.CAB>MEM.EXE', 'WIN9X\WIN_16.CAB>MOVE.EXE',
                     'WIN9X\WIN_9.CAB>CHOICE.COM', 'WIN9X\WIN_9.CAB>DISKCOPY.COM', 'WIN9X\WIN_9.CAB>DOSKEY.COM',
                     'WIN9X\WIN_9.CAB>EDIT.COM', 'WIN9X\WIN_9.CAB>EGA.CPI', 'WIN9X\WIN_9.CAB>MODE.COM', 'WIN9X\WIN_9.CAB>MORE.COM',
                     'WIN9X\WIN_17.CAB>SCANDISK.EXE', 'WIN9X\WIN_17.CAB>SETVER.EXE', 'WIN9X\WIN_17.CAB>SORT.EXE',
                     'WIN9X\WIN_17.CAB>SUBST.EXE', 'WIN9X\WIN_17.CAB>XCOPY.EXE', 'WIN9X\WIN_17.CAB>XCOPY32.EXE',
                     'WIN9X\WIN_18.CAB>EDIT.HLP', 'WIN9X\WIN_18.CAB>SCANDISK.INI', 'WIN9X\WIN_18.CAB>XCOPY32.MOD',
                     'WIN9X\PRECOPY1.CAB>DRVSPACE.BIN', 'WIN9X\PRECOPY1.CAB>DRVSPACE.SYS',
                     'WIN9X\BASE2.CAB>MSCDEX.EXE', 'WIN9X\BASE2.CAB>ASPI2DOS.SYS', 'WIN9X\BASE2.CAB>ASPI4DOS.SYS',
                     'WIN9X\BASE2.CAB>ASPI8DOS.SYS', 'WIN9X\BASE2.CAB>ASPI8U2.SYS', 'WIN9X\BASE2.CAB>ASPICD.SYS',
                     'WIN9X\BASE2.CAB>BTCDROM.SYS', 'WIN9X\BASE2.CAB>BTDOSM.SYS', 'WIN9X\BASE2.CAB>OAKCDROM.SYS',
                     'WIN9X\NET4.CAB>RAMDRIVE.SYS',
                     'WIN9X\EXTRACT.EXE', 'WIN9X\SMARTDRV.EXE',
                     'TOOLS\OLDMSDOS\HELP.COM', 'TOOLS\OLDMSDOS\MSD.EXE', 'TOOLS\OLDMSDOS\QBASIC.EXE', 'TOOLS\OLDMSDOS\QBASIC.HLP') }
        @{ Name = 'MS-DOS 7.1 programs (Windows 98 SE)'; From = 'Windows 98 SE CD, folders WIN98 and TOOLS\RESKIT (not in Windows ME)'; Medium = 'Win98se'; To = 'DOS'
           Files = @('WIN98\WIN98_44.CAB>NLSFUNC.EXE', 'WIN98\EBD.CAB>EXT.EXE',
                     'TOOLS\RESKIT\CONFIG\CHDOSCP\CODEPAGE\EGA2.CPI', 'TOOLS\RESKIT\CONFIG\CHDOSCP\CODEPAGE\EGA3.CPI') }
        # the MS-DOS programs of MS-DOS 6.22 that are not in Windows 95/98/ME
        # (DEFRAG is left out: it knows neither long file names nor FAT32);
        # SHARE for Windows 3.x (MS-DOS 7.1 has no SHARE, the setup option
        # loads it with INSTALL= in CONFIG.SYS)
        @{ Name = 'MS-DOS 6.22'; From = 'MS-DOS 6.22 disks 1-3'; To = 'DOS'; Optional = $true
           Files = @('Dos622:EXPAND.EXE', 'DISKCOMP.CO_', 'DRIVER.SY_', 'FASTHELP.EX_', 'DOSHELP.HL_', 'FASTOPEN.EX_',
                     'POWER.EX_', 'SHARE.EX_', 'UNFORMAT.COM', 'MSAV.EXE', 'MSAV.HL_', 'MSAVHELP.OV_', 'MSAVIRUS.LS_',
                     'VSAFE.CO_') }
        # Windows 3.x programs of MS-DOS 6.22: Backup, Anti-Virus, Undelete,
        # SmartDrive monitor, the File Manager tools menu, the group file
        @{ Name = 'Windows 3.x programs of MS-DOS 6.22'; From = 'MS-DOS 6.22 disks 2 and 3'; To = 'SUPP\WIN3'; Optional = $true
           Files = @('MWBACKUP.EX_', 'MWBACKR.DL_', 'MWBACKF.DL_', 'MWBACKUP.HL_', 'MSTOOLS.DL_', 'VFINTD.38_',
                     'MWAV.EX_', 'MWAV.HL_', 'MWAVABSI.DL_', 'MWAVDLG.DL_', 'MWAVDOSL.DL_', 'MWAVDRVL.DL_', 'MWAVMGR.DL_',
                     'MWAVSCAN.DL_', 'MWAVSOS.DL_', 'MWAVTSR.EX_', 'MWGRAFIC.DL_', 'MWUNDEL.EX_', 'MWUNDEL.HL_',
                     'SMARTMON.EX_', 'SMARTMON.HL_', 'WNTOOLS.GR_') }
        @{ Name = 'MS-DOS Shell'; From = 'MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)'; To = 'SUPP\SHELL'; Optional = $true; KeepFirst = $true
           Files = @('DOSSHELL.CO_', 'DOSSHELL.EX_', 'DOSSHELL.HL_', 'DOSSWAP.EX_',
                     'VGA.GR_=DOSSHELL.GRB', 'EGA.IN_=DOSSHELL.INI', 'VGA.VI_=DOSSHELL.VID') }
        @{ Name = 'MS-DOS 5.0 utilities'; From = 'MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)'; To = 'SUPP\DOS5'; Optional = $true; KeepFirst = $true
           Files = @('ASSIGN.CO_', 'BACKUP.EX_', 'COMP.EX_', 'CV.COM', 'EDLIN.EXE', 'JOIN.EX_', '4201.CP_',
                     '4208.CP_', '5202.CP_', 'LCD.CP_', 'GORILLA.BA_', 'MONEY.BA_', 'NIBBLES.BA_', 'REMLINE.BA_',
                     'EXE2BIN.EX_', 'GRAFTABL.CO_', 'MIRROR.CO_', 'MSHERC.CO_', 'PRINTER.SY_', 'PRINTFIX.COM',
                     'COMMANDS.TX_') }
        @{ Name = 'AccessDOS'; From = 'MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)'; To = 'SUPP\ADOS'; Optional = $true; KeepFirst = $true
           Files = @('ADOS.OV_', 'ADOS.CO_', 'ADOS.CFG', 'ADOS.TX_', 'AREADME.TX_', 'FAKEMOUS.COM') }
        @{ Name = 'Keyboard utilities'; From = 'MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)'; To = 'SUPP\KBD'; Optional = $true; KeepFirst = $true
           Files = @('DVORAK.SY_', 'DVORAK.TX_', 'KBDBUF.SYS', 'ISO.CP_', 'ISO.TXT') }
        @{ Name = 'DRVBOOT'; From = 'MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)'; To = 'SUPP\DRVB'; Optional = $true; KeepFirst = $true
           Files = @('DRVBOOT.BA_', 'AM.EXE') }
        @{ Name = 'MS-DOS 6.22 network files'; From = 'MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)'; To = 'SUPP\NET'; Optional = $true; KeepFirst = $true
           Files = @('NET.1X_', 'NET.TX_', 'SETNAME.EX_', 'NETBEUI.DO_', 'NETWKSTA.1X_', 'NETWKSTA.2X_',
                     'REDIR.1X_', 'REDIR.2X_') }
        @{ Name = 'MS-DOS utilities for Windows 95 (OLDMSDOS)'; From = 'Windows 95 CD (1995, not OSR 2.x), folder OTHER\OLDMSDOS'; Medium = 'Win95'; To = 'OLD'; Optional = $true; KeepFirst = $true
           Files = @('OTHER\OLDMSDOS\APPEND.EXE', 'OTHER\OLDMSDOS\CHKSTATE.SYS', 'OTHER\OLDMSDOS\GRAPHICS.COM',
                     'OTHER\OLDMSDOS\GRAPHICS.PRO', 'OTHER\OLDMSDOS\HELP.COM', 'OTHER\OLDMSDOS\HELP.HLP',
                     'OTHER\OLDMSDOS\INTERLNK.EXE', 'OTHER\OLDMSDOS\INTERSVR.EXE', 'OTHER\OLDMSDOS\LOADFIX.COM',
                     'OTHER\OLDMSDOS\MEMMAKER.EXE', 'OTHER\OLDMSDOS\MEMMAKER.HLP', 'OTHER\OLDMSDOS\MEMMAKER.INF',
                     'OTHER\OLDMSDOS\MONOUMB.386', 'OTHER\OLDMSDOS\PRINT.EXE', 'OTHER\OLDMSDOS\QBASIC.EXE',
                     'OTHER\OLDMSDOS\QBASIC.HLP', 'OTHER\OLDMSDOS\REPLACE.EXE', 'OTHER\OLDMSDOS\RESTORE.EXE',
                     'OTHER\OLDMSDOS\SIZER.EXE', 'OTHER\OLDMSDOS\TREE.COM', 'OTHER\OLDMSDOS\UNDELETE.EXE',
                     'OTHER\OLDMSDOS\MSBACKUP\MSBACKDB.OVL', 'OTHER\OLDMSDOS\MSBACKUP\MSBACKDR.OVL',
                     'OTHER\OLDMSDOS\MSBACKUP\MSBACKFB.OVL', 'OTHER\OLDMSDOS\MSBACKUP\MSBACKFR.OVL',
                     'OTHER\OLDMSDOS\MSBACKUP\MSBACKUP.EXE', 'OTHER\OLDMSDOS\MSBACKUP\MSBACKUP.HLP',
                     'OTHER\OLDMSDOS\MSBACKUP\MSBACKUP.OVL', 'OTHER\OLDMSDOS\MSBACKUP\MSBCONFG.HLP',
                     'OTHER\OLDMSDOS\MSBACKUP\MSBCONFG.OVL') }
    )

    # names of compressed files that do not store them (KWAJ files of the
    # MS-DOS 6.22 Supplemental Disk): extension map and exceptions
    ExpandExt   = @{ 'CO_' = 'COM'; 'EX_' = 'EXE'; 'SY_' = 'SYS'; 'TX_' = 'TXT'; 'OV_' = 'OVL'; 'CP_' = 'CPI'
                     'BA_' = 'BAS'; 'GR_' = 'GRB'; 'IN_' = 'INI'; 'VI_' = 'VID'; 'HL_' = 'HLP'; '1X_' = '1XE'
                     '2X_' = '2XE'; 'DO_' = 'DOS'; 'LS_' = 'LST'; 'DL_' = 'DLL'; '38_' = '386' }
    ExpandNames = @{ 'DRVBOOT.BA_' = 'DRVBOOT.BAT'; 'WNTOOLS.GR_' = 'WNTOOLS.GRP' }

    # Patches: Old/New in hex or OldText/NewText (code page 850), at offset
    # At or where Old occurs exactly once (Count = that many times, all)
    Patches = @(
        # version checks of the MS-DOS 6.22 programs (disks, Supplemental Disk
        # and the OLDMSDOS utilities of Windows 95): they accept only MS-DOS 6.22
        # (CMP AX,1606h) resp. 6.20-6.x (AM.EXE, INT 21h AX=3306h) and are
        # patched to accept MS-DOS 7.10
        @{ Files = @('APPEND.EXE', 'ASSIGN.COM', 'BACKUP.EXE', 'DISKCOMP.COM', 'DRIVER.SYS', 'EDLIN.EXE', 'EXE2BIN.EXE',
                     'FASTOPEN.EXE', 'GRAFTABL.COM', 'GRAPHICS.COM', 'JOIN.EXE', 'PRINT.EXE', 'REPLACE.EXE', 'RESTORE.EXE', 'SHARE.EXE', 'TREE.COM')
           Old = 'B4 30 CD 21 3D 06 16 75 03'; New = 'B4 30 CD 21 3D 07 0A 75 03' }
        @{ Files = @('APPEND.EXE')
           Old = 'B4 30 E8 CF FD 3D 06 16 75 02'; New = 'B4 30 E8 CF FD 3D 07 0A 75 02' }
        @{ Files = @('AM.EXE')
           Old = '80 7E E6 06 75 06 80 7E E7 14'; New = '80 7E E6 07 75 06 80 7E E7 0A' }

        # version checks of the Windows ME programs: they accept only MS-DOS
        # 8.00 (CMP AX,0008h resp. 0800h) and are patched to accept 7.10
        @{ Files = @('ANSI.SYS', 'ATTRIB.EXE', 'CHKDSK.EXE', 'DEBUG.EXE', 'DISKCOPY.COM', 'DISPLAY.SYS', 'DOSKEY.COM',
                     'FC.EXE', 'FIND.EXE', 'FORMAT.COM', 'LABEL.EXE', 'MEM.EXE', 'MODE.COM', 'MORE.COM', 'SETVER.EXE',
                     'SORT.EXE', 'SUBST.EXE', 'XCOPY.EXE', 'XCOPY32.EXE', 'XCOPY32.MOD')
           Old = 'B4 30 CD 21 3D 08 00 74'; New = 'B4 30 CD 21 3D 07 0A 74' }
        @{ Files = @('DOSKEY.COM'); Old = 'CD 21 86 C4 3D 00 08 74'; New = 'CD 21 86 C4 3D 0A 07 74' }

        # Windows ME FORMAT.COM: the size of the medium in MB is computed in 32
        # bits but stored in 16 ("Formatierung 16,859,84 MB" for 82,396 MB).
        # The size code stores the whole 32-bit value at [3203h] (shorter: mov
        # eax,[2C96h] instead of two 16-bit loads), the hundredths move from
        # [3205h] to [3201h] (only used for sizes below 1 MB), the two message
        # arguments of the MB value become 32 bits (and up to 7 digits)
        @{ Files = @('FORMAT.COM'); At = 0x746E
           Old = '66 0F B7 C9 A1 98 2C 66 C1 E0 10 A1 96 2C 66 F7 E1 66 BB 00 00 10 00 66 F7 F3 66 C1 EA 0A EB 4C'
           New = '66 A1 96 2C 66 0F B7 C9 66 F7 E1 66 BB 00 00 10 00 66 F7 F3 66 A3 03 32 66 C1 EA 0A EB 4E 90 90' }
        @{ Files = @('FORMAT.COM'); At = 0x751F; Old = 'A3 05 32'; New = 'A3 01 32' }
        @{ Files = @('FORMAT.COM'); At = 0x7529; Old = '89 0E 05 32'; New = '89 0E 01 32' }
        @{ Files = @('FORMAT.COM'); At = 0x382; Old = '0B 00 03 32 08 00 01 A1 05 05'; New = '0B 00 03 32 08 00 01 B1 07 05' }
        @{ Files = @('FORMAT.COM'); At = 0x38D; Old = '0B 00 03 32 08 00 01 A1 0D 00'; New = '0B 00 03 32 08 00 01 B1 0D 00' }
        @{ Files = @('FORMAT.COM'); At = 0x398; Old = '0B 00 05 32'; New = '0B 00 01 32' }

        # Windows ME FORMAT.COM: /S again. /S only sets bit 1 of [310Ch]
        # ("Microsoft Windows unterstuetzt den Befehl format /s nicht mehr"),
        # now bit 200h as in Windows 98 (or byte [310Dh],2); /? shows the two
        # /S lines again (the help loop skipped messages 136h and 137h)
        @{ Files = @('FORMAT.COM'); At = 0x6A2A; Old = '83 0E 0C 31 01'; New = '80 0E 0D 31 02' }
        @{ Files = @('FORMAT.COM'); At = 0x6BFC; Old = '37 01'; New = 'FF FF' }
        @{ Files = @('FORMAT.COM'); At = 0x6C04; Old = '36 01'; New = 'FF FF' }
        # Windows ME no longer reads the system files (the code of Windows 98
        # that does is gone), so its copy routine (bit 200h) writes no usable
        # files; it is replaced by "%COMSPEC% /C SYS x:" (format-s.asm)
        @{ Files = @('FORMAT.COM'); At = 0x83C4
           Old = 'A0 6F 31 A2 A9 32 B9 06 00 8D 16 A9 32 B4 3C CD 21 72 65 93 B9 78 00 1E 0E 1F 8D 16 0C 2E B4 40 CD 21 1F BA E6 00 8B CA C1 E2 0A C1 E9 06 B8 00 42 CD 21 A3 65 2F 89 16 67'
           New = '60 1E 06 A0 6F 31 2E A2 E5 2E 8E 06 21 27 26 8E 06 2C 00 31 FF 0E 1F 26 80 3D 00 74 2E BE D4 2E B9 08 00 F3 A6 74 0A 4F 30 C0 B9 FF FF F2 AE EB E6 8C 0E EC 2E 8C 0E F0 2E' }
        @{ Files = @('FORMAT.COM'); At = 0x83FD
           Old = '2F E8 31 EE 2B C9 B4 40 CD 21 B4 3E CD 21 A0 6F 31 A2 B3 32 B9 06 00 8D 16 B3 32 B4 3C CD 21 72 1E 93 B9 09 00 8B C1 33 D2 A3 77 2F 89 16 79 2F E8 02 EE BA C0 32 B4 40 CD'
           New = '8C 0E F4 2E 06 1F 89 FA 0E 07 BB E8 2E B8 00 4B CD 21 07 1F 61 F8 C3 43 4F 4D 53 50 45 43 3D 0A 20 2F 43 20 53 59 53 20 41 3A 0D 00 00 DC 2E 00 00 D4 2E 00 00 D4 2E 00 00' }

        # MS-DOS instead of Windows in the titles and messages (references to
        # other systems such as Windows NT or Windows 3.x stay)
        @{ Files = @('FDISK.EXE'); At = 0x476; OldText = '                      Microsoft Windows Millennium '; NewText = '                          Microsoft MS-DOS 7.1     ' }
        @{ Files = @('FDISK.EXE'); At = 0x261A; OldText = 'Beenden Sie Windows vor dem Neustart.'; NewText = 'Beenden Sie alle Programme vorher.   ' }
        @{ Files = @('FDISK.EXE'); At = 0x26AC; OldText = 'bietet diese Windows-Version eine erweiterte '; NewText = 'bietet diese MS-DOS-Version eine erweiterte  ' }
        @{ Files = @('HIMEM.SYS'); At = 0x7CAF; OldText = 'Windows XMS-Treiber,  Version 3.95'; NewText = 'MS-DOS XMS-Treiber, Version 3.95  ' }
        @{ Files = @('EMM386.EXE'); At = 0x1DF49; OldText = 'Windows-Expansionsspeicher-Treiber, Version 4.95'; NewText = 'MS-DOS-Expansionsspeicher-Treiber, Version 4.95 ' }
        # "Windows ausgefuehrt wird. ..." (the u umlaut is 81h)
        @{ Files = @('SETVER.EXE'); At = 0x583
           Old = '57 69 6E 64 6F 77 73 20 61 75 73 67 65 66 81 68 72 74 20 77 69 72 64 2E 20 45 72 6B 75 6E 64 69 67 65 6E 20 53 69 65 20 73 69 63 68 20'
           New = '4D 53 2D 44 4F 53 20 61 75 73 67 65 66 81 68 72 74 20 77 69 72 64 2E 20 45 72 6B 75 6E 64 69 67 65 6E 20 53 69 65 20 73 69 63 68 20 20' }
        @{ Files = @('SETVER.EXE'); At = 0x5B3; OldText = 'beim Softwarehersteller, ob dies der Fall ist. Wenn Sie Windows '; NewText = 'beim Softwarehersteller, ob dies der Fall ist. Wenn Sie MS-DOS  ' }
        @{ Files = @('SETVER.EXE'); At = 0x7AA; OldText = 'Legt die MS-DOS-Versionsnummer fest, die Windows einem Programm meldet.'; NewText = 'Legt die MS-DOS-Versionsnummer fest, die MS-DOS einem Programm meldet. ' }
        @{ Files = @('SYS.COM'); At = 0x48EE; OldText = 'der entsprechenden Windows-Version.'; NewText = 'der entsprechenden MS-DOS-Version. ' }
        @{ Files = @('DRVSPACE.BIN'); At = 0x10AC3; OldText = 'Version von Windows.'; NewText = 'Version von MS-DOS. ' }
        @{ Files = @('DRVSPACE.BIN'); At = 0x10B59; OldText = 'um Windows zu starten.'; NewText = 'um MS-DOS zu starten. ' }

        # Windows ME FDISK.EXE: sizes of 100,000 MB and more with 6 digits, as
        # in the FDISK.EXE (KB263044) fixed by Petr (MSFN, "Corrected FDISK
        # and FORMAT", 2006); the Windows ME FDISK has the same code, its data
        # is 10h higher
        # the 6th character of the input field (a word instead of a byte)
        @{ Files = @('FDISK.EXE'); At = 0x7C27; Old = '8A 46 E4 88 87 10 9E'; New = '8B 46 E4 89 87 10 9E' }
        # limit of the short input field 10,000 -> 100,000 (one 32-bit compare)
        @{ Files = @('FDISK.EXE'); At = 0x816E; Old = '83 7E FC 00 75 07 81 7E FA 10 27 72 03'; New = '90 90 90 66 81 7E FA A0 86 01 00 72 03' }
        @{ Files = @('FDISK.EXE'); At = 0x82C7; Old = '83 7E FC 00 75 48 81 7E FA 10 27 73 41'; New = '90 90 90 66 81 7E FA A0 86 01 00 73 41' }
        # larger line buffers
        @{ Files = @('FDISK.EXE'); At = 0x8D48; Old = 'C7 06 5E 12 C0 9E'; New = 'C7 06 5E 12 C6 9E' }
        @{ Files = @('FDISK.EXE'); At = 0x8D5B; Old = 'C7 06 5E 12 74 9F'; New = 'C7 06 5E 12 80 9F' }
        @{ Files = @('FDISK.EXE'); At = 0x8D6E; Old = 'C7 06 5E 12 28 A0'; New = 'C7 06 5E 12 3A A0' }
        @{ Files = @('FDISK.EXE'); At = 0x9001; Old = 'C7 06 5E 12 94 9E'; New = 'C7 06 5E 12 A4 9E' }
        @{ Files = @('FDISK.EXE'); At = 0x9014; Old = 'C7 06 5E 12 1C 9F'; New = 'C7 06 5E 12 3C 9F' }
        @{ Files = @('FDISK.EXE'); At = 0x9027; Old = 'C7 06 5E 12 A4 9F'; New = 'C7 06 5E 12 D4 9F' }
        # both logical drive lines use the first (widened) format string
        @{ Files = @('FDISK.EXE'); At = 0x8EA2; Old = '50 6A 20 68 D1 11'; New = '50 6A 20 68 C1 11' }
        # format strings
        @{ Files = @('FDISK.EXE'); At = 0xE17E; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE185; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE18C; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE193; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE19A; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE1A1; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE1A8; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE1B6; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE1BD; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE1C4; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE1D2; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE1E3; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE1EA; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE1F8; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xE20A; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xEB8C; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xEB9C; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xEBDC; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xEBFC; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xEC19; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xEC1F; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xEC33; OldText = '%5.0lu'; NewText = '%6.0lu' }
        @{ Files = @('FDISK.EXE'); At = 0xEC39; Old = '25 39 63 00 25'; New = '25 31 30 63 00' }
        @{ Files = @('FDISK.EXE'); At = 0xEC43; OldText = '%5.0lu'; NewText = '%6.0lu' }
        # screen texts: number fields one character wider, the texts keep their length
        @{ Files = @('FDISK.EXE'); Count = 4; OldText = '<IIIII>   <IIIIIIII>   <IIII>'; NewText = '<IIIIII>   <IIIIIIII>  <IIII>' }
        @{ Files = @('FDISK.EXE'); Count = 23; OldText = '<IIIII>  <IIIIIIII>  <IIII>'; NewText = '<IIIIII>  <IIIIIIII> <IIII>' }
        @{ Files = @('FDISK.EXE'); Count = 32; OldText = '<IIIII>   <IIIII>    <IIII>'; NewText = '<IIIIII>  <IIIIII>   <IIII>' }
        @{ Files = @('FDISK.EXE'); Count = 2; OldText = ': <HIIIIIR> MB (1'; NewText = ':<HIIIIIIR> MB (1' }
        @{ Files = @('FDISK.EXE'); OldText = 'Partition: <HIIIIIR>'; NewText = 'Partition:<HIIIIIIR>' }
        @{ Files = @('FDISK.EXE'); OldText = 'maximal <HIIIIIR>'; NewText = 'maximal<HIIIIIIR>' }
        @{ Files = @('FDISK.EXE'); OldText = '..: <H>[<IIIISI>]'; NewText = '.: <H>[<IIIIISI>]' }
        @{ Files = @('FDISK.EXE'); OldText = 'Platzes: <H>[<IIIISI>]'; NewText = 'Platzes:<H>[<IIIIISI>]' }
        @{ Files = @('FDISK.EXE'); OldText = '....<H>[<IIIISI>]'; NewText = '...<H>[<IIIIISI>]' }

        # COMMAND.COM of the German Windows 98 SE CD (96370 bytes): MS-DOS 7.1
        # instead of Windows 98, as on the MS-DOS 7.1 system disk
        @{ Files = @('COMMAND.COM'); At = 0x5CA; OldText = 'Windows kann nicht geladen werden.'; NewText = 'MS-DOS kann nicht geladen werden. ' }
        @{ Files = @('COMMAND.COM'); At = 0x913; OldText = 'Windows 98 [Version %1]'; NewText = 'MS-DOS 7.1' }
        @{ Files = @('COMMAND.COM'); At = 0x22B5; OldText = 'Windows'; NewText = 'MS-DOS ' }
        @{ Files = @('COMMAND.COM'); At = 0x233E; OldText = 'Windows-Eingabeaufforderung.'; NewText = 'MS-DOS-Eingabeaufforderung. ' }
        @{ Files = @('COMMAND.COM'); At = 0x2497; OldText = 'Windows-Version'; NewText = 'MS-DOS-Version ' }
        @{ Files = @('COMMAND.COM'); At = 0x2781; OldText = 'Windows-Umgebungsvariablen oder zeigt sie an.'; NewText = 'MS-DOS-Umgebungsvariablen oder zeigt sie an. ' }
        @{ Files = @('COMMAND.COM'); At = 0x29E3; OldText = 'Windows-Version an.'; NewText = 'MS-DOS-Version an. ' }
        @{ Files = @('COMMAND.COM'); At = 0x39C7; OldText = 'Windows 98 [Version %1]'; NewText = 'MS-DOS Version 7.1' }
        @{ Files = @('COMMAND.COM'); At = 0x3AE2; OldText = 'Windows 98'; NewText = 'MS-DOS 7.1' }
        @{ Files = @('COMMAND.COM'); At = 0x3BA8; OldText = 'Windows-Befehlsinterpreters.'; NewText = 'MS-DOS-Befehlsinterpreters. ' }
        @{ Files = @('COMMAND.COM'); At = 0x8326; OldText = 'WINDOWS\COMMAND'; NewText = 'DOS\COMMAND' }
        @{ Files = @('COMMAND.COM'); At = 0x84E9; OldText = ' (C)Copyright 1981-1995 Microsoft Corp'; NewText = '.1 Copyright 1981-1995 Microsoft Corp.' }
        @{ Files = @('COMMAND.COM'); At = 0x15CED; OldText = ' (C)Copyright 1981-1995 Microsoft Corp'; NewText = '.1 Copyright 1981-1995 Microsoft Corp.' }
        @{ Files = @('COMMAND.COM'); At = 0x167CF; OldText = '4.10.2222'; NewText = '' }
        # runs on every DOS version (CMP AX,0A07h / JE -> JMP)
        @{ Files = @('COMMAND.COM'); At = 0x6E79; Old = '3D 07 0A 74'; New = '90 90 90 EB' }
    )
}
