FROM registry.inventec/proxy/library/ubuntu:20.04
LABEL MAINTAINER="GitLab Inc. <support@gitlab.com>"

SHELL ["/bin/sh", "-c"]

# Default to supporting utf-8
ENV LANG=C.UTF-8

# Install required packages
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
      busybox \
      ca-certificates \
      # openssh-server \
      tzdata \
      wget \
      perl \
      libperl5.30 \
    && rm -rf /var/lib/apt/lists/*

# Ref: https://askubuntu.com/questions/1189747/is-possible-to-upgrade-openssh-server-openssh-7-6p1-to-openssh-8-0p1/1259631#1259631
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
      build-essential \
      zlib1g-dev \
      libssl-dev \
    && mkdir /var/lib/sshd \
    && chmod -R 700 /var/lib/sshd \
    && chown -R root:sys /var/lib/sshd \
    && cd /tmp/ \
    && wget --quiet https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.9p1.tar.gz \
    && tar -xzf openssh-8.9p1.tar.gz \
    && cd openssh-8.9p1/ \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
      libpam0g-dev \
      libselinux1-dev \
      libkrb5-dev \
    && ./configure --with-kerberos5 --with-md5-passwords --with-pam --with-selinux --with-privsep-path=/var/lib/sshd --sysconfdir=/etc/ssh \
    && make && make install \
    && rm -rf /var/lib/apt/lists/*

# Use BusyBox
ENV EDITOR /bin/vi
RUN busybox --install \
    && { \
        echo '#!/bin/sh'; \
        echo '/bin/vi "$@"'; \
    } > /usr/local/bin/busybox-editor \
    && chmod +x /usr/local/bin/busybox-editor \
    && update-alternatives --install /usr/bin/editor editor /usr/local/bin/busybox-editor 1

# Remove MOTD
RUN rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic
RUN ln -fs /dev/null /run/motd.dynamic

# Copy assets
COPY RELEASE /
COPY assets/ /assets/
# as gitlab-ci checks out with mode 666 we need to set permissions of the files we copied into the
# container to a secure value. Issue #5956
RUN chmod -R og-w /assets RELEASE ; \
  /assets/setup

# Allow to access embedded tools
ENV PATH /opt/gitlab/embedded/bin:/opt/gitlab/bin:/assets:$PATH

# Resolve error: TERM environment variable not set.
ENV TERM xterm

# Expose web & ssh
EXPOSE 443 80 22

# Define data volumes
VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab"]

# Wrapper to handle signal, trigger runit and reconfigure GitLab
CMD ["/assets/wrapper"]

HEALTHCHECK --interval=60s --timeout=30s --retries=5 \
CMD /opt/gitlab/bin/gitlab-healthcheck --fail --max-time 10
