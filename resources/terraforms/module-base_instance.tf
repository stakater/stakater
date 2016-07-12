module "base_instance" {
    source = "../modules/base_instance"

    # base_instance cluster_desired_capacity should be in odd numbers, e.g. 3, 5, 9
    cluster_desired_capacity = 1
    image_type = "t2.medium"
    keypair = "base_instance"
    allow_ssh_cidr="0.0.0.0/0"

    # aws
    aws_account_id="${var.aws_account.id}"
    aws_region = "${var.aws_account.default_region}"
    ami = "${var.ami}"

    #cluster name
    cluster_name = "${var.cluster_name}"

    # Note: currently base_instance launch_configuration devices can NOT be changed after etcd cluster is up
    # See https://github.com/hashicorp/terraform/issues/2910
    docker_volume_size = 12
    root_volume_size = 12

    # vpc
    #vpc_id = "${module.vpc.vpc_id}"
    #vpc_cidr = "${module.vpc.vpc_cidr}"

    # vpc from env var
    vpc_id = "${var.env_vpc_id}"
    vpc_cidr = "${var.env_vpc_cidr}"
    subnet_id = "${var.env_subnet_id}"
}
