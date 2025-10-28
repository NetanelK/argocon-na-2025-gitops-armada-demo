data "google_client_config" "current" {}

module "gke" {
  source = "terraform-google-modules/kubernetes-engine/google"

  project_id        = data.google_client_config.current.project
  name              = var.cluster_name
  region            = var.region
  network           = module.vpc.network_name
  subnetwork        = module.vpc.subnets_names[0]
  ip_range_pods     = module.vpc.subnets_secondary_ranges[0][0].range_name
  ip_range_services = module.vpc.subnets_secondary_ranges[0][1].range_name
  deletion_protection = false

  node_pools = [
    {
      name         = "default-node-pool"
      machine_type = "e2-standard-4"
      min_count    = 1
      max_count    = 10
      disk_size_gb = 30
      disk_type    = "pd-standard"
      auto_repair  = true
      auto_upgrade = true
    },
  ]
}

resource "aws_secretsmanager_secret" "cluster_secret" {
  name = "cluster/${var.cluster_name}"
  tags = {
    clusterName   = module.gke.name
    region        = var.region
    environment   = var.environment
    cloudProvider = "gcp"
  }
}

resource "aws_secretsmanager_secret_version" "current" {
  secret_id = aws_secretsmanager_secret.cluster_secret.id
  secret_string = jsonencode({
    name   = module.gke.name
    server = "https://${module.gke.endpoint}"
    config = {
      tlsClientConfig = {
        insecure = false
        caData   = module.gke.ca_certificate
      }
      token = data.google_client_config.current.access_token
    }
  })
}
