variable "region" {
  default     = "ap-northeast-2"
  type        = string
  description = "AWS Region"
}

variable "namespace" {
  default     = "devops-kit-eks-single-cluster"
  type        = string
  description = "The project namespace to use for unique resource naming."
}

variable "environment" {
  default     = "dev"
  type        = string
  description = "The Deployment environment"
}

variable "purpose" {
  type        = string
  description = "The purpose of the resources"
}

variable "owner" {
  type        = string
  description = "Identify who is responsible for the resources"
}
variable "vpc_cidr" {
  type        = string
  description = "The IPv4 CIDR block for the VPC"
}
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "The list of IPv4 CIDR blocks for the public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "The list of IPv4 CIDR blocks for the private subnets"
}

variable "enable_nat_gateway" {
  default     = true
  type        = bool
  description = "Indicates whether to provision NAT Gateways for the private subnets"
}

variable "single_nat_gateway" {
  default     = false
  type        = bool
  description = "Indicates whether to provision a single shared NAT Gateway for all private subnets"
}
variable "ssh_port" {
  default     = 22
  type        = number
  description = "SSH port"
}
variable "cluster_version" {
  default     = null
  type        = string
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.24`)"
}
variable "enable_add_ons" {
  default     = false
  type        = bool
  description = "Indicates whether to enable the add-ons. If set to 'false', all add-ons will not be created."
}
variable "enable_vpc_cni_add_on" {
  default     = true
  type        = bool
  description = "Indicates whether to enable the VPC CNI add-on"
}
variable "enable_coredns_add_on" {
  default     = true
  type        = bool
  description = "Indicates whether to enable the CoreDNS add-on"
}
variable "enable_kube_proxy_add_on" {
  default     = true
  type        = bool
  description = "Indicates whether to enable the kube-proxy add-on"
}
variable "enable_ebs_csi_driver_add_on" {
  default     = true
  type        = bool
  description = "Indicates whether to enable the EBS CSI driver add-on"
}
variable "enable_adot_add_on" {
  default     = false
  type        = bool
  description = "Indicates whether to enable the AWS Distro for OpenTelemetry add-on"
}
variable "desired_size" {
  type        = number
  description = "The desired number of nodes"
}

variable "max_size" {
  type        = number
  description = "The maximum number of nodes"
}

variable "min_size" {
  type        = number
  description = "The minimum number of nodes"
}

variable "disk_size" {
  default     = 20
  type        = number
  description = "The disk size in GiB for nodes. Defaults to `50` for Windows, `20` all other node groups."
}

variable "instance_types" {
  default     = ["t3.medium"]
  type        = list(string)
  description = "The list of instance types to use for the node group"
}

variable "key_name" {
  type        = string
  description = "The key name to use for an EC2 instance"
}
