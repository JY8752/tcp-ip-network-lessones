build:
	@docker build -t myubuntu .

run:
	@docker run -it --rm --name myubuntu -d --privileged \
		-v `pwd`/create_router_network.sh:/tmp/create_router_network.sh \
		-v `pwd`/create_router_network2.sh:/tmp/create_router_network2.sh \
		-v `pwd`/bridge.sh:/tmp/bridge.sh \
		-v `pwd`/ethernet.sh:/tmp/ethernet.sh \
		-v `pwd`/dhcp.sh:/tmp/dhcp.sh \
		myubuntu
	@docker exec myubuntu chmod +x /tmp/create_router_network.sh
	@docker exec myubuntu chmod +x /tmp/create_router_network2.sh
	@docker exec myubuntu chmod +x /tmp/ethernet.sh
	@docker exec myubuntu chmod +x /tmp/bridge.sh
	@docker exec myubuntu chmod +x /tmp/dhcp.sh
