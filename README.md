<!-- ![Banner](./docs/images/banner.png) -->

![AWS EKS Retail Store Diagram](./docs/images/aws%20eks%20retail%20store.png)

  <span> The architecture contains:VPC with public subnets EKS Cluster with managed node group Retail Store microservices deployed via Helm LoadBalancer exposing the UI publicly S3 bucket triggering Lambda on object upload CloudWatch logging integration</span>

  <strong>
  <h2>Repository Structure of folder that have undergone changes</h2>
  </strong>

  aws-retail-website/
│
├── terraform/project-bedrock/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── backend.tf
│   ├── grading.json
│   │
│   ├── vpc/
│   ├── eks/
│   ├── iam/
│   ├── logging/
│   └── s3-lambda/
│ 
│
├── src/
│   └── app/chart/ (Helm Configuration can be found here)
│       ├── Chart.yaml  
│       ├── values.yaml
│   └── app/cart/  
│   └── app/catlog/  
│   └── app/checkout/  
│   └── app/e2e/  
│   └── app/load-generator/  
│   └── app/misc/  
│   └── app/orders/  
│   └── app/ui/  
│ 
│
├── .github/workflows
│   └── terraform.yml
│ 
├── README.md


### Terraform
Infrastructure Provisioning
1. Terraform Initialization
-`terraform init`

2. Validate Configuration
-`terraform validate`

3. Apply Infrastructure
-`terraform apply -var-file="terraform.tfvars"`


 <strong>
  <h3>Backend Configuration (S3 + DynamoDB)</h3>
  </strong>

The Terraform remote backend uses:

##### S3 bucket for state storage

##### DynamoDB table for state locking

<strong> Example AWS CLI Commands Used</strong>
`Create S3 Bucket (for Terraform state)
aws s3api create-bucket --bucket bedrock-tf-state-yourid --region us-east-1`

<strong> Enable Versioning </strong>
`aws s3api put-bucket-versioning --bucket bedrock-tf-state-yourid --versioning-configuration Status=Enabled`

<strong> Create DynamoDB Table (State Lock)</strong>
`aws dynamodb create-table --table-name bedrock-tf-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region us-east-1`


### Connecting kubectl to EKS

After Terraform created the cluster:

```aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster```


Verify nodes:

`kubectl get nodes`


Expected output:
```STATUS = Ready```


### Helm Deployment

The existing Helm chart structure was used as-is.

No modifications were made to the chart templates.
The chart is located at:

`/src/app/chart`

###### Build Dependencies
`helm dependency build`

###### Install Application
`helm install retail-store`


### Exposing the UI to the Internet

By default, services were deployed as ClusterIP.

To expose the UI publicly, the following command was used:

`kubectl patch svc ui -p "{\"spec\": {\"type\": \"LoadBalancer\"}}"`


Verify:

`kubectl get svc ui`


###### Once the EXTERNAL-IP appeared, the application became accessible via:

http://<external-loadbalancer-url>

###### Live Application URL
http://checkthedocisumbitted.us-east-1.elb.amazonaws.com


#### S3 → Lambda Integration

The Terraform module provisions:

* S3 bucket for assets

* Lambda function

* IAM role for Lambda

* S3 event notification trigger

<center><strong>Flow:</center></strong>

<center><strong>Object uploaded to S3</center></strong> 

<center><strong> ↓ ↓ ↓</strong></center>

<center><strong>S3 triggers Lambda</center></strong> 
<center><strong>↓ ↓ ↓</center></strong>

<center><strong>Lambda processes file</center></strong>
<center><strong>↓ ↓ ↓</center></strong>

<center><strong>Logs written to CloudWatch</center></strong>

<br>


### Grading Requirements
Generate Infrastructure Output JSON

From Terraform root:

`terraform output -json > grading.json`


Commit this file to the repository root.

#### Grading Credentials

IAM User:
bedrock-dev-view

Access Key and Secret Key are provided separately for grading purposes.

<strong>⚠ These credentials are NOT committed to this repository.</strong>

Verification Commands

Check pods:

`kubectl get pods`


Check services:

`kubectl get svc`


Check logs:

`kubectl logs <pod-name>`

Cleanup Instructions

To avoid AWS charges:

`helm uninstall retail-store`
`terraform destroy -var-file="terraform.tfvars"`


## License
This project is a copy of the popular aws retail store.