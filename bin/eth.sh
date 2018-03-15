#!/usr/bin/env bash

trap "exit" INT

if [[ -f $(which ec2metadata 2>/dev/null) ]]
then
	# If ec2 instance then get ips from ec2metadata
	LOCALIP=$(ec2metadata --local-ipv4)
	IP=$(ec2metadata --public-ipv4)
else
	# Else get IPs from ifconfig and dig
	LOCALIP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}' | cut -d':' -f2)
	IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
fi

echo "Local IP: $LOCALIP"
echo "Public IP: $IP"

if [[ -f $(which geth 2>/dev/null) ]]
then
	echo "Starting geth"
	echo geth --datadir ./node --rpc --bootnodes "enode://fc56b90c08a529abfcd0108cef2c1fb6ec3c40494b6c5c058061c32191bf60058b1d68f9796e099c424aa6ad46025bfe1603c765416590464e54bd073868ce0a@$(ec2metadata --public-ipv4):80" --nat "extip:$(ec2metadata --public-ipv4)"
	geth --datadir ./node --rpc --bootnodes "enode://fc56b90c08a529abfcd0108cef2c1fb6ec3c40494b6c5c058061c32191bf60058b1d68f9796e099c424aa6ad46025bfe1603c765416590464e54bd073868ce0a@$(ec2metadata --public-ipv4):80" --nat "extip:$(ec2metadata --public-ipv4)"

elif [[ -f $(which eth 2>/dev/null) ]]
then
	echo "Starting eth"
	echo eth --bootstrap --peers 50 --remote 52.16.188.185:30303 --mining off --json-rpc -v 3 --public-ip $IP --listen-ip $LOCALIP --master $1
	eth --bootstrap --peers 50 --remote 52.16.188.185:30303 --mining off --json-rpc -v 3 --public-ip $IP --listen-ip $LOCALIP --master $1

else
	echo "Ethereum was not found!"
	exit 1;
fi