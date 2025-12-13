# Build the image and and push it to Docker Hub
# Login to Docker Hub must be done in advance with docker login

$img = "haflandy/docker-duplicity"
$tag = Get-Date -Format "yyyyMMddHHmm"

& docker buildx build --no-cache -t ${img}:$tag .
& docker push ${img}:$tag
& docker image tag ${img}:$tag ${img}:latest
& docker push ${img}:latest
