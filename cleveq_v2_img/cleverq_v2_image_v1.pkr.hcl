# custom-img-v1.pkr.hcl
source "hcloud" "base-amd64" {
  image         = "ubuntu-24.04"
  location      = "nbg1"
  server_type   = "cx22"
  ssh_keys      = ["lb"]
  user_data     = ""
  ssh_username  = "root"
  snapshot_name = "cleverq-image-1.0"
  snapshot_labels = {
    base    = "ubuntu-24.04",
    version = "v1.0.0",
    name    = "cleverq-image-1.0"
  }
}

build {
  sources = ["source.hcloud.base-amd64"]
  provisioner "shell" {
    inline = [
      # Install Docker
      "apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "apt-get update",
      "apt-get install -y docker-ce docker-ce-cli containerd.io",
      
      # Enable Docker to start on boot
      "systemctl enable docker",
      "systemctl start docker",

      # Verify installation
      "docker --version"
    ]
    env = {
      BUILDER = "packer"
    }
  }
}