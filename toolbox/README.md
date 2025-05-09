- go profiling

```bash
docker run -it --rm --net host registry.inventec/infra/debugger /bin/bash
go tool pprof -http :{port} http://localhost:6060/debug/pprof/heap
```

- PG 备份

```bash
docker run -it --rm registry.inventec/infra/debugger pg_dump --version
```

- mat

```bash
docker run -it --rm -v $(pwd):/dump registry.inventec/infra/debugger \
    /opt/mat/ParseHeapDump.sh \
   /dump/<path/to/dump.hprof> org.eclipse.mat.api:top_components org.eclipse.mat.api:suspects org.eclipse.mat.api:overview
```

- smartctl

```bash
docker run -it --rm -v /dev:/dev --privileged registry.inventec/infra/debugger /smart_report.sh
```
