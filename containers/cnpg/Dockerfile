FROM ghcr.io/cloudnative-pg/postgresql:18-standard-trixie@sha256:81bad466fe006454482678c6c67a24c1e30454b519011e0196cba2e4c83e1e1a

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

