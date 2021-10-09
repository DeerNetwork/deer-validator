#!/bin/bash

installdir=/opt/deer
scriptdir=$installdir/scripts
config_json=$installdir/config.json

source $scriptdir/utils.sh
source $scriptdir/config.sh
source $scriptdir/update.sh
source $scriptdir/install_deer.sh

help()
{
cat << EOF
Usage:
	help				show help information
	install				install your deer services
	uninstall      			uninstall your deer scripts
	start 				start your deer services
	stop 				use docker kill to stop module
	restart 			restart deer services
	rotate-key 			rotate session keys
	config				configure your deer 
	network	{mainnet|testnet}	choose network
	status				display the running status of all components
	update {scripts|chain} 		update deer
	logs 				show services logs
EOF
exit 0
}

check_before_start() {
	local status=$(check_docker_status $1)
	if [ "$status" = "running" ]; then
		log_info "---------Service $1 is running----------"
		return 1
	elif [ "$status" = "exited" ]; then
		exec_docker_rm $1
	fi
	return 0
}

start_chain()
{
	check_before_start chain
	if [ $? -eq 1 ]; then
		return
	fi
	log_info "---------Start chain----------"
	local node_name=$(cat $config_json | jq -r '.nodename')
	if [ -z $node_name ]; then
		config_set_all
		local node_name=$(cat $config_json | jq -r '.nodename')
	fi

	log_info "your node name:$node_name"

	if [ ! -z $(docker ps -qf "name=chain") ]; then
		log_info "---------chain already exists----------"
		exit 0
	fi

	local chain_data_dir=$(cat $config_json | jq -r '.chain_data_dir')
	local chain_args=$(cat $config_json | jq -r '.chain_args')
	local network=$(cat $config_json | jq -r '.network')
	docker run -d --net host --name chain -e NODE_NAME=$node_name -v $chain_data_dir:/root/data $(get_docker_image chain) \
		$chain_args --chain $network --name $node_name --base-path /root/data --validator --pruning archive \
		--port 30666 --rpc-port 9933 --ws-port 9944 --wasm-execution compiled --in-peers 75 --out-peers 75 
	if [ $? -ne 0 ]; then
		log_err "----------Start chain failed-------------"
		exit 1
	fi
}

set_network() {
	network=$1
	if [ x"$network" == x"mainnet" ] || [ x"$network" == x"testnet" ]; then
		jq '.network = "'$network'"' $config_json | sponge $config_json
	else
		log_err "Network must be mainnet or testnet"
		exit 1
	fi
	log_success "Set network: '$network' successfully"
}


chain_status()
{
	local node_block=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://localhost:9933 | jq '.result.currentBlock')
	node_status=$(check_docker_status chain)

	cat << EOF
chain is ${node_status}, current block is ${node_block}
EOF
}


case "$1" in
	install)
		install $2
		;;
	config)
		config $2
		;;
	network)
		set_network $2
		;;
	start)
		start_chain
		;;
	restart)
		exec_docker_rm chain
		start_chain
		;;
	stop)
		exec_docker_stop chain
		;;
	status)
		chain_status
		;;
	rotate-key)
		curl -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}' http://localhost:9933
		;;
	update)
		shift 1
		update $@
		;;
	logs)
		exec_docker_log chain
		;;
	uninstall)
		uninstall
		;;
	*)
		help
		;;
esac

exit 0
