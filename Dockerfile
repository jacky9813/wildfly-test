# syntax=docker/dockerfile:1-labs
# Specifying syntax for --checksum functionality in ADD command.

ARG WILDFLY_VERSION=28.0.1.Final
ARG WILDFLY_SHA256=6224d4b88a79d58c319bed5fb7b44f08de26d7111c68128732b24ae08074cbfd

# ============================================================================================
FROM alpine AS wildfly_downloader
ARG WILDFLY_VERSION
ARG WILDFLY_SHA256
ADD --checksum=sha256:${WILDFLY_SHA256} https://github.com/wildfly/wildfly/releases/download/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.tar.gz /
RUN tar -xC / -f /wildfly-${WILDFLY_VERSION}.tar.gz

# ============================================================================================
FROM openjdk:17-alpine AS wildfly_base
ARG WILDFLY_VERSION
# Create an user "wildfly" to avoid using root in container
RUN addgroup -S wildfly && \
    adduser -h /opt/wildfly -H -S -D -s /usr/sbin/nologin wildfly -G wildfly

# Install WildFly
COPY --from=wildfly_downloader --chown=wildfly:wildfly /wildfly-${WILDFLY_VERSION} /opt/wildfly-${WILDFLY_VERSION}
COPY --chown=wildfly:wildfly --chmod=700 ./wildfly/docker-entrypoint.sh /opt/wildfly-${WILDFLY_VERSION}/bin/
RUN ln -s /opt/wildfly-${WILDFLY_VERSION} /opt/wildfly && \
    chown -R wildfly:wildfly /opt/wildfly
ENV WILDFLY_HOME=/opt/wildfly
ENV PATH="$PATH:$WILDFLY_HOME/bin"
USER wildfly
WORKDIR /opt/wildfly

# WILDFLY_USERS
# A space separated user detail that will be generated in WildFly
# The format for each user is as follows "<USER>:<PASSWORD>" or "<USER>:<REALM>:<PASSWORD>"
# The default realm is "ManagementRealm"
ENV WILDFLY_USERS="admin:admin"
ENTRYPOINT ["/opt/wildfly/bin/docker-entrypoint.sh", "-b=0.0.0.0", "-bmanagement=0.0.0.0"]

# ============================================================================================
FROM maven:3-openjdk-17-slim AS builder
COPY ./pom.xml /build/
COPY ./src /build/src/
WORKDIR /build
RUN mvn package
# Expected war file output location: /build/target/helloworld.war

# ============================================================================================
FROM wildfly_base
COPY --from=builder --chown=wildfly /build/target/helloworld.war /opt/wildfly/standalone/deployments/
