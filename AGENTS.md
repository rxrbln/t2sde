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
   actually work (e.g. `import lxml`, `meson --version`).
4. If a package needs to run a native executable helper to build, it needs to be
   built within the package, or if it is a bigger, shared tool in the t2 native
   tools stage 0 and installed into the build's sysroot/TOOLCHAIN/cross.

## `.desc` / `.cache` — the two most-repeated mistakes

0. Do not simply disable features that do not build, correctly conditoinalize
   optional dependencies to pkginstalled $pkg || ...disable feature... or
   atstage cross && ... if a feature does not cross compile for reasons.
1. **Adding `[E] add pkg` / `[E] opt pkg` to a `.desc` without also adding the
   matching `[DEP] pkg` / `[OPT] pkg` line to that package's `.cache`** (same
   directory, `<pkg>.cache`). The `.cache` file is what the build *scheduler*
   uses for dependency-graph/build-order decisions; a `.desc`-only edit does
   not mmediate take effect for a full/bulk target build until the `.cache`
   also has it (or a full successful build regenerates the cache itself).
2. **The opposite mistake, just as common: adding `[E] add pkg` when `pkg` is
   ALREADY listed in the `.cache`.** If it's already there, the dependency is
   already correctly tracked — adding a `.desc` line is a no-op that doesn't
   fix anything and just adds noise. **Before adding an `[E]` line, grep the
   `.cache` first.** If the error is "dependency not found" but the `.cache`
   already lists it, the real problem is something else: the dependency
   package isn't actually built for this target yet, it's stale (version
   mismatch), or there's a real build-system bug (see the "Common root
   causes" section below) — go find that instead.
3. `pkginstalled()` (in `scripts/functions.in`) takes multiple package names
   for a dependency group in one call and returns true only if **all** are
   installed — use `pkginstalled pkgA pkgB || ...` for a combined AND-gate
   instead of two separate calls. It also auto-registers every argument as
   an `[E] opt` dependency (visible as `[OPT]` in the `.cache` after a build) —
   so a dynamic `pkginstalled` check in the script body does NOT also need a
   static `[E] opt` line; that would be redundant, same as point 2 above.
4. If a package needs its `configure`/`Makefile` regenerated (tarball ships
   only `configure.ac`/`Makefile.am`), set `autogen=1` (or `2`) in the
   `.desc` — do not hand-add a `hook_add preconf ... "autoreconf ..."` line.
   The generic build flow already has this path built in.
5. Code belongs to the end of .desc, not in the middle between tags.
6. Do not cause random white-space and new-line damage.
7. Update `<pkg>.cache` files from successful builds with relevant depencency
   changes.

## Comments and attribution

- Do not comment obvious one-lineers or conditionals.
- Inline comments in `.desc`/patch files: max 1-2 short lines, and never
  prefixed with a maintainer's name/email (e.g. no `# René Rebe: ...`). That
  belongs in the commit message, not scattered through every source file.
- Patches apply at `-p1`. 
  `diff -u`/`svn diff`-style hunks with real context so the affected function
  is visible in the hunk header.
- `t2 create` and normal `.desc` edits already carry the standard T2
  copyright header — don't invent a different header style.

## Disk space

A prior disk-full event during a mass build is what caused a large fraction
of one session's failures (silently truncated installs, corrupted native
tool installs — see below). Before any batch of builds, check
`df -h /srv/t2` (or wherever the tree lives) and keep a safety margin
(≥6-10GB free); stop and reassess rather than continuing into a full disk.

## Common root causes worth checking before deep-diving a new failure

These recurred across many unrelated packages this session — check for them
first:

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
  execute on the build host. Seen with `kdoctools` (needs to run its own
  freshly-built `meinproc6` to generate its documentation) and `akonadi`
  (needs its own `protocolgen` code generator). This needs a *native*
  companion build of the specific tool (or a `QT_HOST_PATH`/
  `KF6_HOST_TOOLING`-style host-tool export a dependent's build can pick up)
  — not something fixable by editing the dependent package alone. Left
  unresolved this session; flagging as a real, recurring cross-build gap
  worth a dedicated pass.
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

## Workflow that worked well this session

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
   use `autogen=`, and don't touch packages another agent/session already owns.
