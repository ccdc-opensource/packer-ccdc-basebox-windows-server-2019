if not exist "C:\Windows\Temp\7z1806-x64.msi" (
    echo "Downloading 7Zip..."
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://www.7-zip.org/a/7z1806-x64.msi', 'C:\Windows\Temp\7z1806-x64.msi')" <NUL
)
echo "Installing 7Zip..."
msiexec /qb /i C:\Windows\Temp\7z1806-x64.msi
del C:\Windows\Temp\7z1806-x64.msi