
resource "google_compute_network" "vpc_network" {
  name = local.vpc_name
  auto_create_subnetworks = false
  
  depends_on = [random_id.random_vpc_name]
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name = local.vpc_subnet
  region = var.region
  network = local.vpc_name
  ip_cidr_range = var.cidr

  depends_on = [google_compute_network.vpc_network]
}


