This project contains Terraform configurations to deploy and manage AWS WAF (Web Application Firewall) resources. AWS WAF helps protect your web applications from common web exploits that could affect application availability, compromise security, or consume excessive resources.

If you wish to deploy this in your own environment you will need

Terraform (v1.0+)
AWS CLI configured with appropriate credentials
Basic understanding of AWS WAF and Terraform

To deploy the AWS WAF resources:

Initialize Terraform:
Copyterraform init

Preview the changes:
Copyterraform plan

Apply the changes:
Copyterraform apply

To destroy the resources:
Copyterraform destroy