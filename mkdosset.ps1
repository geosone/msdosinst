<#
.SYNOPSIS
    Builds an MS-DOS installation disk set (1.44 MB floppy images) with the
    GeosOne DOS Installer from the files of your own MS-DOS disks.

.DESCRIPTION
    You copy the files of your MS-DOS disks into a folder; this script
    expands and compresses them into a GDA archive and writes bootable
    floppy images: disk 1 boots and starts INSTALL.EXE, which partitions
    and formats the hard disk if needed, installs MS-DOS and then offers to
    install further software from other disks (their INSTALL.INI).

    The script contains no Microsoft files.  You need your own, licensed
    copy of the MS-DOS disks.  -List shows the files the set needs.

.PARAMETER Source
    Folder with the files of your disks (subfolders are searched too).

.PARAMETER Out
    Output folder for DISK1.IMG, DISK2.IMG, ... (default: .\out).

.PARAMETER Set
    Name of the disk set definition in sets\ (default: msdos71de).

.PARAMETER List
    Only list the files the set needs (and which of them are missing in
    -Source, if given).

.PARAMETER Eula
    Text file with the license agreement shown by the installer, e.g. the
    Microsoft EULA of your product.  Default: the notice of the set
    (sets\<set>\LIZENZ.TXT).

.PARAMETER Installer
    INSTALL.EXE of the GeosOne DOS Installer (default: .\INSTALL.EXE, then
    ..\gdi\build\INSTALL.EXE).

.PARAMETER Extra
    Folders of further software with INSTALL.INI (e.g. AHCIASPI): each
    becomes an extra disk image EXTRA1.IMG, EXTRA2.IMG, ...

.PARAMETER Dirs
    Also write the files of each disk to a folder (DISK1\, ...).

.EXAMPLE
    .\mkdosset.ps1 -List
    .\mkdosset.ps1 -Source D:\dos71files -Extra D:\ahciaspi

    Copyright (C) 2026 GeosOne.  GNU General Public License version 3.
#>
[CmdletBinding()]
param(
    [string]$Source,
    [string]$Out = (Join-Path (Get-Location) 'out'),
    [string]$Set = 'msdos71de',
    [switch]$List,
    [string]$Eula,
    [string]$Installer,
    [string[]]$Extra = @(),
    [switch]$Dirs
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'tools/GdiDisk.ps1')
Add-Type -AssemblyName System.IO.Compression

$setDir = Join-Path $PSScriptRoot "sets/$Set"
$def = Import-PowerShellDataFile (Join-Path $setDir 'set.psd1')

# --- text files in code page 850 with CR LF ----------------------------------

if ('System.Text.CodePagesEncodingProvider' -as [type]) {
    [Text.Encoding]::RegisterProvider([Text.CodePagesEncodingProvider]::Instance)
}
$cp850 = [Text.Encoding]::GetEncoding(850)

function ConvertTo-DosText([string]$text) {
    $t = ($text -replace "`r`n", "`n" -replace "`n", "`r`n")
    if (-not $t.EndsWith("`r`n")) { $t += "`r`n" }
    return $cp850.GetBytes($t)
}

function Read-TextFile([string]$path) {
    # UTF-8 (with or without BOM) if valid, else code page 850
    $b = [IO.File]::ReadAllBytes($path)
    try {
        $utf8 = New-Object Text.UTF8Encoding($false, $true)
        return $utf8.GetString($b).TrimStart([char]0xFEFF)
    } catch {
        return $cp850.GetString($b)
    }
}

# --- the file list ---------------------------------------------------------------

# source name of a list entry "A=B"
function Get-SourceName([string]$entry) { return ($entry -split '=', 2)[0].ToUpperInvariant() }

$groups = @(
    [pscustomobject]@{ Name = 'System files'; From = $def.SystemFrom; Files = $def.System; Optional = $false }
    [pscustomobject]@{ Name = 'Setup programs'; From = $def.BootFrom; Files = $def.BootFiles; Optional = $false }
) + @($def.Archive | ForEach-Object { [pscustomobject]@{ Name = $_.Name; From = $_.From; Files = $_.Files; Optional = [bool]$_.Optional } })

# all files below $Source by name
$index = @{}
if ($Source) {
    if (-not (Test-Path -LiteralPath $Source -PathType Container)) { throw "Folder not found: $Source" }
    foreach ($f in Get-ChildItem -LiteralPath $Source -Recurse -File) {
        $k = $f.Name.ToUpperInvariant()
        if (-not $index.ContainsKey($k)) { $index[$k] = @() }
        $index[$k] += $f
    }
}

