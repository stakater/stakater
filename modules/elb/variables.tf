# domain for route53 registration
variable "route53_public_zone_id" { }
variable "route53_private_zone_id" { }

# networking vars set by module.vpc
variable "vpc_id" { }
variable "vpc_cidr" { }

# This placeholder will be replaced by module subnet id and availability zone tf variable definations
# For more information look into 'substitute-VPC-AZ-placeholders.sh'

		variable "elb_subnet_b_id" { }
		variable "elb_subnet_az_b" { }
		variable "elb_subnet_c_id" { }
		variable "elb_subnet_az_c" { }
		variable "elb_subnet_d_id" { }
		variable "elb_subnet_az_d" { }
		variable "elb_subnet_e_id" { }
		variable "elb_subnet_az_e" { } }
