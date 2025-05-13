packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.3.1"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "region" {
  type = string
}

data "amazon-ami" "terramino" {
  filters = {
    architecture                       = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name                               = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    root-device-type                   = "ebs"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = var.region
}


source "amazon-ebs" "terramino" {
  ami_name              = "terramino-${local.timestamp}"
  instance_type         = "t2.medium"
  region                = var.region
  source_ami            = "${data.amazon-ami.terramino.id}"
  ssh_username          = "ubuntu"
  force_deregister      = true
  force_delete_snapshot = true

  tags = {
    Name          = "terramino"
    source        = "hashicorp-education/terramino-go"
    purpose       = "demo"
    OS_Version    = "Ubuntu"
    Release       = "Latest"
    Base_AMI_ID   = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }

  snapshot_tags = {
    Name    = "terramino"
    source  = "hashicorp-education/terramino-go"
    purpose = "demo"
  }
}

build {

  sources = ["source.amazon-ebs.terramino"]
  
  provisioner "shell" {
    inline = [
        "sudo mkdir -p /app",
        "sudo chmod 777 -R /app"
    ]
  }

  provisioner "file" {
    source      = "../app/go.mod"
    destination = "/app/go.mod"
  }

  provisioner "file" {
    source      = "../app/go.sum"
    destination = "/app/go.sum"
  }
  
  provisioner "file" {
    source      = "../app/cmd"
    destination = "/app/"
  }

  provisioner "file" {
    source      = "../app/internal"
    destination = "/app/"
  }

  provisioner "file" {
    source      = "../app/main.go"
    destination = "/app/"
  }

  provisioner "shell" {
    inline = [
        "sudo mkdir -p /usr/share/nginx/html",
        "sudo mkdir -p /etc/nginx/conf.d",
        "sudo chmod 777 -R /usr/share/nginx",
        "sudo chmod 777 -R /etc/nginx/conf.d"
    ]
  }

  provisioner "file" {
    source      = "../app/web/"
    destination = "/usr/share/nginx/html/"
  }

  provisioner "file" {
    source      = "../app/nginx-ec2.conf"
    destination = "/etc/nginx/conf.d/default.conf"
  }

  provisioner "shell" {
    script           = "./setup.sh"
  }

  post-processor "manifest" {
    output     = "packer_manifest.json"
    strip_path = true
    custom_data = {
      version_fingerprint = packer.versionFingerprint
    }
  }
}