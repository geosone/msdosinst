<#
.SYNOPSIS
    Builds a bootable installation CD from a mkdosset floppy set.
.DESCRIPTION
    Requires xorriso, genisoimage or mkisofs on PATH and MSCDEX.EXE.  The
    boot disk of the CD finds the CD-ROM drive with AHCIASPI.SYS (SATA/IDE)
    and ASPICD.SYS, taken from the -Extra packages (the AHCIASPI disk and
    the EZ-SCSI disk of ezscsi); without them, -CdDriver names a DOS CD-ROM
    driver compatible with /D:MSCD001 (e.g. OAKCDROM.SYS).
    No Microsoft files or CD-ROM drivers are included in this project.
.EXAMPLE
    ./tools/mkdosiso.ps1 -Disks ./out -Mscdex D:\dosfiles\MSCDEX.EXE -Extra EZSCSI.IMG,AHCIASPI.IMG
.EXAMPLE
    ./tools/mkdosiso.ps1 -Disks ./out -CdDriver D:\dosfiles\OAKCDROM.SYS -Mscdex D:\dosfiles\MSCDEX.EXE
#>
[CmdletBinding()]
param(
    [string]$Disks = (Join-Path (Get-Location) 'out'),
    [string]$CdDriver,
    [Parameter(Mandatory = $true)][string]$Mscdex,
    [string]$Iso,
    [string[]]$Extra = @()
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'GdiDisk.ps1')
if (-not $Iso) { $Iso = Join-Path $Disks 'INSTALL.ISO' }
if ('System.Text.CodePagesEncodingProvider' -as [type]) {
    [Text.Encoding]::RegisterProvider([Text.CodePagesEncodingProvider]::Instance)
}
$encoding = [Text.Encoding]::GetEncoding(850)

# the files of an -Extra package: a folder, or a disk image (*.IMG) such as
# build\AHCIASPI.IMG of AHCIASPI; name -> @{ Data; Time }
function Read-ExtraFiles([string]$x) {
    $files = [ordered]@{}
    if (Test-Path -LiteralPath $x -PathType Leaf) {
        $r = [GeosOne.Gdi.Fat12Reader]::new([IO.File]::ReadAllBytes($x))
        foreach ($n in $r.Files.Keys) { $files[$n.ToUpperInvariant()] = @{ Data = $r.Files[$n]; Time = $r.Times[$n] } }
    } elseif (Test-Path -LiteralPath $x -PathType Container) {
        foreach ($f in Get-ChildItem -LiteralPath $x -File) {
            $files[$f.Name.ToUpperInvariant()] = @{ Data = [IO.File]::ReadAllBytes($f.FullName); Time = $f.LastWriteTime }
        }
    } else { throw "-Extra: $x not found" }
    if (-not $files.Contains('INSTALL.INI')) { throw "$x has no INSTALL.INI" }
    return $files
}
function Get-DosBytes([string]$value) {
    return ,$encoding.GetBytes(($value -replace "`r?`n", "`r`n") + "`r`n")
}

