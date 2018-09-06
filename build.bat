@ECHO OFF

REM The location of the source code
SET "SRC=src"

REM The location of the output directory
SET "OUT=bin"

REM The name of the binary
SET "BIN=pony-gui"

REM The name of the application to compile
SET "APP=demo"

REM The command line parameters to use
REM --live <filename> = The application will reload GUI changes as it runs
SET "CMD=" REM --live ../src/gui/demo/layout.gui

REM Clean up the output directory
FOR %%i IN (%OUT%\*) DO IF NOT %%i == %OUT%\.gitignore DEL /Q %%i

ECHO.
ECHO Building Pony-GUI ...
ECHO.

REM Copy the application API to the source directory
XCOPY /Y %SRC%\gui\%APP%\Api.pony %SRC% 1>NUL

CD %SRC%

ponyc -d -p %SRC% -o ..\%OUT% -b %BIN%

CD ..\

REM The API is no longer needed
DEL %SRC%\Api.pony

REM Get the last exit code and stop the batch script when there's an error
IF %ERRORLEVEL% NEQ 0 (
    GOTO :EOF
)

REM Copy the DLLs to the output directory
XCOPY /Y %SRC%\sdl\*.dll %OUT% 1>NUL
XCOPY /Y %SRC%\sdl-gfx\*.dll %OUT% 1>NUL
XCOPY /Y %SRC%\sdl-ttf\*.dll %OUT% 1>NUL

REM This must be copied after TTF so that we get the newer zlib1.dll
XCOPY /Y %SRC%\sdl-image\*.dll %OUT% 1>NUL

REM Copy the application dependencies to the output directory
XCOPY /Y %SRC%\gui\%APP%\*.gui %OUT% 1>NUL
XCOPY /Y /exclude:%SRC%\gui\%APP%\images\exclude.txt %SRC%\gui\%APP%\images\*.* %OUT% 1>NUL
XCOPY /Y %SRC%\gui\%APP%\fonts\OpenSans\*.ttf %OUT% 1>NUL

ECHO.

cd %OUT%

%BIN% %CMD%

cd ..\

EXIT /B %ERRORLEVEL%