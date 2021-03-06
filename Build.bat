@echo on
setlocal enableDelayedExpansion


set cwd=%cd%
set "cwd=%cwd:\=/%"

set outputDir="__InstalledExternals"

if not exist %outputDir% mkdir %outputDir%

set module=%cwd%/%outputDir%

set compiler="Visual Studio 16 2019"
set arch="x64"

rem Boost is special (who would have guessed)
if not exist boost git clone -j8 --recurse-submodules --depth 1 --branch boost-1.73.0 https://github.com/boostorg/boost.git boost
pushd boost
if not exist builddir mkdir builddir
call bootstrap.bat
call .\b2.exe --prefix=%module% debug release link=shared threading=multi architecture=x86 address-model=64 toolset=msvc-14.2 runtime-link=shared --build-dir=builddir --build-type=complete stage install --with-filesystem --with-system --with-thread --with-regex
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
set libs=%libs%;libtiff
set libs=%libs%;openexr
set libs=%libs%;oiio

set libs=%libs%;OpenShadingLanguage
set libs=%libs%;MaterialX

for %%f in (%libs%) do (
	set dep_name=%%~nf
	call BuildHelper.bat !dep_name!
)

:End












