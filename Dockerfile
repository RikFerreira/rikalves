FROM ghcr.io/gohugoio/hugo:v0.152.0 AS build

WORKDIR /src

COPY . .

RUN hugo

FROM nginx:1.27-alpine AS runtime

COPY --from=build /src/public /usr/share/nginx/html

EXPOSE 80

# CMD ["nginx", "-g", "daemon off;"]