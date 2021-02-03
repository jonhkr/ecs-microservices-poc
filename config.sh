
. env-config.sh

set +x

export AWS_REGION=us-east-1
export AWS_PROFILE=playground

export VPC=vpc-0b313bffeeb573486
export PUBLIC_SUBNET_A=subnet-0bcf780b7bfe6c86d
export PUBLIC_SUBNET_B=subnet-028b3b974da3cbb9a
export PRIVATE_SUBNET_A=subnet-0d80622548733340c
export PRIVATE_SUBNET_B=subnet-008f93177c5d8d473

export ENVIRONMENT_NAME=microservices-poc
export DISCOVERY_DOMAIN="service.production"

set -x