build:
	docker build -t myubuntu .

run:
	docker run -it --rm --name myubuntu -d \
		-v `pwd`/create_router_network.sh:/tmp/create_router_network.sh \
		myubuntu
