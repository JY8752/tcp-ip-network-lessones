#!/bin/bash

# namespaceを一旦削除
echo "delete all namespace"
ip --all netns delete

# namespaceを作成
echo "create namespace"
ip netns add server
ip netns add client

# vethを作成
echo "create veth"
ip link add s-veth0 type veth peer name c-veth0

# vethをnamespaceに所属させる
echo "set veth to namespace"
ip link set s-veth0 netns server
ip link set c-veth0 netns client

# vethインターフェイスを有効化
echo "set veth up"
ip netns exec server ip link set s-veth0 up
ip netns exec client ip link set c-veth0 up

# IPアドレスを設定
echo "set ip address"
ip netns exec server ip address add 192.0.2.254/24 dev s-veth0

# DHCPサーバを起動
echo "start dhcp server."
ip netns exec server dnsmasq \
    --dhcp-range=192.0.2.100,192.0.2.200,255.255.255.0 \
    --interface=s-veth0 \
    --port 0 \
    --no-daemon \
    --no-resolv
