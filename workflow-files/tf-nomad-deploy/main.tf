data "hcp_vault_secrets_secret" "nomad_ip" {
  app_name    = "nomad-stack"
  secret_name = "nomad_ip"
}

data "hcp_vault_secrets_secret" "nomad_token" {
  app_name    = "nomad-stack"
  secret_name = "nomad_token"
}

locals {
  terramino_jobspec    = file("../terramino.nomad.hcl")
  latest_frontend_file = trimspace(file("../../latest-frontend.version"))
  latest_backend_file  = trimspace(file("../../latest-backend.version"))
  rendered_jobspec     = replace(replace(local.terramino_jobspec, "_TERRAMINO_FRONTEND_IMAGE", local.latest_frontend_file), "_TERRAMINO_BACKEND_IMAGE", local.latest_backend_file)
}

# Register a job
resource "nomad_job" "monitoring" {
  jobspec = local.rendered_jobspec
}

resource "nomad_job" "loadbalancer" {
  jobspec = file("lb.nomad.hcl")
}