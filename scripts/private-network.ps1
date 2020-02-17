# Supress network location Prompt
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

# The above suppresses the prompt but defaults to "Public" which prevents WinRM from being enabled even with the SkipNetworkProfileCheck arg
# This command sets any network connections detected to Private to allow WinRM to be configured and started
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory "Private"
