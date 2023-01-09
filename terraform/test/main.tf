provider "google"{
}

module "mymodule" {
   source 		= "../"
   gke_num_nodes        = 1
   gcp_project          = "central-beach-194106"
   gcp_credentials_file = "/Users/jasonhaugland/.gcp/bb-gcp-terraform.json"
   cidr 		=  "10.3.0.0/16"
   region 		= "us-west1"
   cluster_name_final   = "jph-gke"
   zone 		= "us-west1-a"
   redis_enterprise_version = "v6.2.18-41"
   vault_chart_version  = "0.23.0"
   gke_release_channel  = "STABLE"
   postgres_pw          = "jasonrocks"
}
