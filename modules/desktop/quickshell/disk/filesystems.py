#!/usr/bin/env python3
"""One-shot local filesystem capacity. Avoid touching remote/network mounts."""
import json
import os
import re
import sys
from pathlib import Path

ESC = re.compile(r'\\([0-7]{3})')
def unescape(s): return ESC.sub(lambda m: chr(int(m.group(1), 8)), s)

def physical_devices(device_number, sysroot='/sys'):
    """Resolve partitions and dm/md slaves; return only confidently physical disks.

    sysfs links, not /dev names, are the authority. An unresolved component
    makes the mapping incomplete; never silently present a partial list as full.
    """
    sysroot = Path(sysroot)
    if not re.fullmatch(r'[0-9]+:[0-9]+', device_number): return [], False
    try:
        start = (sysroot / 'dev/block' / device_number).resolve(strict=True)
    except (OSError, RuntimeError):
        return [], False
    found, visited = set(), set()
    def visit(node):
        try:
            node = node.resolve(strict=True)
            if node in visited: return True
            visited.add(node)
            if (node / 'partition').exists(): node = node.parent
            slaves = node / 'slaves'
            if slaves.is_dir():
                children = list(slaves.iterdir())
                if children:
                    complete = True
                    for child in children:
                        if not visit(child): complete = False
                    return complete
            # A physical whole device, not loop/dm/virtual block topology.
            if (node / 'device').exists() and (sysroot / 'block' / node.name).exists():
                found.add(node.name)
                return True
            return False
        except (OSError, RuntimeError):
            return False
    complete = visit(start)
    return sorted(found), complete and bool(found)


def local_filesystems(mountinfo='/proc/self/mountinfo', sysroot='/sys'):
    rows = []
    seen = set()
    with open(mountinfo, encoding='utf-8') as f:
        for line in f:
            before, sep, after = line.strip().partition(' - ')
            left, right = before.split(), after.split()
            if not sep or len(left) < 6 or len(right) < 2: continue
            mount, kind, source = unescape(left[4]), right[0], unescape(right[1])
            if not source.startswith('/dev/') or mount in seen: continue
            seen.add(mount)
            devices, complete = physical_devices(left[2], sysroot)
            # Btrfs and ZFS can span devices without exposing a complete slaves
            # graph for this mount; avoid asserting a complete mapping.
            if kind in ('btrfs', 'zfs'): complete = False
            row = {'mount': mount, 'source': source, 'type': kind,
                   'physicalDevices': devices, 'physicalMappingComplete': complete}
            try:
                st = os.statvfs(mount)
                row.update(totalBytes=st.f_blocks * st.f_frsize, freeBytes=st.f_bfree * st.f_frsize,
                           availableBytes=st.f_bavail * st.f_frsize, usedBytes=(st.f_blocks - st.f_bfree) * st.f_frsize)
            except OSError as e: row['error'] = str(e)
            rows.append(row)
    return rows

if __name__ == '__main__':
    try: print(json.dumps({'filesystems': local_filesystems()}, ensure_ascii=False))
    except OSError as e: print(json.dumps({'filesystems': [], 'error': str(e)}))
