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

:: cd
DOSKEY cdu=cd %USERPROFILE%
