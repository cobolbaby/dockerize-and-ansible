#　https://github.com/tianon/docker-postgres-upgrade/blob/master/12-to-16/Dockerfile

ARG OLD_VERSION
ARG NEW_VERSION

FROM registry.inventec/infra/postgres:${NEW_VERSION}
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG OLD_VERSION

USER root

RUN sed -i 's/$/ 12/' /etc/apt/sources.list.d/pgdg.list

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		# postgresql-12='12.18-1.pgdg120+2' \
		postgresql-12 \
	; \
	rm -rf /var/lib/apt/lists/*

ENV PGBINOLD /usr/lib/postgresql/${OLD_VERSION}/bin
ENV PGBINNEW /usr/lib/postgresql/${PG_MAJOR}/bin

ENV PGDATAOLD /var/lib/postgresql/${OLD_VERSION}/data
ENV PGDATANEW /var/lib/postgresql/${PG_MAJOR}/data

RUN set -eux; \
	mkdir -p "$PGDATAOLD" "$PGDATANEW"; \
	chown -R postgres:postgres /var/lib/postgresql

USER postgres

WORKDIR /var/lib/postgresql

COPY docker-upgrade /usr/local/bin/

ENTRYPOINT ["docker-upgrade"]

# recommended: --link
CMD ["pg_upgrade"]
