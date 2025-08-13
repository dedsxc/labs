FROM ghcr.io/cloudnative-pg/postgresql:17.5-bookworm@sha256:89e09df1966a124cd8e015d16f8e888809e5560a3df2900c91433f73176a0b2d

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