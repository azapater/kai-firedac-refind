@echo off
setlocal enabledelayedexpansion

rem ============================================================================
rem  Copy a source tree and run reFind over the copy.
rem
rem  The originals are never touched. If the result is wrong, delete OUT, fix
rem  the rule file and run this again.
rem
rem  Edit the four settings below, then run this file.
rem ============================================================================

set "SRC=C:\src\MyApp"
set "OUT=C:\src\MyApp_FireDAC"
set "RULES=C:\src\FireDAC_Migrate_BDE_MyApp.txt"

rem File extensions to process, space separated. Add fmx for FireMonkey, and
rem dpr, inc or dpk if the scout step found legacy types in them.
set "EXTS=pas dfm"

rem ============================================================================
rem  Nothing below here normally needs editing.
rem ============================================================================

rem Locate reFind.exe, newest installed RAD Studio first.
set "REFIND="
for /f "delims=" %%D in ('dir /b /ad /o-n "%ProgramFiles(x86)%\Embarcadero\Studio" 2^>nul') do (
  if not defined REFIND (
    if exist "%ProgramFiles(x86)%\Embarcadero\Studio\%%D\bin\reFind.exe" (
      set "REFIND=%ProgramFiles(x86)%\Embarcadero\Studio\%%D\bin\reFind.exe"
    )
  )
)
if not defined REFIND (
  where reFind.exe >nul 2>&1 && set "REFIND=reFind.exe"
)
if not defined REFIND (
  echo ERROR: reFind.exe not found. It ships in the RAD Studio bin folder.
  echo        Set REFIND at the top of this file by hand.
  exit /b 1
)

if not exist "%SRC%" (
  echo ERROR: source folder not found: %SRC%
  exit /b 1
)
if not exist "%RULES%" (
  echo ERROR: rule file not found: %RULES%
  echo        Copy the official FireDAC_Migrate_*.txt out of the RAD Studio
  echo        Samples tree first, then add your own rules at the end of the copy.
  exit /b 1
)

echo reFind:  %REFIND%
echo Source:  %SRC%
echo Output:  %OUT%
echo Rules:   %RULES%
echo Types:   %EXTS%
echo.

if exist "%OUT%" (
  echo "%OUT%" already exists and will be deleted.
  echo reFind skips files that already have a .bak beside them, so the copy
  echo has to be fresh or the pass will silently do nothing.
  set /p CONFIRM="Delete it and continue? [y/N] "
  if /i not "!CONFIRM!"=="y" (
    echo Cancelled.
    exit /b 1
  )
  rmdir /s /q "%OUT%"
)

echo Copying sources...
xcopy /e /i /y /q "%SRC%\*.*" "%OUT%\" >nul
if errorlevel 1 (
  echo ERROR: copy failed.
  exit /b 1
)

set "ARGS="
for %%E in (%EXTS%) do set "ARGS=!ARGS! "%OUT%\*.%%E""

echo Running reFind...
echo   "%REFIND%"!ARGS! /S /X:"%RULES%"
echo.
"%REFIND%"!ARGS! /S /X:"%RULES%"
if errorlevel 1 (
  echo.
  echo reFind reported an error.
  exit /b 1
)

echo.
echo Done. Open the project in "%OUT%" and continue with the structural wiring:
echo connection definition, driver link and wait cursor. See prompts\04-structural-finish.md.
endlocal
