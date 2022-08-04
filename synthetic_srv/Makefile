# https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach
container:
	docker build -t \
		synthetic:alphine -f Dockerfile.alphine .

container-run:
	docker run --rm -ti --network=host \
		-v /data/tmp:/data \
		-v /home/jethros:/config \
		-v /home/jethros/dev/pvn/utils/workloads/udf:/tmp/udf \
		synthetic:alphine 1 2  

run:
	docker run --cpuset-cpus 1 --name synthetic_srv_1_2 \
			--rm -ti --network=host \
			-v /data/tmp:/data \
			-v /home/jethros:/config \
			-v /home/jethros/dev/pvn/utils/workloads/udf:/tmp/udf \
			synthetic:alphine 1 2 

test:
	docker build -t \
		synthetic:test -f Dockerfile .

test-run:
	docker run --rm -ti --network=host \
		-v /data/tmp:/data \
		-v /home/jethros:/config \
		-v /home/jethros/dev/pvn/utils/workloads/udf:/tmp/udf \
		synthetic:test 1 2  

bash:
	docker run --rm -ti  synthetic:alphine bash

# https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach
net:
	docker run --rm -p 7419:7419 --add-host host.docker.internal:host-gateway -it ubuntu:trusty bash

host:
	# export UID=$(id -u)
	# export GID=$(id -g)
	docker run --rm --network=host \
		-it ubuntu:trusty bash

net2:
	docker run -d --add-host host.docker.internal:host-gateway ubuntu:trusty bash
