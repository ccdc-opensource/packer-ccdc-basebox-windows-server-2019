if "%PACKER_BUILDER_TYPE%" equ "vmware-iso" goto :vmware
if "%PACKER_BUILDER_TYPE%" equ "virtualbox-iso" goto :virtualbox
if "%PACKER_BUILDER_TYPE%" equ "parallels-iso" goto :parallels
goto :done

:vmware

if exist "C:\Users\vagrant\windows.iso" (
    move /Y C:\Users\vagrant\windows.iso C:\Windows\Temp
)

if not exist "C:\Windows\Temp\windows.iso" (
    echo "Downloading and extracting VMWare Tools..."
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://softwareupdate.vmware.com/cds/vmw-desktop/ws/15.0.2/10952284/windows/packages/tools-windows.tar', 'C:\Windows\Temp\vmware-tools.tar')" <NUL
    cmd /c ""C:\Program Files\7-Zip\7z.exe" x C:\Windows\Temp\vmware-tools.tar -oC:\Windows\Temp"
    FOR /r "C:\Windows\Temp" %%a in (VMware-tools-windows-*.iso) DO REN "%%~a" "windows.iso"
    rd /S /Q "C:\Program Files (x86)\VMWare"
)

echo "Installing VMWare Tools..."
cmd /c ""C:\Program Files\7-Zip\7z.exe" x "C:\Windows\Temp\windows.iso" -oC:\Windows\Temp\VMWare"
cmd /c C:\Windows\Temp\VMWare\setup.exe /S /v"/qn REBOOT=R\"

echo "Removing VMWare Tools downloads..."
del /Q "C:\Windows\Temp\vmware-tools.tar"
del /Q "C:\Windows\Temp\windows.iso"
rd /S /Q "C:\Windows\Temp\VMware"
goto :done

:virtualbox

if exist "C:\Users\vagrant\VBoxGuestAdditions.iso" (
    move /Y C:\Users\vagrant\VBoxGuestAdditions.iso C:\Windows\Temp
)

if not exist "C:\Windows\Temp\VBoxGuestAdditions.iso" (
    echo "Downloading and extracting VirtualBox Guest Additions..."
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://download.virtualbox.org/virtualbox/6.0.2/VBoxGuestAdditions_6.0.2.iso', 'C:\Windows\Temp\VBoxGuestAdditions.iso')" <NUL
)

echo "Installing VirtualBox Guest Additions..."
cmd /c ""C:\Program Files\7-Zip\7z.exe" x C:\Windows\Temp\VBoxGuestAdditions.iso -oC:\Windows\Temp\virtualbox"
echo "Setting up certificates for VirtualBox Guest Additions..."
certutil -addstore -f "TrustedPublisher" C:\Windows\Temp\virtualbox\cert\vbox-sha256.cer
certutil -addstore -f "TrustedPublisher" C:\Windows\Temp\virtualbox\cert\vbox-sha1.cer
echo "Installing VirtualBox Guest Additions..."
cmd /c C:\Windows\Temp\virtualbox\VBoxWindowsAdditions.exe /S
echo "Removing VirtualBox Guest Extensions downloads..."
rd /S /Q "C:\Windows\Temp\virtualbox"
goto :done

:parallels
if exist "C:\Users\vagrant\prl-tools-win.iso" (
    echo "Extracting Parallels Tools..."
    move /Y C:\Users\vagrant\prl-tools-win.iso C:\Windows\Temp
    cmd /C "C:\Program Files\7-Zip\7z.exe" x C:\Windows\Temp\prl-tools-win.iso -oC:\Windows\Temp\parallels
    echo "Installing Parallels Tools..."
    cmd /C C:\Windows\Temp\parallels\PTAgent.exe /install_silent
    echo "Removing Parallels Tools downloads..."
    rd /S /Q "C:\Windows\Temp\parallels"
)

:done
