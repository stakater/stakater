variable "allow_ssh_cidr" { default = "0.0.0.0/0" }
variable "aws_region" { }
variable "aws_account_id" { }
variable "ami" { }
variable "image_type" { default = "t2.micro" }
variable "cluster_min_size" { default = 1 }
variable "cluster_max_size" { default = 9 }
variable "cluster_desired_capacity" { default = 3 }
variable "keypair" { default = "worker_qa" }
variable "root_volume_size" { default = 25 }
variable "docker_volume_size" { default = 12 }
variable "data_volume_size" { default = 12 }
variable "cluster_name" { }

# networking vars set by module.vpc
variable "vpc_id" { }
variable "vpc_cidr" { }

# Application port
variable "application_from_port" { default = 8080 }
variable "application_to_port" { default = 8080 }

# This placeholder will be replaced by module subnet id and availability zone tf variable definations
# For more information look into 'substitute-VPC-AZ-placeholders.sh'

		variable "worker_qa_subnet_b_id" { }
		variable "worker_qa_subnet_az_b" { }
		variable "worker_qa_subnet_c_id" { }
		variable "worker_qa_subnet_az_c" { }
		variable "worker_qa_subnet_d_id" { }
		variable "worker_qa_subnet_az_d" { }
		variable "worker_qa_subnet_e_id" { }
		variable "worker_qa_subnet_az_e" { }