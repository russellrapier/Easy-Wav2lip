@echo off
title Easy-Wav2Lip
setlocal enabledelayedexpansion
cd /d "%~dp0"
echo Welcome to Easy-Wav2Lip^^!


:check_GPU
::check if Nvidia GPU is installed
wmic path win32_VideoController get name | findstr /C:"NVIDIA" >nul
if errorlevel 1 (
	echo NVIDIA GPU has not been detected - This requires an Nvidia GPU as it needs CUDA!
	echo If you do have one installed, try updating your drivers.
	pause
	goto :eof
)
::check if driver is new enough to have a new enough cuda
for /f "tokens=*" %%i in ('nvidia-smi --query-gpu=driver_version --format=csv') do set "driver_version=%%i"
set "major_version=%driver_version:~0,3%"
set "major_version=%major_version:.=%"
if not %major_version% gtr 528 (
    echo Your Nvidia drivers aren't up to date - please update them before continuing!
	pause
	goto :eof
)

:: Check if Easy-Wav2Lip folder exists
if not exist "Easy-Wav2Lip" (
	set firstinstall="True"
	echo Create folders "Easy-Wav2Lip" and "Easy-Wav2Lip-venv" here and install Easy-Wav2Lip %latest_version%?
	echo You will need around 7GB of free space and consider the time it will take you to download that on your connection.
	echo There may be freezes in the cmd for several minutes at a time, this is normal.
	pause
	mkdir "Easy-Wav2Lip"
	mkdir "Easy-Wav2Lip\firstinstall"
	echo Proceeding with install
) else (
	set firstinstall="False"
)

:: Check if Python is installed
:check_python
py -3.10 --version >nul 2>&1
if errorlevel 1 (
	echo Python 3.10 not installed. Downloading Python 3.10.11.. 29040640 total bytes to download
	call :install_python
)

:activate_venv
:: Check if the virtual environment exists and activate it
IF NOT defined VIRTUAL_ENV (
	IF EXIST "Easy-Wav2Lip-venv\Scripts\activate.bat" (
		CALL Easy-Wav2Lip-venv\Scripts\activate.bat
	) ELSE (
		echo Creating virtual environment...
		py -3.10 -m venv Easy-Wav2Lip-venv
		CALL Easy-Wav2Lip-venv\Scripts\activate.bat
	)
)

:: Check if the virtual environment is activated
IF defined VIRTUAL_ENV (
	set PATH=%~dp0Easy-Wav2Lip-venv\Scripts;%PATH%
	echo Virtual environment running from %VIRTUAL_ENV%
) ELSE (
	echo Error: Virtual environment is unable to activate.
	pause
	goto :eof
)

:: Update pip and install requests if not already installed
python -m pip install --upgrade pip >nul 2>&1
python -m pip install requests >nul 2>&1

:: Check if Git is installed
:check_git
git --version >nul 2>&1
if errorlevel 1 (
	echo Git is not installed. Downloading Git 2.44.0...
	call :install_git
)

:check_ffmpeg
where /q ffmpeg
if %errorlevel% neq 0 (
	echo ffmpeg is not detected. Downloading ffmpeg...
	echo This process is automatic.
	call :install_ffmpeg
)

:check_ffplay
where /q ffplay
if %errorlevel% neq 0 (
	echo ffplay is not detected. Downloading ffplay...
	echo This process is automatic.
	call :install_ffmpeg
)

:check_ffprobe
where /q ffprobe
if %errorlevel% neq 0 (
	echo ffprobe is not detected. Downloading ffprobe...
	echo This process is automatic.
	call :install_ffmpeg
)


