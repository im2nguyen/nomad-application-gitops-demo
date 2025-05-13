terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.105.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.5.0"
    }
  }
}

provider "hcp" {
  # Configuration options
}

provider "nomad" {
  address     = "https://${data.hcp_vault_secrets_secret.nomad_ip.secret_value}:4646"
  secret_id   = data.hcp_vault_secrets_secret.nomad_token.secret_value
  skip_verify = true
}