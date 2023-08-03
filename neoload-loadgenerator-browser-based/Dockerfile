#Be carefull openshift change the ID of the user on the fly. But this user is always in root group.

FROM alpine:3.15.7 as builder


ENV NL_VERSION=2023.1.2
ARG URL=https://www.neotys.com/redirect/redirect.php?product=neoload_loadgenerator&target=direct-download&os=linux&version=${NL_VERSION}&format=tar.gz

WORKDIR /tmp/

RUN mkdir /neoload/
RUN wget ${URL} -O - |  tar -xz --strip-components=1 -C /neoload/
RUN rm -rf /neoload/doc

RUN apk add unzip && \
    unzip -oq /neoload/browsers/chromium-*/*.zip -d /neoload/browsers/chromium-*/ && \
    unzip -oq /neoload/browsers/firefox-*/*.zip -d /neoload/browsers/firefox-*/ && \
    unzip -oq /neoload/browsers/webkit-*/*.zip -d /neoload/browsers/webkit-*/ && \
    rm -f /neoload/browsers/*/*.zip

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

FROM ubuntu:22.04

ARG PLAYWRIGHT_CLASSPATH=/home/neoload/neoload/lib/playwright-1.31.0.jar:/home/neoload/neoload/lib/driver-bundle-1.31.0.jar:/home/neoload/neoload/lib/driver-1.31.0.jar

LABEL neoload.product.kind=LoadGenerator \
      neoload.product.version=2023.1.2 \
      neoload.product.build=20230802-67 \
      neoload.project.version=8.7

ENV LOG_ALSO_TO_CONSOLE=true
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD 1

RUN apt update && \
    apt dist-upgrade -y && \
    apt autoremove -y && \
    apt clean && \
    set -ex && \
    useradd -ms /bin/bash -g root neoload -u 10000 &&\
    chmod g+w /etc/passwd && \
    chgrp 0 /home/neoload && \
    chmod g=rwx /home/neoload
#     Try to fix firefox issueLOAD-26846
#     apt install libpci3 -y && \
#     apt install libgtk-3-0 -y

EXPOSE 7100

#The group is root for openshift.
COPY --chown=neoload:0 --from=builder /neoload /home/neoload/neoload
RUN /home/neoload/neoload/jre/bin/java -cp ${PLAYWRIGHT_CLASSPATH} com.microsoft.playwright.CLI install-deps && \
    apt remove ffmpeg -y

ADD ./entrypoint.sh /home/neoload/

USER 10000
WORKDIR /home/neoload/

ENTRYPOINT ["/bin/bash", "/home/neoload/entrypoint.sh"]
