#!/bin/bash

update_help() 
{
cat << EOF
Usage:
	update scripts	update nft360 scripts
	update chain  	update nft360 chain
EOF
}


update_scripts()
{
	log_info "----------Update nft360 script----------"

	mkdir -p /tmp/nft360
	wget https://github.com/nft360/nft360-validator/archive/main.zip -O /tmp/nft360/main.zip
	unzip /tmp/nft360/main.zip -d /tmp/nft360
	rm -rf /opt/nft360/scripts
	cp -r /tmp/nft360/nft360-validator-main/scripts /opt/nft360/scripts
	mv /opt/nft360/scripts/nft360.sh /usr/bin/nft360
	chmod +x /usr/bin/nft360
	chmod +x /opt/nft360/scripts/*

	log_success "----------Update success----------"
	rm -rf /tmp/nft360
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
