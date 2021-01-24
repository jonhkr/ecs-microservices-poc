#!/bin/bash

set -ex

. config.sh

delete_stack () {
	STACK_NAME=$1
	aws cloudformation delete-stack \
		--stack-name "${STACK_NAME}"

	aws cloudformation wait stack-delete-complete \
		--stack-name "${STACK_NAME}"
}

delete_ecr_images () {
	REPOSITORY_NAME=$1

	set +e
	aws ecr describe-repositories --repository-names "${REPOSITORY_NAME}" 2>/dev/null
	status=$?
	set -e
	
	if [[ "${status}" -eq 0 ]]; then
		IMAGE_IDS=$(aws ecr list-images \
			--query "imageIds" \
			--repository-name "${REPOSITORY_NAME}")
	
		aws ecr batch-delete-image \
			--repository-name "${REPOSITORY_NAME}" \
			--image-ids "${IMAGE_IDS}"	
	fi
}

delete_stack "${ENVIRONMENT_NAME}-api-service"
delete_ecr_images "${ENVIRONMENT_NAME}-api"
delete_stack "${ENVIRONMENT_NAME}-api-repository"
delete_stack "${ENVIRONMENT_NAME}-edgelb"
delete_stack "${ENVIRONMENT_NAME}-app1-service"
delete_stack "${ENVIRONMENT_NAME}-app2-service"
delete_ecr_images "${ENVIRONMENT_NAME}-app"
delete_stack "${ENVIRONMENT_NAME}-app-repository"
delete_stack "${ENVIRONMENT_NAME}-discovery"
delete_stack "${ENVIRONMENT_NAME}-cluster"