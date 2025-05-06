terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "~> 1.49.0"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region = var.region
}

# Create a Resource Group if needed
resource "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

# Create VPC
resource "ibm_is_vpc" "vpc" {
  name = "app-vpc"
  resource_group = ibm_resource_group.resource_group.id
}

# Create subnets
resource "ibm_is_subnet" "subnet1" {
  name            = "app-subnet-1"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.region}-1"
  ipv4_cidr_block = "10.240.0.0/24"
  resource_group  = ibm_resource_group.resource_group.id
}

resource "ibm_is_subnet" "subnet2" {
  name            = "app-subnet-2"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.region}-2"
  ipv4_cidr_block = "10.240.64.0/24"
  resource_group  = ibm_resource_group.resource_group.id
}

# Create Kubernetes cluster
resource "ibm_container_vpc_cluster" "cluster" {
  name              = "app-cluster"
  vpc_id            = ibm_is_vpc.vpc.id
  flavor            = "bx2.4x16"
  worker_count      = 2
  resource_group_id = ibm_resource_group.resource_group.id
  
  zones {
    subnet_id = ibm_is_subnet.subnet1.id
    name      = "${var.region}-1"
  }
  
  zones {
    subnet_id = ibm_is_subnet.subnet2.id
    name      = "${var.region}-2"
  }
}

# Create Container Registry namespace
resource "ibm_cr_namespace" "namespace" {
  name              = var.cr_namespace
  resource_group_id = ibm_resource_group.resource_group.id
}

# Create a certificate manager instance
resource "ibm_resource_instance" "certificate_manager" {
  name              = "app-cert-manager"
  service           = "cloudcerts"
  plan              = "free"
  location          = var.region
  resource_group_id = ibm_resource_group.resource_group.id
}
