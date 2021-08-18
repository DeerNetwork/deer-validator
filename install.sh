#!/bin/bash

basedir=$(cd `dirname $0`;pwd)
scriptdir=$basedir/scripts
installdir=/opt/deer

install_scripts()
{
	echo "----------Install deer----------"

	if [ -f /usr/bin/deer ]; then
		rm /usr/bin/deer
		rm -rf $installdir/scripts
	fi
	echo "Install deer data"
	mkdir -p $installdir
	if [ -f $installdir/config.json ]; then
		# cp $installdir/config.json $installdir/config.json.bak 
		# cp $basedir/config.json $installdir/
		sleep 0
	fi
	cp -r $basedir/scripts $installdir/scripts

	echo "Install deer command line tool"
	chmod +x $installdir/scripts/deer.sh
	ln -s $installdir/scripts/deer.sh /usr/bin/deer
	deer install 

	echo "----------Install success----------"
}

if [ $(id -u) -ne 0 ]; then
	echo "Please run with sudo!"
	exit 1
fi

install_scripts