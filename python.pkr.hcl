# 1. Bloco do Plugin: ensina o Packer a falar com o Docker
packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
  }
}

# 2. Bloco da Fonte: imagem base oficial do Ubuntu e commit do contentor como imagem final
source "docker" "ubuntu" {
  image  = "ubuntu:jammy"
  commit = true

  # Metadados aplicados à imagem final: o diretório de trabalho padrão passa a ser /app
  changes = [
    "WORKDIR /app"
  ]
}

build {
  name    = "ambiente-dev-python"
  sources = ["source.docker.ubuntu"]

  # 3a. Instala o python3 e o gestor de pacotes pip
  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
      "apt-get update",
      "apt-get install -y python3 python3-pip",
      "rm -rf /var/lib/apt/lists/*"
    ]
  }

  # 3b. Cria na raiz do sistema a pasta que vai alojar o código da aplicação
  provisioner "shell" {
    inline = [
      "mkdir -p /app"
    ]
  }

  # 3c. Instala a biblioteca Flask via pip
  provisioner "shell" {
    inline = [
      "python3 -m pip install --no-cache-dir flask"
    ]
  }

  # 4. Bloco de Etiqueta: dá à imagem final o nome ambiente-dev-python:v1
  post-processor "docker-tag" {
    repository = "ambiente-dev-python"
    tags       = ["v1"]
  }
}
