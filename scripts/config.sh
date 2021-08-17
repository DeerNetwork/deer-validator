#!/bin/bash

config_help()
{
cat << EOF
Usage:
	help			show help information
	show			show configurations
	set			set configurations
EOF
}

config_show()
{
	cat $installdir/config.json | jq .
}

config_set_all()
{
	line=2
	local node_name=""
	read -p "Enter node name: " node_name
	while [[ x"$node_name" =~ \ |\' || -z "$node_name" ]]; do
		read -p "The node name can't contain spaces, please re-enter：" node_name
	done
	node_name=`echo "$node_name"`
	sed -i "${line}c \\  \"nodename\": \"$node_name\"," $installdir/config.json &>/dev/null
	log_success "Set node name: '$node_name' successfully"

	line=$((line+1))
	local chain_data_dir=""
	read -p "Enter your chain_data_dir [/opt/nft360/data/chain]: " chain_data_dir
	chain_data_dir=`echo "${chain_data_dir:-"/opt/nft360/data/chain"}"`
	mkdir -p "$chain_data_dir" > /dev/null 2>&1
	if [[ ! -d "$chain_data_dir" ]]; then
		log_err "The chain_data_dir is invalid"
	fi
	sed -i "${line}c \\  \"chain_data_dir\": \"$chain_data_dir\"," $installdir/config.json &>/dev/null
	log_success "Set chain_data_dir: '$chain_data_dir' successfully"
}

config()
{
	case "$1" in
		show)
			config_show
			;;
		set)
			config_set_all
			;;
		*)
			config_help
	esac
}
