# 🚀 T2 SDE Quickstart

## 🧭 Overview

T2 SDE is a staged system builder:

```
Bootstrap → Config → Toolchain → System → ISO
```

All builds are driven by configuration files generated in `config/<name>/`.

---

# 📥 1. Get the source

### Git (preferred)

```bash
git clone -b trunk https://github.com/t2sde/t2sde.git
cd t2sde
```

### SVN (legacy / compatibility)

```bash
svn co https://svn.exactcode.de/t2/trunk t2sde
cd t2sde
```

---

# 🧱 2. Bootstrap environment (required)

```bash
./scripts/Bootstrap
```

This installs minimal tools required for the build system.

When finished:

```
Essential bootstrap done.
```

---

# ⚠️ 3. Required dependency fix (luabash build)

Some builds require external luabash build infrastructure:

```bash
svn co https://svn.exactcode.de/exact-build/trunk/build misc/luabash/build
```

Without this, configuration may fail.

---

# ⚙️ 4. Create configuration

```bash
./t2 config -cfg default
```

or:

```bash
./t2 config -cfg desktop
```

This generates:

```
config/<name>/
```

Containing:

* build configuration (`config`)
* package selection (`packages`)
* internal build state

---

# 🧰 5. Build toolchain

```bash
./t2 build-target -2
```

This builds:

* compiler toolchain
* base build environment

---

# 🏗️ 6. Build full system

```bash
./t2 build-target
```

This builds the complete system according to configuration.

---

# 📦 7. Create ISO image

```bash
./scripts/Create-ISO t2-$(uname -m) default
```

---

# 🔁 Full workflow (minimal)

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

# 🧠 Key concepts

## Configuration

Stored in:

```
config/<name>/
```

Defines:

* architecture
* target system
* kernel
* optimization profile
* package selection

---

## Build stages

| Stage | Purpose             |
| ----- | ------------------- |
| -2    | Toolchain bootstrap |
| 0+    | Full system build   |

---

## Package system

Packages are defined under:

```
package/<category>/<name>/
```

Each package is built according to:

* dependency graph
* config selection rules
* stage ordering

---

## Output artifacts

| Type        | Location              |
| ----------- | --------------------- |
| System root | `/build/<arch>/root/` |
| Logs        | `logs/`               |
| Packages    | `/var/adm/packages/`  |
| File lists  | `/var/adm/flists/`    |
| ISO         | `iso/`                |

---

# ⚠️ Common issues

## Missing configuration

```
ERROR: No configuration 'default' found
```

Fix:

```bash
./t2 config -cfg default
```

---

## luabash build failure

Fix:

```bash
svn co https://svn.exactcode.de/exact-build/trunk/build misc/luabash/build
```

---

# 🧭 Build model

T2 follows a strict staged pipeline:

```
Config → Package graph → Stage execution → Root filesystem → ISO
```

Nothing is built randomly — everything is dependency-driven.

