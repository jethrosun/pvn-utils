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
		synthetic:alphine 1 1 3

# docker run --rm -ti --network=host \
#         -v /home/jethros/dev/pvn/utils/data:/udf_data \
#         -v /data/tmp:/data \
#         -v /home/jethros:/config \
#         -v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
#         -v /home/jethros/dev/pvn/workload/udf_workload/contention:/udf_workload \
#         -v /home/jethros/dev/pvn/workload/output:/udf \
#         synthetic:alphine 1 1 3
# Parsing 3 args
# ["/usr/local/bin/synthetic_srv", "1", "1", "3"]
# node id 1, core id 3, profile id 1 // name "xcdr"
# DEBUG: workload path is "/udf_workload/udf_profile1_node1_core3.json"
# thread 'main' panicked at 'file should open read only: Os { code: 2, kind: NotFound, message: "No such file or directory" }', src/udf.rs:61:38
# note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
# Makefile:8: recipe for target 'container-run' failed
# make: *** [container-run] Error 101

