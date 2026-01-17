# Hiive — Terraform Module (EKS + Containerized Service)

This repository contains a Terraform module that provisions an AWS EKS Kubernetes cluster and deploys a simple containerized service onto it.

### What it creates end-to-end:
- VPC (public/private subnets, routing, NAT) — networking/ancillary infrastructure
- EKS cluster + managed node group
- Kubernetes namespace + Deployment + Service (LoadBalancer) running a public container image (default: `nginx:alpine`)

### Repo layout:
- `modules/eks_cluster/` — reusable Terraform module (VPC + EKS + optional app deployment)
- `modules/eks_cluster/k8s_app/` — Kubernetes resources (namespace, deployment, service)
- `dev` — root Terraform configuration that calls the module and wires providers

---

## Prerequisites

- Terraform >= 1.6
- AWS CLI v2 configured with credentials
- kubectl
- An AWS account where we can create VPC, EKS, IAM, EC2, and Load Balancers

> Note: EKS provisioning can take several minutes and incurs AWS costs (EKS control plane, NAT gateway, worker nodes, and LoadBalancer).

## Configure AWS Credentials

Ensure the AWS identity is configured and working:

```bash
aws sts get-caller-identity
```

## Deploy (End-to-End)

All commands below are run from dev. 

## 1) Initialize

```bash
cd dev
terraform init
```

## 2) Phase 1 — Create VPC + EKS only

This phase creates the network + EKS cluster and node group. It does NOT deploy Kubernetes resources.

```bash
terraform apply -var="deploy_app=false"
```

## 3) Configure kubectl

```bash
REGION="$(terraform output -raw region)"
CLUSTER="$(terraform output -raw cluster_name)"
```
```bash
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER"
kubectl get ns
```

If kubectl get ns does not work, confirm:

The same AWS credentials/profile as Terraform
The cluster exists in the region

## The IAM principal has EKS cluster access (this repo configures EKS access for the Terraform identity)

## 4) Phase 2 — Deploy the containerized service to EKS

```bash
terraform apply -var="deploy_app=true"
```

## 5) Get the service URL

The Kubernetes Service is of type LoadBalancer, so AWS will provision a public endpoint. It may take a few minutes.

```bash
terraform output -raw service_url
```

We can also check directly:

```bash
kubectl -n app get svc
kubectl -n app get deploy
```

## Destroy

To tear everything down:

```bash
terraform destroy
```

## Inputs

The module supports basic inputs such as:

- name, region
- cluster_version
- node group sizing (node_desired_size, node_min_size, node_max_size)
- app settings (app_image, replicas, ports, namespace)

## deploy_app (controls the two-phase apply)

## Notes / Design Decisions (Brief)

Two-phase apply (deploy_app): Avoids cluster-read and Kubernetes API auth issues during initial provisioning. Phase 1 creates EKS; Phase 2 deploys Kubernetes objects after the cluster exists.

Private worker nodes + NAT: Nodes run in private subnets and use NAT for outbound access (e.g., pulling public container images).

> Simple public image: The workload uses a public image by default (nginx-alpine).