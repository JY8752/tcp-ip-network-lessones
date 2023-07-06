#!/bin/bash

# namespaceを一旦削除
ip --all netns delete

# namespaceを作成
ip netns add lan
ip netns add router
ip netns add wan

# vethを作成
ip link add lan-veth0 type veth peer name gw-veth0
ip link add wan-veth0 type veth peer name gw-veth1

# vethをnamespaceに所属させる
ip link set lan-veth0 netns lan
ip link set wan-veth0 netns wan
ip link set gw-veth0 netns router
ip link set gw-veth1 netns router

# vethインターフェイスを有効化
ip netns exec lan ip link set lan-veth0 up
ip netns exec wan ip link set wan-veth0 up
ip netns exec router ip link set gw-veth0 up
ip netns exec router ip link set gw-veth1 up

# routerのIPアドレスを設定
ip netns exec router ip address add 192.0.2.254/24 dev gw-veth0
ip netns exec router ip address add 203.0.113.254/24 dev gw-veth1

# lanのIPアドレスとルートを設定
ip netns exec lan ip address add 192.0.2.1/24 dev lan-veth0
ip netns exec lan ip route add default via 192.0.2.254

# wanのIPアドレスとルートを設定
ip netns exec wan ip address add 203.0.113.1/24 dev wan-veth0
ip netns exec wan ip route add default via 203.0.113.254

# iptablesにNATのルールを追加する
ip netns exec router iptables \
    -t nat \
    -A POSTROUTING \
    -s 192.0.2.0/24 \
    -o gw-veth1 \
    -j MASQUERADE

ip netns exec router iptables \
    -A POSTROUTING \
    -p tcp \
    --dport 54321 \
    -d 203.0.113.254 \
    -j DNAT \
    --to-destination 192.0.2.1