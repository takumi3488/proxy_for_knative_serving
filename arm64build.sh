#!/bin/sh

tag=$(git show --format='%H' --no-patch)
repository=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
name="ghcr.io/$repository:$tag"
docker build --platform linux/arm64 -t $name .
if [ $1 = "-t" ]; then
  docker run -it --rm $name
else
    docker push $name
fi
