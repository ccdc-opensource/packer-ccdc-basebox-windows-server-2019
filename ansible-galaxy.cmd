@echo off
REM This is a wrapper script for running WSL-based tools from PowerShell or cmd.exe
set args=%*

REM Replace any backslashes in arguments with forward slashes to fix paths
call set args=%%args:\=/%%

REM Replace drive letters with their WSL-based mount point
call set args=%%args:C:=/mnt/c%%
call set args=%%args:D:=/mnt/d%%
call set args=%%args:E:=/mnt/e%%
call set args=%%args:F:=/mnt/f%%

REM Further replacements for special characters
call set args=%%args:/"=%%
call set args=%%args:"'='%%
call set args=%%args:'"='%%
call set args=%%args:"=^'%%

REM Run the tool matching this .cmd script's file name in WSL with the edited args
C:\Windows\System32\bash.exe -c "%~n0 %args%"
