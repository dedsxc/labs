FROM ghcr.io/cloudnative-pg/postgresql:16.10-bookworm@sha256:67a5da8a690c174ed30b5f9968ba809e74711b9327321ab811ab4948ef4d4476

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