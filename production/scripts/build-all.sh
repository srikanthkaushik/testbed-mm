#!/usr/bin/env bash
# Build Docker images for all 4 Spring Boot services and push to ECR.
# Run from the repository root after `mvn clean package -DskipTests`.
#
# Usage: bash production/scripts/build-all.sh [image-tag]
#   image-tag defaults to the short git commit SHA.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TAG="${1:-$(git -C "$REPO_ROOT" rev-parse --short HEAD)}"
ECR_BASE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/mmucc"

SERVICES=(auth-service crash-service reference-service report-service)

echo "Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
    docker login --username AWS --password-stdin \
    "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Building images with tag: $TAG"

for SERVICE in "${SERVICES[@]}"; do
    JAR_PATH="$REPO_ROOT/backend/$SERVICE/target/$SERVICE-*.jar"
    # shellcheck disable=SC2086
    JAR=$(ls $JAR_PATH 2>/dev/null | head -1)
    if [[ -z "$JAR" ]]; then
        echo "ERROR: JAR not found for $SERVICE — run 'mvn clean package -DskipTests' first"
        exit 1
    fi

    echo "--- Building $SERVICE from $(basename "$JAR") ---"
    docker build \
        --build-arg JAR_FILE="$(basename "$JAR")" \
        -t "$ECR_BASE/$SERVICE:$TAG" \
        -t "$ECR_BASE/$SERVICE:latest" \
        -f "$REPO_ROOT/backend/$SERVICE/Dockerfile" \
        "$REPO_ROOT/backend/$SERVICE/target/"

    echo "--- Pushing $SERVICE ---"
    docker push "$ECR_BASE/$SERVICE:$TAG"
    docker push "$ECR_BASE/$SERVICE:latest"
done

echo "All images pushed with tag: $TAG"
echo "Update IMAGE_TAG=$TAG in /opt/mmucc/app/.env on EC2, then run: docker compose pull && docker compose up -d"
