ARG PG_MAJOR=10

FROM postgres:$PG_MAJOR
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG PG_MAJOR
ARG PGHOME=/home/postgres

RUN set -ex \
    && export DEBIAN_FRONTEND=noninteractive \
    && echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01norecommend \
    && apt-get update -y \
    && apt-cache depends patroni | sed -n -e 's/.* Depends: \(python3-.\+\)$/\1/p' \
            | grep -Ev '^python3-(sphinx|etcd|consul|kazoo|kubernetes)' \
            | xargs apt-get install -y vim-tiny less curl jq locales \
                            python3-pip python3-wheel net-tools pigz \
    # && pip3 install pip --upgrade \
    ## Make sure we have a en_US.UTF-8 locale available
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && pip3 install setuptools \
    && pip3 install psycopg2-binary \
    && pip3 install patroni[etcd] \
    && mkdir -p $PGHOME/data /data $PGHOME/.config/patroni \
    && chown -R postgres:postgres $PGHOME /data /run /var/log \
    && sed -i "s|/var/lib/postgresql.*|$PGHOME:/bin/bash|" /etc/passwd \
    && apt-get purge -y python3-pip python3-wheel \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /root/.cache

WORKDIR $PGHOME
COPY patronictl.yml ./.config/patroni/patronictl.yaml
COPY entrypoint.sh .
RUN chown -R postgres:postgres $PGHOME \
    && chmod -R 700 $PGHOME/data

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PGDATA=$PGHOME/data \
    PGBIN=/usr/lib/postgresql/$PG_MAJOR/bin

USER postgres
EXPOSE 5432 8008
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
