# 🚀 T2 SDE Quickstart

## 🧭 Overview

This guide explains how to initialize a working T2 SDE build tree from a fresh checkout, including required bootstrap steps and common pitfalls.

T2 is a staged build system:

1. Bootstrap minimal tools
2. Initialize configuration system
3. Prepare package/build infrastructure
4. Build toolchain → system → ISO

---

# 📥 1. Get the source tree

### Preferred (Git)

```bash
git clone -b trunk https://github.com/t2sde/t2sde.git
cd t2sde
```

### Alternative (SVN mirror / legacy-compatible)

```bash
svn co https://svn.exactcode.de/t2/trunk t2sde
cd t2sde
```

---

# 🧱 2. Bootstrap environment (MANDATORY)

Before anything else, run:

```bash
./scripts/Bootstrap
```

### What this does:

* installs minimal build utilities:

  * bash
  * sed
  * gawk
  * zstd
* prepares `/var/adm/flists`
* ensures basic toolchain prerequisites exist

### Output should end with:

```
Essential bootstrap done.
```

---

# ⚠️ 3. IMPORTANT: Fix luabash build dependency (SVN-required step)

Some parts of the config system depend on a build helper that is **not included in Git trees by default**.

If you get errors like:

```
Error building the Lua bash accelerator
build/bottom.make: No such file or directory
```

run:

```bash
svn co https://svn.exactcode.de/exact-build/trunk/build misc/luabash/build
```

### Why this is required:

* `scripts/Config` uses `luabash`
* `luabash` depends on helper make infrastructure
* Git trees often omit generated or external build scaffolding

---

# ⚙️ 4. Generate configuration

Now initialize the build configuration:

```bash
./t2 config -cfg default
```

or for a custom profile:

```bash
./t2 config -cfg desktop
```

### What happens:

* builds `luabash` accelerator
* initializes package database
* loads architecture/kernel/target config layers
* creates:

```
config/<name>/
```

---

# 🧠 5. Understand configuration system

Configuration is layered:

### Core config file:

```
config/<cfg>/config
```

### Key variables:

* `SDECFG_ARCH`
* `SDECFG_TARGET`
* `SDECFG_KERNEL`
* `SDECFG_OPT`
* `SDECFG_LTO`
* `SDECFG_PARALLEL`

---

# 🧰 6. Build toolchain

First stage build:

```bash
./t2 build-target -2
```

Then full system:

```bash
./t2 build-target
```

---

# 📦 7. Create ISO

```bash
./scripts/Create-ISO t2-$(uname -m) default
```

---

# 🔁 8. Full standard workflow

```bash
git clone ...
cd t2sde

./scripts/Bootstrap

svn co https://svn.exactcode.de/exact-build/trunk/build misc/luabash/build

./t2 config -cfg default

./t2 build-target -2
./t2 build-target

./scripts/Create-ISO t2-$(uname -m) default
```

---

# 🚨 Common problems

## ❌ “No configuration 'default' found!”

Cause:

* config system not initialized

Fix:

```bash
./t2 config -cfg default
```

---

## ❌ luabash build failure / missing build/*.make

Cause:

* missing SVN build scaffolding

Fix:

```bash
svn co https://svn.exactcode.de/exact-build/trunk/build misc/luabash/build
```

---

## ❌ Bootstrap errors

Cause:

* missing host tools or incomplete repo

Fix:

* ensure full checkout (not shallow / partial)
* re-run Bootstrap

---

# 🧠 Design principles (important)

T2 is not a single build tool — it is:

* 🧩 staged self-building system
* ⚙️ config-driven build graph
* 🧱 dependency bootstrapping chain

So order matters:

```
Bootstrap → luabash → Config → Toolchain → System → ISO
```

Skipping any stage breaks later stages.

---

# 🧭 Summary

Minimum working path:

```bash
Bootstrap
→ luabash build (SVN step)
→ config
→ build-target -2
→ build-target
→ ISO
```

# 🧠 9. What happens after `config`

Once this works:

```bash
./t2 config -cfg default
```

you now have a **fully generated build definition** inside:

```
config/default/
```

That directory becomes the *source of truth* for everything else.

It contains:

* `config` → all `SDECFG_*` variables
* `packages` → enabled package graph
* `pkgsel` → selection rules (optional)
* cached metadata from config system

👉 From this point onward, T2 stops asking questions and becomes deterministic.

---

# 🏗️ 10. Stage system (VERY IMPORTANT)

T2 builds in **stages**, not one monolithic build.

## Stage 0 — Toolchain bootstrap

