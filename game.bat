@echo off
cd /d %~dp0
if not "%SDL2QUICKSTATE%"=="EXECUTE" (
	set SDL2QUICKSTATE=EXECUTE
	start /min cmd /c,"%~0" %*
	exit
)

setlocal enabledelayedexpansion
set lib=lib
for /l %%i in (1, 1, 10) do (
	set lib=..\!lib!
	if exist "!lib!" goto lib_for_break
)
:lib_for_break

set SDL2QUICK_PATH_BACK=%PATH%

set path_ruby="%lib%\Ruby23"
set path_ruby_x64="%lib%\Ruby23-x64"
if exist %path_ruby_x64% (
	set path_ruby=%path_ruby_x64%
)

set PATH=%~dp0\%path_ruby%\bin;%~dp0\%lib%\sdl2quick;%PATH%
%path_ruby%\bin\rubyw.exe -I %~dp0\%lib%\sdl2quick %lib%\sdl2quick\start.rb "%lib%"
set PATH=%SDL2QUICK_PATH_BACK%
