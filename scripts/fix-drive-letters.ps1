$initial_d_drive = Get-CimInstance Win32_LogicalDisk -Filter 'DeviceID="D:"' | Select-Object -Unique
if ($initial_d_drive.DriveType -eq 5) 
{
    Write-Output 'Drive D is a CD-ROM, moving it to F:'
    $drv = Get-WmiObject win32_volume -filter 'DriveLetter = "D:"'
    $drv.DriveLetter = "F:"
    $drv.Put()

    Write-Output 'Setting Drive 1 Online and read-write'
    Set-Disk -Number 1 -IsOffline $False
    Set-Disk -Number 1 -IsReadonly $False
    
    Write-Output 'Setting Drive 2 Online and read-write'
    Set-Disk -Number 2 -IsOffline $False
    Set-Disk -Number 2 -IsReadonly $False
}

