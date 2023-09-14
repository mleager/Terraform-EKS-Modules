# Terraform EKS with Cluster AutoScaler and AWS Load Balancer Controller using Modules

## Overview

This repository enables you to deploy a webpage hosting four playable HTML games on an AWS EKS Cluster. 
Key features include:

- AWS VPC creation
- AWS EKS Cluster setup
- AWS IRSA (IAM Roles for Service Accounts)
- Automatic horizontal scaling of the cluster
- Automatic HTTPS traffic routing
- Path-based routing for individual games

## Installation

### Basic Steps

1. Create VPC
2. Create EKS Cluster
3. Create IRSA for AutoScaler & AWS LB Controller
4. Define Kubectl Provider
5. Create AutoScaler Objects using Kubectl Provider (YAML)
6. Create ACM Certificate
7. Apply Terraform
8. Update Kubeconfig (`aws eks update-kubeconfig --region <YOUR REGION> --name <CLUSTER NAME>`)
9. Apply Cert-Manager YAML file
10. Apply LB Controller YAML file (may need to run twice)
11. Apply IngressClass YAML file
12. Apply Deployment, Service & Ingress Objects
13. Apply Route53/Records Module with AWS ALB DNS Name to connect to Pods via Path Based Routing


### Initialize and Apply Terraform

1. Run Terraform to create VPC, EKS, IRSA, Kubectl Provider, Cluster Autoscaler, and ACM

    $ terraform init
    $ terraform apply


### Installing AutoScaler (using Kubectl Provider)

In this codebase, Cluster AutoScaler is defined and run using the Kubectl Provider. 
Normally, it is created with a second `terraform apply` statement after creating the VPC and EKS Cluster.
The Kubectl Provider waits for Terraform to create the required resources first.

[AutoScaler Documentation](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md)


### Installing AWS LoadBalancer Controller (using YAML definition files)

1. Install Cert Manager (Choose either v1.12.0 or v1.5.4)
    - [Cert Manager Installation Docs](https://cert-manager.io/v1.12-docs/installation/kubectl/)
    - [Cert Manager GitHub](https://github.com/cert-manager/cert-manager)

    (v1.12.0 - recommened for EKS v1.27)
    $ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml

    -- OR --
    
    (v1.5.4 - specified in AWS LB Controller GitHub)
    $ kubectl apply -f manifests/0-cert-manager.yaml

2. Apply AWS LoadBalancer Controller YAML File
    - [AWS Load Balancer Controller GitHub](https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/deploy/installation.md)

    * Note: Add the AWS LB Controller's IRSA ARN to the ServiceAccount annotation.
    ```yaml
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::<Your Account ID>:role/aws-load-balancer-controller-role

    $ kubectl apply -f manifests/1-lb-controller.yaml

3. Apply IngressClass and IngressClassParams YAML File

    $ kubectl apply -f manifests/2-ingclass.yaml


### Apply Deployments, Services, and Ingress (using YAML definition files)

1. Apply YAML Definition file

    $ kubectl apply -f manifests/3-html-games.yaml

2. Confirm Ingress/ALB was created

    $ kubectl get ing

3. Copy ALB DNS Address

    NAME ... ... ADDRESS
     ... ... ... k8s-default-htmlgame-94cf9f8cc7-1702364624.us-east-1.elb.amazonaws.com


### Create DNS Record for Ingress/ALB (using Terraform)

1. Uncomment `dns_record` module in ./5-dns.tf

2. Enter ALB DNS Name in "records" attribute

    module "dns_record" {
    ...
      records = [
        {
          name    = "www"
          type    = "CNAME"
          ttl     = 3600
          records = ["k8s-default-htmlgame-94cf9f8cc7-1702364624.us-east-1.elb.amazonaws.com"]
        }
      ]
    }

3. Apply Terraform to Create CNAME Record

    $ terraform init
    $ terraform apply 
