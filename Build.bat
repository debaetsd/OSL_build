@echo on
setlocal enableDelayedExpansion


set cwd=%cd%
set "cwd=%cwd:\=/%"

set outputDir="__InstalledExternals"

if not exist %outputDir% mkdir %outputDir%

set module=%cwd%/%outputDir%

set compiler="Visual Studio 17 2022"
set arch="x64"

rem Boost is special (who would have guessed)
if not exist boost git clone -j8 --recurse-submodules --depth 1 --branch boost-1.80.0 https://github.com/boostorg/boost.git boost
pushd boost
if not exist builddir mkdir builddir
call bootstrap.bat
if NOT ["%errorlevel%"]==["0"] pause
call .\b2.exe --prefix=%module% debug release link=shared threading=multi architecture=x86 address-model=64 toolset=msvc runtime-link=shared --build-dir=builddir --build-type=complete stage install --with-filesystem --with-system --with-thread --with-regex
if NOT ["%errorlevel%"]==["0"] pause
popd
rem copy boost dlls to bin folder
set libDir=%outputDir%/lib
set binDir=%outputDir%/bin
robocopy %libDir% %binDir% "Boost_*.dll" /NFL /NDL /NJH /NJS /nc /ns /np
 
set libs=zlib
set libs=%libs%;winflexbison
set libs=%libs%;pugixml
set libs=%libs%;LLVM
set libs=%libs%;libjpeg-turbo
set libs=%libs%;libpng
set libs=%libs%;libtiff
set libs=%libs%;openexr
set libs=%libs%;pybind11
set libs=%libs%;oiio
set libs=%libs%;OpenShadingLanguage
rem set libs=%libs%;MaterialX

for %%f in (%libs%) do (
	set dep_name=%%~nf
	call BuildHelper.bat !dep_name!
)

:End












