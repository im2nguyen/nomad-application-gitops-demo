# Terramino workflow related files

This directory contains files used in the build and deployment workflows for Terramino.

## Nomad workflow

`terramino.nomad.hcl` runs Redis, the Terramino backend, and the Terramino frontend Docker images. It uses Consul for service networking specifically for routing to Redis and the backend.

Dockerfiles for the frontend and backend are in the `/app` directory with the application source code.

## EC2 workflow

`image.pkr.hcl` builds the AMI for the EC2 deployment with Packer. It adds the application code from `/app`, builds the go code, and pushes the AMI to AWS.

`terramino-ec2.tf` deploys an EC2 instance using the AMI from Packer and creates security groups for ingress to the frontend on port `8080` and backend on port `8081`.