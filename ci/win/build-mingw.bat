setlocal

set qtplatform=mingw53_32
for %%* in (.) do set CurrDirName=%%~nx*

set PATH=C:\Qt\Tools\mingw530_32\bin;%PATH%;
set MAKEFLAGS=-j%NUMBER_OF_PROCESSORS%

mkdir build-%qtplatform%
cd build-%qtplatform%

C:\Qt\%QT_VER%\%qtplatform%\bin\qmake -r ..\%PROJECT%.pro || exit /B 1
mingw32-make || exit /B 1
mingw32-make INSTALL_ROOT=/projects/%CurrDirName%/install install || exit /B 1

:: tests
mingw32-make all || exit /B 1

set PATH=C:\Qt\%QT_VER%\%qtplatform%\bin;%CD%\lib;%PATH%;
cd tests\auto
set QT_QPA_PLATFORM=minimal
for /r %%f in (tst_*.exe) do (
	%%f || exit /B 1
)
