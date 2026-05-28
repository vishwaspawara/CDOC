# Isolated Development Environment

Would you like to use different versions of a software — say Python — like `py2.7`, `py3.10`, and `py3.12` on the same device?

I created a `chroot` jail inside a `Debian netinst` image running on `QEMU`.
The entire process is logged in `log_pydeb.md`.

---

### Project Structure

```bash
work/
  |-> downloads/                  # .tgz source tarballs from python.org (via wget)
  |-> extracted_source_code/      # extracted source trees
  |-> configured_source_code/     # source after ./configure --prefix
  |-> pyEnv/                      # chroot jail — minimal Debian root
  |-> scripts/                    # automation scripts
          ```

- `work/downloads` — source tarballs downloaded via `wget` from python.org
- `work/extracted_source_code` — extracted `.tgz` contents
- `work/configured_source_code` — Python source after running `./configure --prefix=/some/path`
- `work/pyEnv` — the actual `chroot` jail; Python versions live in `pyEnv/opt/`
- `work/scripts` — shell scripts to automate the setup (see below)

---

### How It Works

Three Python versions are built from source and installed inside the jail at:

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

> Symlinks must be created from inside the chroot — links made outside won't resolve correctly inside the jail.

---

### Usage

From outside the jail, run any version directly:

```bash
sudo chroot /path/to/pyEnv py2.7
sudo chroot /path/to/pyEnv py3.10
sudo chroot /path/to/pyEnv py3.12
```

Confirmed working output:

```
$ sudo chroot Env/ py2.7
Python 2.7 (r27:82500, Aug 28 2025, 17:53:37)
[GCC 12.2.0] on linux6
>>>

$ sudo chroot Env/ py3.10
Python 3.10.1 (main, Aug 28 2025, 18:43:29) [GCC 12.2.0] on linux
>>>

$ sudo chroot Env/ py3.12
Python 3.12.10 (main, Aug 28 2025, 19:33:14) [GCC 12.2.0] on linux
>>>
```

---

### What's Next?

- [ ] Wrap everything into a single `install.sh`
- [ ] Parameterize Python versions (pass as args, not hardcoded)
- [ ] Test non-root usage via `unshare` or user namespaces

~

Will update soon


