FROM jlesage/baseimage-gui:alpine-3.8

MAINTAINER Mathias STRASSER "contact@roukmoute.fr"

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u171
ENV JAVA_ALPINE_VERSION 8.171.11-r0

RUN set -ex \
	&& apk --no-cache add --upgrade --update-cache git python3 openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

ENV DISPLAY=${DISPLAY:-":0"}

ARG unix_ID=1000
ARG phpstorm_folder=".PhpStorm2018.2"

RUN adduser -D -u $unix_ID developer \
    && mkdir /home/developer/$phpstorm_folder \
    && touch /home/developer/$phpstorm_folder/.keep \
    && chown -R developer.developer /home/developer \
    && mkdir -p /opt/phpstorm \
    && wget -O - https://download-cf.jetbrains.com/webide/PhpStorm-2018.2.5.tar.gz | tar xzf - --strip-components=1 -C "/opt/phpstorm"

USER developer
VOLUME /home/developer/$phpstorm_folder
CMD /opt/phpstorm/bin/phpstorm.sh
