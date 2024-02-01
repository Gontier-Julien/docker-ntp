FROM alpine:3.19

ARG BUILD_DATE

# first, a bit about this container
LABEL build_info="Gontier-Julien/docker-ntp build-date:- ${BUILD_DATE}"
LABEL fork_info="A fork of https://github.com/cturra/docker-ntp"  
LABEL maintainer="Gontier Julien <gontierjulien68@gmail.com>"
LABEL documentation="https://github.com/Gontier-Julien/docker-ntp"

# install chrony
RUN apk add --no-cache chrony tzdata

# script to configure/startup chrony (ntp)
COPY assets/startup.sh /opt/startup.sh

# ntp port
EXPOSE 123/udp

# let docker know how to test container health
HEALTHCHECK CMD chronyc -n tracking || exit 1

# start chronyd in the foreground
ENTRYPOINT [ "/bin/sh", "/opt/startup.sh" ]
