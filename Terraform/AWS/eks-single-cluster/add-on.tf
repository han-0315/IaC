data "tls_certificate" "tls_cert" {
  count = var.enable_add_ons ? 1 : 0
  url   = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count           = var.enable_add_ons ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls_cert[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}
data "aws_iam_policy_document" "vpc_cni_assume_role_policy" {
  count = var.enable_add_ons && var.enable_vpc_cni_add_on ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider[0].arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "vpc_cni_role" {
  count              = var.enable_add_ons && var.enable_vpc_cni_add_on ? 1 : 0
  name               = "${var.namespace}-vpc-cni-role"
  assume_role_policy = data.aws_iam_policy_document.vpc_cni_assume_role_policy[0].json
}

resource "aws_iam_role_policy_attachment" "vpc_cni_role_policy_attachment" {
  count      = var.enable_add_ons && var.enable_vpc_cni_add_on ? 1 : 0
  role       = aws_iam_role.vpc_cni_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_eks_addon_version" "vpc_cni_addon_version" {
  count              = var.enable_add_ons && var.enable_vpc_cni_add_on ? 1 : 0
  addon_name         = "vpc-cni"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "vpc_cni" {
  count                    = var.enable_add_ons && var.enable_vpc_cni_add_on ? 1 : 0
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "vpc-cni"
  addon_version            = data.aws_eks_addon_version.vpc_cni_addon_version[0].version
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = aws_iam_role.vpc_cni_role[0].arn

  tags = merge(
    {
      Name = "${var.namespace}-addon-vpc-cni"
    },
    local.additional_tags
  )
}
data "aws_eks_addon_version" "coredns_addon_version" {
  count              = var.enable_add_ons && var.enable_coredns_add_on ? 1 : 0
  addon_name         = "coredns"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "coredns" {
  count             = var.enable_add_ons && var.enable_coredns_add_on ? 1 : 0
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "coredns"
  addon_version     = data.aws_eks_addon_version.coredns_addon_version[0].version
  resolve_conflicts = "OVERWRITE"

  tags = merge(
    {
      Name = "${var.namespace}-addon-coredns"
    },
    local.additional_tags
  )
}
data "aws_eks_addon_version" "kube_proxy_addon_version" {
  count              = var.enable_add_ons && var.enable_kube_proxy_add_on ? 1 : 0
  addon_name         = "kube-proxy"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "kube_proxy" {
  count             = var.enable_add_ons && var.enable_kube_proxy_add_on ? 1 : 0
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "kube-proxy"
  addon_version     = data.aws_eks_addon_version.kube_proxy_addon_version[0].version
  resolve_conflicts = "OVERWRITE"

  tags = merge(
    {
      Name = "${var.namespace}-addon-kube-proxy"
    },
    local.additional_tags
  )
}
data "aws_iam_policy_document" "ebs_csi_driver_assume_role_policy" {
  count = var.enable_add_ons && var.enable_ebs_csi_driver_add_on ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider[0].arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver_role" {
  count              = var.enable_add_ons && var.enable_ebs_csi_driver_add_on ? 1 : 0
  name               = "${var.namespace}-ebs-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_assume_role_policy[0].json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_role_policy_attachment" {
  count      = var.enable_add_ons && var.enable_ebs_csi_driver_add_on ? 1 : 0
  role       = aws_iam_role.ebs_csi_driver_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

data "aws_eks_addon_version" "ebs_csi_driver_addon_version" {
  count              = var.enable_add_ons && var.enable_ebs_csi_driver_add_on ? 1 : 0
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "ebs_csi_driver" {
  count                    = var.enable_add_ons && var.enable_ebs_csi_driver_add_on ? 1 : 0
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = data.aws_eks_addon_version.ebs_csi_driver_addon_version[0].version
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role[0].arn

  tags = merge(
    {
      Name = "${var.namespace}-addon-ebs-csi-driver"
    },
    local.additional_tags
  )
}
data "aws_iam_policy_document" "adot_assume_role_policy" {
  count = var.enable_add_ons && var.enable_adot_add_on ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:adot-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider[0].arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "adot_role" {
  count              = var.enable_add_ons && var.enable_adot_add_on ? 1 : 0
  name               = "${var.namespace}-adot-role"
  assume_role_policy = data.aws_iam_policy_document.adot_assume_role_policy[0].json
}

resource "aws_iam_role_policy_attachment" "adot_role_policy_attachment_prometheus" {
  count      = var.enable_add_ons && var.enable_adot_add_on ? 1 : 0
  role       = aws_iam_role.adot_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
}

resource "aws_iam_role_policy_attachment" "adot_role_policy_attachment_xray" {
  count      = var.enable_add_ons && var.enable_adot_add_on ? 1 : 0
  role       = aws_iam_role.adot_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "adot_role_policy_attachment_cloudwatch" {
  count      = var.enable_add_ons && var.enable_adot_add_on ? 1 : 0
  role       = aws_iam_role.adot_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_eks_addon_version" "adot_addon_version" {
  count              = var.enable_add_ons && var.enable_adot_add_on ? 1 : 0
  addon_name         = "adot"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "adot" {
  count                    = var.enable_add_ons && var.enable_adot_add_on ? 1 : 0
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "adot"
  addon_version            = data.aws_eks_addon_version.adot_addon_version[0].version
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = aws_iam_role.adot_role[0].arn

  tags = merge(
    {
      Name = "${var.namespace}-addon-adot"
    },
    local.additional_tags
  )
}

