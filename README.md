# Terramino GitOps workflow

This repository contains workflows to deploy the [Terramino](https://github.com/hashicorp-education/terramino-go) application.

## Nomad workflow

The Nomad workflow builds the Terramino Docker images and runs them in Nomad.

### GitHub Actions workflows

[`build_terramino_docker_images.yml`](.github/workflows/build_terramino_docker_images.yml)

- Starts when changes to the [`/app` directory](/app) are detected.
- Builds the Terramino [frontend](app/Dockerfile.frontend) and [backend](app/Dockerfile.backend) Docker images.
- Pushes the images to GitHub Container Registry (GHCR).
- Writes the full image paths to files at the root of the directory - `latest-frontend.version` and `latest-backend.version`. These are used by the deployment workflow.

[`deploy_terrramino_nomad.yml`](.github/workflows/deploy_terramino_nomad.yml)

- Starts when the build workflow completes and can be triggered manually.
- Reads the full image paths for the frontend and backend images and substitutes the values in the [`terramino.nomad.hcl`](/workflow-files/terramino.nomad.hcl) jobspec file.
- Sets up the Nomad CLI.
- Reads Nomad cluster information from GitHub secrets.
- Submits Terramino jobspec to the Nomad cluster.

## EC2 workflow

The EC2 workflow builds the Amazon Machine Image (AMI) with Packer and uses Terraform to create an EC2 instance from the AMI.

### GitHub Actions workflows

[`build_terramino_ami.yml`](.github/workflows/build_terramino_ami.yml)

- Starts when changes to the [`/app` directory](/app) are detected.
- Builds the AMI with Packer using the [`image.pkr.hcl`](workflow-files/image.pkr.hcl) file.
- Pushes the AMI to AWS.
- Parses and retrieves the AMI name and AWS region from the output of the Packer build and writes it to `latest-ami.version` in the root of the repository.

[`deploy_terrramino_ec2.yml`](.github/workflows/deploy_terramino_ec2.yml)

- Starts when the build workflow completes and can be triggered manually.
- Reads the AMI name and AWS region from `latest-ami.version` and saves them to GitHub environment variables.
- Runs `terraform apply` in the `workflow-files` directory, passing in the AMI name and AWS region environment variables.
- Sleeps for 30 seconds to allow deployment verification.
- Runs `terraform destroy` in the `workflow-files` directory to clean up resources.