if ($Env:CUSTOMISE_FOR_BUILDMACHINE -eq "1") {
    if (-Not (Test-Path Env:VAGRANT_USER_FINAL_PASSWORD)) {
        Write-Output "VAGRANT_USER_FINAL_PASSWORD is not set!"
        exit
    }
    Write-Output "Setting final password for vagrant user..."
    # Get the password passed in from the Packer provisioner and convert it to a SecureString,
    # then set it as the new password for the vagrant user.
    # ConvertTo-SecureString needs the -Force parameter to work with the -AsPlainText
    # parameter because the password is not an encrypted string.
    $SecurePassword = ConvertTo-SecureString -AsPlainText -Force -String $Env:VAGRANT_USER_FINAL_PASSWORD
    Set-LocalUser -Name vagrant -Password $SecurePassword

    Write-Output "Setting autologon for vagrant user..."
    # Set autologon to the new password
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty $RegPath "DefaultPassword" -Value $Env:VAGRANT_USER_FINAL_PASSWORD -type String
}
else {
    Write-Output("CUSTOMISE_FOR_BUILDMACHINE not set; skipping customisations.")
}
