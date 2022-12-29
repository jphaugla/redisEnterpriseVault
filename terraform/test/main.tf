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
   bundle_yaml_location = "/Users/jasonhaugland/gits/redis-enterprise-k8s-docs/bundle.yaml"
}
