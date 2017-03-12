#!/usr/bin/env bash

INTERPRETERS="3.6.0 2.6.9 2.7.13 3.3.6 3.4.5 3.5.2 pypy2-5.6.0"

echo "===> Install dependencies needed for compiling Python interpreters"
sudo pacman --noconfirm -S base-devel openssl zlib git xz

echo "===> Install pyenv"
curl https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | sh

echo "===> Activate pyenv ..."
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

echo "===> adjust .bashrc to activate pyenv and cd into /vagrant on login"

sed -i '$ a\\ export PATH="$HOME/.pyenv/bin:$PATH"' $HOME/.bashrc
sed -i '$ a\\ eval "$(pyenv init -)"' $HOME/.bashrc
sed -i '$ a\\ cd /vagrant' $HOME/.bashrc

echo "===> Install Python versions: $INTERPRETERS"
for version in ${INTERPRETERS}; do
    pyenv install -s ${version}
done

echo "===> Activate all Python interpreters globally, so tox finds them ..."
pyenv global ${INTERPRETERS}

echo "===> Ensure latest version of tox is installed"
pip install tox
