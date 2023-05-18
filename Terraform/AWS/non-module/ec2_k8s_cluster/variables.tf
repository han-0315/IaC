variable "region" {
  default     = "ap-northeast-1"
  type        = string
  description = "AWS region"
}
variable "namespace" {
  default     = "DevOps-kit"
  type        = string
  description = "The project namespace to use for unique resource naming"
}
variable "vpc_cidr" {
  default     = "192.168.0.0/16"
  type        = string
  description = "The CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  default     = "192.168.1.0/24"
  type        = string
  description = "The CIDR block for the public subnet"
}
variable "ssh_port" {
  default     = 22
  type        = number
  description = "SSH port"
}
variable "http_port" {
  default     = 80
  type        = number
  description = "SSH port"
}
variable "api_server_port" {
  default     = 6443
  type        = number
  description = "SSH port"
}
variable "etcd_client_port" {
  default     = 2379
  type        = number
  description = "SSH port"
}
variable "etcd_peer_port" {
  default     = 2380
  type        = number
  description = "SSH port"
}
variable "kube_scheduler_port" {
  default     = 10251
  type        = number
  description = "SSH port"
}
variable "kube_controller_manager_port" {
  default     = 10252
  type        = number
  description = "HTTP port"
}
variable "kubelet_port" {
  default     = 10255
  type        = number
  description = "HTTP port"
}
variable "kube_proxy_port" {
  default     = 10250
  type        = number
  description = "HTTP port"
}
variable "kubectl_port" {
  default     = 8080
  type        = number
  description = "HTTP port"
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

variable "ec2_instance_type" {
  type        = string
  description = "The type of EC2 instance to launch"
}
variable "key_name" {
  type        = string
  description = "The key name to use for an EC2 instance"
}
