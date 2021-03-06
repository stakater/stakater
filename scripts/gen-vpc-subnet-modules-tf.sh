#!/bin/bash

# This script generates *-subnet.tf files in the vpc module
#
# These .tf files are generated through this script so that the 'resources'(aws_subnet & aws_route_table_association)
# and 'variables' can be created dynamically according to the availability zones of a selected region.

# Map of AWS availability zones
declare -A AWS_AZS=(["us-east-1"]=${AZ_US_EAST_1}
				 ["us-west-1"]=${AZ_US_WEST_1}
				 ["us-west-2"]=${AZ_US_WEST_2}
				 ["eu-west-1"]=${AZ_EU_WEST_1}
				 ["eu-central-1"]=${AZ_EU_CETNRAL_1}
				 ["ap-southeast-1"]=${AZ_AP_SOUTHEAST_1}
				 ["ap-southeast-2"]=${AZ_AP_SOUTHEAST_2}
				 ["ap-south-1"]=${AZ_AP_SOUTH_1}
				 ["ap-northeast-1"]=${AZ_AP_NORTHEAST_1}
				 ["ap-northeast-2"]=${AZ_AP_NORTHEAST_2}
				 ["sa-east-1"]=${AZ_SA_EAST_1})

# Name of modules whose subnet.tf files are to be created in the vpc module
# split value by , and put as an array
IFS=',' read -r -a VPC_SUBNET_MODULE_NAMES <<< "${VPC_SUBNET_MODULES}"

# fetch AWS_REGION from the config file
CONFIG_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
AWS_REGION=$($CONFIG_DIR/read_cfg.sh $HOME/.aws/config "profile $AWS_PROFILE" region)

# Destination where the generated files are to be stored
DESTINATION=""

# Get options from the command line
# set destination from command line option
while getopts ":d:" OPTION
do
    case $OPTION in
        d)
          DESTINATION=$OPTARG
          ;;
        *)
          echo "Usage: $(basename $0) -d <destination of generated .tf files>"
          exit 0
          ;;
    esac
done

# First digit of the 3rd block of the subnet address to be generated
subnet_dig_1="0"

# for all modules
for subnet_module in "${VPC_SUBNET_MODULE_NAMES[@]}"
do
	#parse availability zones to an array, according to the selected AWS_REGION
	IFS=',' read -r -a AVAIL_ZONES <<< "${AWS_AZS["${AWS_REGION}"]}"

	INITIAT_COMMENT="  # subnet for ${subnet_module} cluster
	#
  # This file is generated by 'gen-vpc-subnet-modules-tf.sh'
  # The variable values for CIDR blocks and availability zones are generated dynamically
  # by the same script, according to the selected AWS region"

	VARIABLES=""
	OUTPUTS=""
	RESOURCES=""

  # Used to generate subnet address that is to be assigned to the variable
	# For a same VPC module, the value generated has same digit at the tens place,
	# and has a sequentially increasing digit and units place, in the third part of the CIDR block
	# e.g etcd_subnet_a would have 10.0.10.0/24, etcd_subnet_b would have 10.0.11.0/24, and the next module would have module_subnet_a: 10.0.20.0/24 and so on
	subnet_dig_1=$((${subnet_dig_1}+1))
	subnet_dig_2="-1"

	# for all availability zones
	for availability_zone in "${AVAIL_ZONES[@]}"
	do
		#get last letter of the availability zone
		zone_letter=${availability_zone: -1}
		subnet_dig_2=$((${subnet_dig_2}+1))

		########## VARIABLES ##########
		VARIABLES="$VARIABLES
		variable \"${subnet_module}_subnet_${zone_letter}\" { default = \"10.0.${subnet_dig_1}${subnet_dig_2}.0/24\" }
		variable \"${subnet_module}_subnet_az_${zone_letter}\" { default = \"${availability_zone}\" }"

		########## AWS_SUBNET ##########
		AWS_SUBNET="resource \"aws_subnet\" \"${subnet_module}_${zone_letter}\" {
				vpc_id = \"\${aws_vpc.cluster_vpc.id}\"
				availability_zone = \"\${var.${subnet_module}_subnet_az_${zone_letter}}\"
				cidr_block = \"\${var.${subnet_module}_subnet_${zone_letter}}\"
				map_public_ip_on_launch = \"true\"
				tags {
						Name = \"${subnet_module}_${zone_letter}\"
				}
		}
		"
		########## AWS_ROUTING_TABLE ##########
		AWS_ROUTING_TABLE="resource \"aws_route_table_association\" \"${subnet_module}_rt_${zone_letter}\" {
				subnet_id = \"\${aws_subnet.${subnet_module}_${zone_letter}.id}\"
				route_table_id = \"\${aws_route_table.cluster_vpc.id}\"
		}
		"

		# Concatenate AWS_SUBNET & AWS_ROUTING_TABLE with the rest of the RESOURCES of this subnet module
		RESOURCES="$RESOURCES
		$AWS_SUBNET
		$AWS_ROUTING_TABLE"

		########## OUTPUTS ##########
		OUTPUTS="$OUTPUTS
		output \"${subnet_module}_subnet_${zone_letter}_id\" {value = \"\${aws_subnet.${subnet_module}_${zone_letter}.id}\"}
		output \"${subnet_module}_subnet_az_${zone_letter}\" {value = \"\${var.${subnet_module}_subnet_az_${zone_letter}}\"}"
	done

	# Concatenate all content to be written
	FILE_CONTENT="$INITIAT_COMMENT
	$VARIABLES
	$RESOURCES
	$OUTPUTS"

	FILE_NAME="${subnet_module}-subnet.tf"

	# Write file if folder exists
	if [ -d "$DESTINATION" ]
	then
	  echo "$FILE_CONTENT" > "$DESTINATION/$FILE_NAME"
	fi
done
