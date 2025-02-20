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
  ssh_keys    = ["lb"]
  user_data = file("cloud-init.yaml") # Use an external file
}
