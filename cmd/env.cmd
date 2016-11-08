@echo off

:: Python2
DOSKEY python2="C:\Python27\python.exe" $*
DOSKEY pythonw2="C:\Python27\pythonw.exe" $*

:: Python3
DOSKEY python3="C:\Python35\python.exe" $*
DOSKEY pythonw3="C:\Python35\pythonw.exe" $*

:: ls
DOSKEY ls=ls --color
DOSKEY la=ls -a --color
DOSKEY ll=ls -l --color

:: grep
DOSKEY grep=grep --color=auto $*

:: cd
DOSKEY cdu=cd %USERPROFILE%

:: .NET stuff
DOSKEY nunit-console="%USERPROFILE%\NUnit.3.4.1\NUnit.ConsoleRunner.3.4.1\tools\nunit3-console.exe" $*
DOSKEY msbuild="C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" $*

:: pandoc
DOSKEY pandoc="%USERPROFILE%\AppData\Local\Pandoc\pandoc.exe" $*

:: Work-Specific Aliases
SET work_aliases="%USERPROFILE%\work\aliases.cmd"
IF EXIST %work_aliases% CALL %work_aliases%
