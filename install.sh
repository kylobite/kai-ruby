#!/usr/bin/env sh

cd dep
tar -zxvf sqlite.tar.gz
cd sqlite
./configure; make; make install
make clean
make distclean
cd ../../