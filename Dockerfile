FROM ghcr.io/gohugoio/hugo:latest AS build
WORKDIR /src
COPY . .

RUN hugo

FROM nginx:alpine AS runtime
# Delete all from /usr/share/nginx/html
COPY --from=build /src/public/ /usr/share/nginx/html/

EXPOSE 80

# CMD ["nginx", "-g", "daemon off;"]