function Find-SourceFile([string]$name) {
    $hits = $index[$name.ToUpperInvariant()]
    if (-not $hits) { return $null }
    if ($hits.Count -gt 1) {
        $first = [Convert]::ToBase64String([IO.File]::ReadAllBytes($hits[0].FullName))
        foreach ($h in $hits[1..($hits.Count - 1)]) {
            if ($first -ne [Convert]::ToBase64String([IO.File]::ReadAllBytes($h.FullName))) {
                throw "$name exists more than once with different contents, keep only the right one:`n  " +
                    (($hits | ForEach-Object { $_.FullName }) -join "`n  ")
            }
        }
    }
    return $hits[0]
}

$missingRequired = @()
$skipGroup = @{}
foreach ($g in $groups) {
    $missing = @($g.Files | ForEach-Object { Get-SourceName $_ } | Where-Object { $Source -and -not (Find-SourceFile $_) })
    if ($List) {
        Write-Host ("{0}{1}  - from: {2}" -f $g.Name, $(if ($g.Optional) { ' (optional)' } else { '' }), $g.From)
        foreach ($f in $g.Files) {
            $n = Get-SourceName $f
            $mark = if (-not $Source) { '  ' } elseif ($missing -contains $n) { '- ' } else { '+ ' }
            Write-Host "  $mark$n"
        }
    }
    if ($missing.Count) {
        if ($g.Optional) {
            $skipGroup[$g.Name] = $true
            if (-not $List) { Write-Warning ("{0}: missing {1} - left out" -f $g.Name, ($missing -join ', ')) }
        } else {
            $missingRequired += $missing
        }
    }
}
if ($List) {
    if ($Source) { Write-Host "`n+ = found in $Source, - = missing" }
    return
}
if (-not $Source) { throw "-Source is needed (folder with the files of your disks); -List shows the files" }
if ($missingRequired.Count) { throw ("Missing in {0}: {1}" -f $Source, ($missingRequired -join ', ')) }

function Read-SourceFile([string]$name) {
    $f = Find-SourceFile $name
    return [pscustomobject]@{ Name = $name.ToUpperInvariant(); Data = [IO.File]::ReadAllBytes($f.FullName); Time = $f.LastWriteTime }
}

# expand SZDD/KWAJ files; name from the file or the set's tables
function Expand-File($f) {
    if (-not [GeosOne.Gdi.MsExpand]::IsCompressed($f.Data)) { return $f }
    $stored = $null
    $data = [GeosOne.Gdi.MsExpand]::Expand($f.Data, $f.Name, [ref]$stored)
    $name = $stored
    if ($def.ExpandNames.ContainsKey($f.Name)) { $name = $def.ExpandNames[$f.Name] }
    if (-not $name -or $name.EndsWith('_')) {
        $ext = ($f.Name -split '\.')[-1]
        if (-not $def.ExpandExt.ContainsKey($ext)) { throw "Unknown original name of $($f.Name)" }
        $name = $f.Name.Substring(0, $f.Name.Length - 3) + $def.ExpandExt[$ext]
    }
    return [pscustomobject]@{ Name = $name.ToUpperInvariant(); Data = $data; Time = $f.Time }
}

# bytes of a patch: Old/New in hex or OldText/NewText in code page 850
function Get-PatchBytes($p, [string]$key) {
    if ($p.ContainsKey("${key}Text")) { return [byte[]]$cp850.GetBytes($p["${key}Text"]) }
    return [byte[]]($p[$key] -split ' ' | ForEach-Object { [Convert]::ToByte($_, 16) })
}

# patch the files of the set's Patches table: at offset At, or where the
# old bytes occur exactly once; a shorter new text is padded with NULs
function Set-Patch([string]$name, $f) {
    foreach ($p in @($def.Patches)) {
        if ($p.Files -notcontains $name) { continue }
        $old = Get-PatchBytes $p 'Old'
        $new = Get-PatchBytes $p 'New'
        if ($new.Length -lt $old.Length) { $new = [byte[]]($new + (New-Object byte[] ($old.Length - $new.Length))) }
        $what = if ($p.ContainsKey('OldText')) { "'$($p.OldText)'" } else { $p.Old }
        $hits = @()
        $from, $to = if ($p.ContainsKey('At')) { $p.At, $p.At } else { 0, ($f.Data.Length - $old.Length) }
        for ($i = $from; $i -le $to; $i++) {
            $j = 0
            while ($j -lt $old.Length -and $i + $j -lt $f.Data.Length -and $f.Data[$i + $j] -eq $old[$j]) { $j++ }
            if ($j -eq $old.Length) { $hits += $i }
        }
        if ($hits.Count -ne 1) {
            if ($p.ContainsKey('At')) { Write-Warning ("{0}: {1} not at 0x{2:X}, not patched" -f $name, $what, $p.At) }
            else { Write-Warning ("{0}: {1} found {2} times, not patched" -f $name, $what, $hits.Count) }
            continue
        }
        [Array]::Copy($new, 0, $f.Data, $hits[0], $new.Length)
    }
    return $f
}

