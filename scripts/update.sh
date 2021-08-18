#!/bin/bash

update_help() 
{
cat << EOF
Usage:
	update scripts	update deer scripts
	update chain  	update deer chain
EOF
}


update_scripts()
{
	log_info "----------Update deer script----------"

	mkdir -p /tmp/deer
	wget https://github.com/DeerNetwork/deer-validator/archive/main.zip -O /tmp/deer/main.zip
	unzip /tmp/deer/main.zip -d /tmp/deer
	rm -rf /opt/deer/scripts
	cp -r /tmp/deer/deer-validator-main/scripts /opt/deer/scripts
	mv /opt/deer/scripts/deer.sh /usr/bin/deer
	chmod +x /usr/bin/deer
	chmod +x /opt/deer/scripts/*

	log_success "----------Update success----------"
	rm -rf /tmp/deer
}


update()
{
	case "$1" in
		scripts)
			update_scripts
			;;
		chain)
			exec_docker_pull chain
			;;
		*)
			update_help
			exit 1
	esac
}
