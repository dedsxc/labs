# v17.7
FROM ghcr.io/cloudnative-pg/postgresql:18-standard-trixie@sha256:bbefe420af6ba639167cf6b5ea385a5a5816db47cfaa8c6b1fecc2c503b8df81

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
