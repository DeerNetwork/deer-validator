#!/bin/bash

install_depenencies()
{
	log_info "----------Apt update----------"
	apt-get update
	if [ $? -ne 0 ]; then
		log_err "Apt update failed"
		exit 1
	fi

	log_info "----------Install depenencies----------"
	apt-get install -y jq curl wget unzip zip moreutils
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	apt-get install -y docker-ce docker-ce-cli containerd.io dkms
	if [ $? -ne 0 ]; then
		log_err "Install depenencies failed"
		exit 1
	fi
	if [ "$USER" != "root" ]; then
		usermod -aG docker $USER
	fi

}

download_docker_images()
{
	log_info "----------Download docker images----------"
	local res=0

	docker pull $(get_docker_image chain)
	res=$(($?|$res))

	if [ $res -ne 0 ]; then
		log_err "----------Download docker images failed----------"
		exit 1
	fi
}


install()
{
	install_depenencies
	download_docker_images

	exit 0
}
