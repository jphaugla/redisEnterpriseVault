locals {
    name = random_id.random_vpc_name.hex
    vpc_name = "${local.name}-vpc"
    vpc_subnet = "${local.vpc_name}-subnet"

}
