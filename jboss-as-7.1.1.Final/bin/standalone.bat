@echo off

@if not "%ECHO%" == ""  echo %ECHO%
@if "%OS%" == "Windows_NT" setlocal

if "%OS%" == "Windows_NT" (
  set "DIRECTORYNAME=%~dp0%"
) else (
  set DIRECTORYNAME=.\
)

rem Read an optional configuration file.
if "x%STANDALONE_CONF%" == "x" (
   set "STANDALONE_CONF=%DIRECTORYNAME%standalone.conf.bat"
)
if exist "%STANDALONE_CONF%" (
   echo Calling Program "%STANDALONE_CONF%"
   call "%STANDALONE_CONF%" %*
) else (
   echo Server Config file not found "%STANDALONE_CONF%"
)

pushd %DIRECTORYNAME%..
set "RESOLVED_JBOSS7_HOME=%CD%"
popd

if "x%JBOSS_HOME%" == "x" (
  set "JBOSS_HOME=%RESOLVED_JBOSS7_HOME%"
)

pushd "%JBOSS_HOME%"
set "SANITIZED_JBOSS7_HOME=%CD%"
popd

if "%RESOLVED_JBOSS7_HOME%" NEQ "%SANITIZED_JBOSS7_HOME%" (
    echo WARNING JBOSS7_HOME may be pointing to a some other installation, unpredictable results can occur.
)

set DIRECTORYNAME=

if "%OS%" == "Windows_NT" (
  set "PROGRAMNAME=%~nx0%"
) else (
  set "PROGRAMNAME=standalone.bat"
)

set JAVA_OPTS=-Dprogram.name=%PROGRAMNAME% %JAVA_OPTS%

if "x%JAVA_HOME%" == "x" (
  set  JAVA=java
  echo JAVA_HOME is not set. Unexpected results may occur. Please set Java Home Properly.
  echo Set JAVA_HOME to the directory of your local JDK home to avoid this issue.
) else (
  set "JAVA=%JAVA_HOME%\bin\java"
)

if not "%PRESERVE_JAVA_OPTS%" == "true" (
  echo "%JAVA_OPTS%" | findstr /I \-server > nul
  if errorlevel == 1 (
    "%JAVA%" -client -version 2>&1 | findstr /I /C:"Client VM" > nul
    if not errorlevel == 1 (
      set "JAVA_OPTS=-client %JAVA_OPTS%"
    )
  )

  echo "%JAVA_OPTS%" | findstr /I "\-XX:\-UseCompressedOops \-client" > nul
  if errorlevel == 1 (
    "%JAVA%" -XX:+UseCompressedOops -version > nul 2>&1
    if not errorlevel == 1 (
      set "JAVA_OPTS=-XX:+UseCompressedOops %JAVA_OPTS%"
    )
  )

  echo "%JAVA_OPTS%" | findstr /I "\-XX:\-TieredCompilation \-client" > nul
  if errorlevel == 1 (
    "%JAVA%" -XX:+TieredCompilation -version > nul 2>&1
    if not errorlevel == 1 (
      set "JAVA_OPTS=-XX:+TieredCompilation %JAVA_OPTS%"
    )
  )
)

if exist "%JBOSS_HOME%\jboss-modules.jar" (
    set "RUNJAR=%JBOSS_HOME%\jboss-modules.jar"
) else (
  echo Could not locate or find "%JBOSS_HOME%\jboss-modules.jar".
  echo Please check that you are in the bin directory of Jboss 7 Home when running this script.
  goto END
)

set JBOSS_ENDORSED_DIRS=%JBOSS_HOME%\lib\endorsed

if "x%JBOSS_MODULEPATH%" == "x" (
  set  "JBOSS_MODULEPATH=%JBOSS_HOME%\modules"
)

if "x%JBOSS_BASE_DIR%" == "x" (
  set  "JBOSS_BASE_DIR=%JBOSS_HOME%\standalone"
)

if "x%JBOSS_LOG_DIR%" == "x" (
  set  "JBOSS_LOG_DIR=%JBOSS_BASE_DIR%\log"
)

if "x%JBOSS_CONFIG_DIR%" == "x" (
  set  "JBOSS_CONFIG_DIR=%JBOSS_BASE_DIR%/configuration"
)

echo.
echo ===============================================================================
echo.
echo   JBoss Bootstrap Environment.. Starting Jboss
echo.
echo   JBOSS_HOME Installation Path: %JBOSS_HOME%
echo.
echo   JAVA Home: %JAVA%
echo.
echo   JAVA_OPTS Options: %JAVA_OPTS%
echo.
echo ===============================================================================
echo.

:RESTART
"%JAVA%" %JAVA_OPTS% ^
 "-Dorg.jboss.boot.log.file=%JBOSS_LOG_DIR%\boot.log" ^
 "-Dlogging.configuration=file:%JBOSS_CONFIG_DIR%/logging.properties" ^
    -jar "%JBOSS_HOME%\jboss-modules.jar" ^
    -mp "%JBOSS_MODULEPATH%" ^
    -jaxpmodule "javax.xml.jaxp-provider" ^
     org.jboss.as.standalone ^
    -Djboss.home.dir="%JBOSS_HOME%" ^
     %*

if ERRORLEVEL 10 goto RESTART

:END
if "%NOPAUSE%" == "x" pause

 :END_NO_PAUSE
