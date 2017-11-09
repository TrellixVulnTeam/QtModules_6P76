#!/bin/bash
# $1 Qt Version
# $2 repoid
# $3 version
# $4+ skip packages
set -e

qtVer=$1
moduleName=$2
version=$3
skip=$4
branch=$5
repoId=$6

# prepare vars
if [ -z "$branch" ]; then
	branch="$version"
fi

if [ -z "$repoId" ]; then
	repoId="Skycoder42/$moduleName"
fi

#prepare dirs
mkdir -p "$qtVer"
mkdir -p archives

# clone & prepare the sources
git clone "https://github.com/${repoId}.git" --branch "$branch" ./$qtVer/src
mv ./$qtVer/src/repogen.sh ./
cp ./$qtVer/src/LICENSE ./
rm -rf ./$qtVer/src/.git
rm -f ./$qtVer/src/*.yml

# create headers
#wget -q "https://code.qt.io/cgit/qt/qtbase.git/plain/bin/syncqt.pl"
pushd ./$qtVer/src
syncqt.pl -module "$moduleName" -version "$version" "$(pwd)"
popd

pushd archives
#download all possible packages (.tar.xz)
for arch in android_armv7 android_x86 clang_64 doc gcc_64 ios; do
	ok=1
	for skip_pattern in $skip; do
		if [[ "$arch" == *"$skip_pattern"* ]]; then
			ok=0
		fi
	done

	if [ "$ok" == "1" ]; then
		file=build_${arch}_${qtVer}.tar.xz
		echo downloading and extracting $file
		wget -q "https://github.com/${repoId}/releases/download/${branch}/$file"
		tar -xf "$file" -C "../$qtVer/"
	fi
done

#download all possible packages (.zip)
for arch in mingw53_32 msvc2015 msvc2015_64 msvc2017_64 winrt_armv7_msvc2017 winrt_x64_msvc2017 winrt_x86_msvc2017; do
	ok=1
	for skip_pattern in $skip; do
		if [[ "$arch" == *"$skip_pattern"* ]]; then
			ok=0
		fi
	done

	if [ "$ok" == "1" ]; then
		file=build_${arch}_${qtVer}.zip
		echo downloading and extracting $file
		wget -q "https://github.com/${repoId}/releases/download/${branch}/$file"
		unzip -qq "$file" -d "../$qtVer/"
	fi
done
popd
