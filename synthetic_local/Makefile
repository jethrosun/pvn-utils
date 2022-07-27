container:
	docker build -t synthetic:alphine -f Dockerfile .

container-run:
	# docker run --rm -ti -v $(pwd):/data/tmp synthetic:alphine 1 2 
	# docker run --rm -ti -v /data/tmp:/data/tmp synthetic:alphine 1 2 
	docker run --rm -ti -v /data/tmp:/data \
		-v /home/jethros:/config \
		-v /home/jethros/dev/pvn/utils/workloads/udf:/tmp/udf \
		synthetic:alphine 1 2 
