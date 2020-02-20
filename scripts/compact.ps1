if ($Env:PACKER_BUILDER_TYPE -like "*hyperv*") {
  Write-Output "Skip compact steps in Hyper-V build."
  exit
}

if (-Not (Test-Path "C:\Windows\Temp\7z1900-x64.msi")) {
  Write-Output  "Downloading 7zip..."
  (New-Object System.Net.WebClient).DownloadFile('https://www.7-zip.org/a/7z1900-x64.msi', 'C:\Windows\Temp\7z1900-x64.msi')
}
& msiexec /qb /i C:\Windows\Temp\7z1900-x64.msi

if (-Not (Test-Path "C:\Windows\Temp\ultradefrag.zip")) {
  Write-Output  "Downloading UltraDefrag..."
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://downloads.sourceforge.net/project/ultradefrag/stable-release/6.1.0/ultradefrag-portable-6.1.0.bin.amd64.zip', 'C:\Windows\Temp\ultradefrag.zip')
}

if (-Not (Test-Path "C:\Windows\Temp\ultradefrag-portable-6.1.0.amd64\udefrag.exe")) {
  Write-Output "Extracting UltraDefrag..."
  & 'C:\Program Files\7-Zip\7z.exe' x C:\Windows\Temp\ultradefrag.zip -oC:\Windows\Temp
}

if (-Not (Test-Path "C:\Windows\Temp\SDelete.zip")) {
  Write-Output  "Downloading SDelete..."
  (New-Object System.Net.WebClient).DownloadFile('https://download.sysinternals.com/files/SDelete.zip', 'C:\Windows\Temp\SDelete.zip')
  (New-Object System.Net.WebClient).DownloadFile('https://vagrantboxes.blob.core.windows.net/box/sdelete/v1.6.1/sdelete.exe', 'C:\Windows\Temp\sdelete.exe')
}

if (-Not (Test-Path "C:\Windows\Temp\sdelete.exe")) {
  Write-Output "Extracting SDelete..."
  & 'C:\Program Files\7-Zip\7z.exe' x C:\Windows\Temp\SDelete.zip -oC:\Windows\Temp
}

Write-Output "Creating SDelete registry path"
New-Item -Path "HKCU:\SOFTWARE\Sysinternals\SDelete" -Value "" -Force
Write-Output "Accepting SDelete EULA"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Sysinternals\SDelete" -Name "EulaAccepted" -Value 1

Write-Output "Purging Windows Update downloads..."
Stop-Service -Name wuauserv
Remove-Item -Recurse -Force C:\Windows\SoftwareDistribution\Download
New-Item -ItemType directory -Path C:\Windows\SoftwareDistribution\Download
Start-Service -Name wuauserv

Write-Output "Running UltraDefrag on C:..."
& C:\Windows\Temp\ultradefrag-portable-6.1.0.amd64\udefrag.exe --optimize --repeat C:
Write-Output "Running UltraDefrag on D:..."
& C:\Windows\Temp\ultradefrag-portable-6.1.0.amd64\udefrag.exe --optimize --repeat D:
Write-Output "Running UltraDefrag on E:..."
& C:\Windows\Temp\ultradefrag-portable-6.1.0.amd64\udefrag.exe --optimize --repeat E:

Write-Output "Running SDelete on C:..."
& C:\Windows\Temp\sdelete.exe -q -z C:
Write-Output "Running SDelete on D:..."
& C:\Windows\Temp\sdelete.exe -q -z D:
Write-Output "Running SDelete on E:..."
& C:\Windows\Temp\sdelete.exe -q -z E:
