<#
.SYNOPSIS
    Builds an MS-DOS installation disk set (1.44 MB floppy images) with the
    GeosOne DOS Installer from your own CDs and MS-DOS disks.

.DESCRIPTION
    You put your CDs and disks (their files, or images: *.iso, *.img, also
    packed in *.7z) into a folder; this script
    expands and compresses them into a GDA archive and writes bootable
    floppy images: disk 1 boots and starts INSTALL.EXE, which partitions
    and formats the hard disk if needed, installs MS-DOS and then offers to
    install further software from other disks (their INSTALL.INI).

    The script contains no Microsoft files.  You need your own, licensed
    copy of the CDs and disks.  -List shows the files the set needs.

.PARAMETER Source
    Folder with your CDs and disks (subfolders are searched too): their
    files, or CD images (*.iso), floppy images (*.img, *.ima) and 7-Zip
    archives of them (*.7z).  Images are unpacked with 7-Zip (7z on the
    PATH, Program Files\7-Zip or tools\7zip of the release zip) into the
    folder -Cache.

.PARAMETER Cache
    Folder for the unpacked images (default: mkdosset-cache in the temp
    folder).  It is kept, the next run uses it again.

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
    [string]$Cache = (Join-Path ([IO.Path]::GetTempPath()) 'mkdosset-cache'),
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

# a list entry: [medium:]path[>file in the CAB][=name in the set]
#   NAME.EXT                  a file of your disks, found by name in -Source
#   WinMe:WIN9X\EXTRACT.EXE   a file of a CD (Media), path from the CD root
#   WinMe:WIN9X\WIN_16.CAB>ATTRIB.EXE   a file in a CAB of a CD
function Get-Spec([string]$entry, [string]$medium) {
    $src, $as = $entry -split '=', 2
    if ($src -match '^(\w+):(.*)$') { $medium = $Matches[1]; $src = $Matches[2] }
    $path, $member = $src -split '>', 2
    if (-not $medium -and ($member -or $path -match '\\')) { throw "$entry needs a medium (Media in set.psd1)" }
    $leaf = if ($member) { $member } else { ($path -split '\\')[-1] }
    return [pscustomobject]@{ Medium = $medium; Path = $path; Member = $member; Leaf = $leaf.ToUpperInvariant(); As = $as }
}

# system files that the script makes: IO.SYS and COMMAND.COM from the CABs
# of IoSysCabs (with ext/small-io-sys), MSDOS.SYS from MsdosSys
$madeSystem = @()
if ($def.IoSysCabs) { $madeSystem += 'IO.SYS', 'COMMAND.COM' }
if ($def.MsdosSys) { $madeSystem += 'MSDOS.SYS' }

$groups = @(
    [pscustomobject]@{ Name = 'System files'; From = $def.SystemFrom; Files = @($def.System | Where-Object { $madeSystem -notcontains $_ }); Optional = $false; Medium = $null }
) + @(if ($def.IoSysCabs) {
    [pscustomobject]@{ Name = 'IO.SYS and COMMAND.COM'; From = $def.IoSysFrom; Files = $def.IoSysCabs; Optional = $false; Medium = $null }
}) + @(
    [pscustomobject]@{ Name = 'Setup programs'; From = $def.BootFrom; Files = $def.BootFiles; Optional = $false; Medium = $null }
) + @($def.Archive | ForEach-Object { [pscustomobject]@{ Name = $_.Name; From = $_.From; Files = $_.Files; Optional = [bool]$_.Optional; Medium = $_.Medium } })

# --- images in -Source ----------------------------------------------------------

