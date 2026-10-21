# mkfilelist.ps1 - writes FILES.md (the files a disk set needs) from
# sets\<set>\set.psd1; the sizes come from a folder with the files.
#   tools/mkfilelist.ps1 -Source <folder with the files> [-Set msdos71de]
# Copyright (C) 2026 GeosOne.  GNU General Public License version 3.
param(
    [Parameter(Mandatory = $true)][string]$Source,
    [string]$Set = 'msdos71de',
    [string]$Out = (Join-Path $PSScriptRoot '../FILES.md')
)
$ErrorActionPreference = 'Stop'
$def = Import-PowerShellDataFile (Join-Path $PSScriptRoot "../sets/$Set/set.psd1")
$inv = [Globalization.CultureInfo]::InvariantCulture
$bt = [string][char]96   # backtick for Markdown code
$sizes = @{}
foreach ($f in Get-ChildItem -LiteralPath $Source -Recurse -File) { $sizes[$f.Name.ToUpperInvariant()] = $f.Length }

$groups = @(
    @{ Name = 'System files'; From = $def.SystemFrom; Files = $def.System; Optional = $false }
    @{ Name = 'Setup programs'; From = $def.BootFrom; Files = $def.BootFiles; Optional = $false }
) + @($def.Archive)

$o = New-Object System.Collections.Generic.List[string]
$o.Add("# Files needed for the MS-DOS 7.1 disk set ($Set)")
$o.Add('')
$o.Add('Copy these files from **your own** disks into one folder (subfolders are fine) and run ' +
    $bt + '.\mkdosset.ps1 -Source <folder>' + $bt + '. ' + $bt + '.\mkdosset.ps1 -List -Source <folder>' + $bt +
    ' shows which of them are still missing.')
$o.Add('')
$o.Add('- File names as on the disks: compressed files (' + $bt + '*.??_' + $bt + ') are taken as they are, the script expands them.')
$o.Add('- A file name must occur only once: take ' + $bt + 'IO.SYS' + $bt + ', ' + $bt + 'MSDOS.SYS' + $bt + ', ' +
    $bt + 'SYS.COM' + $bt + ' from the MS-DOS 7.1 system disk, **not** the older ones of disk 1, and ' + $bt + 'COMMAND.COM' + $bt +
    ' of the Windows 98 SE CD (in ' + $bt + 'WIN98\PRECOPY2.CAB' + $bt + '; the script patches it).')
$o.Add('- Optional groups may be missing; the setup then leaves out that part.')
$o.Add('- ' + $bt + 'DISK1.EXE' + $bt + ' ... ' + $bt + 'DISK4.EXE' + $bt + ' are self-extracting ZIP archives; the script unpacks them.')
$o.Add('- The sizes are those of the German MS-DOS 7.1 set the project was tested with; other versions may work but are untested.')
$o.Add('')
foreach ($g in $groups) {
    $opt = if ($g.Optional) { ' (optional)' } else { '' }
    $o.Add("## $($g.Name)$opt")
    $o.Add('')
    $o.Add("From: $($g.From)")
    $o.Add('')
    $o.Add('| File | Size (bytes) |')
    $o.Add('|---|---:|')
    foreach ($f in $g.Files) {
        $n = ($f -split '=', 2)[0].ToUpperInvariant()
        $s = if ($sizes.ContainsKey($n)) { ([long]$sizes[$n]).ToString('N0', $inv) } else { '' }
        $o.Add('| ' + $bt + $n + $bt + ' | ' + $s + ' |')
    }
    $o.Add('')
}
[IO.File]::WriteAllText($Out, ($o -join "`n"), (New-Object Text.UTF8Encoding $false))
Write-Host "$Out written"
