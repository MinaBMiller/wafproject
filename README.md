# AWS WAF Terraform Configuration for S3 Static Website

This repository contains Terraform code for deploying an AWS Web Application Firewall (WAF) designed to protect an S3 static website. The WAF includes both managed and custom rules to safeguard your static content from common web exploits and attacks.

## Structure

The configuration is split into two main files:

1. `main.tf`: Contains the core WAF configuration, including the web ACL, rule groups, and individual rules. It also includes the necessary resources to associate the WAF with an S3 static website.
2. `variables.tf`: Defines input variables used in the main configuration, allowing for easy customization.

## Features

### S3 Static Website Integration

This WAF configuration is specifically tailored to work with an S3 static website:

- It associates the WAF Web ACL with a CloudFront distribution that serves as a content delivery network (CDN) for your S3 static website.
- The configuration includes rules to protect static assets like HTML, CSS, JavaScript, and image files.

### AWS Managed Rules

This WAF configuration includes four AWS managed rule sets:

1. Amazon IP reputation list
2. Amazon anonymous IP list
3. AWS Core rule set (CRS)
4. Known bad inputs

These managed rules provide a baseline level of protection against common web exploits, particularly those relevant to static websites.

### Custom Rules

In addition to the managed rules, this configuration includes three custom rules:

1. Block requests from specific IP addresses
2. Rate limit requests based on IP
3. Geographic restriction to block traffic from specific countries

These custom rules are tailored to address specific security requirements or known threats to your S3 static website.

## Usage

To use this Terraform configuration:

1. Ensure you have Terraform installed and configured with your AWS credentials.
2. Clone this repository.
3. Review and modify the `variables.tf` file to customize the WAF configuration as needed.
5. Run `terraform init` to initialize the Terraform working directory.
6. Run `terraform plan` to preview the changes.
7. Run `terraform apply` to create the WAF and associate it with your CloudFront distribution.

## Customization

You can easily customize this WAF configuration by modifying the `variables.tf` file. This allows you to adjust rule priorities, action types, and other WAF parameters without changing the core logic in `main.tf`. Key variables for S3 static website protection include:

- `cloudfront_distribution_id`: The ID of your CloudFront distribution serving the S3 static website.
- `s3_bucket_name`: The name of your S3 bucket hosting the static website (used for logging purposes).
- `allowed_file_extensions`: A list of allowed file extensions for your static website.

## Maintenance

Regular updates to both managed and custom rules are recommended to ensure optimal protection against evolving threats. Review and update your custom rules periodically, and consider enabling auto-updates for AWS managed rules. Also, keep your S3 bucket policies and CloudFront settings aligned with your WAF rules for comprehensive security.