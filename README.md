# 🖼️ Serverless Image Optimization Platform 

A fully serverless image processing pipeline built with AWS services, written in Go, and managed using Terraform. Users can upload images, which are automatically optimized (e.g. resized or converted to WebP) and delivered globally via signed CloudFront URLs.

---

![alt text](<image/image optimiser.png>)

## 🚀 Features

- Upload images via API Gateway
- Store original + optimized images in S3
- Optimize and convert images using Go Lambdas
- Track image status via DynamoDB
- Generate signed CloudFront URLs for secure access
- Fully serverless & infrastructure-as-code (Terraform)
- frontend in React hosted via S3
