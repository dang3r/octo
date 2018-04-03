provider "google" {
  project = "octo-200003"
  region  = "us-east-1"
}

resource "google_compute_firewall" "https" {
  name          = "octo-https-firewall"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["octo"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_instance" "octo" {
  count        = "${var.size}"
  name         = "${format("octo-%04d", count.index)}"
  machine_type = "f1-micro"
  zone         = "us-east1-b"
  tags         = ["octo"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    sshKeys = "octo:${file("${var.ssh_key_path}")}"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "octo"
    }

    inline = [<<EOF
# Packages
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install \
  apt-transport-https \
  ca-certificates \
  curl \
  git \
  gnupg2 \
  make \
  software-properties-common

# Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) \
  stable"
sudo apt-get update
sudo apt-get -y install docker-ce

# Docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.20.1/docker-compose-`uname -s`-`uname -m`" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Octo
cd ~/
git clone https://github.com/dang3r/octo
cd octo/docker
sudo make
sudo OCTO_SECRET=${var.octo_secret} TARGET_URL=${var.target_url} docker-compose up -d
EOF
    ]
  }

  provisioner "local-exec" {
    command = "echo ${self.network_interface.0.access_config.0.assigned_nat_ip} >> private_ips.txt"
  }
}
