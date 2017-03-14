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

:: fzf
DOSKEY fzf="C:\Users\acraft\Downloads\fzf-0.16.6-windows_amd64\fzf.exe" $*

:: Work-Specific Aliases
CALL %USERPROFILE%\work\aliases.cmd 2> nul
