module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                     = var.cluster_name
  kubernetes_version       = "1.34"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets
  endpoint_public_access   = true
  access_entries = {
    argocd = {
      principal_arn      = var.eks_admin_role_arn,
      policy_association = { admin = { policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" } }
    }
  }
  create_cloudwatch_log_group = false
  addons                      = { coredns = {}, kube-proxy = {}, vpc-cni = { before_compute = true } }
  eks_managed_node_groups = {
    minimal = {
      min_size       = 1
      max_size       = 3
      desired_size   = 1
      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
    }
  }
}

resource "aws_secretsmanager_secret" "cluster_secret" {
  name = "cluster/${module.eks.cluster_name}"
  tags = {
    clusterName   = module.eks.cluster_name
    region        = var.region
    environment   = var.environment
    cloudProvider = "aws"
  }
}

resource "aws_secretsmanager_secret_version" "current" {
  secret_id = aws_secretsmanager_secret.cluster_secret.id
  secret_string = jsonencode({
    name   = module.eks.cluster_name
    server = module.eks.cluster_endpoint
    config = {
      tlsClientConfig = {
        insecure = false
        caData   = module.eks.cluster_certificate_authority_data
      }
      awsAuthConfig = {
        clusterName = module.eks.cluster_name
        roleARN     = var.eks_admin_role_arn
      }
    }
  })
}
