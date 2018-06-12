ARG FROM_BASE=alpine:3.7
FROM $FROM_BASE

# name and version of this docker image
ARG CONTAINER_NAME=container_build_framework
ARG CONTAINER_VERSION=1.0.0

LABEL org_name=$CONTAINER_NAME \
      version=$CONTAINER_VERSION

# Specify CBF version to use with our configuration and customizations
ARG CBF_VERSION=${CBF_VERSION:-v3.0}
# include our project files
COPY build /tmp/
# set to non zero for the framework to show verbose action scripts
#    (0:default, 1:trace & do not cleanup; 2:continue after errors)
ENV DEBUG_TRACE=0


# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh "$CONTAINER_NAME"
RUN [ $DEBUG_TRACE != 0 ] || rm -rf /tmp/*


ENTRYPOINT [ "docker-entrypoint.sh" ]
#CMD ["$CONTAINER_NAME"]
CMD ["container_build_framework"]
