FROM alpine:3.12

RUN apk --no-cache add curl
RUN curl -sLS https://get.inlets.dev | sh

ENTRYPOINT ["inlets"]

