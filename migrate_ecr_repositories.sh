#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Trap errors
trap 'echo "An error occurred. Exiting..."; exit 1' ERR

# Validate inputs
if [ -z "$SOURCE_AWS_PROFILE" ] || [ -z "$TARGET_AWS_PROFILE" ] || [ -z "$SOURCE_AWS_ACCOUNT" ] || [ -z "$TARGET_AWS_ACCOUNT" ] || [ -z "$SOURCE_REGION" ] || [ -z "$TARGET_REGION" ]; then
  echo "All environment variables must be set. Exiting..."
  exit 1
fi

# Retrieve the list of repositories in the source account
QUERY='repositories[].repositoryName'
repositories=$(aws ecr describe-repositories --profile "$SOURCE_AWS_PROFILE" --query $QUERY --output text)

# Docker login for both source and target ECR
aws --profile "$SOURCE_AWS_PROFILE" ecr get-login-password --region "$SOURCE_REGION" | docker login --username AWS --password-stdin "$SOURCE_AWS_ACCOUNT.dkr.ecr.$SOURCE_REGION.amazonaws.com"
aws --profile "$TARGET_AWS_PROFILE" ecr get-login-password --region "$TARGET_REGION" | docker login --username AWS --password-stdin "$TARGET_AWS_ACCOUNT.dkr.ecr.$TARGET_REGION.amazonaws.com"

process_repository() {
  repo=$1
  echo "Processing repository: $repo"

  if ! aws ecr describe-repositories --repository-names "$repo" --profile "$TARGET_AWS_PROFILE" &> /dev/null; then
    aws ecr create-repository --repository-name "$repo" --profile "$TARGET_AWS_PROFILE"
  fi

  image_tags=$(aws ecr list-images --repository-name "$repo" --region "$SOURCE_REGION" --profile "$SOURCE_AWS_PROFILE" --query 'imageIds[].imageTag' --output text)

  for tag in $image_tags; do
    echo "Copying image with tag: $tag"

    source_image="$SOURCE_AWS_ACCOUNT.dkr.ecr.$SOURCE_REGION.amazonaws.com/$repo:$tag"
    target_image="$TARGET_AWS_ACCOUNT.dkr.ecr.$TARGET_REGION.amazonaws.com/$repo:$tag"

    docker pull "$source_image"
    docker tag "$source_image" "$target_image"
    docker push "$target_image"
    docker rmi "$source_image"
    docker rmi "$target_image"
  done
}

# Start processing for each repository in the background
for repo in $repositories; do
  process_repository "$repo" &
done

# Wait for all background processes to complete
wait
