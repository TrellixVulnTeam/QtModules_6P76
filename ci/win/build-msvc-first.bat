:: %1 varsall type
:: %2 platform
setlocal
@echo on

set varsall=%1
set platform=%2

call %VC_DIR% %varsall% || exit /B 1

echo BUILDDDDD build-%platform%
mkdir build-%platform%
cd build-%platform%

echo about to qmake C:\Qt\%QT_VER%\%platform%\bin\qmake
C:\Qt\%QT_VER%\%platform%\bin\qmake -r ..\%PROJECT%.pro || exit /B 1
nmake || exit /B 1

for %%* in (.) do set CurrDirName=%%~nx*
nmake INSTALL_ROOT=\projects\%CurrDirName%\install install || exit /B 1
