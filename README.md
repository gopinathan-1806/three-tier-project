# IBM Cloud Node.js Application Deployment

This project demonstrates a containerized Node.js application deployment to IBM Cloud using Terraform as Infrastructure as Code (IaC). The deployment includes Docker containerization, load balancing, and TLS configuration.

## Prerequisites

- IBM Cloud account with an API key
- Docker installed locally
- Terraform installed locally
- Git (optional, for version control)
- IBM Cloud CLI (will be installed by the deployment script if missing)

## Project Structure

```
.
├── app.js                 # Node.js application code
├── package.json           # Node.js dependencies
├── Dockerfile             # Container definition
├── main.tf                # Main Terraform configuration
├── variables.tf           # Terraform variables
├── outputs.tf             # Terraform outputs
├── kubernetes.tf          # Kubernetes resources
├── deploy.sh              # Deployment script
└── README.md              # This file
```

## Deployment Steps

1. Clone this repository or copy all files to your local machine.

2. Make the deployment script executable:
   ```bash
   chmod +x deploy.sh
   ```

3. If you want to initialize a git repository (optional):
   ```bash
   ./deploy.sh --init-git
   ```

4. Otherwise, just run the deployment script:
   ```bash
   ./deploy.sh
   ```

   You will be prompted for your IBM Cloud API key if it's not set as an environment variable.

5. The script will:
   - Login to IBM Cloud
   - Build and push the Docker image to IBM Container Registry
   - Apply the Terraform configuration to create all required resources
   - Display the URL where your application is deployed

## Testing the Deployment

Once deployment is complete, you can test the following endpoints:

1. **Index Page**: `https://<app_url>/`
   - Displays the welcome page with the SECRET_WORD

2. **Docker Check**: `https://<app_url>/docker`
   - Confirms the application is running in a Docker container

3. **Secret Word Check**: `https://<app_url>/secret_word`
   - Confirms that the SECRET_WORD environment variable is correctly set

4. **Load Balancer Check**: `https://<app_url>/loadbalanced`
   - Confirms the application is being served through a load balancer

5. **TLS Check**: `https://<app_url>/tls`
   - Confirms the connection is secured with TLS (HTTPS)

## Architecture

This deployment creates:

- IBM VPC Network with subnets
- IBM Kubernetes Service (IKS) cluster
- IBM Container Registry namespace
- Kubernetes deployment with 2 replicas
- Load balancer service
- TLS certificate (self-signed)
- Ingress for TLS termination

The application reads the secret word from the index page and sets it as an environment variable in the container.

## Clean Up

To destroy all resources created by this project:

```bash
terraform destroy -auto-approve
```

## Notes

- This project uses a self-signed TLS certificate for demonstration purposes. In a production environment, you would use a properly issued certificate from a trusted CA.
- The SECRET_WORD is hardcoded in the Kubernetes deployment. In a real-world scenario, you would extract it dynamically from the index page.
