# Use the official CNPG standard image with valid tag
ARG PG_VERSION=16.6-34
FROM ghcr.io/cloudnative-pg/postgresql:${PG_VERSION}-bookworm

# Build stage for TimescaleDB compilation
FROM debian:bookworm-slim AS builder

ARG PG_MAJOR=16
ARG TIMESCALE_VERSION=2.17.2

# Add PGDG repository for PostgreSQL development packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        wget && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update

# Install build dependencies
RUN apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        postgresql-server-dev-${PG_MAJOR} \
        libssl-dev && \
    git clone https://github.com/timescale/timescaledb.git && \
    cd timescaledb && \
    git checkout ${TIMESCALE_VERSION} && \
    ./bootstrap && \
    make -C build && \
    make -C build install

# Final image
FROM ghcr.io/cloudnative-pg/postgresql:${PG_VERSION}-bookworm

ARG PG_MAJOR=16

# Copy TimescaleDB from builder
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/timescaledb*.so /usr/lib/postgresql/${PG_MAJOR}/lib/
COPY --from=builder /usr/share/postgresql/${PG_MAJOR}/extension/timescaledb* /usr/share/postgresql/${PG_MAJOR}/extension/

# Configure shared_preload_libraries and adjust user permissions
USER root
RUN echo "shared_preload_libraries = 'timescaledb'" >> /usr/share/postgresql/postgresql.conf.sample && \
    # Create user 1001 if it doesn't exist and make it part of postgres group
    groupmod -g 1001 postgres || true && \
    usermod -u 1001 postgres && \
    # Ensure correct ownership of PostgreSQL files
    chown -R 1001:1001 /var/lib/postgresql && \
    chown -R 1001:1001 /usr/lib/postgresql && \
    chown -R 1001:1001 /usr/share/postgresql

# Initialize extensions
USER 1001
COPY --chown=1001:1001 init-extensions.sh /docker-entrypoint-initdb.d/
RUN chmod 0755 /docker-entrypoint-initdb.d/init-extensions.sh