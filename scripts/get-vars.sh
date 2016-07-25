#!/usr/bin/env bash

# Default Environment variables
COREOS_UPDATE_CHANNEL=${COREOS_UPDATE_CHANNEL}        # stable/beta/alpha
VM_TYPE=${VM_TYPE}                                        # hvm/pv - note: t1.micro supports only pv type

# Private domain for route53
PRIVATE_DOMAIN=${PRIVATE_DOMAIN}

AWS_PROFILE=${AWS_PROFILE}
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
AWS_REGION=$($DIR/read_cfg.sh $HOME/.aws/config "profile $AWS_PROFILE" region)

# Get options from the command line
while getopts ":c:z:t:" OPTION
do
    case $OPTION in
        c)
          COREOS_UPDATE_CHANNEL=$OPTARG
          ;;
        z)
          AWS_REGION=$OPTARG
          ;;
        t)
          VM_TYPE=$OPTARG
          ;;
        *)
          echo "Usage: $(basename $0) -c <stable|beta|alpha> -z <aws zone> -t <hvm|pv>"
          exit 0
          ;;
    esac
done


# Get the AMI id
url=`printf "http://%s.release.core-os.net/amd64-usr/current/coreos_production_ami_%s_%s.txt" $COREOS_UPDATE_CHANNEL $VM_TYPE $AWS_REGION`
cat <<EOF
# Generated by scripts/get-vars.sh
variable "ami" { default = "`curl -s $url`" }
variable "private_domain" { default = "${PRIVATE_DOMAIN}"}
EOF