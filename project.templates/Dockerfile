FROM base_container:20180217

# name and version of this docker image
ARG CONTAINER_NAME=NewContainer
ARG CONTAINER_VERSION=1.0.0

LABEL org_name=$CONTAINER_NAME
LABEL version=$CONTAINER_VERSION 

# set to non zero for the framework to show verbose action scripts
ARG DEBUG_TRACE=0


# Add configuration and customizations
COPY build /tmp/

# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh "$CONTAINER_NAME"
RUN [[ $DEBUG_TRACE == 0 ]] && rm -rf /tmp/* 


ENTRYPOINT [ "docker-entrypoint.sh" ]
#CMD ["$CONTAINER_NAME"]
CMD ["NewContainer"]
