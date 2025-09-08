FROM ghcr.io/cloudnative-pg/postgresql:17.6-bookworm@sha256:f785551be35036d65a0f1ebe71995022d261a829391fc2f14222ca19795d7c20

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