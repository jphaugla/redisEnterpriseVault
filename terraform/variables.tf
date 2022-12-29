variable "gcp_project"  {
    description = "gcp project to be used."
}

variable "gcp_credentials_file"  {
    description = "gcp credentials file"
}

variable "cidr" { 
    description = "CIDR blocks to be used with the network."
}

variable "region" {
    description = "Region to be used with the network and resources."
}

variable "cluster_name_final" {
    description = "name of the GKE cluster"
}

variable "zone" {
    description = "Zone to be used with the network and resources."
}

variable "bundle_yaml_location" {
    description = "The file location for the redis enterprise bundle.yaml file.  Must have full git pull of redis enterprise github containing this yaml"
}
