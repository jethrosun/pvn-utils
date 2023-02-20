# https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach
container:
	docker build -t \
		synthetic:alphine -f Dockerfile.alphine .


container-run:
	docker run --rm -ti --network=host \
		-v /home/jethros/dev/pvn/utils/data:/udf_data \
		-v /data/tmp:/data \
		-v /home/jethros:/config \
		-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
		-v /home/jethros/dev/pvn/workload/udf_workload/contention:/udf_workload \
		-v /home/jethros/dev/pvn/workload/output:/udf \
		synthetic:alphine 1 1 3 0


