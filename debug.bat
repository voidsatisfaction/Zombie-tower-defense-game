@echo off
cd /d %~dp0
set SDL2QUICK_PATH_BACK=%PATH%

setlocal enabledelayedexpansion
set lib=lib
for /l %%i in (1, 1, 10) do (
	set lib=..\!lib!
	if exist "!lib!" goto lib_for_break
)
:lib_for_break

set path_ruby="%lib%\Ruby23"
set path_ruby_x64="%lib%\Ruby23-x64"
if exist "%path_ruby_x64%" (
	set path_ruby="%path_ruby_x64%"
)

:LOOP
	cls
	set PATH=%~dp0\%path_ruby%\bin;%~dp0\%lib%\sdl2quick;%PATH%
	%path_ruby%\bin\ruby.exe -I %~dp0\%lib%\sdl2quick %lib%\sdl2quick\start.rb "%lib%" 2> game.log
	set PATH=%SDL2QUICK_PATH_BACK%
	type game.log
	pause
goto LOOP
