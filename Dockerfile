FROM hugomods/hugo:debian-exts AS builder

ARG HUGO_BASEURL="http://localhost:8080/"

WORKDIR /app

COPY . .

RUN hugo --minify -b ${HUGO_BASEURL}

FROM nginxinc/nginx-unprivileged:alpine

COPY default.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/public /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
