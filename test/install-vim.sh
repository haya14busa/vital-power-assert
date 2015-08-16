#!/bin/sh
# REF: https://github.com/vim-jp/vital.vim/blob/master/install-vim.sh
set -e
if [ x"$HEAD" = "xyes" ]; then
  git clone --depth 1 https://github.com/vim-jp/vim /tmp/vim
  cd /tmp/vim
  ./configure --prefix="$HOME/vim" --with-features=huge \
    --enable-perlinterp --enable-pythoninterp --enable-python3interp \
    --enable-rubyinterp --enable-luainterp --enable-fail-if-missing
  make -j2
  make install
fi
