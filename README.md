# Isolated Development Environment

Would you like to use different versions of a software — say Python — like `py2.7`, `py3.10`, and `py3.12` on the same device?

This project builds toward a minimal containerization system from scratch — no Docker, no OCI, just Linux primitives: `chroot`, `namespaces`, and `cgroups`.

The entire process is logged in `worklog.md`.

---

### Roadmap

| Phase | What | Status |
|---|---|---|
| 1 | `chroot` jail with multiple Python versions | done |
| 2 | Builder → slim image pipeline | in progress |
| 3 | Containerized runtime via namespaces + cgroups | upcoming |

---

### Project Structure

```bash
work/
  |-> downloads/                  # .tgz source tarballs from python.org (via wget)
  |-> extracted_source_code/      # extracted source trees
  |-> configured_source_code/     # source after ./configure --prefix
  |-> pyEnv/                      # chroot jail — full builder environment
  |-> build/                      # slim runtime image (stripped pyEnv)
  |-> scripts/                    # automation scripts
```

---

## Phase 1 — chroot Jail

A working `chroot` jail with three Python versions built from source and
installed inside the jail at:

```
pyEnv/opt/python2.7/
pyEnv/opt/python3.10/
pyEnv/opt/python3.12/
```

Symlinks are created **inside** the jail at `/usr/local/bin/`:

```bash
py2.7  -> /opt/python2.7/bin/python2.7
py3.10 -> /opt/python3.10/bin/python3.10
py3.12 -> /opt/python3.12/bin/python3.12
```

> Symlinks must be created from inside the chroot — links made outside won't
> resolve correctly inside the jail.

### Usage

```bash
sudo chroot /path/to/pyEnv py2.7
sudo chroot /path/to/pyEnv py3.10
sudo chroot /path/to/pyEnv py3.12
```

Confirmed working:

```
$ sudo chroot Env/ py2.7
Python 2.7 (r27:82500, Aug 28 2025, 17:53:37) [GCC 12.2.0] on linux6
>>>

$ sudo chroot Env/ py3.10
Python 3.10.1 (main, Aug 28 2025, 18:43:29) [GCC 12.2.0] on linux
>>>

$ sudo chroot Env/ py3.12
Python 3.12.10 (main, Aug 28 2025, 19:33:14) [GCC 12.2.0] on linux
>>>
```

---

## Phase 2 — Builder Architecture

A two-stage environment model, similar in concept to Docker's multi-stage
builds — implemented entirely with `chroot`.

#### Stage 1 — Builder

`pyEnv` is a full copy of the host filesystem:

```bash
sudo cp -r /{bin,etc,lib,lib64,sbin,usr} ./pyEnv/
```

Inside it you have `apt`, `gcc`, `make`, `wget` — everything needed to
compile and install software. Python versions are built from source here.

Docker equivalent:

```dockerfile
FROM debian AS builder
RUN apt install build-essential && ./configure && make && make install
```

#### Stage 2 — Build (the image)

`build/` is a stripped-down chroot containing *only* runtime artifacts —
compiled Python binaries and their shared library dependencies. No compiler,
no `apt`, no source trees.

Assembled by copying from the builder and resolving shared libs with `ldd`:

```bash
cp -r pyEnv/opt/python3.12 build/opt/python3.12
ldd pyEnv/opt/python3.12/bin/python3.12    # identify .so deps
cp <required .so files> build/lib/
```

Docker equivalent:

```dockerfile
FROM scratch
COPY --from=builder /opt/python3.12 /opt/python3.12
```

Compressed into a portable image:

```bash
tar -czf pyEnv_build.tar.gz -C build/ .
```

This tarball is the image — equivalent to a Docker image layer, without the daemon.

#### Side by side

| | Builder (`pyEnv`) | Build (`build/`) |
|---|---|---|
| Purpose | compile, install | run |
| Has `apt` / `gcc` | yes | no |
| Has source code | yes | no |
| Size | ~hundreds of MB | minimal |
| Exported | no | yes (`.tar.gz`) |
| Docker equivalent | `FROM debian AS builder` | `FROM scratch` |

> The builder → build pipeline currently works manually.
> Automation is the immediate next goal — see scripts below.

---

## Phase 3 — Containerized Runtime *(upcoming)*

The slim `build/` image will be wrapped with proper Linux isolation:

- **`namespaces`** — isolate PID, mount, network, UTS, and user contexts
- **`cgroups`** — limit and account for CPU, memory, and process count

This turns the chroot image into a proper container — spawned and torn down
programmatically, without a daemon.

---

### Scripts

`work/scripts/` automates the pipeline:

| Script | Purpose | Status |
|---|---|---|
| `build_python.sh` | download, extract, configure, make, install a given version | planned |
| `slim.sh` | copy binaries from builder, resolve `.so` deps via `ldd` | planned |
| `export.sh` | compress `build/` into a `.tar.gz` image | planned |
| `install.sh` | single entry point — ties all three together | planned |

---

### What's Next

- [ ] `build_python.sh` — automate Python build inside the builder
- [ ] `slim.sh` — resolve deps and assemble the lean `build/` image
- [ ] `export.sh` — compress and export the image
- [ ] `install.sh` — single-command setup
- [ ] Parameterize Python versions (pass as args, not hardcoded)
- [ ] Phase 3 — wrap `build/` with `unshare` for namespace isolation
- [ ] Phase 3 — apply `cgroups` for resource limits

~
