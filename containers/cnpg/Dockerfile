FROM ghcr.io/cloudnative-pg/postgresql:18-standard-trixie@sha256:7bf7c0aca91af85f2ab73bd727c90886299491272d305d5bf21df0f9ca4f1fb4

USER root 

# Install dependencies
RUN apt-get update && apt-get install -y curl pgcopydb

# Install percona-release
RUN curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
RUN apt install -y gnupg2 lsb-release ./percona-release_latest.generic_all.deb
RUN apt update

# Install pg_stat_monitor
RUN PG_MAJOR=$(ls /usr/lib/postgresql/ | head -n 1) && \
    percona-release setup ppg${PG_MAJOR} && \
    apt-get install -y percona-pg-stat-monitor${PG_MAJOR}

# # Clean up apt cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# # Add rights on /tmp to the postgres user
RUN chown -R postgres:postgres /tmp

USER postgres