```bash
./t2 build-target -2
```

### What it does:

* builds minimal compiler toolchain
* prepares headers, binutils, gcc
* establishes isolation build prefix

👉 This is the “self-hosting foundation”

---

## Stage 1+ — Full system build

```bash
./t2 build-target
```

### What it does:

* builds full package set
* resolves dependencies
* compiles everything in order
* produces system root tree

👉 This is the actual Linux system

---

## Stage 9 (optional rebuild stage)

Controlled by:

```
SDECFG_DO_REBUILD_STAGE
```

Used for:

* recompilation after full system exists
* optimization passes
* rebuild verification

---

# 📦 11. Package system (core of T2)

T2 is not “script-driven build” — it is:

> 🧩 package graph execution engine

Each package has:

```
package/<category>/<name>/
```

Inside:

* `.desc` → metadata
* build scripts
* dependency definitions
* optional patches

---

### Selection flow:

During config:

```
target → architecture → kernel → package selection → rules
```

This builds:

```
config/<cfg>/packages
```

which becomes the **build manifest**

---

# 🧠 12. Why luabash exists

This is critical and often misunderstood.

### `luabash` is:

> a performance accelerator for shell config evaluation

It:

* embeds Lua into bash
* speeds up config parsing
* reduces repeated shell execution overhead

### Why SVN is needed:

Because this part:

```
misc/luabash/build
```

contains:

* generated Makefile fragments
* build glue not always included in Git

👉 Without it:

* config system cannot compile helper
* dialog system fails
* config crashes early

---

# 🧰 13. Config UI system (`confdialog`)

When you run:

```bash
./t2 config
```

you are actually running:

### internal flow:

1. build `luabash`
2. load config.in
3. generate menus dynamically
4. compile ncurses dialog binary
5. render interactive UI

---

### Important insight:

T2 config is NOT static.

It is:

> 🧠 a runtime-generated UI from shell scripts + metadata

---

# ⚙️ 14. Key system variables (how everything connects)

### Architecture layer

```
SDECFG_ARCH
```

### Target system (desktop/server/minimal/etc)

```
SDECFG_TARGET
```

### Kernel choice

```
SDECFG_KERNEL
```

### Optimization profile

```
SDECFG_OPT
SDECFG_LTO
SDECFG_PIE
```

### Build behavior

```
SDECFG_PARALLEL
SDECFG_TMPFS
SDECFG_RETRY_BROKEN
```

👉 These are **not just config options**
They directly influence:

* package selection
* compiler flags
* build stages
* dependency graph

---

# 🧱 15. Build execution model (important mental model)

T2 executes like this:

```
config → package graph → staged execution engine → filesystem root → ISO
```

NOT like:

```
compile everything blindly
```

Instead:

### Each package:

1. checked against config rules
2. staged (0–9)
3. built only if dependency satisfied
4. recorded in flist database

---

# 📦 16. Output artifacts

After full build:

### System root:

```
/build/<arch>/root/
```

### Package logs:

```
logs/<arch>-<package>.log
```

### Package database:

```
/var/adm/packages/
```

### File lists:

```
/var/adm/flists/
```

### ISO:

```
iso/t2-<arch>.iso
```

---

# 🔁 17. Full lifecycle (complete view)

This is the real pipeline:

```text
1. Bootstrap host tools
2. Fix missing luabash build (SVN dependency)
3. Generate config (scripts/Config)
4. Create package graph
5. Build toolchain (stage -2)
6. Build full system
7. Generate ISO
8. (optional) rebuild/optimize
```

---

# 🚨 18. Why your system broke earlier

You hit this chain:

### ❌ Problem:

* config failed → luabash missing build backend
* package graph incomplete
* default config never created
* build-target ran on empty system

### Root cause:

> missing **SVN-provided build scaffolding**

---

# 🧭 19. Key takeaway

T2 is:

> 🧠 a declarative OS builder driven by shell + generated dependency graphs

NOT:

* a makefile project
* a single build script
* a Docker workflow

---

# 🚀 If you want next step

I can help you build something much more powerful:

### 🔧 Option A — “t2 doctor”

Detects:

* missing SVN components
* broken config state
* incomplete bootstrap
* invalid architecture setup

---

### 🔧 Option B — “t2 init”

One command:

```bash
t2 init --arch x86_64 --target desktop
```

Does everything:

* bootstrap
* fetch missing luabash build
* create config
* prepare build graph

---

### 🔧 Option C — full pipeline redesign

Turn this into:

* reproducible DAG execution
* caching layer
* CI-ready build matrix
* deterministic rebuild system

