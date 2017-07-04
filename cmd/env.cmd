@echo off

:: Unicode
chcp 65001 > nul

:: ls
SET ls_options=-I "NTUSER.*" -I "ntuser.*" -I "Desktop.ini" --color
DOSKEY ls=ls %ls_options% $*
DOSKEY la=ls -a %ls_options% $*
DOSKEY ll=ls -l %ls_options% $*

:: find
DOSKEY find="C:\Program Files\Git\usr\bin\find.exe" $*

:: Python
set PYTHONHOME=C:\Python27
set PYTHONPATH=C:\Python27\Lib

:: Work-Specific Aliases
CALL %USERPROFILE%\work\aliases.cmd 2> nul
