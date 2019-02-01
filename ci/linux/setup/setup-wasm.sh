#!/bin/bash
set -ex

scriptdir=$(dirname $0)

export MAKEFLAGS="-j$(nproc)"

# install prequisites
apt-get -qq update
apt-get -qq install software-properties-common python nodejs cmake default-jre git make ca-certificates curl python3 python3-pip doxygen doxyqml $EXTRA_PKG

# install qdep
pip3 install qdep

# install emsdk
git clone https://github.com/juj/emsdk.git /opt/emscripten-sdk
pushd /opt/emscripten-sdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh
popd

# build Qt for wasm
QT_BRANCH=v$QT_VER
PREFIX=/opt/qt/$QT_VER/$PLATFORM
QT_MODS="qtbase,qtwebsockets,qtdeclarative,qtremoteobjects,qtimageformats,qtsvg,qtquickcontrols2,qtgraphicaleffects,qtscxml,qtnetworkauth,qttranslations,qtxmlpatterns,qttools"

tdir=$(mktemp -d)
pushd $tdir
git clone https://code.qt.io/qt/qt5.git ./src --branch $QT_BRANCH
pushd src
./init-repository --module-subset="$QT_MODS"

# WASM FIX
if [ "$QT_VER" == "5.12.1" ]; then
	pushd qtbase
	git config user.email "Skycoder42@users.noreply.github.com"
	git config user.name "Skycoder42"
	git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/33/250433/2 && git cherry-pick FETCH_HEAD
	popd
fi

popd
mkdir build
pushd build
../src/configure -xplatform wasm-emscripten -opensource -confirm-license -make libs -prefix "$PREFIX" || (cat config.log && false)
make > /dev/null
make install
cp config.summary $PREFIX/config.summary
popd
popd

# prepare qdep
qdep prfgen --qmake "/opt/qt/$QT_VER/$PLATFORM/bin/qmake"

# cleanup
rm -rf /opt/emscripten-sdk/.git
