# Notes for AI Agents Working in This Tree

Practical operating notes for coding agents (Claude, Codex, etc.) working on
T2 SDE `.desc`/`.cache`/`scripts/*` fixes and cross-compile builds.
Complements `README.md` (the human developer cheatsheet) — read that first for
command syntax; this file is about the gotchas that aren't obvious from it.

## Core rule: real fixes only

This is a cross-compiling build system. A fix must actually work under real
cross-compilation, not just look plausible. Never:
1. disable a check to make an error go away without understanding it
2. hardcode a flag/path to bypass a genuinely missing dependency
3. claim something is fixed without test building it.
   Always verify: check the package size in `var/adm/packages/<pkg>`
   ("0.00 MB, N files" with N ~5-7 = phantom, bookkeeping-only install, not a
    real one) and, for anything you can directly test, that the installed files
   actually work (e.g. `import lxml`, `meson --version`). Target binaries can
   often be run with `qemu-<arch> -cpu <model> -L $root`, e.g. to run the
   package's own test suite. Commit fixes that could not be build-verified with
   an `, untested` subject suffix.
4. If a package needs to run a native executable helper to build, it needs to be
   built within the package, or if it is a bigger, shared tool in the t2 native
   tools stage 0 and installed into the build's sysroot/TOOLCHAIN/cross.
5. Do not disable a feature per architecture in the `.desc` when upstream
   detection is wrong. Search upstream first: e.g. pcre2 10.49 auto detected
   the sljit Alpha JIT, but its release tarball lacked `sljitNativeALPHA_64.c`;
   the file existed upstream at the pinned sljit commit and was added as a
   hotfix patch. Only if no upstream fix exists, patch the detection itself.

## `.desc` / `.cache` — the most-repeated mistakes

1. Do not simply disable features that do not build, correctly conditionalize
   optional dependencies to pkginstalled $pkg || ...disable feature... or
   atstage cross && ... if a feature does not cross compile for reasons.
2. **Adding `[E] add pkg` / `[E] opt pkg` to a `.desc` without also adding the
   matching `[DEP] pkg` / `[OPT] pkg` line to that package's `.cache`** (same
   directory, `<pkg>.cache`). The `.cache` file is what the build *scheduler*
   uses for dependency-graph/build-order decisions; a `.desc`-only edit does
   not immediately take effect for a full/bulk target build until the `.cache`
   also has it (or a full successful build regenerates the cache itself).
3. **The opposite mistake, just as common: adding `[E] add pkg` when `pkg` is
   ALREADY listed in the `.cache`.** If it's already there, the dependency is
   already correctly tracked — adding a `.desc` line is a no-op that doesn't
   fix anything and just adds noise. **Before adding an `[E]` line, grep the
   `.cache` first.** If the error is "dependency not found" but the `.cache`
   already lists it, the real problem is something else: the dependency
   package isn't actually built for this target yet, it's stale (version
   mismatch), or there's a real build-system bug (see the "Common root
   causes" section below) — go find that instead.
4. `pkginstalled()` (in `scripts/functions.in`) takes multiple package names
   for a dependency group in one call and returns true only if **all** are
   installed — use `pkginstalled pkgA pkgB || ...` for a combined AND-gate
   instead of two separate calls. It also auto-registers every argument as
   an `[E] opt` dependency (visible as `[OPT]` in the `.cache` after a build) —
   so a dynamic `pkginstalled` check in the script body does NOT also need a
   static `[E] opt` line; that would be redundant, same as point 2 above.
5. If a package needs its `configure`/`Makefile` regenerated (tarball ships
   only `configure.ac`/`Makefile.am`), set `autogen=1` (or `2`) in the
   `.desc` — do not hand-add a `hook_add preconf ... "autoreconf ..."` line.
   The generic build flow already has this path built in.
6. Code belongs to the end of .desc, not in the middle between tags, separated
   from the last `[]` tag line by a blank line. Trivial global build variables
   (`runmake=0`, `runcmake=0`, `autogen=1`, `autoextract=0`, `makeinstopt=`,
   `srcdir=`, games `bindir`/`datadir`, ...) go first, directly below the
   tags, not appended at the end after hooks and functions.
   Write single statement conditionals in the short form:
   `atstage cross && var_append ...`, `pkginstalled foo || var_append ...`,
   `cond && var_append A || var_append B` instead of `if ...; then ... fi`
   blocks (only where the first statement cannot fail, and not as the last
   command of a function, where the status matters).
7. Do not cause random white-space and new-line damage: keep the blank lines
   separating topics, give a new comment-led block its own paragraph, and end
   every package file with exactly one newline (no trailing blank line; drop
   the separator too when removing the last block).
8. Update `<pkg>.cache` files from successful builds with relevant dependency
   changes. Only add verified real deps (fl_wrapper deps can be bogus), refresh
   the header, and commit it together with the fix.
9. `[P]` lines added only for build stages omit the default priority:
   `[P] X ?----5---9`, not `... 800.000`.
