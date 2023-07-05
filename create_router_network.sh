#!/bin/bash

# namespaceを一旦削除
# ip netns --all delete

# namespaceを作成
ip netns add ns1
ip netns add ns2
ip netns add router

# vethを作成
ip link add ns1-veth0 type veth peer name gw-veth0
ip link add ns2-veth0 type veth peer name gw-veth1

# vethをnamespaceに所属させる
ip link set ns1-veth0 netns ns1
ip link set ns2-veth0 netns ns2
ip link set gw-veth0 netns router
ip link set gw-veth1 netns router

# vethインターフェイスを有効化
ip netns exec ns1 ip link set ns1-veth0 up
ip netns exec ns2 ip link set ns2-veth0 up
ip netns exec router ip link set gw-veth0 up
ip netns exec router ip link set gw-veth1 up

# IPアドレスを設定
ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0
ip netns exec router ip address add 192.0.2.254/24 dev gw-veth0

ip netns exec ns2 ip address add 198.51.100.1/24 dev ns2-veth0
ip netns exec router ip address add 198.51.100.254/24 dev gw-veth1

# ルーティング設定
ip netns exec ns1 ip route add default via 192.0.2.254
ip netns exec ns2 ip route add default via 198.51.100.254

# routerのipv4フォワードを有効化
# ip netns exec router sysctl net.ipv4.ip_forward=1

# ns1からns2にping
ip netns exec ns1 ping -c 3 198.51.100.1