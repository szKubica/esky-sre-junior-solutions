#!/bin/bash

port=8080
healthcheck=false

display_usage() {
    echo "Usage: $0 [--port <value>] [--healthcheck] [-h]"
    echo "Options:"
    echo "  --port <value>    Allows specifying different port."
    echo "  --healthcheck     Check, if container is running."
    echo "  -h                      Display this help message"
}

parse_options() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --port)
                port="$2"
                shift
                ;;
            --healthcheck)
                healthcheck=true
                ;;
            -h|--help)
                display_usage
                exit 0
                ;;
            *)
                echo "Invalid option: $1" >&2
                display_usage >&2
                exit 1
                ;;
        esac
        shift
    done
}

parse_options "$@"

cleanup() {
	echo Stopping the container $(docker stop go_app)
}

echo "Building image"
docker build -t go_app_img .
echo "Image built successfully"

if [ "$(docker ps -aq -f name=go_app)" ]; then
    docker start go_app
		echo "Starting existing container with app on port $port"
else
    docker run -d --name go_app -p 8080:$port --network go_app_network go_app_img                                                                                                       
		echo "Running the container with app on port $port"
fi

if $healthcheck; then
	curl -i http://localhost:8080/health
fi

echo "App is accessible at http://localhost:8080/"

trap cleanup EXIT
