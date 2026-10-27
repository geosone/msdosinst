# PC-DOS 2000 German programs with the FAT32 kernel of PC-DOS 7.1.
@{
    Name = 'PCDOS71'
    Label = 'PCDOS71'
    Keyboard = 'GR'
    Media = @{
        PcDos = @{ Name = 'IBM PC-DOS 2000 German, disk 1'; Find = 'UNPACK2.EXE' }
        Toolkit = @{ Name = 'IBM ServerGuide Scripting Toolkit DOS 1.3.07'; Find = 'sgdeploy\sgtk\DOS\IBMBIO.COM' }
    }
    System = @('Toolkit:sgdeploy\sgtk\DOS\IBMBIO.COM', 'Toolkit:sgdeploy\sgtk\DOS\IBMDOS.COM', 'PcDos:COMMAND.COM', 'PcDos:SYS.COM')
    SystemFrom = 'PC-DOS 2000 German and ServerGuide PC-DOS 7.1'
    BootSector = 'PcDos:BOOTSECT.BIN'
    BootFiles = @('Toolkit:sgdeploy\sgtk\DOS\FDISK32.COM', 'Toolkit:sgdeploy\sgtk\DOS\FORMAT32.COM',
                  'PcDos:KEYB.COM', 'PcDos:KEYBOARD.SYS', 'PcDos:CHOICE.COM', 'PcDos:FDISK.COM=FDISK16.COM', 'PcDos:FORMAT.COM=FORMAT16.COM')
    BootFrom = 'PC-DOS 2000 German and ServerGuide PC-DOS 7.1'
    BootDriver = @('MOUSE.COM')
    BootDriverFrom = 'PC-DOS 2000 German DOS3 bundle'
    BootRun = @('SET MOUSE=A:\NOINI', 'A:\MOUSE.COM')
    BootAsm = @{ 'SYS32.COM' = 'sys32.asm'; 'FDISK.COM' = 'fdisk-menu.asm'; 'FORMAT.COM' = 'format.asm' }
    Fat32BootTemplate = 'FORMAT32.COM'
    IbmBundles = @('DOS1', 'DOS2', 'DOS3', 'DOS4', 'SHELL1', 'SHELL2', 'REXX')
    Archive = @(
        @{ Name = 'PC-DOS 2000 German base'; From = 'PC-DOS 2000 German disk 1'; Medium = 'PcDos'; To = 'DOS'
           Files = @('ATTRIB.EXE', 'COUNTRY.SYS', 'DEBUG.COM', 'DISKCOPY.COM', 'DISPLAY.SYS', 'E.EXE', 'E.EX', 'E.INI', 'EHELP.HLP', 'EGA.CPI', 'MEM.EXE', 'MODE.COM', 'QCONFIG.EXE', 'WINA20.386') }
        @{ Name = 'PC-DOS 2000 German utilities'; From = 'PC-DOS 2000 German DOS1-DOS4 bundles'; To = 'DOS'
           Files = @('ACALC.EXE', 'APPEND.EXE', 'ANSI.SYS', 'ASSIGN.COM', 'BROWSE.COM', 'CMOSCLK.SYS', 'CRC.EXE', 'DELTREE.EXE', 'DISKCOMP.COM',
                     'DOSKEY.COM', 'DRIVER.SYS', 'DRVLOCK.EXE', 'DYNALOAD.COM', 'EGA.SYS', 'EGAX.CPI', 'EJECT.EXE', 'EMM386.EXE', 'FC.EXE',
                     'FILEUP.EXE', 'FILEUP.HLP', 'FIND.EXE', 'HELP.COM', 'HIMEM.SYS', 'INTERLNK.EXE', 'INTERSVR.EXE', 'ISO.CPI', 'JOIN.EXE', 'LABEL.COM',
                     'LOADFIX.COM', 'MORE.COM', 'MOUSE.COM', 'MOVE.EXE', 'NLSFUNC.EXE', 'POWER.EXE', 'PRINT.COM', 'RAMDRIVE.SYS', 'REPLACE.EXE',
                     'SETVER.EXE', 'SORT.EXE', 'SUBST.EXE', 'TREE.COM', 'XCOPY.EXE', 'CMDREF.INF', 'DOSERROR.INF', 'DOSREXX.INF',
                     'VIEW.EXE', 'VIEW.OVL', 'VIEW.LIB', 'VIEW.HLP', 'VIEW.OHP') }
        @{ Name = 'PC-DOS Shell'; From = 'PC-DOS 2000 German SHELL1/SHELL2 bundles'; To = 'SHELL'; Optional = $true
           Files = @('DOSSHELL.COM', 'DOSSHELL.EXE', 'DOSSHELL.HLP', 'DOSSWAP.EXE', 'VGA.GRB=DOSSHELL.GRB', 'EGA.INI=DOSSHELL.INI', 'VGA.VID=DOSSHELL.VID') }
        @{ Name = 'REXX'; From = 'PC-DOS 2000 German REXX bundle'; To = 'REXX'; Optional = $true
           Files = @('REXX.EXE', 'REXXDUMP.EXE', 'RX.BAT', 'RXCLS.RX', 'RXDOSVER.RX', 'RXGETDIR.RX', 'RXGETDRV.RX', 'RXGETKEY.RX', 'RXGETMEM.RX', 'RXQSYS.RX', 'RXSLEEP.RX') }
    )
    ExpandNames = @{}
    ExpandExt = @{}
    Pklite = @{ 'SYS.COM' = @{ Start = 460; Size = 14544; Sha256 = '91cc8d396e806878d1fd034f96ce454d0a0b28ad471f76974bd5882814d461b7' } }
    Patches = @(
        # SYS must accept both 7.00 and 7.10 system-file headers.
        @{ Files = @('SYS.COM'); At = 0x8A7; Old = '83 3E F3 23 07'; New = '80 3E F3 23 07'; Required = $true }
        # SYS.COM is expanded first; accept DOS 7.10 instead of 7.00.
        @{ Files = @('SYS.COM'); At = 0x4EE; Old = '3D 00 07'; New = '3D 0A 07'; Required = $true }
        # APPEND is PKLITE packed. These two literal bytes decode to
        # TEST AX,0000 instead of CMP AX,0007; JNE is never taken.
        # Verified that decompression changes only those two code bytes.
        @{ Files = @('APPEND.EXE'); At = 0x1415; Old = '3D 07'; New = 'A9 00'; Required = $true }
        @{ Files = @('COMMAND.COM'); OldText = 'PC DOS Version 7.00'; NewText = 'PC DOS Version 7.10'; Count = 2; Required = $true }
        @{ Files = @('COMMAND.COM'); At = 3; Old = '70'; New = '7A'; Required = $true }
        @{ Files = @('COMMAND.COM'); At = 0x170E; Old = '3D 07 00'; New = '3D 07 0A'; Required = $true }
    )
    Translations = 'messages-de.tsv'
}
