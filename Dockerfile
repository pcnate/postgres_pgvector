# syntax=docker/dockerfile:1

# --------------------------------------------
# Builder stage: compile pgvector and AGE
# --------------------------------------------
FROM postgres:17-trixie AS builder

ARG PG_MAJOR=17
ARG PGVECTOR_VERSION=v0.7.4
ARG AGE_VERSION=PG17/v1.6.0-rc0
ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        build-essential \
        postgresql-server-dev-${PG_MAJOR} \
        bison \
        flex; \
    rm -rf /var/lib/apt/lists/*

# Build and stage install pgvector into a temporary directory
# Use OPTFLAGS to ensure compatibility with GitHub Actions runners
RUN set -eux; \
    git clone --depth 1 --branch "${PGVECTOR_VERSION}" https://github.com/pgvector/pgvector.git /tmp/pgvector; \
    make -C /tmp/pgvector OPTFLAGS="-O3 -march=x86-64 -msse4.2"; \
    make -C /tmp/pgvector install DESTDIR=/tmp/install; \
    rm -rf /tmp/pgvector

# Build and stage install AGE into the same temporary directory
RUN set -eux; \
    git clone --depth 1 --branch "${AGE_VERSION}" https://github.com/apache/age.git /tmp/age; \
    make -C /tmp/age install DESTDIR=/tmp/install; \
    rm -rf /tmp/age

# ----------------------------
# Final stage: runtime image
# ----------------------------
FROM postgres:17-trixie

ARG PG_MAJOR=17

# Copy the compiled extension artifacts from the builder stage (pgvector)
COPY --from=builder /tmp/install/usr/lib/postgresql/${PG_MAJOR}/lib/vector.so /usr/lib/postgresql/${PG_MAJOR}/lib/
COPY --from=builder /tmp/install/usr/share/postgresql/${PG_MAJOR}/extension/vector* /usr/share/postgresql/${PG_MAJOR}/extension/

# Copy AGE extension artifacts from the builder stage
COPY --from=builder /tmp/install/usr/lib/postgresql/${PG_MAJOR}/lib/age.so /usr/lib/postgresql/${PG_MAJOR}/lib/
COPY --from=builder /tmp/install/usr/share/postgresql/${PG_MAJOR}/extension/age* /usr/share/postgresql/${PG_MAJOR}/extension/

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
