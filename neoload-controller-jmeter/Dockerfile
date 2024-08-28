#Be carefull openshift change the ID of the user on the fly. But this user is always in root group.

FROM alpine:3.18.6 as builder

ARG LIBERICA_URL=https://download.bell-sw.com/java/11.0.19+7/bellsoft-jre11.0.19+7-linux-x64-musl.tar.gz
ARG LIBERICA_PATCH=https://github.com/Neotys-Labs/jre-patch-neoload/archive/refs/tags/jre-patch-11.0.19+7.tar.gz


ENV NL_VERSION=2024.2.1
ARG URL=https://www.neotys.com/redirect/redirect.php?product=neoload&target=direct-download&os=linux&version=${NL_VERSION}&format=tar.gz

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
           /neoload/jre/lib/amd64/libdecora_sse.so \
           /neoload/jre/lib/amd64/libprism_*.so \
           /neoload/jre/lib/amd64/libfxplugins.so \
           /neoload/jre/lib/amd64/libglass.so \
           /neoload/jre/lib/amd64/libgstreamer-lite.so \
           /neoload/jre/lib/oblique-fonts \
           /neoload/jre/lib/plugin.jar \
           /neoload/browsers \
           /tmp/* /var/cache/apk/*
RUN sed -i 's/wan.emulation.plugin=ipfw/wan.emulation.plugin=none/g' /neoload/conf/agent.properties
RUN chmod -R g=u /neoload

WORKDIR /tmp/
RUN mkdir jmeter
RUN wget -qO- https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.6.3.tgz | tar -xz -C jmeter --strip-components 1 --exclude='*/docs' --exclude='*/printable_docs'
RUN wget https://github.com/Neotys-Labs/Apache-JMeter/releases/download/Neotys-Labs%2FApache-JMeter.git-1.0.14/ApacheJMeter_NeoLoad-1.0.14.jar -P ./jmeter/lib/ext
RUN chmod +x ./jmeter/bin/jmeter
RUN chmod +x ./jmeter/bin/*.sh

FROM alpine:3.18.6
LABEL neoload.product.kind=Controller \
      neoload.product.version=2024.2.1 \
      neoload.product.build=20240821-55 \
      neoload.project.version=8.10



RUN set -ex \
    && adduser -S -G root neoload -u 10000 \
    && chmod g+w /etc/passwd \
    && chgrp 0 /home/neoload \
    && chmod g=rwx /home/neoload \
    && apk --no-cache add ttf-dejavu bash


#Alpine put suid bit on home directory. So the right inherit from parent directory. We prefer to use the GID of process for new files.
#We need to accept that entrypoint.sh changes the /etc/passwd.

#The group is root for openshift.

COPY --chown=neoload:0 --from=builder /neoload /home/neoload/neoload

ADD ./entrypoint.sh ./controller-entrypoint.sh ./controller-agent-entrypoint.sh /home/neoload/

COPY --chown=neoload:0 --from=builder /tmp/jmeter /home/neoload/neoload/tools/jmeter
RUN chmod -R g=u /home/neoload/neoload/tools/jmeter
RUN sed -i 's/jmeter.feature.toggled=false/jmeter.feature.toggled=true/g' /home/neoload/neoload/conf/controller_agent.properties
RUN sed -i 's/<File name="jmeter-log" fileName="${sys:jmeter.logfile:-jmeter.log}" append="false">/<File name="jmeter-log" fileName="\/tmp\/jmeter.log" append="false">/g' /home/neoload/neoload/tools/jmeter/bin/log4j2.xml

USER 10000
WORKDIR /home/neoload/

ENV LOG_ALSO_TO_CONSOLE=true

RUN export JAVA_HOME=/home/neoload/neoload/jre

ENTRYPOINT ["/bin/sh", "/home/neoload/entrypoint.sh"]