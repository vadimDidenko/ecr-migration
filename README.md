# AWS ECR Repository Migrator

## Overview

This script automates the process of transferring all Docker images from one AWS ECR repository to another. Each repository is processed in a separate thread to improve performance.

## Prerequisites

- AWS CLI installed and configured
- Docker installed
- Bash environment

## Setup

### Environment Variables

Before running the script, make sure to set the following environment variables:

- `SOURCE_AWS_PROFILE`: The AWS profile for the source account
- `TARGET_AWS_PROFILE`: The AWS profile for the target account
- `SOURCE_AWS_ACCOUNT`: The AWS account ID for the source account
- `TARGET_AWS_ACCOUNT`: The AWS account ID for the target account
- `SOURCE_REGION`: The AWS region of the source ECR repositories
- `TARGET_REGION`: The AWS region of the target ECR repositories

You can set these variables in your session using `export` command:

```bash
export SOURCE_AWS_PROFILE="source_profile"
export TARGET_AWS_PROFILE="target_profile"
export SOURCE_AWS_ACCOUNT="source_account_id"
export TARGET_AWS_ACCOUNT="target_account_id"
export SOURCE_REGION="source_region"
export TARGET_REGION="target_region"
```

Or, you can provide them inline when running the script:

```bash
SOURCE_AWS_PROFILE="source_profile" TARGET_AWS_PROFILE="target_profile" SOURCE_AWS_ACCOUNT="source_account_id" TARGET_AWS_ACCOUNT="target_account_id" SOURCE_REGION="source_region" TARGET_REGION="target_region" ./script.sh
```

### Script File

Save the provided script as `migrate_ecr_repositories.sh` and give it execute permission:

```bash
chmod +x migrate_ecr_repositories.sh
```

## Usage

Run the script:

```bash
./migrate_ecr_repositories.sh
```

The script will:

1. Retrieve a list of all repositories in the source AWS ECR.
2. Authenticate Docker to both source and target AWS ECRs.
3. Loop through each repository, create it in the target ECR if it doesn't exist, and copy all images.

---

Feel free to add this README.md to your repository to guide users through the process of setting up and using the script.