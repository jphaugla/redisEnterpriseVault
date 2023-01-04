resource "null_resource" "provision" {

    triggers = {
        always_run = "${timestamp()}"
    }

    provisioner "local-exec" {
        working_dir = "../ansible-gke/"
        command = "ansible-playbook  -vv --extra-vars cluster_state=present playbook.yml -e 'cluster_name=${google_container_cluster.primary.name}'  -e 'gcp_region=${var.region}' -e 'gcp_project=${var.gcp_project}' -e 'ansible_python_interpreter=/usr/local/bin/python3' -e 'redis_enterprise_version=${var.redis_enterprise_version}' -e 'vault_chart_version=${var.vault_chart_version}'"
    }

    depends_on = [
google_container_node_pool.primary_nodes
    ]
}
