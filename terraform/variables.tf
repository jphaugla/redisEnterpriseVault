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

variable "redis_enterprise_version" {
    description = "The redis enterprise operator version.  Can find versions here-https://github.com/RedisLabs/redis-enterprise-k8s-docs/releases"
}

variable "gke_release_channel" {
    description = "The gke release channel.  Can be RAPID, REGULAR, or STABLE"
}

variable "vault_chart_version" {
    description = "The vault chart version for installing vault using helm.  Version information is here https://developer.hashicorp.com/vault/docs/platform/k8s/helm"
}
