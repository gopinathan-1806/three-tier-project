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

The application reads the secret word from the index page and sets it as an environment variable in the container.

## Clean Up

To destroy all resources created by this project:

```bash
terraform destroy -auto-approve
```
## Execution steps:

## Deploying a Node.js App on IBM Cloud Kubernetes

This project demonstrates how to deploy a simple Node.js web application on an IBM Cloud Kubernetes Service (IKS) cluster using Terraform and Docker. The application is containerized and made accessible via a LoadBalancer service.

1. Provisioned IBM Cloud Kubernetes Cluster
   A. Created a Kubernetes cluster using IBM Cloud Terraform provider.
   B. Configured the required VPC, subnets, worker pools, and cluster settings.
<img width="1312" alt="Screenshot 2025-05-06 at 11 27 28 PM" src="https://github.com/user-attachments/assets/7301e12a-ab95-4fc1-a5dd-8dc037307ef0" />

2. Developed a Simple Node.js Web Application
   A. Built a basic Express.js app (app.js) that responds with a greeting message.
   B. Included package.json and created a lightweight Dockerfile to containerize the app.
<img width="623" alt="Screenshot 2025-05-06 at 11 37 14 PM" src="https://github.com/user-attachments/assets/500038cc-e113-404b-8d75-5c3281ea1ac9" />

3. Containerized the Node.js Application
   A. Built the Docker image locally:
   B. Pushing the image to Docker HUB
<img width="1312" alt="Screenshot 2025-05-06 at 11 27 44 PM" src="https://github.com/user-attachments/assets/8a37bbee-fe80-470a-b04c-f794ea1dd6fb" />

4. Deployed to Kubernetes Cluster
   A. Created a Kubernetes Deployment manifest to deploy the image with 2 replicas.
   B. Defined a LoadBalancer type Service to expose the app externally.
<img width="826" alt="Screenshot 2025-05-06 at 11 29 42 PM" src="https://github.com/user-attachments/assets/40252caf-e13c-4069-bfda-2b8fc72d05fd" />


6. Accessed the Application via Load Balancer

<img width="1037" alt="Screenshot 2025-05-06 at 11 29 58 PM" src="https://github.com/user-attachments/assets/1120a1cd-2df5-414f-b043-9c8ba2009f82" />

7. URL for the application:
http://688116a8-us-south.lb.test.appdomain.cloud/