10. Disable test suites, benchmarks and examples unconditionally for build
    speed (`-DBUILD_TESTING=OFF`, `--disable-tests`, ...), not just under
    `atstage cross`. Keep only really cross specific things (man pages
    generated by running the built binary) behind `atstage cross`.
11. `[R]` lines list the architectures really supported by the toolchain or
    upstream (LLVM backends, Rust, Go, mono/dotnet targets, ...), also for the
    hard dependent users, not a bare `[R] - alpha` for the current target.
    Prefer making the code build generically over an `[R]` limit.
12. Use `[F] FCOMMON` instead of appending `-fcommon`, and do not sed
    `-march=native`, `-mtune`, `-mcpu`, `-O*`, `-Werror`, `-Wextra` out of
    Makefiles: the gcc wrapper (`GCC_WRAPPER_REMOVE` in
    `package/develop/gcc/parse-config`) already strips them. Fix only what
    really bypasses the wrapper, like a hardcoded `gcc`/`g++` instead of
    `$(CC)`/`$(CXX)`.
13. When a CMake build is incomplete or ignores options the autotools build
    honors (e.g. pcre2 16/32 bit libraries), use `runcmake=0` and the
    configure build instead of duplicating every option as `cmakeopt`.

## Generic fixes already in `scripts/functions.in`

Do not re-add these per package, and remove per package copies you find:
- `-DCMAKE_POLICY_VERSION_MINIMUM=3.5` default for CMake 4.
- `sharedstatedir` is `/var/lib` (autoconf defaults to `$prefix/com`).
- The builtin autogen copies `config.guess`/`config.sub` when `configure`
  needs them and no automake adds them.
- The CMake toolchain file sets `CMAKE_SYSTEM_IGNORE_PATH` for the sysroot
  `bin`/`sbin` dirs, so target programs are not found as build host tools.
- Generic PEP517 install with `--destdir` (see below).

When the same workaround appears in several `.desc` files, implement it once
generically and drop the per package copies in the same commit.

## Comments and attribution

- Do not add comments for one-liners, variable settings (`var=`, `export`,
  `var_append`) or conditionals around them (`atstage`/`pkginstalled`
  chains, `if`/`case` blocks), e.g. no `# help2man runs the built programs`
  above `atstage cross && var_append confopt ...`. The reason goes into the
  commit message. Only more complex code (hooks, functions, loops, sed
  scripts) gets a brief comment.
- Inline comments in `.desc`/patch files: max 1-2 short lines, and never
  prefixed with a maintainer's name/email (e.g. no `# René Rebe: ...`). That
  belongs in the commit message, not scattered through every source file.
- Patches apply at `-p1`.
  `diff -u`/`svn diff`-style hunks with real context so the affected function
  is visible in the hunk header.
- `t2 create` and normal `.desc` edits already carry the standard T2
  copyright header — don't invent a different header style.
- Do not add signed-off-by or additional copyright to pkgs .patch files.
- Name patches for upstream problems `hotfix-*.patch`: newer compiler/C23/C++
  strictness, glibc/kernel header and library API changes (OpenSSL, libxml2,
  libpng, giflib, ...), build tool changes (setuptools, bison, gettext,
  doxygen), release tarball packaging bugs and upstream build system bugs
  (underlinking, broken `autogen.sh`). Cross build, install dir, system
  library and architecture support patches keep descriptive names.
  Keep filenames short. Patches apply in sorted name order: after a rename,
  check other patches of the package touching the same files.
- Static source edits are patches, not `hook_add ... "sed -i ... Makefile"`
  in the `.desc`: save them as `hotfix-*.patch` in the package dir, and as
  `hotfix-*.patch.cross` when only needed for cross builds. Patches apply in
  `srcdir` before configure, so patch the template (`Makefile.in`/`.am`/
  `.pre`) of generated Makefiles. Keep a sed only for values known at build
  time (`$root`, `$libdir`, `$CC`, `$ver`, ...), negative arch conditions
  (`[[ $arch = x86* ]] ||`) and edits to files created during the build.

## Local git history

- One-line commit subjects starting with `<pkg>: `, no trailers.
- Same-kind changes across packages go into one topic commit, e.g. the trivial
  `[F] CROSS`/`[R]` marks, "no introspection and vapi without
  gobject-introspection", "no docs when their build tools are missing or when
  cross compiling", "use the autotools or Makefile builds instead of
  incomplete or unusable CMake ones". Split mixed commits so their topic part
  joins the topic commit.
- Fix formatting, naming and flag mistakes in the commit that caused them
  (rebase/fixup), not with later cleanup commits. Never drop a commit without
  explicit approval.
- Shared helper files belong to their owning package (e.g. `samba-waf.in` in
  samba, sourced by talloc and tdb).
- When rewriting history in a separate worktree and syncing the main work tree
  afterwards, use `git diff --no-renames --name-only`; with rename detection
  the old paths stay behind in the index and work tree.

