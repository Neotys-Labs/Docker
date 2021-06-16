#Be carefull openshift change the ID of the user on the fly. But this user is always in root group.

FROM alpine:3.13.5 as builder

ARG LIBERICA_URL=https://download.bell-sw.com/java/11.0.8+10/bellsoft-jre11.0.8+10-linux-x64-musl.tar.gz
ARG LIBERICA_PATCH=https://github.com/Neotys-Labs/jre-patch-neoload/archive/refs/tags/jre-patch-11.0.8+10.tar.gz


ENV NL_VERSION=7.10
ARG URL=https://www.neotys.com/redirect/redirect.php?product=neoload_loadgenerator&target=direct-download&os=linux&version=${NL_VERSION}&format=tar.gz

WORKDIR /tmp/
RUN wget $LIBERICA_URL
RUN wget $LIBERICA_PATCH

RUN mkdir /neoload/
RUN wget ${URL} -O - |  tar -xz --strip-components=1 -C /neoload/
RUN rm -rf /neoload/doc \
	   /neoload/jre/*

RUN tar -xzf /tmp/bellsoft-jre*.tar.gz --strip-components=1 -C /neoload/jre
RUN tar -xzf /tmp/jre-patch*.tar.gz --strip-components=2 -C /neoload/jre
RUN rm -rf /neoload/jre/*src.zip \
           /neoload/jre/lib/missioncontrol \
           /neoload/jre/lib/visualvm \
           /neoload/jre/lib/*javafx* \
           /neoload/jre/plugin \
           /neoload/jre/bin/javaws \
           /neoload/jre/bin/jjs \
           /neoload/jre/bin/orbd \
           /neoload/jre/bin/pack200 \
           /neoload/jre/bin/policytool \
           /neoload/jre/bin/rmid \
           /neoload/jre/bin/rmiregistry \
           /neoload/jre/bin/servertool \
           /neoload/jre/bin/tnameserv \
           /neoload/jre/bin/unpack200 \
           /neoload/jre/lib/javaws.jar \
           /neoload/jre/lib/deploy* \
           /neoload/jre/lib/desktop \
           /neoload/jre/lib/*javafx* \
           /neoload/jre/lib/*jfx* \
           /neoload/jre/lib/amd64/libdecora_sse.so \
           /neoload/jre/lib/amd64/libprism_*.so \
           /neoload/jre/lib/amd64/libfxplugins.so \
           /neoload/jre/lib/amd64/libglass.so \
           /neoload/jre/lib/amd64/libgstreamer-lite.so \
           /neoload/jre/lib/amd64/libjavafx*.so \
           /neoload/jre/lib/amd64/libjfx*.so \
           /neoload/jre/lib/ext/jfxrt.jar \
           /neoload/jre/lib/oblique-fonts \
           /neoload/jre/lib/plugin.jar \
           /tmp/* /var/cache/apk/*

RUN sed -i 's/wan.emulation.plugin=ipfw/wan.emulation.plugin=none/g' /neoload/conf/agent.properties
RUN chmod -R g=u /neoload

ADD ./lglogs.xconfig ./logs.xconfig /neoload/conf/

RUN echo "-Dneotys.logs.noredirection=false" >> /neoload/bin/LoadGeneratorAgent.vmoptions && \
    sed -i "s|collected.lg.logs.size.max=.*|collected.lg.logs.size.max=-1|g" /neoload/conf/agent.properties

FROM alpine:3.13.5

LABEL neoload.product.kind=LoadGenerator \
      neoload.product.version=7.10.0 \
      neoload.product.build=20210611-55 \
      neoload.project.version=8.3

ENV LOG_ALSO_TO_CONSOLE=true

RUN set -ex && \
    addgroup -S neoload &&\
    adduser -S -G neoload neoload &&\
    chmod g+w /etc/passwd && \
    chgrp 0 /home/neoload && \
    chmod g=rwx /home/neoload

#Alpine put suid bit on home directory. So the right inherit from parent directory. We prefer to use the GID of process for new files.
#We need to accept that entrypoin.sh changes the /etc/passwd.

EXPOSE 7100

#The group is root for openshift.
COPY --chown=neoload:0 --from=builder /neoload /home/neoload/neoload

ADD ./entrypoint.sh /home/neoload/

USER neoload
WORKDIR /home/neoload/

ENTRYPOINT ["/bin/sh", "/home/neoload/entrypoint.sh"]
