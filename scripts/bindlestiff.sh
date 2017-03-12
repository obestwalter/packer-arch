#!/usr/bin/env bash

# tmpfs is to small for big test runs - deactivating it to use block device
# see https://wiki.archlinux.org/index.php/Tmpfs
echo "===> Deactivate tmpfs"
sudo systemctl mask tmp.mount

echo "===> Install dependencies needed for compiling Python interpreters"
sudo pacman --noconfirm -S base-devel openssl zlib git xz

echo "===> Install pyenv"
curl https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | sh

echo "===> Activate pyenv ..."
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

echo "===> Adjust .bashrc: activate pyenv, delete *.pyc files, cd into /vagrant on login"
sed -i '$ a\\ export PATH="$HOME/.pyenv/bin:$PATH"' $HOME/.bashrc
sed -i '$ a\\ eval "$(pyenv init -)"' $HOME/.bashrc
# pytest fails with ImportMismatchError if we don't tidy up between runs
# on the host and on the guest
sed -i '$ a\\ echo "Removing all *.pyc files in mapped project ..."' $HOME/.bashrc
sed -i '$ a\\ find /vagrant -name '*.pyc' -delete' $HOME/.bashrc
sed -i '$ a\\ cd /vagrant' $HOME/.bashrc
sed -i '$ a\\ echo "WARNING you need to remove .pyc when you switch runs between guest and host"' $HOME/.bashrc

INTERPRETERS="3.6.0 2.6.9 2.7.13 3.3.6 3.4.5 3.5.2 pypy2-5.6.0"
echo "===> Install Python versions: $INTERPRETERS"
for version in ${INTERPRETERS}; do
    pyenv install -s ${version}
done

echo "===> Activate all Python interpreters globally, so tox finds them ..."
pyenv global ${INTERPRETERS}

echo "===> Ensure latest version of tox is installed"
pip install tox
