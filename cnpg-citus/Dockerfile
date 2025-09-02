FROM ghcr.io/cloudnative-pg/postgresql:17.6-bookworm@sha256:184f7535266f17ba0c7afc55bce137ee03b1685a8d79cdc9800f0506a96799f7

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