

# Running backend services as containers

1. use docker stats to collect resource usage
2. use docker log container to collect logs
3. qos to regulate?


package another container for RDR only?

## commands

```bash
docker build -t synthetic:distroless -f Dockerfile .
# docker run --rm -ti -v $PWD:/data/tmp synthetic:distroless 1 2
docker run --rm -ti -v $(pwd):/data/tmp synthetic:distroless 1 2
```

## CMD vs ENTRYPOINT

https://stackoverflow.com/questions/64035402/is-it-possible-run-a-docker-container-multiple-times-with-different-arguments

https://stackoverflow.com/questions/30494050/how-do-i-pass-environment-variables-to-docker-containers

https://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile


## Make a Rut Docker image

https://kerkour.com/rust-small-docker-image

https://www.dataset.com/blog/create-docker-image/


## Read config file


https://matthewfeickert.github.io/intro-to-docker/04-file-io/index.html

https://stackoverflow.com/questions/52856353/docker-accessing-files-inside-container-from-host


## Log file to dir

https://www.baeldung.com/ops/docker-volumes

```bash
docker run -v $(pwd):/data/tmp bash:latest   bash -c "echo Hello > /data/tmp/file.txt"
```

https://docs.docker.com/config/containers/logging/configure/

https://stackoverflow.com/questions/33017329/where-is-a-log-file-with-logs-from-a-container

https://docs.docker.com/config/containers/logging/

---------------

https://sematext.com/guides/docker-logs/

https://www.papertrail.com/solution/tips/how-to-live-tail-docker-logs/

https://www.baeldung.com/ops/docker-logs

https://linuxhint.com/docker_logs_linux_tutorial/

https://www.howtogeek.com/devops/where-does-docker-keep-log-files/




{"1": "xcdr", "2": "rand1", "3": "rand2", "4": "rand4", "5": "rand3", "6": "tlsv", "7": "p2p", "8": "rdr"}
