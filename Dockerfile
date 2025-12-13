FROM ubuntu:resolute

LABEL org.opencontainers.image.authors="Ralf Geschke <ralf@kuerbis.org>"

LABEL last_changed="2025-12-07"

# necessary to set default timezone Etc/UTC
ENV DEBIAN_FRONTEND=noninteractive 

# mostly taken from https://github.com/cjhardekopf/docker-duplicity/blob/master/Dockerfile

RUN apt-get update \
	&& apt-get -y dist-upgrade \
    && apt-get install -y --no-install-recommends locales \
    && sed -i 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen \
    && locale-gen \
    && apt-get install -y ca-certificates openssh-client \
    && apt-get -y install duplicity \
    && mkdir -p /var/log/duplicity

ENV LANG=en_US.utf8

COPY scripts/backup.sh /usr/local/bin/
COPY scripts/backup_sftp.sh /usr/local/bin/
COPY scripts/restore.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/*.sh

COPY scripts/entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["help"]
