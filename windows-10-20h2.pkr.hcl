packer {
  required_plugins {
  }
}

variable "iso_url" {
  type    = string
  default = "https://software-download.microsoft.com/download/pr/19042.508.200927-1902.20h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-gb.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:574f00380ead9e4b53921c33bf348b5a2fa976ffad1d5fa20466ddf7f0258964"
}

variable "vagrant_box" {
  type    = string
  default = "ccdc-basebox/windows-10"
}

variable "system_disk_size" {
  type    = string
  default = "80000"
  description = "System disk size in megabytes."
}

variable "x_mirror_disk_size" {
  type    = string
  default = "200000"
  description = "Size in megabytes for x_mirror disk."
}

variable "builds_disk_size" {
  type    = string
  default = "300000"
  description = "Size in megabytes for builds disk."
}

variable "hyperv_switch_name" {
  type    = string
  default = env("HYPERV_SWITCH_NAME")
}

variable "hyperv_vlan_id" {
  type    = string
  default = env("HYPERV_VLAN_ID")
}

variable "output_directory" {
  type    = string
  default = "${env("PWD")}/output/"
}

variable "artifactory_api_key" {
  type    = string
  default = env("ARTIFACTORY_API_KEY")
}

source "virtualbox-iso" "windows-10-20h2" {
  guest_additions_interface = "sata"
  guest_additions_mode      = "attach"
  guest_os_type             = "Windows10_64"
  hard_drive_interface      = "sata"
  iso_interface             = "sata"
  vboxmanage = [
    ["storagectl", "{{ .Name }}", "--name", "IDE Controller", "--remove"],
    ["modifyvm", "{{ .Name }}", "--firmware", "efi"],
    ["modifyvm", "{{ .Name }}", "--vrde", "off"],
    ["modifyvm", "{{ .Name }}", "--graphicscontroller", "vboxsvga"],
    ["modifyvm", "{{ .Name }}", "--vram", "128"],
    ["modifyvm", "{{ .Name }}", "--accelerate3d", "on"],
    ["modifyvm", "{{ .Name }}", "--usb", "on"],
    ["modifyvm", "{{ .Name }}", "--mouse", "usbtablet"],
    ["modifyvm", "{{ .Name }}", "--audio", "none"],
    ["modifyvm", "{{ .Name }}", "--nictype1", "82540EM"],
    ["modifyvm", "{{ .Name }}", "--natpf1", "guestwinrm,tcp,127.0.0.1,5985,,5985"],
    ["createmedium", "disk", "--filename", "${var.output_directory}/-{{ .Name }}/x_mirror-{{ timestamp }}.vdi",
    "--size", "${var.x_mirror_disk_size}"],
    ["createmedium", "disk", "--filename", "${var.output_directory}-{{ .Name }}/builds-{{ timestamp }}.vdi",
    "--size", "${var.builds_disk_size}"],
    ["storageattach", "{{.Name}}", "--storagectl", "SATA Controller", "--port", "2",
    "--type", "hdd", "--mtype", "writethrough",
    "--medium", "${var.output_directory}-{{ .Name }}/x_mirror-{{ timestamp }}.vdi"],
    ["storageattach", "{{.Name}}", "--storagectl", "SATA Controller", "--port", "3",
      "--type", "hdd", "--mtype", "writethrough",
      "--medium", "${var.output_directory}-{{ .Name }}/builds-{{ timestamp }}.vdi"
    ],
  ]
  // Settings shared between all builders
  cpus             = 2
  memory           = 4096
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  disk_size        = var.system_disk_size
  headless         = false
  cd_files         = ["answer_files/windows-10-20h2/autounattend.xml"]
  boot_wait        = "2s"
  boot_command     = ["<enter>"]
  shutdown_command = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""
  communicator     = "winrm"
  winrm_username   = "vagrant"
  winrm_password   = "vagrant"
  winrm_use_ssl    = "false"
  winrm_insecure   = "true"
  winrm_use_ntlm   = "true"
  winrm_timeout    = "10m"
}

source "vmware-iso" "windows-10-20h2" {
  disk_additional_size = [
    "${var.x_mirror_disk_size}",
    "${var.builds_disk_size}"
  ]
  // Settings shared between all builders
  cpus             = 2
  memory           = 4096
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  disk_size        = var.system_disk_size
  headless         = false
  cd_files         = ["answer_files/windows-10-20h2/autounattend.xml"]
  boot_wait        = "2s"
  boot_command     = ["<enter>"]
  shutdown_command = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""
  communicator     = "winrm"
  winrm_username   = "vagrant"
  winrm_password   = "vagrant"
  winrm_use_ssl    = "false"
  winrm_insecure   = "true"
  winrm_use_ntlm   = "true"
  winrm_timeout    = "10m"
}

source "hyperv-iso" "windows-10-20h2" {
  generation   = 2
  boot_order   = ["SCSI:0:0"]
  first_boot_device = "DVD"
  switch_name       = var.hyperv_switch_name
  temp_path         = "tmp"
  vlan_id           = var.hyperv_vlan_id
  // Settings shared between all builders
  cpus             = 2
  memory           = 4096
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  disk_size        = var.system_disk_size
  headless         = false
  cd_files         = ["answer_files/windows-10-20h2/autounattend.xml"]
  boot_wait        = "2s"
  boot_command     = ["<enter>"]
  shutdown_command = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""
  communicator     = "winrm"
  winrm_username   = "vagrant"
  winrm_password   = "vagrant"
  winrm_use_ssl    = "false"
  winrm_insecure   = "true"
  winrm_use_ntlm   = "true"
  winrm_timeout    = "10m"
}

build {

  sources = [
    "source.vmware-iso.windows-10-20h2",
    "source.virtualbox-iso.windows-10-20h2",
    "source.hyperv-iso.windows-10-20h2",
  ]

  provisioner "ansible" {
    playbook_file = "./ansible_provisioning/playbook.yaml"
    galaxy_file = "./ansible_provisioning/requirements.yaml"
    roles_path = "./ansible_provisioning/roles"
    galaxy_force_install = true
    user            = "vagrant"
    use_proxy       = false
    extra_arguments = [
      "-e",
      "ansible_winrm_server_cert_validation=ignore",
      "-e",
      "ansible_winrm_scheme=http",
      "-e",
      "ansible_become_method=runas"
    ]
  }

  post-processors {

    post-processor "vagrant" {
      output               = var.vagrant_box
      vagrantfile_template = "Vagrantfile-uefi.template"
    }

    // Once box has been created, upload it to Artifactory
    post-processor "shell-local" {
      environment_vars = [
        "ARTIFACTORY_API_KEY=${ var.artifactory_api_key }",
        "BOX_NAME=${ var.vagrant_box }",
        "PROVIDER=${ replace(source.type, "-iso", "") }",
        "BOX_VERSION=\"${ formatdate("YYYYMMDD", timestamp()) }.0\""
      ]
      command = join(" ", [
        "jf rt upload",
        "--target-props \"box_name=$BOX_NAME;box_provider=$PROVIDER;box_version=$BOX_VERSION\"",
        "--retries 10",
        "--url \"https://artifactory.ccdc.cam.ac.uk/artifactory\"",
        "${ var.output_directory }/${ var.vagrant_box }/${ var.vagrant_box }.box",
        "ccdc-vagrant-repo/$BOX_NAME.$BOX_VERSION.$PROVIDER.box"
      ])
    }
  }
}
