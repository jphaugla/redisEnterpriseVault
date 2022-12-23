variable "gcp_project"  {
    description = "gcp project to be used."
    default = "central-beach-194106"
}

variable "gcp_credentials_file"  {
    description = "gcp credentials file"
    default = "/Users/jasonhaugland/.gcp/bb-gcp-terraform.json"
}

variable "cidr" { 
    description = "CIDR blocks to be used with the network."
    default = "10.3.0.0/16"
}

variable "region" {
    description = "Region to be used with the network and resources."
    default = "us-west1"
}

variable "cluster_name_final" {
    description = "name of the GKE cluster"
    default = "jph-gke"
}

variable "zone" {
    description = "Zone to be used with the network and resources."
    default = "us-west1-a"
}


variable "instances_inventory_file" {
    description = "Path and file name to send inventory details for ansible later."
    default = "inventory"
}

variable "ansible_verbosity_switch" {
    description = "Set the about of verbosity to pass through to the ansible playbook command. No additional verbosity by default. Example: -v or -vv or -vvv."
    default = ""
}
