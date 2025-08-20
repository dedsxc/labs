FROM ghcr.io/cloudnative-pg/postgresql:17.6-bookworm@sha256:3099c2dc4f7f23e62abf370bb9d693e81685244fe5479329cedebb51d2af2e6b

USER root 

# Install Citus extension
RUN apt-get update && apt-get install -y curl 
RUN curl https://install.citusdata.com/community/deb.sh | bash 
RUN CITUS_VERSION=$(apt-cache search postgresql-${PG_MAJOR}-citus | sort -r | head -n1 | awk '{print $1}') && \
    apt-get -y install ${CITUS_VERSION}

USER postgres

# No need for cloudnative-pg following 
# https://cloudnative-pg.io/documentation/1.23/container_images/
# CMD ["postgres"]