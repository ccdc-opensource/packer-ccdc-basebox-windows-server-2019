# Packer configuration for Windows base boxes

This repository contains a number of HashiCorp Configuration Language files specifying builds
for Vagrant boxes based on different versions of Windows, to be used as base boxes for e.g.
build machines or other infrastructure VMs.

There is also a Windows unattended installation Answer File for each of these versions with a
minimal setup - most of the provisioning is done via Ansible roles. Generally the only thing
the answer files do is set up WinRM so that Ansible can connect.

## How to build

```
packer build -on-error=abort windows-10-21h2.pkr.hcl
```

## How to build Hyper-V images

Building Hyper-V images is somewhat more complex because it only works on Windows; however Ansible
(which is used to provision the base system) does not work natively on Windows. There are a few
prerequisites for building Hyper-V images:

* Hyper-V enabled (`Enable-WindowsOptionalFeature Microsoft.Hyper-V`)
* WSL installed with an Ubuntu distribution set up
* Your user SSH keys set up in Ubuntu WSL (in order to get the provisioning Ansible roles)
* Ansible installed to Ubuntu system Python (`sudo apt update; sudo apt install python3-pip; sudo pip3 install ansible`)
* mkisofs installed to WSL Ubuntu (`sudo apt update; sudo apt install genisoimage`)

## Detailed build information

The full process, end-to-end, will perform the following steps:

- `[Packer]` Create and boot a VM for the specified Windows version
- `[Packer]` Mount the `autounattend.xml` file for the Windows installer to read
- `[Windows installer]` Set up Windows according to `autounattend.xml`
  - WinRM is configured in the `autounattend.xml` file - if Packer fails to connect after Windows
    has finished installing, then the answer file has not correctly set up WinRM
- `[Packer]` Run Ansible with the playbook in `ansible-provisioning/playbook.yml` against the VM
- `[Ansible]` Set up the VM for use as a Vagrant base box
  - [Provision CCDC-specific Vagrant base box options](https://github.com/ccdc-confidential/ansible-role-vagrant-base-box)
  - [Install VM guest tools as appropriate](https://github.com/ccdc-confidential/ansible-role-vm-tools)
  - [Debloat Windows](https://github.com/ccdc-confidential/ansible-role-debloat-windows)
  - [Compact the VM image for export](https://github.com/ccdc-confidential/ansible-role-compact-vm-image)
- `[Packer]` Export the VM to Vagrant box format
- `[Packer]` Upload the finished Vagrant box to Artifactory
