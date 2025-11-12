# syntax=docker/dockerfile:1

# --------------------------------
# Builder stage: compile pgvector
# --------------------------------
FROM postgres:16-bookworm AS builder

ARG PG_MAJOR=16
ARG PGVECTOR_VERSION=v0.7.4
ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        build-essential \
        postgresql-server-dev-${PG_MAJOR}; \
    rm -rf /var/lib/apt/lists/*

# Build and stage install into a temporary directory
RUN set -eux; \
    git clone --depth 1 --branch "${PGVECTOR_VERSION}" https://github.com/pgvector/pgvector.git /tmp/pgvector; \
    make -C /tmp/pgvector; \
    make -C /tmp/pgvector install DESTDIR=/tmp/install; \
    rm -rf /tmp/pgvector

# ----------------------------
# Final stage: runtime image
# ----------------------------
FROM postgres:16-bookworm

ARG PG_MAJOR=16

# Copy the compiled extension artifacts from the builder stage
COPY --from=builder /tmp/install/usr/lib/postgresql/${PG_MAJOR}/lib/vector.so /usr/lib/postgresql/${PG_MAJOR}/lib/
COPY --from=builder /tmp/install/usr/share/postgresql/${PG_MAJOR}/extension/ /usr/share/postgresql/${PG_MAJOR}/extension/

# Default credentials and database (can be overridden at runtime)
ENV POSTGRES_DB=lightrag \
    POSTGRES_USER=lightrag \
    POSTGRES_PASSWORD=lightrag

# Copy initialization scripts that run on first-time database init
# These scripts are executed only when the data directory is empty
COPY --chown=postgres:postgres db/init /docker-entrypoint-initdb.d

# Expose PostgreSQL port
EXPOSE 5432

# Inherit default entrypoint/cmd from base image
