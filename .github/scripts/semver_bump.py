#!/usr/bin/env python3
# FILE_NAME: semver_bump.py
# DESCRIPTION: Compute next chart semver for rc / stable / next-dev cycles
# VERSION: 1.0.0
# AUTHORS: ravichandrapatel

from __future__ import annotations

import argparse
import re

_SEMVER = re.compile(
    r"^(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)(?:-rc\.(?P<rc>\d+))?$"
)
_RELEASE_BRANCH = re.compile(r"^release/(?:v)?(?P<version>\d+\.\d+\.\d+)$")


def parse(version: str) -> tuple[int, int, int, int | None]:
    match = _SEMVER.match(version.strip())
    if not match:
        raise SystemExit(f"unsupported version {version!r}; expected X.Y.Z or X.Y.Z-rc.N")
    rc = match.group("rc")
    return (
        int(match.group("major")),
        int(match.group("minor")),
        int(match.group("patch")),
        int(rc) if rc is not None else None,
    )


def format_version(major: int, minor: int, patch: int, rc: int | None = None) -> str:
    base = f"{major}.{minor}.{patch}"
    return f"{base}-rc.{rc}" if rc is not None else base


def next_version(current: str, channel: str, bump: str = "patch") -> str:
    major, minor, patch, rc = parse(current)

    if channel == "rc":
        if rc is not None:
            return format_version(major, minor, patch, rc + 1)
        if bump == "major":
            return format_version(major + 1, 0, 0, 1)
        if bump == "minor":
            return format_version(major, minor + 1, 0, 1)
        return format_version(major, minor, patch + 1, 1)

    if channel == "stable":
        if rc is not None:
            return format_version(major, minor, patch, None)
        if bump == "major":
            return format_version(major + 1, 0, 0, None)
        if bump == "minor":
            return format_version(major, minor + 1, 0, None)
        return format_version(major, minor, patch + 1, None)

    if channel == "next-dev":
        # After stable X.Y.Z → next cycle X.Y.(Z+1)-rc.1 (patch by default)
        if rc is not None:
            major, minor, patch, _ = major, minor, patch, rc
            # finalize then bump
            pass
        if bump == "major":
            return format_version(major + 1, 0, 0, 1)
        if bump == "minor":
            return format_version(major, minor + 1, 0, 1)
        # patch: if currently on RC of X.Y.Z, next cycle is X.Y.(Z+1)-rc.1
        # if currently stable X.Y.Z, next is X.Y.(Z+1)-rc.1
        return format_version(major, minor, patch + 1, 1)

    raise SystemExit(f"unknown channel {channel!r}")


def stable_from_release_branch(branch: str, current: str) -> str:
    """INTENT: Validate release/X.Y.Z branch against Chart.yaml RC base and return stable version."""
    name = branch.removeprefix("refs/heads/")
    match = _RELEASE_BRANCH.match(name)
    if not match:
        raise SystemExit(
            f"release branch must match release/X.Y.Z (got {name!r})"
        )
    target = match.group("version")
    major, minor, patch, rc = parse(current)
    base = format_version(major, minor, patch, None)
    if target != base:
        raise SystemExit(
            f"branch {name!r} targets {target}, but Chart.yaml base version is {base} (current={current})"
        )
    return target


def main() -> None:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="cmd", required=True)

    bump_p = sub.add_parser("bump")
    bump_p.add_argument("current")
    bump_p.add_argument("channel", choices=("rc", "stable", "next-dev"))
    bump_p.add_argument("bump", choices=("major", "minor", "patch"), default="patch", nargs="?")

    stab_p = sub.add_parser("stable-from-branch")
    stab_p.add_argument("branch")
    stab_p.add_argument("current")

    args = parser.parse_args()
    if args.cmd == "bump":
        print(next_version(args.current, args.channel, args.bump))
    else:
        print(stable_from_release_branch(args.branch, args.current))


if __name__ == "__main__":
    main()
