# T2 SDE
T2 System Development Environment
  ... more than a Linux distribution.

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

# Build architecture

T2 builds in stages to bootstrap from nothing:

| Stage | What | How |
|-------|------|-----|
| 0 | Cross-compiler toolchain | Builds binutils + gcc for `$arch` targeting the build host |
| 1 | Minimal target base | Cross-compiles glibc, kernel headers, core utils into a sysroot |
| 2 | Target GCC | Rebuilds gcc natively inside the fresh sysroot |
| 3-8 | Full system | Cross-compiles packages against the stage-2 sysroot |
| 9 | Final rebuild | `Emerge-Pkg` / `t2 install` — natively on the running target |

All package recipes are plain shell + metadata (`.desc` files). No custom
DSL, no Python, no XML — just `sh` and `make`. The build is reproducible:
same config = same binary checksums.

# Portability

T2 currently targets these architectures — many bootstrapped nightly
with automated ISO generation:

`alpha`, `arm`, `arm64`, `hppa`, `ia64`, `loongarch64`, `m68k`,
`microblaze`, `mips64`, `mipsel`, `openrisc`, `ppc64le`, `ppc64-32`,
`riscv32`, `riscv64`, `sparc64`, `x86`, `x86-64`

# Bug philosophy

T2 ships "rolling with tags" — packages land in the tree as soon as they
build. If a build breaks, we revert or fix it forward. There is no
separate "stable" branch; stability comes from the stage system and
automated rebuild infrastructure.

Known rough edges:
- Python cross-compilation (KB#8 on t2sde.org)
- GObject introspection on cross-compiled ISOs
- PowerPC 32-bit GRUB boot
- NVIDIA nouveau support for Turing+ GPUs

If you hit a failure, `scripts/Build-Target` with `-xtrace` will show
exactly where it broke. Patches welcome — bounties available for larger
fixes (see below).

# History

"T2" started as a community driven fork of the ROCK Linux project in
2004 which aims at simplicity, clean and lightweight Linux build system.

"T2" was an intern project name for "try two / second try" or "technology
two". The idea was to eventually choose a more public relation aware
name, but somehow we just kept sticking with t2 so far ;-)
