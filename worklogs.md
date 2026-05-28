 TASK - 

 the following exercise, in about a week's time:

 on a typical qemu

 install Debian
 create a normal user, test,

 in test's home
 create a chroot env, pych

 in pych, install 3 different versions of python, py2.7, py3.10, py3.12

 demonstrate the following:
 from outside pych, test user can use 3 different versions of python, py2.7, py3.10, py3.12 to do some simple computations.

 [[27/08/2025]]
 created QEMU environment - DEBIAN12 netinst.

 - `apt install sudo`
 - `apt install openssh-server`
 - `apt install vim`
 - `apt install git`
 - `sudo usermod -aG sudo user`
 - `mkdir {main,work}`
 - `set -o vi` and `export TERM=xterm256color` on `.bashrc`
 - `git config --global user.name vishwaspawara`
 - `git config --global user.email vishwaspawara07@gmail.com`
 - `cd main`
 - `git init`
 - ` git remote add origin git@github.com:vishwaspawara/Isolated_Development_Environment.git`
 - `touch README.md`
 - `git add README.md`
 - `git commit -m "init environment`
 - `git branch Main` 
 - `git branch -a` list all the branches
 - `git branch -m Main mani` rename from `Main` to `main`
 - `git push -u origin main` Error due to missing ssh

 - `ls -al ~/.ssh`
 - `ssh-keygen -t ed25519 -C "your-email@example.com"`
 - `ssh -T git@github.com`
 - `eval "$(ssh-agent -s)"`
 - `ssh-add ~/.ssh/id_ed25519`

 - `apt install man-db`
 - changed hostname from `debian` to `6pydeb` from `/etc/hostname`
 
 - `git push -u origin main`

 
 Downloading Python `.tgz` files

 - `apt install wget`
 - `wget https://www.python.org/ftp/python/2.7/Python-2.7.tgz`
 - `wget https://www.python.org/ftp/python/3.10.1/Python-3.10.1.tgz`
 - `wget https://www.python.org/ftp/python/3.12.10/Python-3.12.10.tgz`

 extract `.tgz`

 - `tar -xzf Python-3.12.10 -C ../extracted_source_code/` and so on

 Prepare for Chroot by copying necessary files in `~/work/Env/`

 - `sudo cp -r /{bin,etc,lib,lib64,sbin,usr} ./`
 - `mkdir mkdir dev mnt opt proc sys tmp var`

 Enter into basic Chroot environment 
 - `sudo chroot Env/`
 - `sudo chroot Env/ ./test` created `test` in chroot env.


[[28/08/2025]]

- `./configure` failed as no C compiler was found 
- `apt install build-essential` to install `gcc`, `g++`, `make`, `libc6-deb` and `dpkg-dev`

- `./configure --prefix=DIR`

- `mkdir /home/user/work/configured_source_code/py{2.7,3.10,3.13}` for `./configure`d source.

Configure and install make

for Python2.7.0 -
	from `/home/user/work/configured_source_code/python2.7` 
- `../../extracted_source_code/Python-2.7/configure --prefix=/home/user/work/Env/opt/python2.7`
- `make`
- `make install DESTDIR=/home/user/work/Env/opt/python2.7/` this *wrong* no need to put `DESTDIR` so
- `make install`

for Python3.10.1 -
	from `/home/user/work/configured_source_code/python3.10`
- `./../extracted_source_code/Python-3.10.1/configure --prefix=/home/user/work/Env/opt/python3.10`
- `make`
- `make install`

for Python3.12.10 -
	from `/home/user/work/configured_source_code/python3.12.10`
- `./../extracted_source_code/Python-3.12.10/configure --prefix=/home/user/work/Env/opt/python3.12`
- `make`
- `make install`

Different versions of python are installed in `~/opt/` now creating links between `/usr/bin` and `/opt/*`

enter the Chroot Env - if Symlinks are created outside Jail they wont work.

- `chroot Env` now create symlinks between `/opt/*` and `/usr/local/bin/*`

- `sudo ln -s /opt/python2.7/bin/python2.7 /usr/local/bin/py2.7`
- `sudo ln -s /opt/python3.10/bin/python3.10 /usr/local/bin/py3.10`
- `sudo ln -s /opt/python3.12/bin/python3.12 /usr/local/bin/py3.12`

tested `py2.7`,`py3.10`,and `py3.12` in Jail - working perfectly fine.

- `exit` from `chroot` Jail

Access python versions (py2.7, py3.10, py3.12) from outside the Jail -

- `chroot /home/user/work/Env py2.7` works 
- `chroot /home/user/work/Env py3.10` works 
- `chroot /home/user/work/Env py3.12` works
