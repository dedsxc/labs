# v17.7
FROM ghcr.io/cloudnative-pg/postgresql:18-standard-trixie@sha256:f445b2f8e9b4b3b9a4df56d944c976a2d7eb9b50280f3a6986b0fc7c422f7f27

USER root 

# Install Citus extension
RUN apt-get update && apt-get install -y curl pgcopydb
RUN curl https://install.citusdata.com/community/deb.sh | bash 
RUN CITUS_VERSION=$(apt-cache search postgresql-${PG_MAJOR}-citus | sort -r | head -n1 | awk '{print $1}') && \
    apt-get -y install ${CITUS_VERSION}

# Add rights on /tmp to the postgres user
RUN chown -R postgres:postgres /tmp

USER postgres

# No need for cloudnative-pg following 
# https://cloudnative-pg.io/documentation/1.23/container_images/
# CMD ["postgres"]