# CD images (*.iso), floppy images (*.img, *.ima) and 7-Zip archives of them
# (*.7z) are unpacked with 7-Zip into $Cache\<name>-<size>; of a CD only the
# folders the set needs (those of the Media entries)
$cdPatterns = @(foreach ($g in $groups) {
    foreach ($e in $g.Files) {
        $s = Get-Spec $e $g.Medium
        if ($s.Medium -and $s.Path -match '\\') { ($s.Path -replace '\\[^\\]*$', '') + '\*' }
    }
}) + @(foreach ($k in $def.Media.Keys) { $def.Media[$k].Find }) | ForEach-Object { $_.Replace('\', '/') } | Sort-Object -Unique

function Get-SevenZip([string]$for) {
    foreach ($c in '7z', '7zz', '7za') {
        $cmd = Get-Command $c -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cmd) { return $cmd.Source }
    }
    foreach ($p in @($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
        if ($p -and (Test-Path -LiteralPath (Join-Path $p '7-Zip\7z.exe'))) { return (Join-Path $p '7-Zip\7z.exe') }
    }
    # the one of the release zip
    foreach ($c in '7z.exe', '7zz') {
        $p = Join-Path $PSScriptRoot "tools/7zip/$c"
        if ((Test-Path -LiteralPath $p) -and (($c -eq '7z.exe') -eq ([IO.Path]::DirectorySeparatorChar -eq '\'))) { return $p }
    }
    throw "7-Zip is needed for $for (7z on the PATH, Program Files\7-Zip\7z.exe or tools\7zip)"
}

function Expand-SourceImage([IO.FileInfo]$f, [string]$into) {
    $len = $f.Length
    if ($f.LinkTarget) { $len = (Get-Item -LiteralPath ([IO.Path]::Combine($f.DirectoryName, $f.LinkTarget))).Length }   # symbolic link
    $d = Join-Path $into (('{0}-{1}' -f ($f.BaseName -replace '[^\w.-]', '_'), $len))
    # .done holds the folders unpacked from a CD (also in a .7z): unpack again
    # when they change
    $what = if ($f.Extension -in '.iso', '.7z') { $cdPatterns -join "`n" } else { '' }
    $done = Join-Path $d '.done'
    if ((Test-Path -LiteralPath $done) -and ([IO.File]::ReadAllText($done) -eq $what)) { return $d }
    if (Test-Path -LiteralPath $d) { Remove-Item -LiteralPath $d -Recurse -Force }
    New-Item -ItemType Directory -Path $d | Out-Null
    $7z = Get-SevenZip $f.Name
    Write-Host "Unpacking $($f.Name) ..."
    switch ($f.Extension.ToLowerInvariant()) {
        '.7z' {
            $log = & $7z x -y -r -ssc- "-o$d" $f.FullName '*.iso' '*.img' '*.ima' 2>&1
            if ($LASTEXITCODE) { throw "7-Zip failed on $($f.FullName):`n$($log -join "`n")" }
            foreach ($i in @(Get-ChildItem -LiteralPath $d -Recurse -File)) {
                [void](Expand-SourceImage $i $d)
                Remove-Item -LiteralPath $i.FullName
            }
            Get-ChildItem -LiteralPath $d -Directory | Where-Object { -not (Get-ChildItem -LiteralPath $_.FullName -Recurse -File) } |
                Remove-Item -Recurse -Force
        }
        '.iso' { $log = & $7z x -y -ssc- "-o$d" $f.FullName $cdPatterns 2>&1 }
        default { $log = & $7z x -y "-o$d" $f.FullName 2>&1 }
    }
    if ($LASTEXITCODE) { throw "7-Zip failed on $($f.FullName):`n$($log -join "`n")" }
    [IO.File]::WriteAllText($done, $what)
    return $d
}

# all files below $Source (and of its unpacked images) by name
$index = @{}
if ($Source) {
    if (-not (Test-Path -LiteralPath $Source -PathType Container)) { throw "Folder not found: $Source" }
    $files = @(Get-ChildItem -LiteralPath $Source -Recurse -File)
    foreach ($i in @($files | Where-Object { $_.Extension -in '.7z', '.iso', '.img', '.ima' })) {
        New-Item -ItemType Directory -Force -Path $Cache | Out-Null
        $files += @(Get-ChildItem -LiteralPath (Expand-SourceImage $i $Cache) -Recurse -File)
    }
    foreach ($f in $files) {
        $k = $f.Name.ToUpperInvariant()
        if (-not $index.ContainsKey($k)) { $index[$k] = @() }
        $index[$k] += $f
    }
}

function Find-SourceFile([string]$name) {
    $hits = @($index[$name.ToUpperInvariant()] | Where-Object { $_ })
    if (-not $hits) { return $null }
    if ($hits.Count -gt 1 -and $def.Media) {
        # files of disks, not those of the CDs (e.g. EXPAND.EXE is on both)
        $roots = @(@(foreach ($k in $def.Media.Keys) { Get-MediumRoot $k }) | Where-Object { $_ })
        $own = @($hits | Where-Object { $p = $_.FullName; -not ($roots | Where-Object { $p.StartsWith($_ + [IO.Path]::DirectorySeparatorChar) }) })
        if ($own) { $hits = $own }
    }
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

# root folder of a CD in -Source: the folder that holds its Find file
# (e.g. WIN9X\WIN_19.CAB); copy the CD or the folders the set needs
$mediaRoot = @{}
function Get-MediumRoot([string]$medium) {
    if ($mediaRoot.ContainsKey($medium)) { return $mediaRoot[$medium] }
    $m = $def.Media[$medium]
    if (-not $m) { throw "Unknown medium $medium (Media in set.psd1)" }
    $parts = $m.Find -split '\\'
    $root = $null
    foreach ($f in @($index[$parts[-1].ToUpperInvariant()])) {
        if (-not $f) { continue }
        $d = $f.Directory
        $ok = $true
        for ($i = $parts.Count - 2; $i -ge 0; $i--) {
            if ($d.Name -ne $parts[$i]) { $ok = $false; break }   # file systems of CDs and Windows ignore case
            $d = $d.Parent
        }
        if ($ok) { $root = $d.FullName; break }
    }
    $mediaRoot[$medium] = $root
    return $root
}

# the file of a list entry on a medium, case-insensitive, or $null
function Find-MediumFile($s) {
    $d = Get-MediumRoot $s.Medium
    if (-not $d) { return $null }
    foreach ($p in $s.Path -split '\\') {
        $hit = Get-ChildItem -LiteralPath $d -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $p } | Select-Object -First 1
        if (-not $hit) { return $null }
        $d = $hit.FullName
    }
    return Get-Item -LiteralPath $d
}

function Test-Spec($s) {
    if ($s.Medium) { return [bool](Find-MediumFile $s) }
    return [bool](Find-SourceFile $s.Path)
}

$missingRequired = @()
$skipGroup = @{}
foreach ($g in $groups) {
    $specs = @($g.Files | ForEach-Object { Get-Spec $_ $g.Medium })
    $missing = @($specs | Where-Object { $Source -and -not (Test-Spec $_) } | ForEach-Object {
        if ($_.Medium) { "$($_.Medium):$($_.Path)" } else { $_.Path } } | Select-Object -Unique)
    if ($List) {
        Write-Host ("{0}{1}  - from: {2}" -f $g.Name, $(if ($g.Optional) { ' (optional)' } else { '' }), $g.From)
        foreach ($s in $specs) {
            $mark = if (-not $Source) { '  ' } elseif (-not (Test-Spec $s)) { '- ' } else { '+ ' }
            $n = if ($s.Medium) { "$($s.Path)$(if ($s.Member) { " > $($s.Member)" })" } else { $s.Path }
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
    if ($def.Media) {
        Write-Host "`nCDs: put their images (*.iso, *.7z) into -Source, or copy them (or the folders named above), keeping the folders:"
        foreach ($k in $def.Media.Keys) { Write-Host ("  {0}: {1} (found by {2})" -f $k, $def.Media[$k].Name, $def.Media[$k].Find) }
    }
    return
}
if (-not $Source) { throw "-Source is needed (folder with your CDs and disks); -List shows the files" }
if ($missingRequired.Count) { throw ("Missing in {0}: {1}" -f $Source, ($missingRequired -join ', ')) }

# files from CABs: cabextract (ext/small-io-sys/tools) on Linux, expand.exe
# on Windows; the other CABs of a set are in the same folder
$cabDir = Join-Path ([IO.Path]::GetTempPath()) ("mkdosset-" + [guid]::NewGuid().ToString('N'))
function Expand-CabFile([IO.FileInfo]$cab, [string]$member) {
    $d = Join-Path $cabDir ([guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $d | Out-Null
    if ([Environment]::OSVersion.Platform -eq 'Win32NT') {
        $log = & (Join-Path $env:SystemRoot 'System32\expand.exe') "-F:$member" $cab.FullName $d 2>&1
    } else {
        $log = & (Join-Path $PSScriptRoot 'ext/small-io-sys/tools/cabextract-1.11.upx') -q -d $d -F $member $cab.FullName 2>&1
    }
    $f = Get-ChildItem -LiteralPath $d -File -Recurse | Where-Object { $_.Name -eq $member } | Select-Object -First 1
    if (-not $f) { throw "$member not found in $($cab.FullName):`n$($log -join "`n")" }
    return $f
}

function Read-Spec($s) {
    $f = if ($s.Medium) { Find-MediumFile $s } else { Find-SourceFile $s.Path }
    if ($s.Member) { $f = Expand-CabFile $f $s.Member }
    return [pscustomobject]@{ Name = $s.Leaf; Data = [IO.File]::ReadAllBytes($f.FullName); Time = $f.LastWriteTime }
}
function Read-SourceFile([string]$entry) { return Read-Spec (Get-Spec $entry $null) }

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
# old bytes occur exactly once (or Count times: all of them); a shorter new
# text is padded with NULs
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
        $want = if ($p.ContainsKey('Count')) { $p.Count } else { 1 }
        if ($hits.Count -ne $want) {
            if ($p.ContainsKey('At')) { Write-Warning ("{0}: {1} not at 0x{2:X}, not patched" -f $name, $what, $p.At) }
            else { Write-Warning ("{0}: {1} found {2} times, not patched" -f $name, $what, $hits.Count) }
            continue
        }
        foreach ($h in $hits) { [Array]::Copy($new, 0, $f.Data, $h, $new.Length) }
    }
    return $f
}

# --- archive contents -----------------------------------------------------------

$entries = [ordered]@{}            # archive name -> entry
$known = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
foreach ($n in $def.System + $def.BootFiles) { $s = Get-Spec $n $null; [void]$known.Add($(if ($s.As) { $s.As } else { $s.Leaf })) }

function Add-Entry([string]$name, $f) {
    $entries[$name.ToUpperInvariant()] = New-Object GeosOne.Gdi.GdaEntry($name, $f.Data, $f.Time)
}

foreach ($rule in $def.Archive) {
    if ($skipGroup[$rule.Name]) { continue }
    $count = 0
    foreach ($item in $rule.Files) {
        $s = Get-Spec $item $rule.Medium
        $as = $s.As
        $f = Read-Spec $s
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

# --- IO.SYS and COMMAND.COM: ext/small-io-sys ------------------------------------

# compile.ps1 de builds IO.SYS in ext/small-io-sys/de from the PRECOPY CABs
# and extracts COMMAND.COM (on Windows it downloads nasm and apack1p once)
$made = @{}
if ($def.IoSysCabs) {
    $sios = Join-Path $PSScriptRoot 'ext/small-io-sys'
    if (-not (Test-Path -LiteralPath (Join-Path $sios 'compile.ps1'))) {
        throw "ext/small-io-sys is missing: git submodule update --init"
    }
    $build = Join-Path $sios 'de'
    if (Test-Path -LiteralPath $build) { Remove-Item -LiteralPath $build -Recurse -Force }
    New-Item -ItemType Directory -Path $build | Out-Null
    foreach ($n in $def.IoSysCabs) {
        $s = Get-Spec $n $null
        $f = if ($s.Medium) { Find-MediumFile $s } else { Find-SourceFile $s.Path }
        Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $build $s.Leaf)
    }
    try { & (Join-Path $sios 'compile.ps1') de *>&1 | Out-Null }
    catch { throw "ext/small-io-sys/compile.ps1 de failed: $_" }
    foreach ($m in @(@('IO.SYS', 'IO.SYS.win98sekbpc'), @('COMMAND.COM', 'command.com'))) {
        $f = Get-Item -LiteralPath (Join-Path $build $m[1])
        $made[$m[0]] = [pscustomobject]@{ Name = $m[0]; Data = [IO.File]::ReadAllBytes($f.FullName); Time = $f.LastWriteTime }
    }
    Write-Host ("IO.SYS (small-io-sys)                        {0,7:N0} bytes" -f $made['IO.SYS'].Data.Length)
}
if ($def.MsdosSys) {
    $made['MSDOS.SYS'] = [pscustomobject]@{ Name = 'MSDOS.SYS'; Data = (ConvertTo-DosText ($def.MsdosSys -join "`n")); Time = (Get-Date) }
}

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
    $f = if ($made.ContainsKey($n)) { $made[$n] } else { Read-SourceFile $n }
    $f = Set-Patch $f.Name $f
    $disk1Files[$f.Name] = @{ Data = $f.Data; Time = $f.Time; Attr = $(if ($f.Name -in 'IO.SYS', 'MSDOS.SYS') { 7 } else { 0x20 }) }
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
    $f = Read-SourceFile $n
    $f = Set-Patch $f.Name $f
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
if (Test-Path -LiteralPath $cabDir) { Remove-Item -LiteralPath $cabDir -Recurse -Force }
Write-Host "Done: $($images.Count) disks."
