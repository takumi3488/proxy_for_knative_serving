#!/bin/sh

tag=$(git show --format='%H' --no-patch)
repository=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
name="ghcr.io/$repository:$tag"
docker build -t $name .
docker push $name
