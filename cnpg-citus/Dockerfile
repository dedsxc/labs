FROM ghcr.io/cloudnative-pg/postgresql:16.9-bookworm@sha256:cf18ae5bff664c2d3153f1696daf8a131e6b439690ddf16f7741a6fc6868cb03

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