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

variable "gears_version" {
    description = "The gears version.  Can find versions here-https://docs.redis.com/latest/rs/release-notes/"
}
 
variable "gke_release_channel" {
    description = "The gke release channel.  Can be RAPID, REGULAR, or STABLE"
}

variable "vault_chart_version" {
    description = "The vault chart version for installing vault using helm.  Version information is here https://developer.hashicorp.com/vault/docs/platform/k8s/helm"
}

variable "postgres_pw" {
    description = "the postgres password"
}

variable "python_path" {
    description = "the path to python"
}

variable "do_vault" {
    description = "include integration with vault"
    type = bool
}

variable "do_postgres" {
    description = "include integration with postgres"
    type = bool
}

variable "do_redis_connect" {
    description = "include integration with redis_connect"
    type = bool
}

variable "do_rdi" {
    description = "include integration with redis data integration"
    type = bool
}
