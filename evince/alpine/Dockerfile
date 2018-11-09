FROM alpine:latest

RUN set -ex\
	&& apk --no-cache add --upgrade --update-cache evince ttf-opensans

CMD ["/usr/bin/evince"]