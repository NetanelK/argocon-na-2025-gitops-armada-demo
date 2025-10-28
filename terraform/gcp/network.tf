module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 12.0"

  network_name = "${var.cluster_name}-network"
  project_id   = var.project_id

  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = "10.0.0.0/24"
      subnet_region = var.region
    }
  ]

  secondary_ranges = {
    "subnet-01" = [
      {
        range_name    = "${var.cluster_name}-pods"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "${var.cluster_name}-services"
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}
