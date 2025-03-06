# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token}"
}

resource "hcloud_server" "cis_hardened_server" {
  name        = "ubuntu24-cis-hardened"
  server_type = "cax11"
  image       = "ubuntu-24.04"
  location    = "nbg1"
  ssh_keys    = ["hetzner.pem"]

  # Enable Rescue Mode First
  rescue = "linux64"

  # user_data = file("cloud-init.yaml") # Use an external file

  provisioner "remote-exec" {
    inline = [
      "wget https://raw.githubusercontent.com/vultros/hcloud_terraform/refs/heads/main/terraform_1/install_config.txt -O /root/install_config.txt",
      "installimage -a -c /root/install_config.txt",
      "reboot"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("~/.ssh/hetzner.pem")  # Hier deine `.pem`-Datei angeben
      host        = self.ipv4_address
    }
  }

}
