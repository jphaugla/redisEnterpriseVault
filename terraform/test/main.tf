provider "google"{
}

module "mymodule" {
   source 		= "../"
   gcp_project          = "central-beach-194106"
   gcp_credentials_file = "/Users/jasonhaugland/.gcp/bb-gcp-terraform.json"
   cidr 		=  "10.3.0.0/16"
   region 		= "us-central1"
   cluster_name_final   = "jph-gke"
   rec_name             = "test-rec-1"
   zone 		= "us-central1-a"
   redis_enterprise_version = "v6.4.2-8"
   vault_chart_version  = "0.24.0"
   gears_version        = "1.2.6"
   gke_release_channel  = "STABLE"
   postgres_pw          = "jasonrocks"
   python_path          = "/usr/local/bin/python3"
   do_vault             = true
   do_postgres          = true
   do_redis_connect     = true
   do_rdi               = false
   dns_domain           = "demo.redislabs.com"
   dns_name             = "demo-clusters"
}
