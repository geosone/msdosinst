# msdosinst - MS-DOS 7.1 disk set with the GeosOne DOS Installer

`mkdosset.ps1` builds a set of bootable 1.44 MB floppy images that install MS-DOS 7.1 with the [GeosOne DOS Installer](https://github.com/geosone/gdi):

1. Disk 1 boots and starts the setup (license, options).
2. No drive C: yet: FDISK starts, the computer restarts, the setup continues.
3. C: is not formatted: FORMAT.
4. SYS C:, MS-DOS to `C:\DOS` (the other disks are asked for), new `CONFIG.SYS` and `AUTOEXEC.BAT`.
5. Further software from other disks, e.g. [AHCIASPI](https://github.com/geosone/ahciaspi): the setup reads their `INSTALL.INI` and installs them in the same run.

The files are packed with deflate, so the MS-DOS 7.1 disks 1-4, the MS-DOS 6.22 Supplemental Disk and the Windows 95 "OLDMSDOS" utilities fit on 4 disks.

**This project contains no Microsoft programs.** You need your own, licensed MS-DOS disks; the script takes the files from them. The setup shows, one after another, a notice (`LIZENZ.TXT`, or your own text with `-Eula`) and the Microsoft license terms of Windows 98 SE and Windows 95 (from `PRECOPY1.CAB` of the German CDs) and of MS-DOS 6.22 (the OEM license printed in the MS-DOS 6.22 User's Guide; the disks contain none).

## Use

PowerShell 5.1 (Windows) or PowerShell 7 (Windows, Linux): clone with the submodules (`git clone --recursive`, or `git submodule update --init`).

    .\mkdosset.ps1 -List                       # the files the set needs
    .\mkdosset.ps1 -List -Source D:\dosfiles   # ... and which are missing
    .\mkdosset.ps1 -Source D:\dosfiles -Extra D:\ahciaspi

1. Copy the files of your disks into one folder (subfolders are fine). **[FILES.md](FILES.md) lists every file the set needs, with its size and the disk it comes from** (`-List` shows the same). A file name must not occur twice with different contents: `SYS.COM` must be the MS-DOS 7.1 one of the system disk "W98_de", not the older one of DISK1. `IO.SYS` and `COMMAND.COM` come from `WIN98\PRECOPY1.CAB` and `PRECOPY2.CAB` of the Windows 98 SE CD (see below), `MSDOS.SYS` is written by the script.
2. Run the script: it writes `out\DISK1.IMG` ... `DISK4.IMG` and for each `-Extra` folder (with an `INSTALL.INI`) an `EXTRAn.IMG`.
3. Write the images to floppy disks (RawWrite, WinImage, `dd`) or use them in an emulator.

| Parameter | |
|---|---|
| `-Source` | folder with the files of your disks |
| `-Out` | output folder (default `.\out`) |
| `-Set` | disk set in `sets\` (default `msdos71de`) |
| `-List` | only list the files the set needs |
| `-Eula` | text shown instead of the notice `LIZENZ.TXT` |
| `-Installer` | `INSTALL.EXE` (default `.\INSTALL.EXE`, then `..\gdi\build\INSTALL.EXE`) |
| `-Extra` | folders of further software, one extra disk each |
| `-Dirs` | also write the disk contents to folders |

## Disk sets

`sets\msdos71de\` (German):

| File | |
|---|---|
| `set.psd1` | the files needed (and their disks), the archive layout, names of compressed files |
| `INSTALL.INI` | the setup (options, `CONFIG.SYS`, `AUTOEXEC.BAT`, texts) |
| `LIZENZ.TXT` | the license notice shown first |
| `EULA98SE.TXT`, `EULA95.TXT`, `EULA622.TXT` | the Microsoft license terms shown after it (`LicenseN=` in `INSTALL.INI`) |
| `LIESMICH.TXT` | readme |

Options of the setup: HIMEM.SYS, EMM386.EXE (NOEMS), German keyboard and country, MS-DOS Shell (VGA), MS-DOS 5.0/6.22 utilities, Windows 95 MS-DOS utilities (MEMMAKER, MSBACKUP, ...), AccessDOS, keyboard utilities, DRVBOOT, MS-DOS 6.22 network files.

`tools\mkfilelist.ps1 -Source <folder>` writes `FILES.md` from `set.psd1`.

## How it works

- `tools\GdiDisk.ps1` / `GdiDisk.cs` (from the GDI project): FAT12 image writer with our own boot sector for the MS-DOS 7.x `IO.SYS`, SZDD/KWAJ expand (the `*.??_` files), GDA archives (deflate, split over disks).
- `IO.SYS`: [small-io-sys](https://github.com/geosone/small-io-sys) (submodule `ext\small-io-sys`, German build `compile.ps1 de`) makes it from `winboot.sys` of the CD: the changes of the Microsoft update KB311561, MS-DOS 7.1 instead of Windows 98 in the messages, without logo and MSDCM, compressed with aPACK (72,815 bytes). On Windows it downloads nasm and [apack1p](https://github.com/pts/apack1p) (submodule `ext\apack1p`, the source) once.
- `COMMAND.COM`: the one of the same CD, with MS-DOS 7.1 in the messages (`Patches` in `set.psd1`), like on the MS-DOS 7.1 system disk.
- Disk 1: `IO.SYS`, `MSDOS.SYS`, `COMMAND.COM`, `SYS.COM`, `FDISK`, `FORMAT`, `KEYB`, `INSTALL.EXE`, `INSTALL.INI`, texts and the first archive part; the other disks hold the archive parts `MSDOS71.D02` ...

Tested in QEMU: empty 500 MB disk, FDISK, restart, FORMAT, installation from 4 disks, AHCIASPI from an extra disk, boot from C: with CD-ROM (ASPICD + MSCDEX).

## License

GNU General Public License version 3 (see `LICENSE`). MS-DOS is a trademark of Microsoft Corporation; this project is not affiliated with Microsoft.
