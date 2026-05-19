#!/bin/bash
aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS --password-stdin $ECR_REPO
docker push ${ECR_REPO}:${BUILD_NUMBER}