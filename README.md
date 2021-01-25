## Amazon ECS Microservices POC

### Architecture

### Project structure

- `api/` - Contains the API service source
- `app/` - Contains the source for the App1 and App2 services
- `cluster.yml` - CloudFormation to setup an ECS cluser
- `discovery.yml` - CloudFormation to setup service discovery
- `service.yml` - CloudFormation to deploy the App1 and App2 services
- `repository.yml` - CloudFormation to create ECR repositories
- `edgelb.yml` - CloudFormation to deploy a publicly available ALB
- `api.yml` - CloudFormation to deploy the API service

### Scripts

- `deploy-all.sh` - Build and deploy everything
- `terminate.sh` - Deletes everything