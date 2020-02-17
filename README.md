# Packer template for creating a windows server 2019 image for running builds

This packer template creates a basic windows 2019 server box with a predefined administrator user called vagrant, removes unnecessary packages from windows and packages up the result as a VMWare or Virtualbox image.

## What happens here specifically?

The following list is just a reference that may become out of date if people update the scripts and not the list. It's here to give a high level overview of what is going on and is not a substitute for reading the scripts, starting with the ccdc-windows-cpp-builder.json file!

- It downloads an ISO file from Microsoft's servers.
- It starts up VMWare and/or Virtualbox based on the parameters passed to the packer command and on each of those does the following steps:
- It creates a Virtual Machine with three virtual disks (one for the system, one for the x_mirror contents and one for the builds)
- It runs the windows server installation based on the autounattend.xml file in answer_files\2019_core
- This installs a windows server operating system based on the downloaded ISO.
- It adds a build user that logs in automatically on machine startup
- It reboots the machine and on the first start up runs a series of commands that can be edited by changing the FirstLogonCommands section in Autounattend.xml:
  - Sets the execution policy to RemoteSigned for both 32 and 64 bit windows commands (See https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-6)
  - Disables winrm for a moment
  - Shows file extensions in explorer
  - Enables QuickEdit mode in CMD
  - enables the Run command in the start menu
  - enables the Administrative Tools in the start menu
  - disables hibernation
  - disables password expiration for the build user
  - installs the ssh server and enables it on startup
  - Uninstalls XPS-Viewer, Internet Explorer, and Windows Media Player (no browser is available)
  - Uninstalls windows defender (no antivirus required if you can't download anything)
  - Uninstalls Handwriting, OCR, Speech, Math recognition
  - enables wirm so that the machine can be configured by ansible
- After that, the scripts under the provisioners section in the json file are run doing the following:
  - VMWare or virtualbox guest tools are installed
  - RDP login is enabled
  - Windows update is reset
  - UAC is explicitly enabled (https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-lua-settings-enablelua)
  - dotnet assemblies are precompiled
  - the D drive containing the virtual DVD is moved to an upper drive letter to make space for D:\x_mirror
  - defragmentation and compaction of free disk space is performed


## How do I use this?

You need the following prerequisites:

- Packer: install it via choco install packer on windows or via brew on MacOS
- Virtualbox: required for creating an image that runs on virtualbox
- VMWare Workstation: required for running an image that runs on VMWare

Once these are installed, open a command line window, cd in this directory and run 

packer build ccdc-windows-cpp-builder.json

This will create 
To create the base box, you need a host capable of running ansible, so either a MacOS or Ubuntu machine, or by using ansible inside Linux Subsystem for Linux:
- install ansible (on windows do that under the WSL Ubuntu distribution)
- run the ansible-ccdc-windows-cpp-builder/playbook.yml playbook. on the target machine to install required packages and data
- run the ansible-ccdc-windows-cpp-builder/enslave_to_teamcity.yml playbook. on the target machine to install a teamcity agent on it

## Where do I begin stydying this?

This stuff was shamelessly pilfered from https://github.com/StefanScherer/packer-windows in late January 2020 and extended for the purpose of building an "almost headless" build machine. That repository contains files for most windows versions and the community might be able to help with questions.

The microsoft docs for unattended desktop installation and customisation are the reference for the autounattend.xml file

https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/

Why Packer? https://www.packer.io/intro/why.html

Packer documentation: https://www.packer.io/docs/index.html

Useful blog posts:
- Best practices: https://hodgkins.io/best-practices-with-packer-and-windows
- WinRM troubleshooting: http://www.hurryupandwait.io/blog/understanding-and-troubleshooting-winrm-connection-and-authentication-a-thrill-seekers-guide-to-adventure

## Now what?

Now you have a basic windows image, it's time to add software to it. So open the README.md file in the ansible-ccdc-windows-cpp-builder directory!

## Troubleshooting

If virtualbox is complaining that a disk already exists, run the virtualbox management application and remove the two disks (x_mirror.vmdk and builds.vmdk)

## Wishes

I wish it were possible to just add this command to the json. Then we would have a one click VM generation process. Unfortunately this can't work on the remaining 260Gb on my laptop...

{
    "type": "ansible",
    "playbook_file": "../ansible-ccdc-windows-cpp-builder/playbook.yml",
    "extra_arguments": [
    "--connection", "packer",
    "--extra-vars", "ansible_shell_type=powershell ansible_shell_executable=None"
    ]
},
