@echo off

:: Unicode
chcp 65001 > nul

:: ls
SET ls_options=-I "NTUSER.*" -I "ntuser.*" --color
DOSKEY ls=ls %ls_options% $*
DOSKEY la=ls -a %ls_options% $*
DOSKEY ll=ls -l %ls_options% $*

:: grep
DOSKEY grep=grep --color=auto $*

:: find
DOSKEY find="C:\tools\cygwin64\bin\find.exe" $*
DOSKEY findf="C:\tools\cygwin64\bin\find.exe" $* -type f
DOSKEY findd="C:\tools\cygwin64\bin\find.exe" $* -type d

:: cd
DOSKEY cdu=cd %USERPROFILE%

:: .NET
DOSKEY msbuild="C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" $*

:: pandoc
DOSKEY pandoc="%USERPROFILE%\AppData\Local\Pandoc\pandoc.exe" $*

DOSKEY pip="C:\Python36\Scripts\pip.exe" $*
DOSKEY pip2="C:\Python27\Scripts\pip.exe" $*

:: Work-Specific Aliases
SET work_aliases="%USERPROFILE%\work\aliases.cmd"
IF EXIST %work_aliases% CALL %work_aliases%
