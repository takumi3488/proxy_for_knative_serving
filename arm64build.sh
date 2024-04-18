#!/bin/sh

tag=$(git show --format='%H' --no-patch)
repository=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
name="ghcr.io/$repository:$tag"
docker build -t $name .
if [ $1 = "-t" ]; then
  docker run -it --rm $name
else
    docker push $name
fi
