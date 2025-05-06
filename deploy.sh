#!/bin/bash
set -e

# Check if IBM Cloud CLI is installed
if ! command -v ibmcloud &> /dev/null; then
  echo "IBM Cloud CLI not found. Installing..."
  curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
  echo "Terraform not found. Please install Terraform."
  exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker not found. Please install Docker."
  exit 1
fi

# Check if git is installed and initialize repository if requested
if [ "$1" == "--init-git" ]; then
  if ! command -v git &> /dev/null; then
    echo "Git not found. Please install Git."
    exit 1
  fi

  # Initialize git repository
  if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit"
  fi
fi

# Ask for IBM Cloud API Key if not set
if [ -z "$IBMCLOUD_API_KEY" ]; then
  read -p "Enter your IBM Cloud API Key: " IBMCLOUD_API_KEY
  export IBMCLOUD_API_KEY=$IBMCLOUD_API_KEY
fi

# Login to IBM Cloud
echo "Logging in to IBM Cloud..."
ibmcloud login --apikey $IBMCLOUD_API_KEY -r us-south

# Create a terraform.tfvars file
cat > terraform.tfvars << EOF
ibmcloud_api_key = "$IBMCLOUD_API_KEY"
region = "us-south"
resource_group = "app-resource-group"
cr_namespace = "app-namespace"
app_name = "node-app"
app_port = 8080
domain_name = "app.example.com"
EOF

# Build and tag the Docker image
echo "Building Docker image..."
docker build -t simple-app:latest .


echo "Logging in to Docker Registry..."
docker login

# Tag and push Docker image
echo "Tagging and pushing Docker image..."
docker tag node-app:latest gopi1806/simple-app:latest
docker push gopi1806/simple-app:latest

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Apply Terraform configuration
echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Get app URL
APP_URL=$(terraform output -raw app_url 2>/dev/null || echo "URL not available yet")

echo "Deployment completed!"

