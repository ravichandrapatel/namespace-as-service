#!/usr/bin/env python3
from __future__ import annotations

from semver_bump import next_version, stable_from_release_branch


def main() -> None:
    cases = [
        ("1.0.0-rc.1", "rc", "patch", "1.0.0-rc.2"),
        ("1.0.0", "rc", "patch", "1.0.1-rc.1"),
        ("1.0.0", "rc", "minor", "1.1.0-rc.1"),
        ("1.0.0-rc.3", "stable", "patch", "1.0.0"),
        ("1.0.0", "next-dev", "patch", "1.0.1-rc.1"),
        ("1.0.0-rc.5", "next-dev", "patch", "1.0.1-rc.1"),
        ("1.0.0", "next-dev", "minor", "1.1.0-rc.1"),
    ]
    for current, channel, bump, expected in cases:
        got = next_version(current, channel, bump)
        assert got == expected, f"{current}/{channel}/{bump}: got {got}, want {expected}"

    assert stable_from_release_branch("release/1.0.0", "1.0.0-rc.4") == "1.0.0"
    assert stable_from_release_branch("refs/heads/release/1.0.0", "1.0.0-rc.1") == "1.0.0"
    try:
        stable_from_release_branch("release/1.1.0", "1.0.0-rc.1")
        raise AssertionError("expected mismatch failure")
    except SystemExit:
        pass
    print("semver_bump ok", len(cases) + 3, "cases")


if __name__ == "__main__":
    main()
