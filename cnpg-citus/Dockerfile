FROM ghcr.io/cloudnative-pg/postgresql:17.6-bookworm@sha256:4a0c526f86af3cd6c9256b3217ec1384d4435ba3c41ad0957e33627a68d5286a

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