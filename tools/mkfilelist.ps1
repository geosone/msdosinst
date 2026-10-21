# mkfilelist.ps1 - writes FILES.md (the files a disk set needs) from
# sets\<set>\set.psd1; the sizes come from the same folder as for
# mkdosset.ps1 -Source (CDs and the files of the disks; the sizes of files in
# CABs are read from the CAB directory).
# Images and archives in -Source (*.iso, *.img, *.7z) are read from the
# folder that mkdosset.ps1 unpacked them to (-Cache, run mkdosset.ps1 first).
#   tools/mkfilelist.ps1 -Source <folder with the files> [-Set msdos71de]
# Lines between the title and the text of an existing FILES.md are kept.
# Copyright (C) 2026 GeosOne.  GNU General Public License version 3.
param(
    [Parameter(Mandatory = $true)][string]$Source,
    [string]$Set = 'msdos71de',
    [string]$Cache = (Join-Path ([IO.Path]::GetTempPath()) 'mkdosset-cache'),
    [string]$Out = (Join-Path $PSScriptRoot '../FILES.md')
)
$ErrorActionPreference = 'Stop'
$def = Import-PowerShellDataFile (Join-Path $PSScriptRoot "../sets/$Set/set.psd1")
$inv = [Globalization.CultureInfo]::InvariantCulture
$bt = [string][char]96   # backtick for Markdown code
$sizes = @{}   # files of the disks by name
$paths = @{}   # all files by full path (lower case)
$files = @(Get-ChildItem -LiteralPath $Source -Recurse -File)
if (($files | Where-Object { $_.Extension -in '.7z', '.iso', '.img', '.ima' }) -and (Test-Path -LiteralPath $Cache)) {
    $files += @(Get-ChildItem -LiteralPath $Cache -Recurse -File)
}
foreach ($f in $files) {
    $sizes[$f.Name.ToUpperInvariant()] = $f.Length
    $paths[$f.FullName.Replace('\', '/').ToLowerInvariant()] = $f
}
# the folder of a CD: the one holding its Find file
$roots = @{}
foreach ($m in $def.Media.Keys) {
    $find = '/' + $def.Media[$m].Find.Replace('\', '/').ToLowerInvariant()
    foreach ($p in $paths.Keys) { if ($p.EndsWith($find)) { $roots[$m] = $p.Substring(0, $p.Length - $find.Length); break } }
}
# size of a file in a CAB (CFFILE entries of the CAB directory), or $null
function Get-CabMemberSize($cab, $member) {
    $b = [IO.File]::ReadAllBytes($cab)
    $at = [BitConverter]::ToUInt32($b, 0x10)
    $n = [BitConverter]::ToUInt16($b, 0x1C)
    for ($i = 0; $i -lt $n; $i++) {
        $size = [BitConverter]::ToUInt32($b, $at)
        $e = [Array]::IndexOf($b, [byte]0, $at + 16)
        $name = [Text.Encoding]::ASCII.GetString($b, $at + 16, $e - $at - 16)
        if ($name -ieq $member) { return $size }
        $at = $e + 1
    }
    $null
}
function Get-Size($s) {
    if (-not $s.Medium) { if ($sizes.ContainsKey($s.Leaf)) { return $sizes[$s.Leaf] }; return $null }
    if (-not $roots.ContainsKey($s.Medium)) { return $null }
    $p = $roots[$s.Medium] + '/' + $s.Path.Replace('\', '/').ToLowerInvariant()
    if (-not $paths.ContainsKey($p)) { return $null }
    if ($s.Member) { return Get-CabMemberSize $paths[$p].FullName $s.Member }
    $paths[$p].Length
}

# [medium:]path[>member][=as] -> medium, place on the medium, file name
function Get-Spec($entry, $medium) {
    $e = ($entry -split '=', 2)[0]
    if ($e -match '^(\w+):(.*)$') { $medium = $Matches[1]; $e = $Matches[2] }
    $path, $member = $e -split '>', 2
    $leaf = if ($member) { $member } else { ($path -split '\\')[-1] }
    $where = if ($medium) { if ($member) { "$path > $member" } else { $path } } else { '' }
    @{ Medium = $medium; Path = $path; Member = $member; Where = $where; Leaf = $leaf.ToUpperInvariant() }
}

$groups = @(
    @{ Name = 'System files'; From = $def.SystemFrom; Files = $def.System; Optional = $false }
    @{ Name = 'IO.SYS and COMMAND.COM'; From = $def.IoSysFrom; Files = $def.IoSysCabs; Optional = $false }
    @{ Name = 'Setup programs'; From = $def.BootFrom; Files = $def.BootFiles; Optional = $false }
) + @($def.Archive)

$o = New-Object System.Collections.Generic.List[string]
$o.Add("# Files needed for the MS-DOS 7.1 disk set ($Set)")
$o.Add('')
if (Test-Path -LiteralPath $Out) {
    # the lines of the old file between the title and its first paragraph
    $old = [IO.File]::ReadAllLines($Out)
    $i = 1
    while ($i -lt $old.Count -and -not $old[$i].StartsWith('Copy ')) { $i++ }
    if ($i -lt $old.Count) {
        $keep = @($old[1..($i - 1)] | Where-Object { $_.Trim() })
        if ($keep.Count) { foreach ($l in $keep) { $o.Add($l) }; $o.Add('') }
    }
}
$o.Add('Put **your own** media into one folder (subfolders are fine): the CD images (' + $bt + '*.iso' + $bt + '), the disk images (' +
    $bt + '*.img' + $bt + ') or 7-Zip archives of them (' + $bt + '*.7z' + $bt + ') as they are - the script unpacks them with 7-Zip - ' +
    'or copies of the CDs (or the folders named below) and the files of your disks. Then run ' + $bt + '.\mkdosset.ps1 -Source <folder>' + $bt + '. ' +
    $bt + '.\mkdosset.ps1 -List -Source <folder>' + $bt + ' shows which of them are still missing.')
$o.Add('')
$o.Add('- Files of a CD are found by their place on the CD (keep its folders); ' + $bt + 'X.CAB > NAME' + $bt +
    ' = the file NAME in that CAB, the script extracts it (the other CABs of the CD must be in the same folder, ' +
    'a file can continue in the next CAB). The size is that of the extracted file.')
$o.Add('- Files of the disks are found by name: compressed files (' + $bt + '*.??_' + $bt + ') are taken as they are, the script expands them.')
$o.Add('- ' + $bt + 'IO.SYS' + $bt + ' is built from ' + $bt + 'WINBOOT.SYS' + $bt + ' in ' + $bt + 'WIN98\PRECOPY1.CAB' + $bt +
    ' and ' + $bt + 'PRECOPY2.CAB' + $bt + ' of the Windows 98 SE CD, ' + $bt + 'COMMAND.COM' + $bt +
    ' is taken from them, ' + $bt + 'MSDOS.SYS' + $bt + ' is written by the script; patched programs: see ' + $bt + 'Patches' + $bt +
    ' in ' + $bt + "sets\$Set\set.psd1" + $bt + '.')
$o.Add('- Optional groups may be missing; the setup then leaves out that part.')
$o.Add('- The sizes are those of the German media the project was tested with; other versions may work but are untested.')
$o.Add('')
$o.Add('## CDs')
$o.Add('')
$o.Add('| Name | Found by |')
$o.Add('|---|---|')
foreach ($m in $def.Media.Keys | Sort-Object) {
    $o.Add('| ' + $def.Media[$m].Name + ' | ' + $bt + $def.Media[$m].Find + $bt + ' |')
}
$o.Add('')
foreach ($g in $groups) {
    $opt = if ($g.Optional) { ' (optional)' } else { '' }
    $o.Add("## $($g.Name)$opt")
    $o.Add('')
    $o.Add("From: $($g.From)")
    $o.Add('')
    $specs = @($g.Files | ForEach-Object { Get-Spec $_ $g.Medium } | Where-Object { $_.Leaf -notin @('IO.SYS', 'MSDOS.SYS', 'COMMAND.COM') -or $_.Where })
    $onCd = @($specs | Where-Object { $_.Where }).Count -gt 0
    if ($onCd) { $o.Add('| File | On the CD | Size (bytes) |'); $o.Add('|---|---|---:|') }
    else { $o.Add('| File | Size (bytes) |'); $o.Add('|---|---:|') }
    foreach ($s in $specs) {
        $n = $s.Leaf
        $z = Get-Size $s
        $z = if ($null -ne $z) { ([long]$z).ToString('N0', $inv) } else { '' }
        if ($onCd) {
            $w = if ($s.Where) { $bt + $s.Where + $bt } else { '' }
            $o.Add('| ' + $bt + $n + $bt + ' | ' + $w + ' | ' + $z + ' |')
        } else { $o.Add('| ' + $bt + $n + $bt + ' | ' + $z + ' |') }
    }
    $o.Add('')
}
[IO.File]::WriteAllText($Out, ($o -join "`n"), (New-Object Text.UTF8Encoding $false))
Write-Host "$Out written"
