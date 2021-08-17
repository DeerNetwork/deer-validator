#!/bin/bash
service_images=( 
	"chain:nft360/nft360"
)


echo_c()
{
	printf "\033[0;$1m$2\033[0m\n"
}

log_info()
{
	echo_c 33 "$1"
}

log_success()
{
	echo_c 32 "$1"
}

log_err()
{
	echo_c 35 "$1"
}

check_docker_status()
{
	local exist=`docker inspect --format '{{.State.Running}}' $1 2>/dev/null`
	if [ x"${exist}" == x"true" ]; then
		echo "running"
	elif [ "${exist}" == "false" ]; then
		echo "exited"
	else
		echo "missed"
	fi
}

get_docker_image() {
	for item in "${service_images[@]}" ; do
		name="${item%%:*}"
		if [ "$name" = "$1" ]; then
			echo "${item##*:}"
		fi
	done
}

exist_service() {
	image=$(get_docker_image $1)
	if [ -z "$image" ]; then
		log_err "----------Unknown service $1----------"
		exit 1
	fi
}

exec_docker_log() {
	exist_service $1
	log_info "----------Log $1----------"
	docker logs $1
}

exec_docker_pull() {
	exist_service $1
	image=$(get_docker_image $1)
	docker pull $image
}

exec_docker_stop() {
	exist_service $1
	log_info "----------Stop $1----------"
	docker stop $1
}

exec_docker_rm() {
	exist_service $1
	log_info "----------Remove $1----------"
	local status=$(check_docker_status $1)
	if  [ "$status" != "missed" ]; then
		docker rm -f $1
	fi
}

exec_docker_rmi() {
	exec_docker_rm
	log_info "----------Remove image $1----------"
	docker rmi -f $1
}

batch_exec() {
	for item in "${service_images[@]}" ; do
		eval $1 "${item%%:*}"
	done
}