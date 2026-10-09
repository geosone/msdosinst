# msdosinst - MS-DOS 7.1 disk set with the GeosOne DOS Installer

`mkdosset.ps1` builds a set of bootable 1.44 MB floppy images that install MS-DOS 7.1 with the [GeosOne DOS Installer](https://github.com/geosone/gdi):

1. Disk 1 boots and starts the setup (license, options).
2. No drive C: yet: FDISK starts, the computer restarts, the setup continues.
3. C: is not formatted: FORMAT.
4. SYS C:, MS-DOS to `C:\DOS` (the other disks are asked for), new `CONFIG.SYS` and `AUTOEXEC.BAT`.
5. Further software from other disks, e.g. [AHCIASPI](https://github.com/geosone/ahciaspi): the setup reads their `INSTALL.INI` and installs them in the same run.

The files are packed with deflate, so the MS-DOS 7.1 disks 1-4, the MS-DOS 6.22 Supplemental Disk and the Windows 95 "OLDMSDOS" utilities fit on 4 disks.

**This project contains no Microsoft files.** You need your own, licensed MS-DOS disks; the script takes the files from them. The license text the setup shows is a notice by default; give the Microsoft EULA of your product with `-Eula`.

## Use

PowerShell 5.1 (Windows) or PowerShell 7 (Windows, Linux, macOS):

    .\mkdosset.ps1 -List                       # the files the set needs
    .\mkdosset.ps1 -List -Source D:\dosfiles   # ... and which are missing
    .\mkdosset.ps1 -Source D:\dosfiles -Extra D:\ahciaspi

1. Copy the files of your disks into one folder (subfolders are fine). **[FILES.md](FILES.md) lists every file the set needs, with its size and the disk it comes from** (`-List` shows the same). A file name must not occur twice with different contents: the system files `IO.SYS`, `MSDOS.SYS`, `COMMAND.COM` and `SYS.COM` must be the MS-DOS 7.1 ones (IO.SYS 76036 bytes, from the system disk "W98_de"), not the older ones of DISK1.
2. Run the script: it writes `out\DISK1.IMG` ... `DISK4.IMG` and for each `-Extra` folder (with an `INSTALL.INI`) an `EXTRAn.IMG`.
3. Write the images to floppy disks (RawWrite, WinImage, `dd`) or use them in an emulator.

| Parameter | |
|---|---|
| `-Source` | folder with the files of your disks |
| `-Out` | output folder (default `.\out`) |
| `-Set` | disk set in `sets\` (default `msdos71de`) |
| `-List` | only list the files the set needs |
| `-Eula` | license text to show (e.g. the Microsoft EULA) |
| `-Installer` | `INSTALL.EXE` (default `.\INSTALL.EXE`, then `..\gdi\build\INSTALL.EXE`) |
| `-Extra` | folders of further software, one extra disk each |
| `-Dirs` | also write the disk contents to folders |

## Disk sets

`sets\msdos71de\` (German):

| File | |
|---|---|
| `set.psd1` | the files needed (and their disks), the archive layout, names of compressed files |
| `INSTALL.INI` | the setup (options, `CONFIG.SYS`, `AUTOEXEC.BAT`, texts) |
| `LIZENZ.TXT` | the license notice shown by default |
| `LIESMICH.TXT` | readme |

Options of the setup: HIMEM.SYS, EMM386.EXE (NOEMS), German keyboard and country, MS-DOS Shell (VGA), MS-DOS 5.0/6.22 utilities, Windows 95 MS-DOS utilities (MEMMAKER, MSBACKUP, ...), AccessDOS, keyboard utilities, DRVBOOT, MS-DOS 6.22 network files.

`tools\mkfilelist.ps1 -Source <folder>` writes `FILES.md` from `set.psd1`.

## How it works

- `tools\GdiDisk.ps1` / `GdiDisk.cs` (from the GDI project): FAT12 image writer with our own boot sector for the MS-DOS 7.x `IO.SYS`, SZDD/KWAJ expand (the `*.??_` files), GDA archives (deflate, split over disks).
- Disk 1: `IO.SYS`, `MSDOS.SYS`, `COMMAND.COM`, `SYS.COM`, `FDISK`, `FORMAT`, `KEYB`, `INSTALL.EXE`, `INSTALL.INI`, texts and the first archive part; the other disks hold the archive parts `MSDOS71.D02` ...

Tested in QEMU: empty 500 MB disk, FDISK, restart, FORMAT, installation from 4 disks, AHCIASPI from an extra disk, boot from C: with CD-ROM (ASPICD + MSCDEX).

## License

GNU General Public License version 3 (see `LICENSE`). MS-DOS is a trademark of Microsoft Corporation; this project is not affiliated with Microsoft.