$builder = $null
foreach ($name in 'xorriso', 'genisoimage', 'mkisofs') {
    $builder = Get-Command $name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($builder) { break }
}
if (-not $builder) { throw 'ISO creation needs xorriso, genisoimage or mkisofs on PATH.' }
# the CD-ROM drive at boot: AHCIASPI.SYS and ASPICD.SYS of the -Extra
# packages, else -CdDriver
$Extra = @($Extra | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$aspi = @{}
foreach ($x in $Extra) {
    $xf = Read-ExtraFiles $x
    foreach ($n in 'AHCIASPI.SYS', 'ASPICD.SYS') {
        if ($xf.Contains($n) -and -not $aspi.ContainsKey($n)) { $aspi[$n] = $xf[$n] }
    }
}
$useAspi = $aspi.Count -eq 2
if (-not $useAspi) {
    if (-not $CdDriver) { throw 'The CD needs AHCIASPI.SYS and ASPICD.SYS in -Extra (the AHCIASPI and EZ-SCSI disks), or -CdDriver.' }
    $driverFile = Get-Item -LiteralPath $CdDriver
}
$mscdexFile = Get-Item -LiteralPath $Mscdex
$firstPath = Join-Path $Disks 'DISK1.IMG'
$first = [GeosOne.Gdi.Fat12Reader]::new([IO.File]::ReadAllBytes($firstPath))
foreach ($name in 'IO.SYS', 'MSDOS.SYS', 'COMMAND.COM', 'INSTALL.EXE', 'INSTALL.INI') {
    if (-not $first.Files.ContainsKey($name)) { throw "$firstPath is missing $name" }
}
$stage = Join-Path ([IO.Path]::GetTempPath()) ('mkdosiso-' + [guid]::NewGuid().ToString('N'))
try {
    $setup = Join-Path $stage 'SETUP'
    New-Item -ItemType Directory -Path $setup -Force | Out-Null
    foreach ($name in $first.Files.Keys) {
        [IO.File]::WriteAllBytes((Join-Path $setup $name), $first.Files[$name])
    }
    # Read the archive header rather than globbing: old DISKn.IMG files may
    # remain in the output folder after a smaller set has been built.
    $archiveNames = @($first.Files.Keys | Where-Object { $_ -match '\.D01$' })
    if ($archiveNames.Count -ne 1) { throw 'DISK1.IMG must contain exactly one GDA archive (.D01).' }
    $archiveName = $archiveNames[0]
    $header = $first.Files[$archiveName]
    if ($header.Length -lt 12 -or [Text.Encoding]::ASCII.GetString($header, 0, 4) -ne 'GDA1' -or $header[8] -ne 1 -or $header[9] -lt 1) {
        throw 'Invalid GDA archive header on DISK1.IMG.'
    }
    $base = $archiveName.Substring(0, $archiveName.Length - 4)
    for ($i = 2; $i -le $header[9]; $i++) {
        $disk = [GeosOne.Gdi.Fat12Reader]::new([IO.File]::ReadAllBytes((Join-Path $Disks "DISK$i.IMG")))
        $name = '{0}.D{1:D2}' -f $base, $i
        if (-not $disk.Files.ContainsKey($name)) { throw "DISK$i.IMG is missing $name" }
        $part = $disk.Files[$name]
        if ($part.Length -lt 12 -or [Convert]::ToBase64String($part, 0, 8) -cne [Convert]::ToBase64String($header, 0, 8) -or $part[8] -ne $i -or $part[9] -ne $header[9]) {
            throw "DISK$i.IMG belongs to a different or invalid archive."
        }
        [IO.File]::WriteAllBytes((Join-Path $setup $name), $part)
    }
    $ini = $encoding.GetString($first.Files['INSTALL.INI'])
    $extrasDir = if ($Extra.Count) { 'R:\EXTRA1' } else { 'R:\' }
    $ini = $ini -replace '(?m)^ExtrasDir=[^\r\n]*', "ExtrasDir=$extrasDir"
    $ini = $ini -replace '(?m)^RestartText=[^\r\n]*', 'RestartText=Der Computer muss jetzt neu starten. Lassen Sie die Installations-CD eingelegt und starten Sie erneut von CD.'
    $ini = $ini -replace '(?m)^DosDoneText=[^\r\n]*', 'DosDoneText=Nehmen Sie die Installations-CD heraus und starten Sie den Computer neu.'
    $ini = $ini.Replace('von anderen Disketten installieren.', 'aus den EXTRA-Verzeichnissen dieser CD installieren.')
    # [Extras]: the n-th package is in R:\EXTRAn of the CD
    $script:extraN = 0
    $ini = [regex]::Replace($ini, '(?m)^(Extra=[^\r\n]*)', { param($m) $script:extraN++; "$($m.Groups[1].Value)|R:\EXTRA$script:extraN" })
    [IO.File]::WriteAllBytes((Join-Path $setup 'INSTALL.INI'), $encoding.GetBytes($ini))
    $n = 0
    foreach ($x in $Extra) {
        $xf = Read-ExtraFiles $x
        $n++
        $dest = Join-Path $stage "EXTRA$n"
        New-Item -ItemType Directory -Path $dest | Out-Null
        foreach ($k in $xf.Keys) { [IO.File]::WriteAllBytes((Join-Path $dest $k), $xf[$k].Data) }
    }
    # El Torito floppy emulation keeps the boot medium on A:, leaving C:
    # available for the real hard disk. All archive parts live on the CD.
    $boot = [GeosOne.Gdi.Fat12Image]::new([GeosOne.Gdi.BootSectors]::Win9xFat12, 'MSDOS71 CD', 0x714344)
    foreach ($name in 'IO.SYS', 'MSDOS.SYS', 'COMMAND.COM') {
        $attr = if ($name -eq 'COMMAND.COM') { 0x20 } else { 7 }
        $boot.AddFile($name, $first.Files[$name], $first.Times[$name], [byte]$attr)
    }
    if ($first.Files.ContainsKey('KEYB.COM') -and $first.Files.ContainsKey('KEYBOARD.SYS')) {
        foreach ($name in 'KEYB.COM', 'KEYBOARD.SYS') { $boot.AddFile($name, $first.Files[$name], $first.Times[$name], 0x20) }
    }
    $now = Get-Date
    if ($useAspi) {
        foreach ($n in 'AHCIASPI.SYS', 'ASPICD.SYS') { $boot.AddFile($n, $aspi[$n].Data, $aspi[$n].Time, 0x20) }
        $drivers = "DEVICE=A:\AHCIASPI.SYS`nDEVICE=A:\ASPICD.SYS /D:MSCD001"
    } else {
        $boot.AddFile('CDROM.SYS', [IO.File]::ReadAllBytes($driverFile.FullName), $driverFile.LastWriteTime, 0x20)
        $drivers = "DEVICE=A:\CDROM.SYS /D:MSCD001"
    }
    $boot.AddFile('MSCDEX.EXE', [IO.File]::ReadAllBytes($mscdexFile.FullName), $mscdexFile.LastWriteTime, 0x20)
    $config = "FILES=30`nBUFFERS=20`nLASTDRIVE=Z`n$drivers"
    $boot.AddFile('CONFIG.SYS', (Get-DosBytes $config), $now, 0x20)
    # Preserve the keyboard choice from the disk set's AUTOEXEC.BAT.
    $keyboard = ''
    if ($first.Files.ContainsKey('AUTOEXEC.BAT')) {
        $match = [regex]::Match($encoding.GetString($first.Files['AUTOEXEC.BAT']), '(?im)^KEYB[^\r\n]*')
        if ($match.Success) { $keyboard = $match.Value + "`n" }
    }
    $auto = "@ECHO OFF`n${keyboard}A:\MSCDEX.EXE /D:MSCD001 /L:R`nIF NOT EXIST R:\SETUP\INSTALL.INI GOTO NOCD`nSET PATH=A:\;R:\SETUP`nR:`nCD \SETUP`nR:\SETUP\INSTALL.EXE`nGOTO END`n:NOCD`nECHO Installation CD not found. Check the CD-ROM driver.`n:END"
    $boot.AddFile('AUTOEXEC.BAT', (Get-DosBytes $auto), $now, 0x20)
    $boot.Save((Join-Path $stage 'BOOT.IMG'))
    $isoPath = [IO.Path]::GetFullPath($Iso)
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $isoPath) | Out-Null
    $args = @('-iso-level', '1', '-V', 'MSDOS71', '-b', 'BOOT.IMG', '-c', 'BOOT.CAT', '-o', $isoPath, $stage)
    if ($builder.Name -match '^xorriso') { $args = @('-as', 'mkisofs') + $args }
    & $builder.Source @args
    if ($LASTEXITCODE -ne 0) { throw "ISO builder failed (exit $LASTEXITCODE)." }
    Write-Host "Installation ISO: $isoPath"
} finally {
    if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
}
