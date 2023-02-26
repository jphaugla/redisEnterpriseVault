resource "null_resource" "provision" {

    triggers = {
        always_run = "${timestamp()}"
    }

    provisioner "local-exec" {
        working_dir = "../ansible-gke/"
        command = "ansible-playbook  -vv --extra-vars cluster_state=present playbook.yml -e 'cluster_name=${google_container_cluster.primary.name}'  -e 'gcp_region=${var.region}' -e 'gcp_project=${var.gcp_project}' -e 'gke=true' -e 'vault=${var.do_vault}' -e 'postgres=${var.do_postgres}' -e 'rdi=${var.do_rdi}' -e 'redis_connect=${var.do_redis_connect}' -e 'ansible_python_interpreter=${var.python_path}' -e 'redis_enterprise_version=${var.redis_enterprise_version}' -e 'vault_chart_version=${var.vault_chart_version}' -e 'postgres_pw=${var.postgres_pw}' -e 'KUBECONFIG=gkeconfig'"
    }

    depends_on = [
google_container_node_pool.primary_nodes
    ]
}
