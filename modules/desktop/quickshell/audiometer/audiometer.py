#!/usr/bin/env python3
"""Stream short-window PCM peaks from PipeWire's PulseAudio compatibility server.

No samples are written to disk; only an aggregate amplitude is printed. One
instance reads either the default input or the default output monitor.
"""
import array
import os
import select
import signal
import subprocess
import sys
import time

if len(sys.argv) != 2 or sys.argv[1] not in ('input', 'output'):
    sys.exit('usage: qs-audiometer input|output')
device = '@DEFAULT_SOURCE@' if sys.argv[1] == 'input' else '@DEFAULT_MONITOR@'
child = subprocess.Popen([os.environ.get('QS_PAREC', 'parec'), '--raw',
    '--device=' + device, '--format=s16le', '--rate=16000', '--channels=2',
    '--latency-msec=100', '--process-time-msec=25',
    '--client-name=Quickshell Signal Meter',
    '--property=application.name=Quickshell Signal Meter'],
    stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, bufsize=0)
def stop(_signal, _frame):
    child.terminate()
    try:
        child.wait(timeout=1)
    except subprocess.TimeoutExpired:
        child.kill(); child.wait()
    sys.exit(0)
signal.signal(signal.SIGTERM, stop)
signal.signal(signal.SIGINT, stop)
try:
    leftover = b''
    peak = 0
    received = False
    deadline = time.monotonic() + 0.1
    while True:
        ready, _, _ = select.select([child.stdout], [], [], max(0, deadline - time.monotonic()))
        if ready:
            data = os.read(child.stdout.fileno(), 8192)
            if not data:
                break
            data = leftover + data
            leftover = data[len(data) & ~1:]
            samples = array.array('h'); samples.frombytes(data[:len(data) & ~1])
            if sys.byteorder != 'little': samples.byteswap()
            if samples:
                peak = max(peak, max(abs(v) for v in samples)); received = True
        now = time.monotonic()
        if now >= deadline:
            # A stalled or absent capture is unavailable, not fabricated silence.
            if received:
                print('%.5f' % min(1.0, peak / 32768.0), flush=True)
                peak = 0; received = False
            deadline = now + 0.1
finally:
    if child.poll() is None:
        child.terminate()
        try: child.wait(timeout=1)
        except subprocess.TimeoutExpired: child.kill(); child.wait()
