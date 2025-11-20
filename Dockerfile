FROM nginx:alpine3.22-slim
LABEL maintainer="eazytraining"
RUN apk update && \
    apk add --no-cache git && \
    rm -rf /var/cache/apk/*

RUN rm -rf  /usr/share/nginx/html/* && \
    git clone https://github.com/diranetafen/static-website-example.git /usr/share/nginx/html/

EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]