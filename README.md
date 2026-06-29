# T2 SDE

T2 SDE is not just a regular Linux distribution - it is a flexible
Open Source System Development Environment or Distribution Build Kit.
Others might even name it Meta Distribution. T2 allows the creation of
custom distributions with state of the art technology, up-to-date
packages and integrated support for cross compilation. Currently the
Linux kernel is usually used, but we also started to port T2 to
support compiling home-brew like open source package add-ons on macOS,
other BSDs, classic Unix systems (Irix, ...) or support bootstrapping
alternative micro kernel systems (like a L4 variant or
Fuchsia). Similarly building Haiku, Android, Minix, Hurd, Open (or
Pure) Darwin, Haiku and OpenBSD could be supported, too.

# Download

It is usually best to start with a pre-built ISO download. More
information, including about the latest source tree are at:

https://t2sde.org/download/


# T2 SDE Developer Cheatsheet

Quick reference for T2 SDE development, system maintenance and hacking. Run commands from `/usr/src/t2-src`.

Reference docs:
- [T2 Handbook](https://t2linux.com/handbook/)
- [Knowledge Base](https://t2linux.com/documentation/kb/)

---

## Background: t2, mine and bize

T2 SDE started as a fork of ROCK Linux, and some of the tools date back
to that time. Source build scripts live in `scripts/*`; binary package handling
is a separate, older layer:

| Tool | Origin | Role |
|---|---|---|
| `t2` | added 2023 | modern CLI wrapper around `scripts/*` |
| `scripts/*` | ROCK era | the build system itself: `Build-Pkg` builds one package, `Emerge-Pkg` resolves dependencies, `Build-Target` builds whole systems |
| `mine` | ROCK Linux | the original binary package manager; installs, removes and creates `.gem` packages, also handles `tar.*` |
| `bize` | T2 | lighter reimplementation; installs and removes `tar.*` binary packages |

Source builds always go through the top-level `t2` mapping to internal `scripts/*`.
Binary package install/remove goes through `mine` or `bize`; the `stone` installer
and `t2 uninstall` use `mine` when available and fall back to `bize`. The
`.gem` format is the ROCK/T2 binary package container (unrelated to Ruby
gems); plain `tar.*` packages carry the same content without the wrapper.

---

## Contents

- [Background: t2, mine and bize](#background-t2-mine-and-bize)
- [t2 Command Overview](#t2-command-overview)
- [Getting Started](#getting-started)
- [Package Maintenance](#package-maintenance)
  - [Build](#build)
  - [Rebuild](#rebuild)
  - [Cleaning](#cleaning)
  - [Reading Build Errors](#reading-build-errors)
- [Package Development](#package-development)
  - [Create a Package from a URL](#create-a-package-from-a-url)
  - [.desc Field Reference](#desc-field-reference)
  - [Update a Package Version](#update-a-package-version)
  - [Compute a Download Checksum](#compute-a-download-checksum)
  - [Validate Packages](#validate-packages)
  - [Submit a New Package](#submit-a-new-package)
  - [Test Downloads Against the Real URL (not the mirror)](#test-downloads-against-the-real-url-not-the-mirror)
- [Hacking the Source Tree](#hacking-the-source-tree)
  - [Listing Changed Files](#listing-changed-files)
  - [Comparing Against Upstream](#comparing-against-upstream)
  - [Single File - Diff & Pull from Upstream](#single-file---diff--pull-from-upstream)
  - [Colored Diff](#colored-diff)
  - [Patching](#patching)
  - [Commit Workflow](#commit-workflow)
- [Building Systems](#building-systems)
  - [Building a T2 Target (Full System)](#building-a-t2-target-full-system)
  - [Kernel Build Options](#kernel-build-options)
  - [Build an ISO](#build-an-iso)
  - [Install Binary Packages into Another Root](#install-binary-packages-into-another-root)

---

## t2 Command Overview

| Command | Does |
|---|---|
| `t2 up` (`pull`, `sync`) | update the source tree (svn/git) |
| `t2 config` | create/edit a target configuration profile |
| `t2 install` (`inst`) | build + install a package and its dependencies |
| `t2 uninstall <pkg>` | remove a package (via mine/bize) |
| `t2 upgrade` | upgrade all installed packages (`Emerge-Pkg -system`) |
| `t2 build-target` | build a whole target sandbox |
| `t2 create-iso` | create an ISO after a target build |
| `t2 download` (`dl`) | download a package's source assets |
| `t2 clean` (`clear`) | clean up build artifacts |
| `t2 find <keyword>` | find packages by name/metadata |
| `t2 create <url>` | create a new package from an external URL |
| `t2 update <pkg>` | bump a package's version metadata |
| `t2 list-errors` | list build errors across the target |
| `t2 commit` (`ci`) | commit changes to the T2 source tree |
| `t2 apply <patch>` | apply a patch to the tree |
| `t2 bench` | benchmark the system |
| `t2 help <cmd>` | help for a sub-command |

---

## Getting Started

Always update the source tree before starting work to avoid working on stale files.

```sh
t2 up
```

> **Note:** `t2 update <package>` is different: it bumps a package's version metadata (queries Repology, refreshes checksums). It does **not** update the source tree.

---

## Package Maintenance

### Build

Build (and install) a package and its dependencies. Use `-optional-deps=no` to
skip optional deps and `-parallel 1` for serialized, readable output.

```sh
t2 install -optional-deps=no -parallel 1 <package>
```

### Rebuild

Rebuild and reinstall a package even if it is already installed and up to
date. Use this after editing a `.desc` so the change takes effect.

```sh
t2 install -force <package>
t2 install -force -optional-deps=no -parallel 1 <package>
```

The second form skips optional dependencies and prints serialized,
readable output.

### Cleaning

Remove build artifacts (temporary `src.*` build dirs, logs) to start fresh.

```sh
t2 clean <package>
t2 clean
```

### Reading Build Errors

When a build fails, T2 writes per-package logs to `/var/adm/logs/`, named
`<stage>-<package>.{out,log,err}`. A `.err` file means that package failed;
`.out` holds the full output and `.log` a successful build. The path is:

```sh
/var/adm/logs/<stage>-<package>.err
```

List or browse current build errors across the target with:

```sh
t2 list-errors
```

Inspect a specific failure directly (full output and the error log):

```sh
ls /var/adm/logs/*.err
less /var/adm/logs/9-<package>.err
less /var/adm/logs/9-<package>.out
```

---

## Package Development

### Create a Package from a URL

`t2 create` generates a new package skeleton. For GitHub/GitLab URLs it
queries the API and fills in description, author, license, latest release
version and the `[D]` download automatically; kde.org and gnome.org URLs
get matching repository defaults.

```sh
t2 create https://github.com/<user>/<repo>
t2 create package/<repository>/<name> <tarball-url>
```

It creates `package/<repository>/<name>/<name>.desc`, adds the copyright
header, runs `svn add`, then immediately starts a test build. Fill in any
fields it prints as TODOs afterwards.

### .desc Field Reference

| Field | Required | Notes |
|---|---|---|
| `[COPY]` | yes | always GPL-2.0, license of the `.desc` file itself, not the package |
| `[I]` | yes | one-line title |
| `[T]` | yes | description, one sentence per line |
| `[A]` | yes | upstream author(s) |
| `[M]` | yes | maintainer name and email |
| `[U]` | yes | homepage URL |
| `[C]` | yes | category from `misc/share/PKG-CATEGORIES` |
| `[F]` | no | build flags, see below |
| `[L]` | yes | license from `misc/share/REGISTER`, e.g. `GPL`, `GPL3`, `MIT`, `OpenSource` |
| `[V]` | yes | upstream version |
| `[P]` | no | build-by-default flag, stage mask and build priority, see below |
| `[E]` | no | dependencies: `add pkg`, `opt pkg`, `del pkg` |
| `[D]` | yes | `<checksum> <filename> <base-url>` |

`[P]` syntax, e.g. `X 01---5---9 110.900`:

- `X` or `O`: build by default or not
- 10-character stage mask, one position per stage 0-9: a digit means the
  package builds in that stage (0 = host toolchain, 1-2 = cross, 5+ = native),
  `-` means it is skipped there
- priority number: a plain sort key for the build order (`sort -k3` in
  `scripts/Create-PkgList`), the dot is only a naming convention: digits
  before it are the coarse group (000 dirtree, 101 libc, 102 toolchain,
  110 libraries, 5xx applications, 800 kernel), digits after it order
  packages within the group

Common `[F]` flags:

| Flag | Meaning |
|---|---|
| `CROSS` | can be built during the cross-compilation stage |
| `NO-LTO` | disable Link Time Optimization |
| `NO-SSP` | disable stack smashing protector |
| `OBJDIR` | build out-of-tree (separate build directory) |

### Update a Package Version

`t2 update` bumps a package's `[V]` version and refreshes the `[D]`
checksums:

| Invocation | Effect |
|---|---|
| `t2 update <pkg>` | query Repology for the latest version and update to it |
| `t2 update <pkg> <ver>` | update to the given version |
| `t2 update <pkg> refresh` | keep the version, recompute checksums only |
| `t2 update <url>` | scan a directory listing and update all matching packages |

### Compute a Download Checksum

`[D]` lines use the legacy "Unix" CRC cksum or, preferably, modern SHA of the **decompressed** tarball, not of the file:

```sh
cripts/Create-CkSumPatch <pkg>

```

### Validate Packages

Lint a package's `.desc` format, and check upstream for newer versions:

```sh
scripts/Check-PkgFormat <package>
scripts/Check-PkgVersion <package>
```

Both also accept `-repository <name>` to sweep a whole repository.

### Submit a New Package

Include the build cache so reviewers have dependency information:

```sh
t2 ci --cache <package>
```

### Test Downloads Against the Real URL (not the mirror)

By default `t2 download` uses the T2 mirror, which hides broken `[D]` URLs. To test the real upstream URL, turn the mirror off, re-fetch, then restore it:

```sh
t2 download --mirror none<package>
rm download/Mirror-Cache
```

---

## Hacking the Source Tree

### Listing Changed Files

Show which files have changed across the tree, or scoped to a package:

```sh
svn status
svn status package/base/bash
```

For a per-file line-count summary (+/-), pipe through `diffstat`:

```sh
svn diff | diffstat
svn diff package/base/bash | diffstat
```

### Comparing Against Upstream

Show what changed on the server since your last update (ignores your local edits):

```sh
svn diff -r BASE:HEAD | diffstat
svn diff -r BASE:HEAD | colordiff | less -R
```

Show how your working copy differs from the latest upstream HEAD (local + upstream changes combined):

```sh
svn diff -r HEAD | diffstat
```

Quick reference:

| Command | Compares |
|---|---|
| `svn diff` | working copy vs BASE (your last update) |
| `svn diff -r HEAD` | working copy vs HEAD (latest on server) |
| `svn diff -r BASE:HEAD` | BASE vs HEAD (server changes only, no local edits) |

### Single File - Diff & Pull from Upstream

Diff one file against upstream (server changes only):

```sh
svn diff -r BASE:HEAD package/base/bash/bash.desc
```

Pull (update) one file from upstream without touching anything else:

```sh
svn update package/base/bash/bash.desc
```

### Colored Diff

Pipe through `colordiff` and page with `-R` to preserve colors:

```sh
svn diff | colordiff | less -R
svn diff package/base/bash | colordiff | less -R
```

### Patching

Generate a patch to ship upstream. In an svn checkout, `svn diff` is enough:

```sh
svn diff package/<cat>/<package>/<package>.desc > package-fix.patch
```

Apply a patch to the tree:

```sh
t2 apply <patch-file>
```

### Commit Workflow

For an interactive diff-review + auto-generated cksum and commit log before committing to SVN:

```sh
t2 commit bash
```

To batch commit all locally modified packages that have a `[D]` download entry:

```sh
t2 ci $(grep 'D] .[^ ]' $(svn st package/ | grep '\.desc$' | sed 's/.* //') | cut -d / -f 3)
```

---

## Building Systems

### Building a T2 Target (Full System)

Build a complete system from source into a sandbox under `build/<ID>/`.

#### 1. Create a build config

Each config lives in `config/<name>/` and is independent of `default`.

```sh
t2 config -cfg mini
```

Key options in the menu:

| Option | Where | Recommended |
|---|---|---|
| Package preselection template | first option (generic target) | `Bootstrap` or `Base` |
| Show expert and experimental options | main menu | needed for custom package selection |
| Custom package selection | expert → `- Additional Package Selection` | only for fine-tuning |

#### 2. Package preselection templates

Templates live in `target/generic/pkgsel/*.in` and compose via `include`:

| Template | ~Packages | Contents |
|---|---|---|
| Toolchain | 8 | bare cross toolchain |
| Bootstrap | 99 | smallest self-hosting system (can rebuild itself) |
| Base | 187 | bootstrap + compression, filesystem and network basics |
| Base-xorg / Base-desktop / Base-wayland | more | graphical stacks on top of Base |

The template is re-applied each time Config saves, so switching templates
resets the selection.

#### 3. Custom package selection rules

Enable *Custom package selection* (`SDECFG_PKGSEL`), then edit the rules file
(also editable in-menu under *Edit package selection rules*). Re-run Config
to apply the rules:

```sh
$EDITOR config/mini/pkgsel
t2 config -cfg mini
```

Rule syntax (one rule per line, patterns may be `repo/*`):

| Rule | Effect |
|---|---|
| `O *` | deselect everything |
| `X base/*` | select the whole base repository |
| `X dropbear` | select one package |
| `- somepkg` | remove a package entirely |
| `= glibc` | reset a package to its default state |

> **Note:** keep the file to plain rule lines: comment-only or blank lines
> trigger a syntax popup in Config.

Verify the selection before building (`X` = will build):

```sh
grep -c '^X' config/mini/packages
grep '^X' config/mini/packages | awk '{print $4"/"$5}' | less
```

#### 4. Build

Sources are downloaded per package as needed; pre-fetching with
`t2 download -required` avoids mid-build network stalls.

```sh
t2 download -cfg mini -required
t2 build-target -cfg mini
```

> **Note:** options like `-cfg` must come **before** mode flags like
> `-required`; `t2 download` stops option parsing at the first
> unknown token and silently ignores the rest.

`t2 build-target` is equivalent to `scripts/Build-Target`. Stage order:
0 (toolchain on host), 1-2 (cross into sandbox), then native chroot stages.
Re-running after a failure resumes; already-built packages are skipped.

#### 5. Monitor a target build

Per-package logs are written inside the build sandbox; a `.err` file means
that package failed.

```sh
ls build/mini-*/var/adm/logs/ | tail
ls build/mini-*/var/adm/logs/*.err
```

The finished system root is `build/<ID>/`.

### Kernel Build Options

The kernel `.config` for a target build is assembled automatically in
layers; later stages override earlier ones:

| Stage | Source |
|---|---|
| 1 | `architecture/<arch>/linux.conf{,.sh,.m4}` base template |
| 2 | everything enabled as modules (`make no2modconfig`) |
| 3 | `target/<target>/linux.conf.sh` script hooks |
| 4 | `config/<cfg>/linux.cfg`, then `target/<target>/linux.conf` |
| 5 | `make oldconfig` validation, modules/nomodules split |

Override options with plain kernel-config lines in
`config/<cfg>/linux.cfg`. The file is merged automatically when it exists
and overrides the auto-generated config. `=n` is translated to
`is not set`. The Config menu offers a built-in editor for this file under
*Linux Kernel Options* → *"Apply custom kernel build configuration
settings"*:

```
CONFIG_PREEMPT=y
CONFIG_BTRFS_FS=y
CONFIG_SOUND=n
```

Config style (Config menu → *Linux Kernel Options*):

| Style | Effect |
|---|---|
| `modules` | auto-config, modular where possible (default) |
| `nomodules` | auto-config, everything built-in |
| `none` | skip auto-config, `config/<cfg>/linux.cfg` is used verbatim as the complete `.config` |

Rebuild the kernel into the target after changing the config:

```sh
rm -f build/mini-*/var/adm/logs/*-linux.{log,err}
t2 build-target -cfg mini
```

> **Note:** prefer override snippets over style `none`: a full verbatim
> `.config` freezes you to one kernel version, while snippets survive
> kernel updates because the base config is regenerated each build.

### Build an ISO

Create a bootable/install ISO from a finished target build. Output is
`<prefix>.iso` plus a `<prefix>.sha` checksum in the T2 top directory.

```sh
t2 create-iso mini mini
```

`t2 create-iso <prefix> <config>` is equivalent to `scripts/Create-ISO`.
Useful options (before the prefix):

| Option | Effect |
|---|---|
| `-size <MB>` | split across media of the given size |
| `-source` | include package sources on the ISO |

Write the image to a USB stick:

```sh
dd if=mini.iso of=/dev/sdX bs=4M status=progress
```

### Install Binary Packages into Another Root

Install prebuilt binary packages into a mounted system instead of `/`.
`bize` installs and removes `tar.*` binary packages; `-R <root>` redirects
everything to the target, including registration in the target's own
`/var/adm`. This is the same mechanism the `stone` installer uses.

Prerequisite: make the target build produce binary packages:

| Option | Where | Value |
|---|---|---|
| Binary package format | expert → `- Binary package format` | `tar.zst` |

The build then writes one file per package to `build/<ID>/TOOLCHAIN/pkgs/`.

Install and remove in a target root:

```sh
bize -i -R /mnt/target build/<ID>/TOOLCHAIN/pkgs/<pkg>-[0-9]*.tar.zst
bize -r -R /mnt/target <pkg>
```

Seed a fresh root with a whole build:

```sh
for p in build/<ID>/TOOLCHAIN/pkgs/*.tar.zst; do bize -i -R /mnt/target "$p"; done
```

Inspect the target's package database:

```sh
ls /mnt/target/var/adm/packages
```

> **Note:** `bize` does not resolve dependencies; install runtime deps
> yourself. Run as root so file ownership is preserved.


# Subversion and Git

Historically we adapted SVN when it was state of the art. Currently
we mirror to Git for user's convenience and might switch to it as
primary repository in the future.

# Feature & bug bounties

In 2021 René Rebe's https://exactco.de started a feature bounty
program! At the time of writing paying out 10€ for bounty-S, 25€ for
bounty-M, 50€ for bounty-L and 100€ for bounty-XL feature requests
issues marked so by "rxrbln".

The provided patch or pull request must be reasonably clean code,
reproducible (at least mostly) build and work. Successful bounties are
paid out thru PayPal or (if preferred, and reasonable for the amount)
wire transfer within the EU.

The bounties are meant to give back to the community, inspire next
generation open source developers and not to feed automated LLM "AI"
clankers. Therefore only real humans are eligible. To limit
administrative overhead we can unfortunately not pay fractional work.

If in doubt, best ask before working on a larger bounty.

https://github.com/rxrbln/t2sde/issues?q=is%3Aopen+is%3Aissue+author%3Arxrbln

# History

"T2" started as a community driven fork of the ROCK Linux project in
2004 which aims at simplicity, clean and lightweight Linux build system.

"T2" was an intern project name for "try two / second try" or "technology
two". The idea was to eventually choose a more public relation aware
name, but somehow we just kept sticking with t2 so far ;-)
