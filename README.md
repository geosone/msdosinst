# msdosinst - MS-DOS and German PC-DOS installation disk sets

A German **PC-DOS 7.1** set is also available: PC-DOS 2000 German programs
with the FAT32 kernel from IBM ServerGuide Scripting Toolkit DOS 1.3.07.
It has a German interactive FDISK menu and keeps the original German
FDISK and FORMAT as `FDISK16.COM` and `FORMAT16.COM`.

```powershell
./mkdosset.ps1 -Set pcdos71de -Download -Out ./out/pcdos71de
./mkdosset.ps1 -Set pcdos71de -Download -Out ./out/pcdos71de -Iso -Extra AHCIASPI.IMG
```

See [PC-DOS instructions](sets/pcdos71de/README.md) for sources,
dependencies, compatibility patches and [tests](sets/pcdos71de/TESTED.md).
The default set remains `msdos71de`; the MS-DOS instructions follow below.

`mkdosset.ps1` builds a set of bootable 1.44 MB floppy images that install MS-DOS 7.1 with the [GeosOne Dual Installer](https://github.com/geosone/gdi):

1. Disk 1 boots and starts the setup (license, options).
2. No drive C: yet: FDISK starts, the computer restarts, the setup continues.
3. C: is not formatted: FORMAT.
4. SYS C:, MS-DOS to `C:\DOS` (the other disks are asked for), new `CONFIG.SYS` and `AUTOEXEC.BAT`.
5. Further software from other disks, e.g. [AHCIASPI](https://github.com/geosone/ahciaspi): the setup reads their `INSTALL.INI` and installs them in the same run.

The set replaces MS-DOS 6.22 and its Supplemental Disk with the newest MS-DOS programs of Windows ME and Windows 98 SE (the system is MS-DOS 7.1 of Windows 98 SE), plus the MS-DOS 6.22 and Windows 95 "OLDMSDOS" programs that are not in them (DEFRAG is left out: the 6.22 one knows neither long file names nor FAT32, those of Windows 95/98/ME run only under Windows) and the Windows 3.x programs of MS-DOS 6.22, and the Microsoft mouse driver (Mouse 11.0, patched for PS/2 mice with today's BIOSes). The files are packed with deflate and fit on 4 disks. Of the CD-ROM and SCSI drivers only `MSCDEX.EXE` is in the set: the drivers come as extra disks (`-Extra`), [AHCIASPI](https://github.com/geosone/ahciaspi) for SATA/IDE and [EUSBASPI](https://github.com/geosone/eusbaspi) for USB drives, which bring the [OpenASPI](https://github.com/geosone/OpenAspi) drivers (`ASPICDA.SYS`, `ASPIDSK.SYS`, `ASPIFDD.SYS`, `ASPITAP.SYS`) and SHSUCDX since 0.4. `ASPICD.SYS`/`ASPIDISK.SYS` of your own Adaptec EZ-SCSI CD ([ezscsi](https://github.com/geosone/ezscsi)) still work as another extra disk.

**This project contains no Microsoft or IBM programs.** You need your own, licensed CDs and disks; the script takes the files from them. The setup shows, one after another, a notice (`LIZENZ.TXT`, or your own text with `-Eula`) and the Microsoft license terms of Windows ME, Windows 98 SE and Windows 95 (from `PRECOPY1.CAB` of the German CDs) and of MS-DOS 6.22 (the OEM license printed in the MS-DOS 6.22 User's Guide; the disks contain none).

## Use

PowerShell 5.1 (Windows) or PowerShell 7 (Windows, Linux). The **release zip** (GitHub Releases) has everything else: the submodules, `INSTALL.EXE`, 7-Zip for Windows and Linux (`tools\7zip`), nasm and apack1p for Windows (`ext\small-io-sys\tools\win`) and the Linux tools of small-io-sys; unpack it and run the script. From git: clone with the submodules (`git clone --recursive`, or `git submodule update --init`); 7-Zip then comes from the PATH or Program Files, on Windows nasm and apack1p are downloaded on the first run.

    .\mkdosset.ps1 -List                       # the files the set needs
    .\mkdosset.ps1 -List -Source D:\dosfiles   # ... and which are missing
    .\mkdosset.ps1 -Source D:\dosfiles -Extra AHCIASPI.IMG, EUSBASPI.IMG
    .\mkdosset.ps1 -Source D:\dosfiles -Iso -Extra AHCIASPI.IMG, EUSBASPI.IMG
    .\mkdosset.ps1 -Download -Iso -Extra AHCIASPI.IMG, EUSBASPI.IMG   # media from WinWorld

1. Put your German Windows ME, Windows 98 SE and Windows 95 CDs and your MS-DOS 6.22 disks (with the Supplemental Disk), optionally the Microsoft Mouse 11.0 disk, into one folder (subfolders are fine): as images (`*.iso`, `*.img`, or 7-Zip archives `*.7z` of them, e.g. `Windows ME.CD1.iso` and `Disk01.img` ... `Disk04 - Supplemental.img` - the script unpacks them with [7-Zip](https://www.7-zip.org/) into `-Cache` and keeps them there for the next run), or as files: the folders `WIN9X` and `TOOLS\OLDMSDOS` of the ME CD, `WIN98` of the 98 SE CD, `OTHER\OLDMSDOS` of the 95 CD (keep the folders) and the files of the disks (disk 1 in its own folder: the Supplemental Disk has another `EXPAND.EXE`). **[FILES.md](FILES.md) lists every file the set needs, with its place on the CD (CAB) and its size** (`-List` shows the same). The script extracts the files from the CABs (cabextract on Linux - `ext\small-io-sys\tools`, `expand.exe` on Windows). `IO.SYS` and `COMMAND.COM` come from `WIN98\PRECOPY1.CAB` and `PRECOPY2.CAB` of the Windows 98 SE CD (see below), `MSDOS.SYS` is written by the script.
   Or let the script download them: `-Download` fetches every medium that is missing in `-Source` (all of them without `-Source`) from [WinWorld](https://winworldpc.com): MS-DOS 6.22 [German], Windows 95 [German] (OEM) (ISO), Windows 98 Second Edition [German] (OEM), Windows ME [German] and Microsoft Mouse 11.0, about 1.3 GB (`sets\msdos71de\downloads.txt`). They go to `-Cache\download`, are checked by SHA-256 and kept for the next run. You still need a license for each product.
2. Run the script: it writes `out\DISK1.IMG` ... `DISK4.IMG` and for each `-Extra` package (a folder or disk image with an `INSTALL.INI`) an `EXTRAn.IMG`.
3. Write the images to floppy disks (RawWrite, WinImage, `dd`) or use them in an emulator.

| Parameter | |
|---|---|
| `-Source` | folder with your CDs and disks (images, 7-Zip archives or files) |
| `-Download` | download the media missing in `-Source` from WinWorld (`downloads.txt` of the set) |
| `-Cache` | folder for the unpacked images (default `mkdosset-cache` in the temp folder) |
| `-Out` | output folder (default `.\out`) |
| `-Set` | disk set in `sets\` (default `msdos71de`) |
| `-List` | only list the files the set needs |
| `-Eula` | text shown instead of the notice `LIZENZ.TXT` |
| `-Installer` | `INSTALL.EXE` (default `.\INSTALL.EXE`, then `..\gdi\build\INSTALL.EXE`) |
| `-Disk1Free` | kilobytes left free on disk 1 for files of your own, e.g. the driver of a controller (default 256) |
| `-Extra` | further software, one extra disk each: folders or disk images (`AHCIASPI.IMG`, `EUSBASPI.IMG` of `make package`, `EZSCSI.IMG` of [ezscsi](https://github.com/geosone/ezscsi)); Setup offers them with the options (`[Extras]`) and asks for each disk chosen, in this order |
| `-Dirs` | also write the disk contents to folders |
| `-Iso` | also create a bootable `out\INSTALL.ISO` with all installation files |
| `-CdDriver` | DOS CD-ROM driver for the ISO, accepting `/D:MSCD001`, when `-Extra` has no AHCIASPI disk 0.4 (or AHCIASPI with the EZ-SCSI disk); default: `OAKCDROM.SYS` found in `-Source` |

### Installation CD

`-Iso` creates a BIOS-bootable El Torito CD in addition to the floppy images.
It requires **xorriso**, **genisoimage** or **mkisofs** on PATH (Windows or
Linux). The boot disk of the CD finds the CD-ROM drive with `AHCIASPI.SYS`
(SATA/AHCI and IDE) and `ASPICDA.SYS` of OpenASPI, both on the AHCIASPI
disk 0.4 given with `-Extra` (with an older AHCIASPI disk: `ASPICD.SYS` of
the EZ-SCSI disk). Without them, `-CdDriver` names a DOS CD-ROM
driver such as `OAKCDROM.SYS` from your own boot disk (it must accept
`/D:MSCD001`). `MSCDEX.EXE` is taken from the DOS files already collected
for the set.

The CD boots with a 1.44 MB floppy image on A:, loads the CD driver, the mouse driver and
MSCDEX, assigns the CD to R:, and starts `R:\SETUP\INSTALL.EXE`. All archive
parts are in `R:\SETUP`, so installation needs no floppy changes. Boot from
the CD again after FDISK restarts the computer. Remove the CD when setup
finishes. This is a legacy BIOS CD; it requires BIOS/CSM boot and a CD
drive on a SATA (AHCI) or IDE controller (or one the `-CdDriver` supports).

Each `-Extra` package is also copied to `R:\EXTRA1`, `R:\EXTRA2`, etc.; the
packages chosen from the list are installed from there without a question.
The extra software dialog afterwards starts at `R:\EXTRA1`; enter another
directory to install another package.

You can also create the ISO from an existing disk set without rebuilding it:

    pwsh -File tools/mkdosiso.ps1 -Disks ./out -Mscdex ./MSCDEX.EXE -Extra AHCIASPI.IMG

This writes `out/INSTALL.ISO`. Use `-Iso <path>` on **mkdosiso.ps1** to choose
another filename and `-Extra <folders or images>` to include additional packages.

## Disk sets

`sets\msdos71de\` (German):

| File | |
|---|---|
| `set.psd1` | the files needed (CDs, CABs, disks), the archive layout, names of compressed files, the patches |
| `INSTALL.INI` | the setup (options, `CONFIG.SYS`, `AUTOEXEC.BAT`, texts) |
| `LIZENZ.TXT` | the license notice shown first |
| `EULAME.TXT`, `EULA98SE.TXT`, `EULA95.TXT`, `EULA622.TXT` | the Microsoft license terms shown after it (`LicenseN=` in `INSTALL.INI`) |
| `LIESMICH.TXT` | readme |
| `format-s.asm` | source of the `FORMAT /S` patch (in `set.psd1`) |
| `mouse-ps2.asm` | source of the PS/2 patch of `MOUSE.EXE` (in `set.psd1`) |
| `downloads.txt` | the WinWorld downloads of `-Download`: medium, SHA-256, URL, file name |
| `mouse-de.lan` | German messages of `MOUSE.EXE`, written as `MOUSE.LAN` (`Texts` in `set.psd1`) |

Options of the setup: HIMEM.SYS, EMM386.EXE (NOEMS), German keyboard and country, MS-DOS Shell (VGA), MS-DOS 5.0/6.22 utilities, Windows 95 MS-DOS utilities (MEMMAKER, MSBACKUP, ...), AccessDOS, keyboard utilities, DRVBOOT, MS-DOS 6.22 network files, Windows 3.x programs of MS-DOS 6.22 (MWBACKUP, MWAV, MWUNDEL, SMARTMON; off by default), SHARE (`INSTALL=` in `CONFIG.SYS`, off by default; MS-DOS 7.1 has no SHARE of its own, Windows 3.x wants it), the Microsoft mouse driver in `AUTOEXEC.BAT` (when the mouse disk was in `-Source`).

`tools\mkfilelist.ps1 -Source <folder>` writes `FILES.md` from `set.psd1`.

## How it works

- `tools\GdiDisk.ps1` / `GdiDisk.cs` (from the GDI project): FAT12 image writer with our own boot sector for the MS-DOS 7.x `IO.SYS`, SZDD/KWAJ expand (the `*.??_` files), GDA archives (deflate, split over disks).
- `IO.SYS`: [small-io-sys](https://github.com/geosone/small-io-sys) (submodule `ext\small-io-sys`, German build `compile.ps1 de`) makes it from `winboot.sys` of the CD: the changes of the Microsoft update KB311561, MS-DOS 7.1 instead of Windows 98 in the messages, without logo and MSDCM, compressed with aPACK (72,815 bytes). On Windows it downloads nasm and [apack1p](https://github.com/pts/apack1p) (submodule `ext\apack1p`, the source) once.
- `COMMAND.COM`: the one of the same CD, with MS-DOS 7.1 in the messages (`Patches` in `set.psd1`), like on the MS-DOS 7.1 system disk.
- The programs of Windows ME check for MS-DOS 8.00; the script patches the check to 7.10 (likewise the 6.22 programs, which check for 6.22). Without a Windows ME counterpart are taken from Windows 98 SE: `SYS.COM`, `KEYB.COM`, `NLSFUNC.EXE`, `EXT.EXE`.
- `FDISK.EXE` (Windows ME): sizes of 100,000 MB and more with 6 digits, as in the FDISK of KB263044 fixed by Petr ([MSFN](https://msfn.org/board/topic/85573-corrected-fdisk-and-format/)), ported to the Windows ME FDISK.
- `FORMAT.COM` (Windows ME): the size in MB was stored in 16 bits ("16,859,84 MB" for 82,396 MB); now in 32 bits.
- `FORMAT.COM` (Windows ME): `/S` works again. Windows ME only answers it with "Microsoft Windows unterstützt den Befehl format /s nicht mehr" and no longer reads the system files; now `/S` sets the flag of Windows 98 again and the copy routine runs `%COMSPEC% /C SYS x:` ([format-s.asm](sets/msdos71de/format-s.asm)).
- `MOUSE.EXE` (Microsoft Mouse 11.0, English; there is no German one): it initializes the PS/2 mouse with packets of 1 byte, which SeaBIOS (QEMU) and other newer BIOSes refuse ("mouse not found"); now with packets of 3 bytes, the BIOS callback takes the whole packet ([mouse-ps2.asm](sets/msdos71de/mouse-ps2.asm)). Serial mice are unchanged. Its messages are German (`mouse-de.lan` in place of the English `MOUSE.LAN`). The setup disk loads it before the setup, the installed system with the option in `AUTOEXEC.BAT`. Without the mouse disk in `-Source` both are left out.
- The setup formats C: with `FORMAT /V:DOS /AUTOTEST` (the hidden switch of the Windows 98/ME FORMAT: no J/N question, the setup has asked before) and the label `DOS` as MS-DOS 6.22 did; `FORMAT.COM` is patched so that `/AUTOTEST` writes the label of `/V:` (before it left it out).
- The installation CD runs FDISK and FORMAT from its boot disk A: and `SYS A: C:` (started from the CD, FORMAT stopped at "CDR101: Not ready" reading R:, unseen under the setup, and `SYS C:` answered "Ungültige Funktion").
- MS-DOS instead of Windows in the titles and messages of `FDISK`, `HIMEM.SYS`, `EMM386.EXE`, `SETVER`, `SYS` and `DRVSPACE.BIN` (as in `COMMAND.COM`); references to other systems (Windows NT, Windows 3.x in enhanced mode) stay.
- Disk 1: `IO.SYS`, `MSDOS.SYS`, `COMMAND.COM`, `SYS.COM`, `FDISK`, `FORMAT`, `KEYB`, `INSTALL.EXE`, `INSTALL.INI`, texts, `MOUSE.EXE` with `MOUSE.LAN` and the first archive part; the other disks hold the archive parts `MSDOS71.D02` ...

Tested in QEMU: empty 2 GB disk, FDISK, restart, FORMAT, installation from 4 disks, all programs from C: (`/?`), SHARE, DRIVER.SYS, RAMDRIVE, VSAFE, MSAV, FDISK and FORMAT on 100 and 200 GB disks, `FORMAT A: /S` (the disk boots), AHCIASPI from an extra disk, boot from C: with CD-ROM (ASPICD + MSCDEX).

## License

GNU General Public License version 3 (see `LICENSE`). MS-DOS is a trademark of Microsoft Corporation; this project is not affiliated with Microsoft.
