#!/bin/bash
#######################################################
## THIS FILE IS ONLY USED FOR ANY MODULE IN WHICH WE NEED TO CREATE A STANDALONE INSTANCE IN ONLY SINGLE AVAILIBILITY ZONE
## IN $(BUILD)/.terraform/modules/*.tf AND $(BUILD)/*.tf FILES
#######################################################

# first argument: path to dir for terraform modules
TF_MODULES_DIRECTORY=$1

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

# fetch AWS_REGION from the config file
CONFIG_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
AWS_REGION=$($CONFIG_DIR/read_cfg.sh $HOME/.aws/config "profile $AWS_PROFILE" region)

IFS=',' read -r -a AVAIL_ZONES <<< "${AWS_AZS["${AWS_REGION}"]}"


# find files with .tf.tmpl extension in the directory: $TF_MODULES_DIRECTORY
TF_MODULES_FILES=$(find $TF_MODULES_DIRECTORY -type f -iname "*.tf.tmpl")

# find files which contain any of the three placeholders
files=$(grep -s -l -e \<%MODULE-AZ-VARIABLE%\> -e \<%MODULE-SUBNET-VARIABLE%\> -r $TF_MODULES_FILES)
for f in $files
do
	# extract module from file name like *modules/<MODULE_NAME>/*.tf
	current_module_name=${f##*modules/}
	current_module_name=${current_module_name%%/*}

	# create a new file tf file without the .tmpl extension
  newFile="${f%%.tmpl*}"
  cp $f $newFile
	# Replace placeholders with their respective values in the new tf file
	zone_letter=${AVAIL_ZONES[0]: -1}
	MODULE_SUBNET_VAR="\\\"\\\${var.${current_module_name}_subnet_${zone_letter}_id}\\\""

	perl -p -i -e "s/<%MODULE-SUBNET-VARIABLE%>/${MODULE_SUBNET_VAR}/g" "${newFile}"
	perl -p -i -e "s/<%MODULE-AZ-VARIABLE%>/\"${AVAIL_ZONES[0]}\"/g" "${newFile}"
done