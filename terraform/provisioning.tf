resource "null_resource" "provision" {

    triggers = {
        always_run = "${timestamp()}"
    }

    provisioner "local-exec" {
        working_dir = "ansible-gke/"
        command = "ansible-playbook  -vv --extra-vars cluster_state=present playbook.yml ${var.ansible_verbosity_switch} -e 'cluster_name=${google_container_cluster.primary.name}'  -e 'gcp_region=${var.region}' -e 'gcp_project=${var.gcp_project}' -e 'ansible_python_interpreter=/usr/local/bin/python3' -e 'bundle_location=/Users/jasonhaugland/gits/redis-enterprise-k8s-docs/bundle.yaml'"
    }

    depends_on = [
google_container_node_pool.primary_nodes
    ]
}