# --- archive contents -----------------------------------------------------------

$entries = [ordered]@{}            # archive name -> entry
$known = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
foreach ($n in $def.System + $def.BootFiles) { [void]$known.Add($n) }

function Add-Entry([string]$name, $f) {
    $entries[$name.ToUpperInvariant()] = New-Object GeosOne.Gdi.GdaEntry($name, $f.Data, $f.Time)
}

foreach ($rule in $def.Archive) {
    if ($skipGroup[$rule.Name]) { continue }
    $count = 0
    foreach ($item in $rule.Files) {
        $src, $as = $item -split '=', 2
        $f = Read-SourceFile $src
        if ($rule.Zip) {
            $ms = New-Object IO.MemoryStream(, $f.Data)
            $z = New-Object IO.Compression.ZipArchive($ms, [IO.Compression.ZipArchiveMode]::Read)
            foreach ($e in $z.Entries) {
                if (-not $e.Name) { continue }
                $o = New-Object IO.MemoryStream
                $s = $e.Open(); $s.CopyTo($o); $s.Close()
                $zf = [pscustomobject]@{ Name = $e.Name.ToUpperInvariant(); Data = $o.ToArray(); Time = $e.LastWriteTime.DateTime }
                Add-Entry "$($rule.To)\$($zf.Name)" $zf
                [void]$known.Add($zf.Name)
                $count++
            }
            $z.Dispose()
            continue
        }
        $x = Expand-File $f
        $target = if ($as) { $as.ToUpperInvariant() } else { $x.Name }
        if ($rule.KeepFirst -and $known.Contains($target)) { continue }
        $x = Set-Patch $target $x
        Add-Entry "$($rule.To)\$target" $x
        if ($rule.To -eq 'DOS') { [void]$known.Add($target) }
        $count++
    }
    Write-Host ("{0,-44} {1,4} files" -f $rule.Name, $count)
}
$archive = New-Object 'System.Collections.Generic.List[GeosOne.Gdi.GdaEntry]'
foreach ($e in $entries.Values) { $archive.Add($e) }
$total = 0; foreach ($e in $archive) { $total += $e.Data.Length }
Write-Host ("Archive: {0} files, {1:N0} bytes" -f $archive.Count, $total)

# --- disk 1 --------------------------------------------------------------------------

if (-not $Installer) {
    $Installer = @((Join-Path $PSScriptRoot 'INSTALL.EXE'), (Join-Path $PSScriptRoot '../gdi/build/INSTALL.EXE')) |
        Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $Installer) { throw "INSTALL.EXE not found (-Installer)" }
}
$licenseFile = if ($Eula) { $Eula } else { Join-Path $setDir 'LIZENZ.TXT' }

