if not exist "C:\Windows\Temp\7z1806-x64.msi" (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://www.7-zip.org/a/7z1806-x64.msi', 'C:\Windows\Temp\7z1806-x64.msi')" <NUL
)
msiexec /qb /i C:\Windows\Temp\7z1806-x64.msi
