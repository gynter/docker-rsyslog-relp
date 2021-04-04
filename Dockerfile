#
# Docker RSyslog with RELP module support (https://github.com/gynter/docker-rsyslog-relp)
#
# See https://github.com/gynter/rsyslog-docker-compose-example for deployment example using Docker Compose.
#

# Use https://github.com/gynter/docker-rsyslog-alpine as base image.
FROM gynter/rsyslog:alpine

# Change user to root.
USER root

# Install RSyslog RELP module.
RUN apk update && \
    apk add --no-cache rsyslog-relp

# Create directory for TLS certificates and key.
RUN mkdir -p /etc/pki/rsyslog

# Copy configuration for RELP over TLS.
COPY 13-listen-relp-tls.conf /etc/rsyslog.d/

# Set permissions.
RUN chown -R root:1000 /etc/rsyslog.conf /etc/rsyslog.d /etc/pki/rsyslog; \
    chmod -R 0750 /etc/rsyslog.d /etc/pki/rsyslog; \
    find /etc/rsyslog.conf /etc/rsyslog.d/ /etc/pki/rsyslog -type f -exec chmod 0440 {} \;

# Change back to unprivileged user.
USER 1000:1000

# Expose RELP TLS port for incoming connections.
EXPOSE 2514/tcp

# Run rsyslogd in foreground with custom PID file path, since it's running under unprivileged user.
ENTRYPOINT [ "sh", "-c", "/usr/sbin/rsyslogd -n -i /srv/rsyslog/rsyslog.pid" ]
