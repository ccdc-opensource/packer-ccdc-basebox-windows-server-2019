if ($Env:CUSTOMISE_FOR_BUILDMACHINE -eq "1") {
    Write-Output "Setting final password for vagrant user..."
    # Get the password passed in from the Packer provisioner and convert it to a SecureString
    # This needs the -Force parameter to work with the -AsPlainText parameter because the password
    # is not an encrypted string.
    $SecurePassword = ($Env:VAGRANT_USER_FINAL_PASSWORD | ConvertTo-SecureString -AsPlainText -Force)
    # Set the password for vagrant to the final password
    Set-LocalUser -Name vagrant -Password $SecurePassword

    Write-Output "Setting autologon for vagrant user..."
    # Set autologon to the new password
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty $RegPath "DefaultPassword" -Value $Env:VAGRANT_USER_FINAL_PASSWORD -type String
}
else {
    Write-Output("CUSTOMISE_FOR_BUILDMACHINE not set; skipping customisations.")
}