$serial = [uint32](Get-Random -Maximum ([int]::MaxValue))
$now = Get-Date
# the boot sector loads IO.SYS (FreeDOS OEM boot sector for MS-DOS 7.x)
$disk1 = [GeosOne.Gdi.Fat12Image]::new([GeosOne.Gdi.BootSectors]::Win9xFat12, "$($def.Label) 1", $serial)
$disk1Files = [ordered]@{}
foreach ($n in $def.System) {
    $f = Set-Patch $n (Read-SourceFile $n)
    $disk1Files[$f.Name] = @{ Data = $f.Data; Time = $f.Time; Attr = $(if ($n -in 'IO.SYS', 'MSDOS.SYS') { 7 } else { 0x20 }) }
}
$kb = $def.Keyboard
$disk1Files['CONFIG.SYS'] = @{ Data = (ConvertTo-DosText "FILES=30`nBUFFERS=20`nLASTDRIVE=Z"); Time = $now; Attr = 0x20 }
$auto = "@ECHO OFF`n"
if ($kb) { $auto += "KEYB $kb,,A:\KEYBOARD.SYS >NUL`n" }
$auto += "A:\INSTALL.EXE`n"
$disk1Files['AUTOEXEC.BAT'] = @{ Data = (ConvertTo-DosText $auto); Time = $now; Attr = 0x20 }
$disk1Files['INSTALL.EXE'] = @{ Data = [IO.File]::ReadAllBytes($Installer); Time = (Get-Item $Installer).LastWriteTime; Attr = 0x20 }
$disk1Files['INSTALL.INI'] = @{ Data = (ConvertTo-DosText (Read-TextFile (Join-Path $setDir 'INSTALL.INI'))); Time = $now; Attr = 0x20 }
$disk1Files['LIZENZ.TXT'] = @{ Data = (ConvertTo-DosText (Read-TextFile $licenseFile)); Time = $now; Attr = 0x20 }
# further license texts of the set (LicenseN=Name|file in INSTALL.INI)
foreach ($m in [regex]::Matches((Read-TextFile (Join-Path $setDir 'INSTALL.INI')), '(?m)^License\d=(?:[^|\r\n]*\|)?([^\s;]+)')) {
    $n = $m.Groups[1].Value.ToUpperInvariant()
    if ($disk1Files.Contains($n)) { continue }
    $disk1Files[$n] = @{ Data = (ConvertTo-DosText (Read-TextFile (Join-Path $setDir $m.Groups[1].Value))); Time = $now; Attr = 0x20 }
}
$disk1Files['LIESMICH.TXT'] = @{ Data = (ConvertTo-DosText (Read-TextFile (Join-Path $setDir 'LIESMICH.TXT'))); Time = $now; Attr = 0x20 }
foreach ($n in $def.BootFiles) {
    $f = Set-Patch $n (Read-SourceFile $n)
    $disk1Files[$f.Name] = @{ Data = $f.Data; Time = $f.Time; Attr = 0x20 }
}
foreach ($n in $disk1Files.Keys) { $disk1.AddFile($n, $disk1Files[$n].Data, $disk1Files[$n].Time, [byte]$disk1Files[$n].Attr) }

# --- archive over the disks ------------------------------------------------------

$cap1 = $disk1.FreeBytes - 512
$parts = [GeosOne.Gdi.Gda]::Build($archive, [Func[int, long]] { param($n) if ($n -eq 1) { $cap1 } else { [GeosOne.Gdi.Fat12Image]::Size - 33 * 512 } }, $serial)

New-Item -ItemType Directory -Force -Path $Out | Out-Null
$images = @($disk1)
for ($i = 2; $i -le $parts.Count; $i++) {
    $images += [GeosOne.Gdi.Fat12Image]::new($null, "$($def.Label) $i", ($serial + $i))
}
for ($i = 1; $i -le $parts.Count; $i++) {
    $images[$i - 1].AddFile(("{0}.D{1:D2}" -f $def.Name, $i), $parts[$i - 1], $now, 0x20)
}
for ($i = 1; $i -le $images.Count; $i++) {
    $p = Join-Path $Out "DISK$i.IMG"
    $images[$i - 1].Save($p)
    Write-Host ("{0}  ({1:N0} bytes free)" -f $p, $images[$i - 1].FreeBytes)
}

# --- extra software --------------------------------------------------------------

$n = 0
foreach ($x in $Extra) {
    $n++
    if (-not (Test-Path -LiteralPath (Join-Path $x 'INSTALL.INI'))) { throw "$x has no INSTALL.INI" }
    $img = [GeosOne.Gdi.Fat12Image]::new($null, "EXTRA $n", ($serial + 100 + $n))
    foreach ($f in Get-ChildItem -LiteralPath $x -File) {
        $img.AddFile($f.Name, [IO.File]::ReadAllBytes($f.FullName), $f.LastWriteTime, 0x20)
    }
    $p = Join-Path $Out "EXTRA$n.IMG"
    $img.Save($p)
    Write-Host ("{0}  ({1})" -f $p, $x)
}

# --- folders ---------------------------------------------------------------------

if ($Dirs) {
    $d1 = Join-Path $Out 'DISK1'
    New-Item -ItemType Directory -Force -Path $d1 | Out-Null
    foreach ($k in $disk1Files.Keys) { [IO.File]::WriteAllBytes((Join-Path $d1 $k), $disk1Files[$k].Data) }
    for ($i = 1; $i -le $parts.Count; $i++) {
        $d = Join-Path $Out "DISK$i"
        New-Item -ItemType Directory -Force -Path $d | Out-Null
        [IO.File]::WriteAllBytes((Join-Path $d ("{0}.D{1:D2}" -f $def.Name, $i)), $parts[$i - 1])
    }
}
Write-Host "Done: $($images.Count) disks."
