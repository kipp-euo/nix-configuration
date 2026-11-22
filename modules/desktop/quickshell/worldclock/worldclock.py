#!/usr/bin/env python3
"""Offline world clock service. JSON lines in/out; never invokes a shell or network."""

import datetime as dt
import json
import os
import re
import select
import sys
import tempfile
import zoneinfo
from functools import lru_cache
from pathlib import Path

UTC = dt.UTC
OFFSET = re.compile(r"^(?:UTC|GMT)?([+-])(\d{1,2})(?::?(\d{2}))?$", re.I)


def fixed_zone(key):
    m = OFFSET.fullmatch(key.strip())
    if not m:
        return None
    hours, minutes = int(m[2]), int(m[3] or 0)
    if hours > 23 or minutes > 59:
        return None
    seconds = (hours * 60 + minutes) * 60 * (1 if m[1] == "+" else -1)
    return dt.timezone(dt.timedelta(seconds=seconds))


@lru_cache(maxsize=2048)
def get_zone(key):
    if key == "UTC":
        return UTC
    fixed = fixed_zone(key)
    if fixed is not None:
        return fixed
    try:
        return zoneinfo.ZoneInfo(key)
    except (zoneinfo.ZoneInfoNotFoundError, ValueError):
        return None


def offset_text(seconds):
    n = int(seconds)
    sign = "+" if n >= 0 else "-"
    n = abs(n)
    return "%s%02d:%02d" % (sign, n // 3600, n % 3600 // 60)


def metadata():
    result, countries, links = {}, {}, {}
    for root in zoneinfo.TZPATH:
        try:
            for line in (Path(root) / "iso3166.tab").read_text().splitlines():
                if line and not line.startswith("#"):
                    code, name = line.split("\t", 1)
                    countries[code] = name
            # zone.tab has more precise territories; zone1970.tab is fallback.
            for filename in ("zone.tab", "zone1970.tab"):
                try:
                    for line in (Path(root) / filename).read_text().splitlines():
                        if line and not line.startswith("#"):
                            f = line.split("\t")
                            result.setdefault(
                                f[2],
                                " ".join(countries.get(c, c) for c in f[0].split(",")),
                            )
                except (OSError, ValueError, IndexError):
                    continue
            try:
                for line in (Path(root) / "tzdata.zi").read_text().splitlines():
                    parts = line.split()
                    if len(parts) >= 3 and parts[0] in ("L", "Link"):
                        links[parts[2]] = parts[1]
            except OSError:
                pass
            if result or links:
                break
        except (OSError, ValueError):
            continue
    return result, links


def canonical_zone(key, links):
    if key in ("UTC", "Etc/UTC"):
        return "UTC"
    seen = set()
    candidate = key
    while candidate in links and candidate not in seen:
        seen.add(candidate)
        candidate = links[candidate]
    if candidate == "Etc/UTC":
        return "UTC"
    return candidate if get_zone(candidate) is not None else key


def state_path():
    base = os.environ.get("XDG_STATE_HOME") or str(Path.home() / ".local/state")
    return Path(base) / "quickshell-topbar" / "worldclock.json"


def load_state():
    try:
        data = json.loads(state_path().read_text())
        if not isinstance(data, dict):
            return {}
        return data
    except (OSError, ValueError):
        return {}


def save_state(data):
    path = state_path()
    try:
        path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        fd, name = tempfile.mkstemp(prefix=".worldclock-", dir=path.parent)
        try:
            with os.fdopen(fd, "w") as f:
                json.dump(data, f, ensure_ascii=False)
                f.flush()
                os.fsync(f.fileno())
            os.replace(name, path)
        finally:
            if os.path.exists(name):
                os.unlink(name)
        return None
    except OSError as e:
        return str(e)


def valid_keys(values, links):
    if not isinstance(values, list):
        return []
    output = []
    for value in values[:100]:
        if not isinstance(value, str) or len(value) > 255:
            continue
        value = canonical_zone(value, links)
        if value not in output and get_zone(value) is not None:
            output.append(value)
    return output


def main():
    countries, links = metadata()
    raw_ids = zoneinfo.available_timezones()
    catalogue = sorted(
        {canonical_zone(key, links) for key in raw_ids if get_zone(key) is not None}
    )
    if "UTC" not in catalogue:
        catalogue.insert(0, "UTC")
    aliases = {}
    for alias in links:
        canonical = canonical_zone(alias, links)
        if canonical != alias and canonical in catalogue:
            aliases.setdefault(canonical, []).append(alias)
    saved = load_state()
    favorites = valid_keys(saved.get("favorites", []), links)
    recent = valid_keys(saved.get("recent", []), links)[:10]
    reference = saved.get("reference", "UTC")
    if not isinstance(reference, str):
        reference = "UTC"
    reference = canonical_zone(reference, links)
    if get_zone(reference) is None:
        reference = "UTC"
    error = ""
    pending = b""
    while True:
        now = dt.datetime.now(UTC)
        local = now.astimezone()
        keys = list(dict.fromkeys(catalogue + favorites + recent + [reference]))
        rows = []
        localoffset = int(local.utcoffset().total_seconds())
        for key in keys:
            tz = get_zone(key)
            if tz is None:
                continue
            current = now.astimezone(tz)
            off = int(current.utcoffset().total_seconds())
            days = (current.date() - local.date()).days
            label = key.replace("_", " ")
            country = countries.get(key, "")
            rows.append(
                {
                    "id": key,
                    "label": label,
                    "country": country,
                    "aliases": " ".join(aliases.get(key, [])),
                    "abbr": current.tzname() or "",
                    "offset": offset_text(off),
                    "offsetSeconds": off,
                    "deltaSeconds": off - localoffset,
                    "dayShift": days,
                    "date": current.strftime("%a %Y-%m-%d"),
                    "time24": current.strftime("%H:%M:%S"),
                    "time12": current.strftime("%I:%M:%S %p"),
                }
            )
        payload = {
            "zones": rows,
            "favorites": favorites,
            "recent": recent,
            "reference": reference,
            "localZone": str(local.tzname() or ""),
            "localOffset": offset_text(localoffset),
            "error": error,
        }
        print(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), flush=True)
        ready, _, _ = select.select([sys.stdin], [], [], 1.0)
        if not ready:
            continue
        chunk = os.read(sys.stdin.fileno(), 65536)
        if not chunk:
            break
        pending += chunk
        if len(pending) > 262144:
            pending = b""
            continue
        while b"\n" in pending:
            line, pending = pending.split(b"\n", 1)
            try:
                command = json.loads(line)
            except (ValueError, UnicodeDecodeError):
                continue
            if not isinstance(command, dict):
                continue
            action, key = command.get("action"), command.get("id")
            if not isinstance(key, str) or len(key) > 255:
                continue
            key = canonical_zone(key, links)
            if get_zone(key) is None:
                continue
            changed = False
            if action == "select":
                reference = key
                recent = [key] + [x for x in recent if x != key][:9]
                changed = True
            elif action == "favorite":
                favorites = (
                    [x for x in favorites if x != key]
                    if key in favorites
                    else favorites + [key]
                )
                changed = True
            if changed:
                error = (
                    save_state(
                        {"favorites": favorites, "recent": recent, "reference": reference}
                    )
                    or ""
                )


if __name__ == "__main__":
    main()
