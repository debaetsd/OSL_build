@echo on

if %1.==. goto End
set root=%1

set /p gitArgs=<"%root%.git"
if not exist %root% (
	git clone --depth 1 %gitArgs% %root%
)

set cmakeArgs=
if exist %root%.cmakeArgs set /p cmakeArgs=<"%root%.cmakeArgs"

set postBuild=
if exist %root%.postBuild set /p postBuild=<"%root%.postBuild"

set invokeDir=..
if exist "%root%.invokeDir" set /p invokeDir=<"%root%.invokeDir"

pushd %root%

if exist ../%root%.patch patch -p0 -i ../%root%.patch -N

set cmBuild=cmBuild

if not exist %cmBuild% mkdir %cmBuild%

pushd %cmBuild%

cmake -G %compiler% -A %arch% %invokeDir%  -DCMAKE_DEBUG_POSTFIX=d -DCMAKE_INSTALL_PREFIX=%module% -DCMAKE_PREFIX_PATH=%module% %cmakeArgs%
if NOT ["%errorlevel%"]==["0"] pause

if not exist ../../%root%.releaseOnly cmake --build . --target install -j 8 --config debug
if NOT ["%errorlevel%"]==["0"] pause
cmake --build . --target install -j 8 --config release
if NOT ["%errorlevel%"]==["0"] pause

%postBuild%

popd

popd

goto End


:End