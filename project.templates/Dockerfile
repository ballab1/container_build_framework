ARG FROM_BASE=base_container:20180217
FROM $FROM_BASE


# version of this docker image
ARG CONTAINER_VERSION=1.0.0
LABEL version=$CONTAINER_VERSION 

# set to non zero for the framework to show verbose action scripts
ARG DEBUG_TRACE=0


# Add configuration and customizations
COPY build /tmp/

# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh 'newcontainer'
RUN rm -rf /tmp/* 


ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD ["newcontainer"]
