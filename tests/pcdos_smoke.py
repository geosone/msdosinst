#!/usr/bin/env python3
"""QEMU smoke test of a built German PC-DOS set. Uses temporary disks only.

python3 tests/pcdos_smoke.py --disks /tmp/pcdos-build --output /tmp/pcdos-test
Requires qemu-system-i386 and mcopy. Output contains a sparse 12 GiB disk.
"""
import argparse
import pathlib
import subprocess
import time

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--disks', type=pathlib.Path, required=True)
p.add_argument('--output', type=pathlib.Path, required=True)
a = p.parse_args()
a.output.mkdir(parents=True, exist_ok=True)
a.output = a.output.resolve()
hd = a.output / 'harddisk.img'
with hd.open('wb') as f:
    f.truncate(12 * 1024**3)


def run(name, batch=None):
    floppy = a.output / (name + '.img')
    if batch:
        floppy.write_bytes((a.disks / 'DISK1.IMG').read_bytes())
        bat = a.output / 'AUTOEXEC.BAT'
        bat.write_bytes(('@ECHO OFF\r\n' + batch.replace('\n', '\r\n') + '\r\n').encode('cp850'))
        subprocess.run(['mcopy', '-o', '-i', str(floppy), str(bat), '::AUTOEXEC.BAT'], check=True)
    cmd = ['qemu-system-i386', '-machine', 'pc', '-m', '32', '-display', 'none',
           '-serial', 'none', '-monitor', 'stdio', '-no-reboot',
           '-drive', f'file={hd},format=raw', '-boot', 'a' if batch else 'c']
    if batch:
        cmd += ['-drive', f'file={floppy},format=raw,if=floppy']
    with (a.output / (name + '-qemu.log')).open('wb') as log:
        q = subprocess.Popen(cmd, env=dict(__import__('os').environ, TMPDIR=str(a.output)), stdin=subprocess.PIPE, stdout=log, stderr=log)
        screen = a.output / (name + '-vga.bin')
        expected = 'PRUEFUNG FERTIG' if batch else 'FAT32-START ERFOLGREICH'
        try:
            deadline = time.monotonic() + 90
            while time.monotonic() < deadline:
                if q.poll() is not None:
                    raise RuntimeError(f'{name}: QEMU exited early')
                q.stdin.write(f'pmemsave 0xb8000 4000 "{screen}"\n'.encode())
                q.stdin.flush()
                time.sleep(.5)
                if not screen.exists():
                    continue
                b = screen.read_bytes()
                text = '\n'.join(b[i:i+160:2].decode('cp850') for i in range(0, len(b), 160))
                (a.output / (name + '-screen.txt')).write_text(text)
                if expected in text:
                    if 'FEHLER IM TEST' in text:
                        raise RuntimeError(text)
                    return text
            raise RuntimeError(f'{name}: timeout; see {a.output / (name + "-screen.txt")}')
        finally:
            if q.poll() is None:
                q.stdin.write(b'quit\n')
                q.stdin.flush()
                try:
                    q.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    q.kill()
                    q.wait()


partition = run('partition', '''VER
FDISK32.COM 1 /PRI:8192
IF ERRORLEVEL 1 GOTO FAIL
FDISK32.COM /STATUS
ECHO PRUEFUNG FERTIG
GOTO END
:FAIL
ECHO FEHLER IM TEST
ECHO PRUEFUNG FERTIG
:END''')
assert '7.10' in partition, partition
formatted = run('format', '''FORMAT.COM C: /V:DOS /AUTOTEST
IF ERRORLEVEL 1 GOTO FAIL
SYS32.COM C:
IF ERRORLEVEL 1 GOTO FAIL
ECHO DATEN BLEIBEN ERHALTEN >C:\\BEHALTEN.TXT
SYS32.COM C:
IF ERRORLEVEL 1 GOTO FAIL
TYPE C:\\BEHALTEN.TXT
ECHO @ECHO OFF >C:\\AUTOEXEC.BAT
ECHO VER >>C:\\AUTOEXEC.BAT
ECHO ECHO FAT32-START ERFOLGREICH >>C:\\AUTOEXEC.BAT
ECHO PRUEFUNG FERTIG
GOTO END
:FAIL
ECHO FEHLER IM TEST
ECHO PRUEFUNG FERTIG
:END''')
assert 'DATEN BLEIBEN ERHALTEN' in formatted, formatted
boot = run('harddisk')
assert '7.10' in boot, boot
# Inspect the FAT32 primary and backup boot sectors written by SYS32.
with hd.open('rb') as f:
    mbr = f.read(512)
    start = int.from_bytes(mbr[454:458], 'little')
    f.seek(start * 512)
    sector = f.read(512)
    backup = int.from_bytes(sector[50:52], 'little')
    f.seek((start + backup) * 512)
    assert f.read(512) == sector, 'Backup boot sector differs'
    assert sector[3:11] == b'IBM  7.1'
    assert int.from_bytes(sector[32:36], 'little') * 512 > 4 * 1024**3
print('PASS: German COMMAND.COM; 8 GiB FAT32; SYS32 preserves files; hard disk boot; backup boot sector.')
