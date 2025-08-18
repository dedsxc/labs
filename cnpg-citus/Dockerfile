FROM ghcr.io/cloudnative-pg/postgresql:17.6-bookworm@sha256:3099c2dc4f7f23e62abf370bb9d693e81685244fe5479329cedebb51d2af2e6b

USER root 

ENV PG_MAJOR=16

# Install Citus extension
RUN apt-get update && \
    apt-get install -y curl && \
    curl https://install.citusdata.com/community/deb.sh | bash && \
    apt-get -y install postgresql-${PG_MAJOR}-citus-12.1

USER postgres

# No need for cloudnative-pg following 
# https://cloudnative-pg.io/documentation/1.23/container_images/
# CMD ["postgres"]