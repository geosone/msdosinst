# MS-DOS 7.1 (German) disk set: the files mkdosset.ps1 needs from your own
# disks and where they go in the archive (see INSTALL.INI).
#
# Copy the files of your disks into one folder (subfolders are fine) and
# give it with -Source; mkdosset.ps1 -List shows this list.  File names as
# on the disks; compressed files (*.??_, SZDD/KWAJ) are expanded.
@{
    Name   = 'MSDOS71'            # archive MSDOS71.D01, MSDOS71.D02, ...
    Label  = 'MSDOS71'            # volume labels "MSDOS71 1", ...
    Keyboard = 'GR'               # KEYB on the setup disk

    # disk 1: the MS-DOS 7.1 system files, the boot sector is written by
    # mkdosset.ps1.  IO.SYS is built by ext/small-io-sys (compile.sh de) from
    # winboot.sys of the Windows 98 SE CD, COMMAND.COM is the one of the same
    # CD (see Patches); both are in WIN98\PRECOPY1.CAB, continued in
    # PRECOPY2.CAB.  MSDOS.SYS is MsdosSys, SYS.COM comes from the system disk.
    System     = @('IO.SYS', 'MSDOS.SYS', 'COMMAND.COM', 'SYS.COM')
    SystemFrom = 'MS-DOS 7.1 system disk "W98_de" (Win98_System_deutsch.IMG)'
    IoSysCabs  = @('PRECOPY1.CAB', 'PRECOPY2.CAB')
    IoSysFrom  = 'Windows 98 SE CD, folder WIN98'
    # the options that the IO.SYS of the system disk had built in
    MsdosSys   = @('[Options]', 'BootKeys=0', 'Logo=0', 'DblSpace=0', 'DrvSpace=0', 'SystemReg=0')
    BootFiles  = @('FDISK.EXE', 'FORMAT.COM', 'KEYB.COM', 'KEYBOARD.SYS', 'KEYBRD2.SYS')
    BootFrom   = 'MS-DOS 7.1 disk 1'

    # archive: Files (as on the disks), Zip = self-extracting ZIP archive,
    # To = directory in the archive, Optional = may be missing,
    # KeepFirst = leave out names that are already in DOS\,
    # "A=B" = store file A (after expanding) as B
    Archive = @(
        @{ Name = 'MS-DOS 7.1 (disks 1-4)'; From = 'MS-DOS 7.1 disks 1-4'; To = 'DOS'; Zip = $true
           Files = @('DISK1.EXE', 'DISK2.EXE', 'DISK3.EXE', 'DISK4.EXE') }
        @{ Name = 'MS-DOS 7.1 (disk 4)'; From = 'MS-DOS 7.1 disk 4'; To = 'DOS'
           Files = @('POWER.EX_', 'PRINT.EX_', 'SETVER.EX_', 'SHARE.EX_') }
        @{ Name = 'Logo'; From = 'MS-DOS 7.1 disk 1'; To = 'ROOT'; Optional = $true
           Files = @('LOGO.SY_') }
        @{ Name = 'MS-DOS Shell'; From = 'MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)'; To = 'SUPP\SHELL'; Optional = $true; KeepFirst = $true
           Files = @('DOSSHELL.CO_', 'DOSSHELL.EX_', 'DOSSHELL.HL_', 'DOSSWAP.EX_',
                     'VGA.GR_=DOSSHELL.GRB', 'EGA.IN_=DOSSHELL.INI', 'VGA.VI_=DOSSHELL.VID') }
        @{ Name = 'MS-DOS 5.0 utilities'; From = 'MS-DOS 6.22 Supplemental Disk (Zusatzdiskette)'; To = 'SUPP\DOS5'; Optional = $true; KeepFirst = $true
           Files = @('ASSIGN.CO_', 'BACKUP.EX_', 'COMP.EX_', 'CV.COM', 'EDLIN.EX_', 'JOIN.EX_', '4201.CP_',
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
        @{ Name = 'MS-DOS utilities for Windows 95 (OLDMSDOS)'; From = 'Windows 95 CD, folder OTHER\OLDMSDOS'; To = 'OLD'; Optional = $true; KeepFirst = $true
           Files = @('APPEND.EXE', 'CHKSTATE.SYS', 'GRAPHICS.COM', 'GRAPHICS.PRO', 'HELP.COM', 'HELP.HLP',
                     'INTERLNK.EXE', 'INTERSVR.EXE', 'LOADFIX.COM', 'MEMMAKER.EXE', 'MEMMAKER.HLP', 'MEMMAKER.INF',
                     'MONOUMB.386', 'PRINT.EXE', 'QBASIC.EXE', 'QBASIC.HLP', 'REPLACE.EXE', 'RESTORE.EXE',
                     'SIZER.EXE', 'TREE.COM', 'UNDELETE.EXE', 'MSBACKDB.OVL', 'MSBACKDR.OVL', 'MSBACKFB.OVL',
                     'MSBACKFR.OVL', 'MSBACKUP.EXE', 'MSBACKUP.HLP', 'MSBACKUP.OVL', 'MSBCONFG.HLP', 'MSBCONFG.OVL') }
    )

    # names of compressed files that do not store them (KWAJ files of the
    # MS-DOS 6.22 Supplemental Disk): extension map and exceptions
    ExpandExt   = @{ 'CO_' = 'COM'; 'EX_' = 'EXE'; 'SY_' = 'SYS'; 'TX_' = 'TXT'; 'OV_' = 'OVL'; 'CP_' = 'CPI'
                     'BA_' = 'BAS'; 'GR_' = 'GRB'; 'IN_' = 'INI'; 'VI_' = 'VID'; 'HL_' = 'HLP'; '1X_' = '1XE'
                     '2X_' = '2XE'; 'DO_' = 'DOS' }
    ExpandNames = @{ 'DRVBOOT.BA_' = 'DRVBOOT.BAT' }

    # version checks of the MS-DOS 6.22 programs (Supplemental Disk and the
    # OLDMSDOS utilities of Windows 95): they accept only MS-DOS 6.22
    # (CMP AX,1606h) resp. 6.20-6.x (AM.EXE, INT 21h AX=3306h) and are
    # patched to accept MS-DOS 7.10; each byte string must occur exactly once
    Patches = @(
        @{ Files = @('APPEND.EXE', 'ASSIGN.COM', 'BACKUP.EXE', 'EDLIN.EXE', 'EXE2BIN.EXE', 'GRAFTABL.COM',
                     'GRAPHICS.COM', 'JOIN.EXE', 'REPLACE.EXE', 'RESTORE.EXE', 'TREE.COM')
           Old = 'B4 30 CD 21 3D 06 16 75 03'; New = 'B4 30 CD 21 3D 07 0A 75 03' }
        @{ Files = @('APPEND.EXE')
           Old = 'B4 30 E8 CF FD 3D 06 16 75 02'; New = 'B4 30 E8 CF FD 3D 07 0A 75 02' }
        @{ Files = @('AM.EXE')
           Old = '80 7E E6 06 75 06 80 7E E7 14'; New = '80 7E E6 07 75 06 80 7E E7 0A' }

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
