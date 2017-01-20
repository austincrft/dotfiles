@echo off

:: Unicode
chcp 65001

:: ls
DOSKEY ls=ls --color
DOSKEY la=ls -a --color
DOSKEY ll=ls -l --color

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

:: Work-Specific Aliases
SET work_aliases="%USERPROFILE%\work\aliases.cmd"
IF EXIST %work_aliases% CALL %work_aliases%
