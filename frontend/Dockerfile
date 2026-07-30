# Ce Dockerfile sert à construire l'application Flutter Web.
# Il n'est pas recommandé pour Android direct car il nécessite un SDK complet.
FROM cirrusci/flutter:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get
COPY . ./
RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
