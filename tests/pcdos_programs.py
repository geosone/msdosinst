#!/usr/bin/env python3
"""Start every bundled DOS program and load each device driver under QEMU.

Run pcdos_smoke.py first. --harddisk is its temporary FAT32 harddisk.img.
Every guest uses a disposable snapshot. Programs are unpacked from the GDA
with CRC verification and staged in C:\\DOS on that temporary test disk.
This checks startup, help and driver initialization, not every function or
real serial/parallel hardware. Screens and JSON results remain in --output.
"""
import argparse
import concurrent.futures
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import time
import zlib

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--disks', required=True, type=Path)
p.add_argument('--harddisk', required=True, type=Path)
p.add_argument('--output', required=True, type=Path)
a = p.parse_args()
a.output = a.output.resolve()
a.output.mkdir(parents=True, exist_ok=True)
a.harddisk = a.harddisk.resolve()
programs = a.output / 'programs'
programs.mkdir(exist_ok=True)
fragments = {}
for n in range(1, 100):
    image = a.disks / f'DISK{n}.IMG'
    if not image.exists():
        break
    dest = a.output / f'disk{n}'
    subprocess.run(['7z', 'x', '-y', '-o' + str(dest), str(image)], check=True, stdout=subprocess.DEVNULL)
    for part in dest.glob('*.D[0-9][0-9]'):
        data = part.read_bytes()
        assert data[:4] == b'GDA1'
        pos = 16
        while pos < len(data) and data[pos] == ord('F'):
            flags, method, length = data[pos+1:pos+4]
            pos += 4
            name = data[pos:pos+length].decode('ascii')
            pos += length
            size, crc, _, _, count = struct.unpack_from('<IIHHI', data, pos)
            pos += 16
            fragments[name] = fragments.get(name, b'') + data[pos:pos+count]
            pos += count
            if not flags & 2:
                raw = fragments.pop(name)
                raw = zlib.decompress(raw, -15) if method == 8 else raw
                assert len(raw) == size and zlib.crc32(raw) == crc, name
                (programs / name.split('\\')[-1]).write_bytes(raw)
assert not fragments
for f in (a.output / 'disk1').iterdir():
    if f.is_file() and not re.search(r'\.D\d\d$', f.name):
        (programs / f.name).write_bytes(f.read_bytes())
with a.harddisk.open('rb') as f:
    start = int.from_bytes(f.read(512)[454:458], 'little')