## Disk space

A prior disk-full event during a mass build is what caused a large fraction
of one session's failures (silently truncated installs, corrupted native
tool installs — see below). Before any batch of builds, check
`df -h /srv/t2` (or wherever the tree lives) and keep a safety margin
(≥6-10GB free); stop and reassess rather than continuing into a full disk.
Clean only your own temporary data and stale build dirs.

## Common root causes worth checking before deep-diving a new failure

These recurred across many unrelated packages — check for them first:

- **`python -m installer` bootstrap circularity.** Any PEP517/flit-based
  Python package's generic install path (`scripts/functions.in`, the
  `rungpepinstall` branch) ends with `python -m installer .dist/*.whl` —
  which itself needs the `installer` module already present. `python-installer`
  itself can't rely on this (chicken/egg). Fixed by giving it a custom
  `premake`/`inmake` hook pair (`rungpepinstall=0 runmake=0` +
  `gpep517 build-wheel` + a raw `zipfile` unpack to
  `sysconfig.get_path('purelib')`), mirroring the same pattern
  `python-flit-core` already uses via its own `bootstrap_install.py`.
- **Generic PEP517 install missing `--destdir`.** The same
  `python -m installer .dist/*.whl` call had no destination root, so it
  wrote straight into the live host `site-packages` instead of the
  sandboxed target root — the sandbox's `fl_wrapper.so` correctly blocks
  that as "write outside basedir", and the package silently ends up with
  0 real files. Fixed globally: `python -m installer --destdir="$root"
  .dist/*.whl` in `scripts/functions.in`.
- **A package needing to run its own just-built binary during its own
  build**, when that binary is cross-compiled for the target arch and can't
  execute on the build host. Seen with `kdoctools` (`meinproc6`), `akonadi`
  (`protocolgen`), and many code generators (mir's wayland generator,
  ftk-resource, table/codebook generators). Build the helper for the build
  host within the package (`$BUILDCC`/`$BUILDCXX`, a host CMake sub build or
  a `*_build-cc` patch), or for bigger shared tools a native stage 0 build
  installed into the sysroot/TOOLCHAIN/cross (`QT_HOST_PATH`/
  `KF6_HOST_TOOLING`-style host-tool export).
- **Files installed into the prefix top level or wrong dirs** (data,
  translations, CMake configs, NuGet/packaging files directly below `/usr`,
  `$prefix/com`, Python packages outside site-packages). Check the flist after
  a build and fix the install dirs (e.g. qt6base `INSTALL_DATADIR`, nanobind
  site-packages).
- **Stale flist entries** from an earlier build of a package can make later
  builds fail on "shared files" conflicts or list old files (e.g. docs of a
  former CMake build); verify against file timestamps before blaming the new
  recipe.
- **KDE Frameworks / Applications version skew.** A tree-wide version bump
  (e.g. KF6 6.29.0 → 6.30.0, KDE Applications 26.08.0 → 26.08.1) leaves many
  already-built packages stale (installed at the old version) while their
  `.desc` declares the new one. Symptom: `Could NOT find KF6Foo ... (found
  suitable version "6.29.0")` when 6.30.0 was required. Not a bug — just
  needs a plain rebuild (`./t2 build-target -cfg <cfg> 2-<pkg>`) in roughly
  dependency order (lower-level frameworks before apps that use them).
  Compare `head -1 var/adm/packages/<pkg>` (installed version) against
  `grep '^\[V\]' package/*/<pkg>/<pkg>.desc` (declared version) to find all
  stale packages at once.
- **Dead upstream download URLs.** Several `[D]` lines pointed at URLs that
  407/404 now (`docbook.org` moved to `oasis-open.org`/`archive.docbook.org`,
  `pagure.io` archive paths moved to `releases.pagure.org`, project domains
  gone dark). Fix by finding a real, currently-live replacement and verifying
  it (don't guess a URL or fabricate a checksum).

## Workflow that worked well

1. Get the real error text from the actual `.err` log, not just the
   one-line summary from `list-errors` — the truncated/wrapped summary
   view can hide or mis-order the real failure line.
2. When many packages fail with a shared signature, cluster them (grep the
   tail of each `.err` for the last real error line, normalize, `sort | uniq -c`)
   before fixing one-by-one — several "35 separate failures" turned out to
   be 2-3 systemic root causes each affecting dozens of packages.
3. Fix the systemic/shared-infrastructure bug once (in `scripts/functions.in`,
   `scripts/parse-config`, or a widely-depended-on package like `perl`),
   then re-verify a sample of the previously-failing packages rather than
   patching each one individually.
4. When dispatching multiple parallel agents/workers on independent package
   batches, explicitly tell each one: check disk space before/during, expect
   and tolerate shared-config races, check `.cache` before adding `[E]` lines,
   use `autogen=`, follow the `.desc` formatting and patch naming rules above,
   and don't touch packages another agent/session already owns. Serialize
   `build-target` runs on one config.
