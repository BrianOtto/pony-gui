@ECHO OFF

REM The location of the source code
SET "SRC=src"

REM The location of the output directory
SET "OUT=bin"

REM The name of the gui application to compile
SET "APP=videoplayer"

REM The name of the binary
REM You must use no spaces or the Pony linker will fail
SET "BIN=%APP%"

REM The compiler options to use
REM -d to view Debug output
SET "OPT=" REM -d

REM The command line parameters to use
REM --live <filename> = The application will reload GUI changes as it runs
SET "CMD=" REM --live ../src/gui/%APP%/layout.gui

REM Clean up the ouput and API directories
FOR %%i IN ("%OUT%\*") DO IF NOT "%%i" == "%OUT%\.gitignore" DEL /Q "%%i"
FOR %%i IN ("%SRC%\api\*") DO IF NOT "%%i" == "%SRC%\api\.gitignore" DEL /Q "%%i"

REM Clean up the VLC plugins
RMDIR /S /Q "%OUT%\plugins"

ECHO.
ECHO Building Pony-GUI ...
ECHO.

REM Copy the default API classes to the API directory
XCOPY /Y "%SRC%\gui\common\Api.pony" "%SRC%\api" 1>NUL

REM Copy the application classes to the API directory
XCOPY /Y "%SRC%\gui\%APP%\*.pony" "%SRC%\api" > NUL 2>&1

CD "%SRC%"

ponyc %OPT% -o "..\%OUT%" -b "%BIN%"

CD ..\

REM Get the last exit code and stop the batch script when there's an error
IF %ERRORLEVEL% NEQ 0 (
    GOTO :EOF
)

REM Set the EXE subsytem to Windows, since Pony defaults to Console
REM Unless we are compiling with the debug option
ECHO %OPT% | findstr /i /c:"-d" >NUL || (
    EDITBIN /SUBSYSTEM:WINDOWS "%OUT%\%BIN%.exe" 1>NUL
)

REM Get the last exit code and stop the batch script when there's an error
IF %ERRORLEVEL% NEQ 0 (
    GOTO :EOF
)

REM Copy the DLLs to the output directory
XCOPY /Y "%SRC%\sdl\*.dll" "%OUT%" 1>NUL
XCOPY /Y "%SRC%\sdl-gfx\*.dll" "%OUT%" 1>NUL
XCOPY /Y "%SRC%\sdl-ttf\*.dll" "%OUT%" 1>NUL
XCOPY /Y "%SRC%\vlc\*.dll" "%OUT%" 1>NUL

REM Copy the VLC plugins to the output directory
REM TODO: This should be optional / configurable
XCOPY /Y /I /E "%SRC%\vlc\plugins" "%OUT%\plugins" 1>NUL

REM This must be copied after TTF so that we get the newer zlib1.dll
XCOPY /Y "%SRC%\sdl-image\*.dll" "%OUT%" 1>NUL

REM Copy the default dependencies to the output directory
XCOPY /Y "%SRC%\gui\common\fonts\OpenSans\*.ttf" "%OUT%" 1>NUL

REM Copy the application dependencies to the output directory
XCOPY /Y "%SRC%\gui\%APP%\*.gui" "%OUT%" 1>NUL
XCOPY /Y "%SRC%\gui\%APP%\fonts\*.ttf" "%OUT%" > NUL 2>&1

IF EXIST "%SRC%\gui\%APP%\media\NUL" AND EXIST "%SRC%\gui\%APP%\media\exclude.txt" (
    XCOPY /Y /exclude:"%SRC%\gui\%APP%\media\exclude.txt" "%SRC%\gui\%APP%\media\*" "%OUT%" > NUL 2>&1
) ELSE (
    XCOPY /Y "%SRC%\gui\%APP%\media\*" "%OUT%" > NUL 2>&1
)

ECHO.

CD "%OUT%"

REM Run the application
"%BIN%" %CMD%

CD ..\

EXIT /B %ERRORLEVEL%