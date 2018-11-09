FROM alpine:latest
LABEL maintainer="Mathias STRASSER <contact@roukmoute.fr>"

RUN set -ex\
	&& apk --no-cache add --upgrade --update-cache evince ttf-opensans

CMD ["/usr/bin/evince"]