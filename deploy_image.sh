
CONTAINER_NAME=$1
CONTAINER_PORT=$2
DOCKER_HUB_REPOSITORY=$3
DOCKER_HUB_IMAGE=$4
TAG=$5

docker run -d --name $CONTAINER_NAME -p $CONTAINER_PORT:80 $DOCKER_HUB_REPOSITORY/$DOCKER_HUB_IMAGE:$TAG