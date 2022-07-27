# https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach
container:
	# export UID=$(id -u)
	# export GID=$(id -g)
	# docker build --build-arg USER=$USER \
	# 	     --build-arg UID=$UID \
	# 	     --build-arg GID=$GID \
	# 	     --build-arg PW=docker \
	# 	     -t synthetic:alphine -f Dockerfile .
	docker build -t \
		synthetic:alphine -f Dockerfile .

container-run:
	# docker run --rm -ti -v $(pwd):/data/tmp synthetic:alphine 1 2 
	# docker run --rm -ti -v /data/tmp:/data/tmp synthetic:alphine 1 2 
	
	# docker run --rm -ti --add-host host.docker.internal:host-gateway \
	# docker run --rm --network=host -ti \
	docker run --rm -ti \
		-v /data/tmp:/data \
		-v /home/jethros:/config \
		-v /home/jethros/dev/pvn/utils/workloads/udf:/tmp/udf \
		synthetic:alphine 1 2 

test:
	docker run --rm -ti  synthetic:alphine bash

# https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach
net:
	docker run --rm -p 7419:7419 --add-host host.docker.internal:host-gateway -it ubuntu:trusty bash

host:
	export UID=$(id -u)
	export GID=$(id -g)
	docker run --rm --network=host     --user $UID:$GID \
		-it ubuntu:trusty bash

net2:
	docker run -d --add-host host.docker.internal:host-gateway ubuntu:trusty bash
