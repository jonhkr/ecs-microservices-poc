#!/bin/bash

set -ex

. config.sh

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
	--query "Account" \
	--output text)

# Deploy cluster
aws cloudformation deploy \
	--capabilities CAPABILITY_IAM \
	--stack-name "${ENVIRONMENT_NAME}-cluster" \
	--parameter-overrides \
		VPC="${VPC}" \
		EnvironmentName="${ENVIRONMENT_NAME}" \
		PublicSubnetA="${PUBLIC_SUBNET_A}" \
		PublicSubnetB="${PUBLIC_SUBNET_B}" \
		PrivateSubnetA="${PRIVATE_SUBNET_A}" \
		PrivateSubnetB="${PRIVATE_SUBNET_B}" \
	--template-file cluster.yml \
	--no-fail-on-empty-changeset

# Setup Service Discovery
aws cloudformation deploy \
	--capabilities CAPABILITY_IAM \
	--stack-name "${ENVIRONMENT_NAME}-discovery" \
	--parameter-overrides \
		EnvironmentName="${ENVIRONMENT_NAME}" \
		Domain="${DISCOVERY_DOMAIN}" \
	--template-file discovery.yml \
	--no-fail-on-empty-changeset


aws ecr get-login-password \
	| docker login \
		--username AWS \
		--password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

push_image () {
	local APP=$1
	local REPOSITORY_STACK_NAME="${ENVIRONMENT_NAME}-${APP}-repository"

	aws cloudformation deploy \
		--stack-name ${REPOSITORY_STACK_NAME} \
		--parameter-overrides ServiceName="${ENVIRONMENT_NAME}-${APP}" \
		--template-file repository.yml \
		--no-fail-on-empty-changeset

	local REPOSITORY_URI=$(aws cloudformation describe-stacks \
		--stack-name "${REPOSITORY_STACK_NAME}" \
		--query "Stacks[0].Outputs[?OutputKey=='ContainerRepositoryURI'].OutputValue" \
		--output text)

	sh "./${APP}/build.sh"

	docker build -t ${REPOSITORY_URI}:latest "./${APP}"
	docker push ${REPOSITORY_URI}:latest

	IMAGE="${REPOSITORY_URI}:latest"
}

deploy_app () {
	local APP=$1
	local SERVICE_TO_CALL=$2
	local IMAGE=$3

	aws cloudformation deploy \
		--capabilities CAPABILITY_IAM \
		--stack-name "${ENVIRONMENT_NAME}-${APP}-service" \
		--parameter-overrides \
			EnvironmentName="${ENVIRONMENT_NAME}" \
			ServiceName="${APP}" \
			ImageUrl="${IMAGE}" \
			ServiceToCall="${SERVICE_TO_CALL}" \
			ContainerPort="80" \
		--template-file service.yml \
		--no-fail-on-empty-changeset
}

# DEPLOY APPS

push_image "app"

deploy_app app1 "app2.${DISCOVERY_DOMAIN}" "${IMAGE}" &
app1_pid=$!
deploy_app app2 "javaapp.${DISCOVERY_DOMAIN}" "${IMAGE}" &
app2_pid=$!

wait $app1_pid
echo "app1 deployment exited with status $?"

wait $app2_pid
echo "app2 deployment exited with status $?"

push_image "javaapp"
deploy_app javaapp "javaapp.${DISCOVERY_DOMAIN}" "${IMAGE}" &
javaapp_pid=$!
wait $javaapp_pid
echo "javaapp deployment exited with status $?"

# DEPLOY API

aws cloudformation deploy \
	--stack-name "${ENVIRONMENT_NAME}-edgelb" \
	--parameter-overrides EnvironmentName="${ENVIRONMENT_NAME}" \
	--template-file edgelb.yml \
	--no-fail-on-empty-changeset

push_image "api"

aws cloudformation deploy \
	--capabilities CAPABILITY_IAM \
	--stack-name "${ENVIRONMENT_NAME}-api-service" \
	--parameter-overrides \
		EnvironmentName="${ENVIRONMENT_NAME}" \
		ServiceName="api" \
		ImageUrl="${IMAGE}" \
		ContainerPort="8080" \
	--template-file api.yml \
	--no-fail-on-empty-changeset