spec = f'{a.harddisk}@@{start*512}'
subprocess.run(['mmd', '-i', spec, '::DOS'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
subprocess.run(['mcopy', '-o', '-i', spec, *map(str, programs.iterdir()), '::DOS/'], check=True)
rexx = programs / 'TEST.CMD'
rexx.write_bytes(b"say 'REXX FUNCTION OK'\r\nsay 6 * 7\r\nexit 0\r\n")
subprocess.run(['mcopy', '-o', '-i', spec, str(rexx), '::DOS/TEST.CMD'], check=True)


def test(job):
    name, config = job
    dest = a.output / name
    dest.mkdir(exist_ok=True)
    floppy = dest / 'boot.img'
    floppy.write_bytes((a.disks / 'DISK1.IMG').read_bytes())
    command = name + ' /? <NUL'
    if name == 'REXX.EXE':
        command = 'REXX.EXE C:\\DOS\\TEST.CMD'
    if config:
        command = 'MEM.EXE /C'
    batch = '@ECHO OFF\r\nSET PATH=C:\\DOS\r\nC:\r\nCD \\DOS\r\n' + command + '\r\nECHO.\r\nECHO PRUEFUNG_FERTIG\r\n'
    auto = dest / 'AUTOEXEC.BAT'
    auto.write_bytes(batch.encode('cp850'))
    subprocess.run(['mcopy', '-o', '-i', str(floppy), str(auto), '::AUTOEXEC.BAT'], check=True)
    if config:
        cfg = dest / 'CONFIG.SYS'
        cfg.write_bytes(config.replace('\n', '\r\n').encode('cp850'))
        subprocess.run(['mcopy', '-o', '-i', str(floppy), str(cfg), '::CONFIG.SYS'], check=True)
    cmd = ['qemu-system-i386', '-machine', 'pc', '-m', '32', '-snapshot', '-display', 'none', '-monitor', 'stdio', '-serial', 'none', '-no-reboot',
           '-drive', f'file={a.harddisk},format=raw', '-drive', f'file={floppy},format=raw,if=floppy', '-boot', 'a']
    screen = dest / 'vga.bin'
    text = ''
    done = False
    with (dest / 'qemu.log').open('wb') as log:
        q = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=log, stderr=log, env=dict(os.environ, TMPDIR=str(dest)))
        try:
            deadline = time.monotonic() + 30
            last_key = 0
            while q.poll() is None and time.monotonic() < deadline:
                q.stdin.write(f'pmemsave 0xb8000 4000 "{screen}"\n'.encode())
                q.stdin.flush()
                time.sleep(.3)
                if not screen.exists():
                    continue
                b = screen.read_bytes()
                text = '\n'.join(b[i:i+160:2].decode('cp850') for i in range(0, len(b), 160))
                if 'PRUEFUNG_FERTIG' in text:
                    done = True
                    break
                if name == 'E.EXE' and '-- Weiter --' in text and time.monotonic() - last_key > .7:
                    q.stdin.write(b'sendkey spc\n')
                    q.stdin.flush()
                    last_key = time.monotonic()
        finally:
            if q.poll() is None:
                q.stdin.write(b'quit\n')
                q.stdin.flush()
                try:
                    q.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    q.kill()
                    q.wait()
    (dest / 'screen.txt').write_text(text)
    version_error = bool(re.search(r'(Falsche DOS-Version|Incorrect DOS version)', text, re.I))
    return dict(file=name, returned=done, version_error=version_error, screen=text)


# Kernel files are tested by booting; the generated front ends and SYS32 by
# pcdos_smoke.py plus the interactive menu/installation checks in TESTED.md.
excluded = {'INSTALL.EXE', 'IBMBIO.COM', 'IBMDOS.COM', 'EMM386.EXE', 'POWER.EXE', 'SYS32.COM', 'FDISK.COM', 'FORMAT.COM'}
jobs = [(f.name, None) for f in sorted(programs.iterdir()) if f.suffix.upper() in ('.COM', '.EXE') and f.name not in excluded]
for name in ['HIMEM.SYS', 'EMM386.EXE', 'ANSI.SYS', 'DISPLAY.SYS', 'DRIVER.SYS', 'EGA.SYS', 'RAMDRIVE.SYS', 'POWER.EXE', 'CMOSCLK.SYS', 'SETVER.EXE']:
    args = {'EMM386.EXE': ' NOEMS', 'DISPLAY.SYS': ' CON=(EGA,,1)', 'DRIVER.SYS': ' /D:0', 'RAMDRIVE.SYS': ' 1024 /E'}.get(name, '')
    base = 'DEVICE=C:\\DOS\\HIMEM.SYS\n' if name in ('EMM386.EXE', 'RAMDRIVE.SYS') else ''
    jobs.append((name, base + f'DEVICE=C:\\DOS\\{name}{args}\nFILES=40\nLASTDRIVE=Z\n'))
results = []
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
    for result in pool.map(test, jobs):
        results.append(result)
        print(result['file'], 'PASS' if result['returned'] and not result['version_error'] else 'FAIL', flush=True)
(a.output / 'results.json').write_text(json.dumps(results, ensure_ascii=False, indent=2))
failed = [r['file'] for r in results if not r['returned'] or r['version_error']]
if failed:
    raise SystemExit('Failed: ' + ', '.join(failed))
print(f'PASS: {len(results)} program/driver startup checks; hardware functions require separate tests.')
