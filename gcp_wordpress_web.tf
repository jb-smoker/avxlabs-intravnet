data "cloudinit_config" "conf" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/gcp_web.tftpl")
    filename     = "gcp_web.tftpl"
  }
}

resource "google_compute_instance" "wp_web" {
  name         = "gcp-wp-be-1"
  machine_type = "g1-small"
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network    = module.spoke_gcp_web.vpc.name
    subnetwork = module.spoke_gcp_web.vpc.subnets[0].name

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  #   metadata_startup_script = templatefile("${path.module}/gcp_web_tftpl", { db_fqdn = "${azurerm_mysql_flexible_server.default.fqdn}", db_user = "${var.database_admin_login}", db_password = "${var.database_admin_password}" })

  tags = ["wp-web"]
  metadata = {
    user-data = templatefile("${path.module}/gcp_web.tftpl", { db_fqdn = "${azurerm_mysql_flexible_server.default.fqdn}", db_user = "${var.database_admin_login}", db_password = "${var.database_admin_password}" })
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "google_compute_firewall" "wp_external" {
  name    = "wp-web-internet"
  network = module.spoke_gcp_web.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["wp-web"]
}

data "http" "myip" {
  url = "http://ifconfig.me"
}

resource "google_compute_firewall" "wp_internal" {
  name    = "wp-web-internal"
  network = module.spoke_gcp_web.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8", "${chomp(data.http.myip.response_body)}/32"]
  target_tags   = ["wp-web"]
}

