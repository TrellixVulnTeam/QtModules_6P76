#!/bin/bash
set -e

export XZ_OPT=-9

cd install/opt
tar cJf build_osx_$QT_VER.tar.xz qt
