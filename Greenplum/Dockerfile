#
#  Dockerfile for a GPDB Image
#
FROM centos/systemd:latest

# Argument
ARG GPDB_VERSION_FULL="4.3.25.1-rhel5-x86_64"
ARG GPDB_VERSION="4.3.25.1"
ARG GPCC_VERSION_FULL="3.3.2-LINUX-x86_64"
ARG GPCC_VERSION="3.3.2"

################################################################################
COPY bins/*.bin /tmp/
COPY configs /opt/configs/

################################################################################
#
# Default RPM
################################################################################
RUN echo root:inventec | chpasswd \
    && yum install -y net-tools which openssh-clients openssh-server less zip unzip iproute.x86_64 perl \
	&& chmod +x /tmp/*.bin \
    && sed -i s/"more << EOF"/"cat << EOF"/g /tmp/greenplum-db-${GPDB_VERSION_FULL}.bin \
    && echo -e "yes\n\nyes\nyes\n" | /tmp/greenplum-db-${GPDB_VERSION_FULL}.bin \
    && ln -s /usr/local/greenplum-db-${GPDB_VERSION} /usr/local/greenplum-db \
	&& sed -i s/"more << EOF"/"cat << EOF"/g /tmp/greenplum-cc-web-${GPCC_VERSION_FULL}.bin \
    && echo -e "yes\n\nyes\nyes\n" | /tmp/greenplum-cc-web-${GPCC_VERSION_FULL}.bin \
    && ln -s /usr/local/greenplum-cc-web-${GPCC_VERSION} /usr/local/greenplum-cc-web \
    && cat /opt/configs/sysctl.conf.add >> /etc/sysctl.conf \
    && cat /opt/configs/limits.conf.add >> /etc/security/limits.conf \
	&& cat /opt/configs/selinux_config >> /etc/selinux/config \
    && /usr/sbin/groupadd -g 530 gpadmin \
    && /usr/sbin/useradd -g 530 -u 530 -m -d /home/gpadmin -s /bin/bash gpadmin \
    && echo "gpadmin"|passwd --stdin gpadmin \
    && echo "gpadmin        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers \
    && mv /opt/configs/bash_profile /home/gpadmin/.bash_profile \
    && mv /opt/configs/pgpass /home/gpadmin/.pgpass \
	&& mkdir /home/gpadmin/conf \
	&& mv /opt/configs/gpinitsystem_config /home/gpadmin/conf/gpinitsystem_config \
	&& mv /opt/configs/hostlist /home/gpadmin/conf/hostlist \
	&& mv /opt/configs/seg_hosts /home/gpadmin/conf/seg_hosts \
	&& mv /opt/configs/entrypoint.sh /entrypoint.sh \
	&& chmod +x /entrypoint.sh \
    && chown -R gpadmin: /home/gpadmin \
	&& chmod 0600 /home/gpadmin/.pgpass \
    && chown -R gpadmin: /usr/local/green* \
    && chown -R gpadmin:gpadmin /usr/local/greenplum-db-${GPDB_VERSION} \
	&& chown -R gpadmin:gpadmin /usr/local/greenplum-cc-web-${GPCC_VERSION} \
	&& ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
	&& ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
	&& ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' \
	&& ssh-keygen -f /root/.ssh/id_rsa -N '' \
    && cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys \
    && mkdir -p /home/gpadmin/.ssh  \
    && cat /root/.ssh/id_rsa.pub >> /home/gpadmin/.ssh/authorized_keys \
    && cp /root/.ssh/id_rsa /root/.ssh/id_rsa.pub /home/gpadmin/.ssh/  \
    && chown gpadmin:gpadmin -R /home/gpadmin/.ssh \
    && rm -f /tmp/greenplum-db-${GPDB_VERSION_FULL}.bin \
	&& rm -f /tmp/greenplum-cc-web-${GPCC_VERSION_FULL}.bin \
    && yum clean all \
    && rm -rf /var/cache/yum
################################################################################
# Set the default command to run when starting the container
RUN  systemctl enable sshd.service

ENTRYPOINT ["/entrypoint.sh"]

# Default command
# CMD ["bin/bash"]
################################################################################
