#!/bin/bash

config_help()
{
cat << EOF
Usage:
	help			show help information
	show			show configurations
	set			set configurations
	network      		choose mainnet or testnet
EOF
}

config_show()
{
	cat $config_json | jq .
}

config_set_all()
{
	local node_name=""
	read -p "Enter node name: " node_name
	while [[ x"$node_name" =~ \ |\' || -z "$node_name" ]]; do
		read -p "The node name can't contain spaces, please re-enter：" node_name
	done
	node_name=`echo "$node_name"`
	jq '.nodename = "'$node_name'"' $config_json | sponge $config_json
	log_success "Set node name: '$node_name' successfully"

	local chain_data_dir=""
	read -p "Enter your chain_data_dir [/opt/deer/data/chain]: " chain_data_dir
	chain_data_dir=`echo "${chain_data_dir:-"/opt/deer/data/chain"}"`
	mkdir -p "$chain_data_dir" > /dev/null 2>&1
	if [[ ! -d "$chain_data_dir" ]]; then
		log_err "The chain_data_dir is invalid"
	fi
	jq '.chain_data_dir = "'$chain_data_dir'"' $config_json | sponge $config_json
	log_success "Set chain_data_dir: '$chain_data_dir' successfully"
}

config_set_network()
{
	local network=""
	read -p "Choose network: [mainnet|testnet] " network
	network=`echo "$network"`
	if [ x"$network" == x"mainnet" ] || [ x"$network" == x"testnet" ]; then
		jq '.network = "'$network'"' $config_json | sponge $config_json
	else
		log_err "Network must be mainnet or testnet"
		exit 1
	fi
	log_success "Set network: '$network' successfully"
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
		network)
			config_set_network
			;;
		*)
			config_help
	esac
}
