region                       = "ap-northeast-1"
namespace                    = "devops-kit-eks-single"
environment                  = "dev"
purpose                      = "devops-kit-test"
owner                        = "kane"
vpc_cidr                     = "192.168.0.0/16"
public_subnet_cidrs          = ["192.168.1.0/24", "192.168.2.0/24"]
private_subnet_cidrs         = ["192.168.101.0/24", "192.168.102.0/24"]
enable_nat_gateway           = true
single_nat_gateway           = true
ssh_port                     = 22
cluster_version              = "1.25"
enable_add_ons               = true
enable_vpc_cni_add_on        = true
enable_coredns_add_on        = true
enable_kube_proxy_add_on     = true
enable_ebs_csi_driver_add_on = true
enable_adot_add_on           = false
desired_size                 = 2
max_size                     = 3
min_size                     = 1
disk_size                    = 20
instance_types               = ["t3.medium"]
key_name                     = "Kane"