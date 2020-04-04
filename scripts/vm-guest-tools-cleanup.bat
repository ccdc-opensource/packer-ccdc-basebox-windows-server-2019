echo "Removing VMWare Tools downloads..."
del /Q "C:\Windows\Temp\vmware-tools.tar" || Echo all good
del /Q "C:\Windows\Temp\windows.iso" || Echo all good
rd /S /Q "C:\Windows\Temp\VMware" || Echo all good
echo "Removing VirtualBox Guest Extensions downloads..."
rd /S /Q "C:\Windows\Temp\virtualbox"|| Echo all good
rd /S /Q "C:\Windows\Temp\parallels"|| Echo all good