:check_version
:: Find out the latest version of Easy-Wav2Lip
echo Fetching the latest version of Easy-Wav2Lip...
:: Retrieve the default branch name using Python
for /f %%I in ('python -c "import requests; r = requests.get('https://api.github.com/repos/anothermartz/Easy-Wav2Lip', stream=True); print(r.json().get('default_branch', ''))"') do set latest_version=%%I
:: You can install a particular version by removing the comment colons (::) below:
set latest_version=v8.3

if exist "Easy-Wav2Lip\firstinstall" (
		set firstinstall="True"
	)

if %firstinstall%=="True" (
	goto install
)

:check_install
:: Check if installed.txt exists in the Easy-Wav2Lip folder
if not exist "Easy-Wav2Lip\installed.txt" (
	echo Easy-Wav2lip apears to not be installed correctly, reinstall?
	echo You may need up to 7GB of free space.
	pause
	goto install
	)

:: Easy_Wav2Lip installed, get the first line of installed.txt
set /p installed_version=<"Easy-Wav2Lip\installed.txt"
echo Easy-Wav2Lip %installed_version% installed.

:: Compare the versions
if "%installed_version%"=="%latest_version%" (
	cd Easy-Wav2Lip
	call run_loop.bat
	goto finished
) else (
	echo %latest_version% is now available, do you want to download and install it?
	:user_input_loop
	set /p user_input=enter y or n: 
	if /i "!user_input!"=="y" (
	call :install

	) else if /i "!user_input!"=="n" (
		cd Easy-Wav2Lip
		call run_loop.bat
		goto finished
	) else (
		echo Invalid input. Please enter y or n.
		goto user_input_loop
		)
	)
	
:finished
echo Closing Easy-Wav2Lip
timeout /t 1 >nul
goto :eof

:install
::copy checkpoint folder to temp folder
if exist "Easy-Wav2Lip\checkpoints" (
	echo saving the large downloaded files
	xcopy /e /i /y "Easy-Wav2Lip\checkpoints" "temp\checkpoints"
	)

:: Delete the Easy-Wav2Lip directory and clone the repository
if exist "Easy-Wav2Lip" (
	rmdir /s /q "Easy-Wav2Lip"
)

:: Set the default Git path (with quotes)
set "GitPath=%ProgramFiles%\Git\bin\git.exe"

:: Check if Git is installed
where git > nul 2>&1
if %errorlevel% equ 0 (
    :: Git is installed, update the GitPath
    set "GitPath=git"
)

:: Use the GitPath variable when calling git clone
"%GitPath%" clone -b %latest_version% https://github.com/anothermartz/Easy-Wav2Lip.git

::Copy temp checkpoints folder into Easy-Wav2Lip folder
if exist temp\checkpoints (
	xcopy /e /i /y "temp\checkpoints" "Easy-Wav2Lip\checkpoints"
	)
rmdir /s /q temp
cd Easy-Wav2Lip
IF defined VIRTUAL_ENV (
	echo Virtual environment running from %VIRTUAL_ENV%
)
pip install -r requirements.txt
python install.py
cd ..
goto :check_install

:install_python
set url=https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe
set outfile=%~dp0install_python.exe
powershell -Command "Invoke-WebRequest -Uri %url% -OutFile %outfile%"
python --version >nul 2>&1
if errorlevel 1 (
echo Installing python 3.10.11 to PATH...
start /wait install_python.exe /quiet PrependPath=1
) else (
echo Installing python 3.10.11...
start /wait install_python.exe /quiet PrependPath=0
)
del install_python.exe
echo Python installation complete
goto :eof

:install_git
set url=https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe
set outfile=install_git.exe
python -c "import requests; r = requests.get('%url%', stream=True); open('%outfile%', 'wb').write(r.content)"
echo Git downloaded, installing...
start /wait install_git.exe /SILENT /NORESTART /NOCANCEL /SP- /LOG
del install_git.exe
echo Git installation complete
goto :eof

:install_ffmpeg
call :get_python_path
set url=https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip
set outfile=ffmpeg.zip
python -c "import requests; r = requests.get('%url%', stream=True); open('%outfile%', 'wb').write(r.content)"
echo ffmpeg downloaded - installing...
powershell -Command "Expand-Archive -Path .\\ffmpeg.zip -DestinationPath .\\"
del %outfile%
xcopy /e /i /y "ffmpeg-master-latest-win64-gpl\bin\*" %python_path%
rmdir /s /q ffmpeg-master-latest-win64-gpl
echo ffmpeg installed
goto :eof

:get_python_path
set "python_path=%VIRTUAL_ENV%\Scripts"
	goto :eof

:end
pause
endlocal